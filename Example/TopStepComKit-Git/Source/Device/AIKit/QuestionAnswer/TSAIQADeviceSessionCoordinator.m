//
//  TSAIQADeviceSessionCoordinator.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQADeviceSessionCoordinator.h"

#import <TopStepAIKit/TSAIDeviceCoordination.h>
#import <TopStepAIKit/TSAIStartEligibility.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIQADeviceRound.h"

NSNotificationName const TSAIQADeviceSessionDidRequestPresentationNotification =
    @"TSAIQADeviceSessionDidRequestPresentationNotification";
NSNotificationName const TSAIQADeviceSessionDidChangeNotification =
    @"TSAIQADeviceSessionDidChangeNotification";
NSNotificationName const TSAIQADeviceSessionDidUpdateRoundNotification =
    @"TSAIQADeviceSessionDidUpdateRoundNotification";
NSNotificationName const TSAIQADeviceSessionDidAppendLogNotification =
    @"TSAIQADeviceSessionDidAppendLogNotification";

NSString * const TSAIQADeviceSessionRoundUserInfoKey = @"TSAIQADeviceSessionRound";
NSString * const TSAIQADeviceSessionLogLineUserInfoKey = @"TSAIQADeviceSessionLogLine";

static const NSUInteger kTSAIQADeviceSessionMaximumRoundCount = 50;
static const NSUInteger kTSAIQADeviceSessionMaximumLogCount = 300;
static TSAIQADeviceSessionCoordinator *gTSAIQADeviceSessionCoordinator = nil;

@interface TSAIQADeviceSessionCoordinator ()

// 当前绑定的 Context
@property (nonatomic, strong, nullable) TSAIContext *context;
// 当前绑定的问答接口
@property (nonatomic, strong, nullable) id<TSAIQuestionAnswerInterface> questionAnswer;
// 当前会话状态
@property (nonatomic, assign, readwrite) TSAIQADeviceSessionState state;
// 当前轮次发起方
@property (nonatomic, assign, readwrite) TSAIQADeviceSessionOrigin origin;
// 当前轮次的精确请求
@property (nonatomic, copy, nullable, readwrite) TSAIStartRequest *currentRequest;
// startDeviceQuestionAnswer 返回的标识
@property (nonatomic, copy, nullable, readwrite) NSString *sessionTaskId;
// 事件上报的对外会话标识
@property (nonatomic, copy, nullable, readwrite) NSString *sessionIdentifier;
// 下一轮使用的配置
@property (nonatomic, copy, readwrite) TSAIQuestionAnswerConfig *config;
// 轮次
@property (nonatomic, strong) NSMutableArray<TSAIQADeviceRound *> *mutableRounds;
// 日志行
@property (nonatomic, strong) NSMutableArray<NSString *> *mutableLogLines;
// 最近错误
@property (nonatomic, strong, nullable, readwrite) NSError *lastError;
// 轮次代次，用于丢弃旧轮次的迟到回调
@property (nonatomic, assign) NSUInteger generation;
// 日志时间格式
@property (nonatomic, strong) NSDateFormatter *logTimeFormatter;

@end

@implementation TSAIQADeviceSessionCoordinator

#pragma mark - 单例

/** 获取共享协调器 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gTSAIQADeviceSessionCoordinator = [[super allocWithZone:NULL] initPrivate];
    });
    return gTSAIQADeviceSessionCoordinator;
}

/** 保证 alloc 仍返回共享实例 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

/** 保证复制仍返回共享实例 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

/** 保证可变复制仍返回共享实例 */
- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - 生命周期

/** 初始化共享协调器 */
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _state = TSAIQADeviceSessionStateUnbound;
        _origin = TSAIQADeviceSessionOriginNone;
        _config = [TSAIQuestionAnswerConfig defaultConfig];
        _mutableRounds = [NSMutableArray array];
        _mutableLogLines = [NSMutableArray array];
        _logTimeFormatter = [[NSDateFormatter alloc] init];
        _logTimeFormatter.dateFormat = @"HH:mm:ss.SSS";
    }
    return self;
}

#pragma mark - 公开方法 - 绑定

/** 绑定已鉴权的 Context 并注册问答路由 */
- (void)bindAuthenticatedContext:(TSAIContext *)context {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf bindAuthenticatedContext:context];
        });
        return;
    }
    if (!context || context.state != TSAIContextStateActive ||
        context.authorizationState != TSAIAuthorizationStateAuthenticated) {
        TSLog(@"[TSAIQADeviceSessionCoordinator] bind ignored: context is not authenticated");
        return;
    }
    if (self.context &&
        ![self.context.contextIdentifier isEqualToString:context.contextIdentifier]) {
        [self teardownRoundWithReason:@"Context 已切换" unregister:YES];
    } else if (self.context == context && self.state != TSAIQADeviceSessionStateUnbound &&
               self.state != TSAIQADeviceSessionStateUnsupported) {
        TSLog(@"[TSAIQADeviceSessionCoordinator] bind ignored: already registered");
        return;
    }
    self.context = context;
    self.questionAnswer = context.questionAnswer;
    if (!self.questionAnswer) {
        self.state = TSAIQADeviceSessionStateUnsupported;
        [self appendLogLine:@"bind: questionAnswer 接口不可用"];
        [self postStateDidChange];
        return;
    }
    [self registerDeviceSessionHandlers];
    self.state = TSAIQADeviceSessionStateRegistered;
    self.origin = TSAIQADeviceSessionOriginNone;
    [self appendLogLine:@"bind: 已注册 TSAIUseCaseVoiceQuestionAnswer 路由（手表发起 / App 发起共用）"];
    [self postStateDidChange];
}

/** 解绑 Context，注销路由并本地取消进行中的轮次 */
- (void)unbindContext:(TSAIContext *)context {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf unbindContext:context];
        });
        return;
    }
    if (context && self.context &&
        ![context.contextIdentifier isEqualToString:self.context.contextIdentifier]) {
        return;
    }
    if (self.state == TSAIQADeviceSessionStateUnbound) {
        return;
    }
    [self teardownRoundWithReason:@"设备断开或 Context 失活" unregister:YES];
    self.context = nil;
    self.questionAnswer = nil;
    self.state = TSAIQADeviceSessionStateUnbound;
    self.origin = TSAIQADeviceSessionOriginNone;
    [self appendLogLine:@"unbind: Context 已解绑"];
    [self postStateDidChange];
}

/** 替换下一轮使用的配置 */
- (void)updateConfig:(TSAIQuestionAnswerConfig *)config {
    if (!config) {
        return;
    }
    self.config = config;
    [self appendLogLine:[NSString stringWithFormat:@"config: agent=%ld route=%@",
                         (long)config.agent,
                         [self describeRoute:config.audioRouteConfiguration]]];
}

#pragma mark - 公开方法 - App 发起

/** 由 App 发起一轮手表拾音的问答 */
- (void)startRoundFromApp {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf startRoundFromApp];
        });
        return;
    }
    if (self.state != TSAIQADeviceSessionStateRegistered || !self.context) {
        [self appendLogLine:[NSString stringWithFormat:@"startRoundFromApp ignored: state=%ld",
                             (long)self.state]];
        return;
    }
    NSError *eligibilityError =
        [self deviceRoundEligibilityErrorForInitiator:TSAISessionInitiatorApp];
    if (eligibilityError) {
        self.lastError = eligibilityError;
        [self appendLogLine:[NSString stringWithFormat:@"startRoundFromApp rejected by eligibility: %ld %@",
                             (long)eligibilityError.code, eligibilityError.localizedDescription ?: @""]];
        [self postStateDidChange];
        return;
    }

    TSAIStartRequest *request = [self makeStartRequestWithInitiator:TSAISessionInitiatorApp];
    self.generation += 1;
    NSUInteger generation = self.generation;
    self.lastError = nil;
    self.currentRequest = request;
    self.origin = TSAIQADeviceSessionOriginApp;
    self.state = TSAIQADeviceSessionStatePreparing;
    [self appendLogLine:[NSString stringWithFormat:
        @"startDeviceAISessionFromAppWithRequest requestId=%@ scene=QuestionAnswer initiator=App route=%@",
        request.requestIdentifier,
        [self describeRoute:request.deviceCoordination.audioRouteConfiguration]]];
    [self postStateDidChange];

    __weak typeof(self) weakSelf = self;
    [self.context startDeviceAISessionFromAppWithRequest:request
                                              completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleAppStartCompletionWithSuccess:success error:error generation:generation];
        });
    }];
}

/** 由 App 停止当前轮次 */
- (void)stopCurrentRound {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopCurrentRound];
        });
        return;
    }
    TSAIStartRequest *request = self.currentRequest;
    if (!request || !self.context ||
        self.state == TSAIQADeviceSessionStateStopping ||
        self.state == TSAIQADeviceSessionStateRegistered) {
        return;
    }
    if (self.state == TSAIQADeviceSessionStatePreparing) {
        // 尚未激活：取消准备，SDK 会经 terminationHandler 回滚
        [self appendLogLine:[NSString stringWithFormat:@"cancelDeviceAISessionStart requestId=%@",
                             request.requestIdentifier]];
        NSError *reason = [self errorWithCode:TSAIErrorCodeCancelled description:@"App 取消了本轮问答"];
        __weak typeof(self) weakSelf = self;
        [self.context cancelDeviceAISessionStartWithRequest:request
                                                     reason:reason
                                                 completion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf appendLogLine:[NSString stringWithFormat:@"cancel completion success=%d error=%@",
                                         success, error.localizedDescription ?: @"nil"]];
            });
        }];
        return;
    }
    self.state = TSAIQADeviceSessionStateStopping;
    [self appendLogLine:[NSString stringWithFormat:@"stopDeviceAISessionWithRequest requestId=%@",
                         request.requestIdentifier]];
    [self postStateDidChange];
    __weak typeof(self) weakSelf = self;
    [self.context stopDeviceAISessionWithRequest:request
                                      completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf appendLogLine:[NSString stringWithFormat:@"stop completion success=%d error=%@",
                                       success, error.localizedDescription ?: @"nil"]];
            if (!success && strongSelf.state == TSAIQADeviceSessionStateStopping) {
                strongSelf.lastError = error;
                // 停止失败但 SDK 未回滚：本地回到空闲，避免页面卡在停止中
                [strongSelf finishCurrentRoundLocally];
                [strongSelf postStateDidChange];
            }
        });
    }];
}

#pragma mark - 公开方法 - 查询

/** 清空轮次 */
- (void)clearRounds {
    [self.mutableRounds removeAllObjects];
    [self postStateDidChange];
}

/** 向共享日志追加一行 */
- (void)appendLogLine:(NSString *)line {
    if (line.length == 0) {
        return;
    }
    NSString *stamped = [NSString stringWithFormat:@"%@ %@",
                         [self.logTimeFormatter stringFromDate:[NSDate date]], line];
    [self.mutableLogLines addObject:stamped];
    if (self.mutableLogLines.count > kTSAIQADeviceSessionMaximumLogCount) {
        [self.mutableLogLines removeObjectsInRange:
            NSMakeRange(0, self.mutableLogLines.count - kTSAIQADeviceSessionMaximumLogCount)];
    }
    TSLog(@"[TSAIQADeviceSessionCoordinator] %@", line);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIQADeviceSessionDidAppendLogNotification
                      object:self
                    userInfo:@{TSAIQADeviceSessionLogLineUserInfoKey: stamped}];
}

/** 尚未到终态的轮次 */
- (TSAIQADeviceRound *)activeRound {
    for (TSAIQADeviceRound *round in self.mutableRounds.reverseObjectEnumerator) {
        if (![round isTerminal]) {
            return round;
        }
    }
    return nil;
}

/** 已绑定 Context 的问答接口 */
- (id<TSAIQuestionAnswerInterface>)questionAnswerInterface {
    return self.questionAnswer;
}

/** 是否支持文字问答 */
- (BOOL)supportsTextQuestionAnswer {
    return self.context != nil && [self.context supportsAIFeatures:TSAIFeatureQuestionAnswering];
}

/** 指定发起方的设备协同问答启动资格错误 */
- (NSError *)deviceRoundEligibilityErrorForInitiator:(TSAISessionInitiator)initiator {
    if (!self.context) {
        return [self errorWithCode:TSAIErrorCodeContextInactive description:@"AI Context is inactive"];
    }
    TSAIStartRequest *request = [self makeStartRequestWithInitiator:initiator];
    TSAIStartEligibility *eligibility = [self.context startEligibilityForRequest:request];
    if (eligibility.support == TSAICapabilitySupported) {
        return nil;
    }
    return eligibility.error
        ?: [self errorWithCode:TSAIErrorCodeNotSupported description:@"Unsupported without a reason"];
}

/** 配置对应的已解析设备音频路由 */
+ (TSAIAudioRouteConfiguration *)resolvedDeviceRouteForConfig:(TSAIQuestionAnswerConfig *)config {
    TSAIAudioRouteConfiguration *route = config.audioRouteConfiguration;
    TSAIAudioOutputChannel output = route ? route.outputChannel : TSAIAudioOutputChannelAutomatic;
    if (output == TSAIAudioOutputChannelAutomatic || output == TSAIAudioOutputChannelUnknown) {
        output = TSAIAudioOutputChannelSystemDefault;
    }
    TSAIAudioRouteUnavailablePolicy policy = route
        ? route.routeUnavailablePolicy
        : TSAIAudioRouteUnavailablePolicyFail;
    // FitCloud 的 App 发起会话固定请求设备 Opus；设备发起时输入通道由设备上报，此处只作资格查询
    return [TSAIAudioRouteConfiguration configurationWithInputChannel:TSAIAudioInputChannelOpus
                                                        outputChannel:output
                                               routeUnavailablePolicy:policy];
}

- (NSArray<TSAIQADeviceRound *> *)rounds {
    return [self.mutableRounds copy];
}

- (NSArray<NSString *> *)logLines {
    return [self.mutableLogLines copy];
}

#pragma mark - 私有方法 - 路由注册

/** 注册 VoiceQuestionAnswer 用例的四个 Handler（主线程回调） */
- (void)registerDeviceSessionHandlers {
    __weak typeof(self) weakSelf = self;
    [self.context registerDeviceAISessionHandlerForUseCase:TSAIUseCaseVoiceQuestionAnswer
        prepareHandler:^(TSAIStartRequest *request, TSAICompletionBlock completion) {
            [weakSelf handlePrepareRequest:request completion:completion];
        }
        activationHandler:^(TSAIStartRequest *request) {
            [weakSelf handleActivation:request];
        }
        inputCompletionHandler:^(TSAIStartRequest *request) {
            [weakSelf handleInputCompletion:request];
        }
        terminationHandler:^(TSAIStartRequest *request, BOOL interrupted, NSError * _Nullable error) {
            [weakSelf handleTermination:request interrupted:interrupted error:error];
        }
        voiceDataHandler:nil];
}

/** 注销 VoiceQuestionAnswer 路由 */
- (void)unregisterDeviceSessionHandlers {
    [self.context registerDeviceAISessionHandlerForUseCase:TSAIUseCaseVoiceQuestionAnswer
                                            prepareHandler:nil
                                         activationHandler:nil
                                    inputCompletionHandler:nil
                                        terminationHandler:nil
                                          voiceDataHandler:nil];
}

/**
 * 本地准备：按 SDK 接入示例，在 prepareHandler 内调用
 * startDeviceQuestionAnswerWithConfig:onEvent:completion:，并把 completion 原样转给 SDK
 */
- (void)handlePrepareRequest:(TSAIStartRequest *)request completion:(TSAICompletionBlock)completion {
    if (!self.questionAnswer) {
        NSError *error = [self errorWithCode:TSAIErrorCodeContextInactive description:@"问答接口不可用"];
        completion(NO, error);
        return;
    }
    BOOL fromApp = [request.requestIdentifier isEqualToString:self.currentRequest.requestIdentifier] &&
        request.deviceCoordination.initiator == TSAISessionInitiatorApp;
    if (!fromApp) {
        // 手表发起：此时才第一次看到本轮请求
        self.generation += 1;
        self.lastError = nil;
        self.currentRequest = request;
        self.origin = TSAIQADeviceSessionOriginDevice;
        self.state = TSAIQADeviceSessionStatePreparing;
        [self appendLogLine:[NSString stringWithFormat:@"prepare(手表发起) requestId=%@ route=%@",
                             request.requestIdentifier,
                             [self describeRoute:request.deviceCoordination.audioRouteConfiguration]]];
        [self postStateDidChange];
    } else {
        [self appendLogLine:[NSString stringWithFormat:@"prepare(App 发起) requestId=%@", request.requestIdentifier]];
    }
    NSUInteger generation = self.generation;

    TSAIQuestionAnswerConfig *config = [self.config copy] ?: [TSAIQuestionAnswerConfig defaultConfig];
    config.audioRouteConfiguration = request.deviceCoordination.audioRouteConfiguration
        ?: [[self class] resolvedDeviceRouteForConfig:config];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [self.questionAnswer
        startDeviceQuestionAnswerWithConfig:config
                                    onEvent:^(TSAIDeviceQuestionAnswerEvent *event) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleEvent:event generation:generation];
        });
    }
                                 completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf appendLogLine:[NSString stringWithFormat:
                @"startDeviceQuestionAnswer completion success=%d error=%@",
                success, error ? [NSString stringWithFormat:@"%ld %@", (long)error.code,
                                  error.localizedDescription ?: @""] : @"nil"]];
            if (!success && generation == strongSelf.generation) {
                strongSelf.lastError = error;
            }
            // 仍按 SDK 的设备启动约定把结果交回 prepare completion
            completion(success, error);
        });
    }];
    self.sessionTaskId = taskId;
    [self appendLogLine:[NSString stringWithFormat:@"startDeviceQuestionAnswer → taskId=%@ agent=%ld route=%@",
                         taskId ?: @"nil", (long)config.agent,
                         [self describeRoute:config.audioRouteConfiguration]]];
}

/** 双端激活：手表开始拾音；此时才允许打开页面 */
- (void)handleActivation:(TSAIStartRequest *)request {
    if (![self isCurrentRequest:request]) {
        return;
    }
    self.currentRequest = request;
    self.state = TSAIQADeviceSessionStateListening;
    [self appendLogLine:[NSString stringWithFormat:@"activation requestId=%@ · 手表拾音中", request.requestIdentifier]];
    [self postStateDidChange];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIQADeviceSessionDidRequestPresentationNotification
                      object:self
                    userInfo:@{}];
}

/** 拾音自然结束：等待识别、回答与播放 */
- (void)handleInputCompletion:(TSAIStartRequest *)request {
    if (![self isCurrentRequest:request]) {
        return;
    }
    self.state = TSAIQADeviceSessionStateAnswering;
    [self appendLogLine:[NSString stringWithFormat:@"inputCompletion requestId=%@ · 拾音结束，等待 ASR / 回答",
                         request.requestIdentifier]];
    [self postStateDidChange];
}

/** 本轮终止（正常结束或中断） */
- (void)handleTermination:(TSAIStartRequest *)request interrupted:(BOOL)interrupted error:(NSError *)error {
    if (![self isCurrentRequest:request]) {
        [self appendLogLine:[NSString stringWithFormat:@"termination ignored: requestId=%@ 非当前轮次",
                             request.requestIdentifier]];
        return;
    }
    [self appendLogLine:[NSString stringWithFormat:@"termination requestId=%@ interrupted=%d error=%@",
                         request.requestIdentifier, interrupted,
                         error ? [NSString stringWithFormat:@"%ld %@", (long)error.code,
                                  error.localizedDescription ?: @""] : @"nil"]];
    if (error) {
        self.lastError = error;
    }
    TSAIQADeviceRound *activeRound = [self activeRound];
    if (activeRound && (interrupted || error)) {
        [activeRound markCancelledWithError:error ?: [self errorWithCode:TSAIErrorCodeCancelled
                                                               description:@"设备会话被中断"]];
        [self postRoundDidUpdate:activeRound];
    }
    [self finishCurrentRoundLocally];
    [self postStateDidChange];
}

#pragma mark - 私有方法 - 回调处理

/** App 发起的启动结果：成功表示本地准备与设备同步都完成，激活由 activationHandler 通知 */
- (void)handleAppStartCompletionWithSuccess:(BOOL)success
                                      error:(NSError *)error
                                 generation:(NSUInteger)generation {
    if (generation != self.generation) {
        [self appendLogLine:@"app start completion ignored: stale generation"];
        return;
    }
    if (success) {
        [self appendLogLine:@"startDeviceAISessionFromApp completion: 设备已同步"];
        return;
    }
    self.lastError = error;
    [self appendLogLine:[NSString stringWithFormat:@"startDeviceAISessionFromApp failed: %ld %@",
                         (long)error.code, error.localizedDescription ?: @""]];
    [self finishCurrentRoundLocally];
    [self postStateDidChange];
}

/** 处理设备问答累计快照 */
- (void)handleEvent:(TSAIDeviceQuestionAnswerEvent *)event generation:(NSUInteger)generation {
    if (!event || generation != self.generation) {
        return;
    }
    if (event.sessionIdentifier.length > 0) {
        self.sessionIdentifier = event.sessionIdentifier;
    }
    TSAIQADeviceRound *round = [self roundWithIdentifier:event.roundIdentifier];
    BOOL isNewRound = (round == nil);
    if (isNewRound) {
        round = [[TSAIQADeviceRound alloc] initWithEvent:event index:self.mutableRounds.count + 1];
        [self.mutableRounds addObject:round];
        if (self.mutableRounds.count > kTSAIQADeviceSessionMaximumRoundCount) {
            [self.mutableRounds removeObjectAtIndex:0];
        }
    } else if (![round applyEvent:event]) {
        [self appendLogLine:[NSString stringWithFormat:@"event dropped: seq=%ld round=%@ (stale)",
                             (long)event.sequence, event.roundIdentifier]];
        return;
    }
    if (event.error) {
        self.lastError = event.error;
    }
    [self appendLogLine:[NSString stringWithFormat:@"seq=%ld round=%@ phase=%@ q=%lu a=%lu%@",
                         (long)event.sequence,
                         event.roundIdentifier,
                         [self describePhase:event.phase],
                         (unsigned long)event.question.length,
                         (unsigned long)event.answer.length,
                         event.error ? [NSString stringWithFormat:@" error=%ld", (long)event.error.code] : @""]];
    if (event.phase == TSAIDeviceQuestionAnswerPhaseAnswer &&
        self.state == TSAIQADeviceSessionStateListening) {
        // 有的固件不单独上报输入结束，收到回答即视为拾音已结束
        self.state = TSAIQADeviceSessionStateAnswering;
        [self postStateDidChange];
    }
    [self postRoundDidUpdate:round];
}

#pragma mark - 私有方法 - 清理与通知

/** 是否为当前轮次的请求 */
- (BOOL)isCurrentRequest:(TSAIStartRequest *)request {
    return request.requestIdentifier.length > 0 &&
        [request.requestIdentifier isEqualToString:self.currentRequest.requestIdentifier];
}

/** 本轮结束：回到已注册空闲态，不改动轮次数据 */
- (void)finishCurrentRoundLocally {
    self.generation += 1;
    self.currentRequest = nil;
    self.sessionTaskId = nil;
    self.origin = TSAIQADeviceSessionOriginNone;
    self.state = self.context ? TSAIQADeviceSessionStateRegistered : TSAIQADeviceSessionStateUnbound;
}

/** 本地取消进行中的轮次并停止 SDK 会话；可选注销路由 */
- (void)teardownRoundWithReason:(NSString *)reason unregister:(BOOL)unregister {
    TSAIQADeviceRound *activeRound = [self activeRound];
    if (activeRound) {
        NSError *error = [self errorWithCode:TSAIErrorCodeCancelled description:reason];
        [activeRound markCancelledWithError:error];
        [self appendLogLine:[NSString stringWithFormat:@"round=%@ 本地置 Cancelled：%@",
                             activeRound.roundIdentifier, reason]];
        [self postRoundDidUpdate:activeRound];
    }
    if (self.currentRequest && self.context &&
        (self.state == TSAIQADeviceSessionStateListening ||
         self.state == TSAIQADeviceSessionStateAnswering)) {
        [self.context stopDeviceAISessionWithRequest:self.currentRequest completion:nil];
        [self appendLogLine:[NSString stringWithFormat:@"stopDeviceAISession requestId=%@ (%@)",
                             self.currentRequest.requestIdentifier, reason]];
    }
    if (self.sessionTaskId.length > 0 && self.questionAnswer) {
        [self.questionAnswer stopDeviceQuestionAnswerWithTaskId:self.sessionTaskId];
        [self appendLogLine:[NSString stringWithFormat:@"stopDeviceQuestionAnswer taskId=%@ (%@)",
                             self.sessionTaskId, reason]];
    }
    if (unregister && self.context) {
        [self unregisterDeviceSessionHandlers];
        [self appendLogLine:@"已注销 TSAIUseCaseVoiceQuestionAnswer 路由"];
    }
    self.generation += 1;
    self.currentRequest = nil;
    self.sessionTaskId = nil;
    self.sessionIdentifier = nil;
    self.origin = TSAIQADeviceSessionOriginNone;
}

/** 构造设备协同问答的启动请求 */
- (TSAIStartRequest *)makeStartRequestWithInitiator:(TSAISessionInitiator)initiator {
    TSAIDeviceCoordination *coordination =
        [TSAIDeviceCoordination coordinationWithScene:TSAIDeviceAISceneQuestionAnswer
                                            initiator:initiator
                              audioRouteConfiguration:[[self class] resolvedDeviceRouteForConfig:self.config]];
    NSString *prefix = initiator == TSAISessionInitiatorApp ? @"qa-app" : @"qa-device";
    return [TSAIStartRequest requestWithIdentifier:[NSString stringWithFormat:@"%@.%@", prefix, NSUUID.UUID.UUIDString]
                                           useCase:TSAIUseCaseVoiceQuestionAnswer
                                        parameters:nil
                                deviceCoordination:coordination];
}

/** 按轮次标识查找 */
- (TSAIQADeviceRound *)roundWithIdentifier:(NSString *)roundIdentifier {
    if (roundIdentifier.length == 0) {
        return nil;
    }
    for (TSAIQADeviceRound *round in self.mutableRounds.reverseObjectEnumerator) {
        if ([round.roundIdentifier isEqualToString:roundIdentifier]) {
            return round;
        }
    }
    return nil;
}

/** 发送状态变化通知 */
- (void)postStateDidChange {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIQADeviceSessionDidChangeNotification
                      object:self];
}

/** 发送轮次更新通知 */
- (void)postRoundDidUpdate:(TSAIQADeviceRound *)round {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIQADeviceSessionDidUpdateRoundNotification
                      object:self
                    userInfo:@{TSAIQADeviceSessionRoundUserInfoKey: round}];
}

/** 构造 TSAIErrorDomain 的错误 */
- (NSError *)errorWithCode:(TSAIErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:TSAIErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @""}];
}

/** 阶段的可读名称 */
- (NSString *)describePhase:(TSAIDeviceQuestionAnswerPhase)phase {
    switch (phase) {
        case TSAIDeviceQuestionAnswerPhaseQuestion:  return @"Question";
        case TSAIDeviceQuestionAnswerPhaseAnswer:    return @"Answer";
        case TSAIDeviceQuestionAnswerPhaseCompleted: return @"Completed";
        case TSAIDeviceQuestionAnswerPhaseFailed:    return @"Failed";
        case TSAIDeviceQuestionAnswerPhaseCancelled: return @"Cancelled";
    }
    return [NSString stringWithFormat:@"%ld", (long)phase];
}

/** 路由的可读名称 */
- (NSString *)describeRoute:(TSAIAudioRouteConfiguration *)route {
    if (!route) {
        return @"Automatic";
    }
    return [NSString stringWithFormat:@"in=%ld out=%ld policy=%ld",
            (long)route.inputChannel, (long)route.outputChannel, (long)route.routeUnavailablePolicy];
}

@end
