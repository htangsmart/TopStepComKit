//
//  TSAIChatDeviceSessionCoordinator.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatDeviceSessionCoordinator.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NSNotificationName const TSAIChatDeviceSessionDidRequestPresentationNotification =
    @"TSAIChatDeviceSessionDidRequestPresentationNotification";
NSNotificationName const TSAIChatDeviceSessionDidChangeNotification =
    @"TSAIChatDeviceSessionDidChangeNotification";
NSNotificationName const TSAIChatDeviceSessionDidReceiveContentNotification =
    @"TSAIChatDeviceSessionDidReceiveContentNotification";
NSNotificationName const TSAIChatDeviceSessionDidReceiveEventNotification =
    @"TSAIChatDeviceSessionDidReceiveEventNotification";
NSNotificationName const TSAIChatDeviceSessionDidCompleteNotification =
    @"TSAIChatDeviceSessionDidCompleteNotification";

NSString * const TSAIChatDeviceSessionPhaseUserInfoKey = @"TSAIChatDeviceSessionPhase";
NSString * const TSAIChatDeviceSessionContentUserInfoKey = @"TSAIChatDeviceSessionContent";
NSString * const TSAIChatDeviceSessionEventUserInfoKey = @"TSAIChatDeviceSessionEvent";
NSString * const TSAIChatDeviceSessionReportUserInfoKey = @"TSAIChatDeviceSessionReport";
NSString * const TSAIChatDeviceSessionErrorUserInfoKey = @"TSAIChatDeviceSessionError";

static const NSUInteger kTSAIChatDeviceSessionMaximumHistoryCount = 200;
static TSAIChatDeviceSessionCoordinator *gTSAIChatDeviceSessionCoordinator = nil;

@interface TSAIChatDeviceSessionCoordinator ()

// 当前会话状态机
@property (nonatomic, strong) TSAIChatDeviceSessionState *sessionState;
// 当前绑定的 Context
@property (nonatomic, strong, nullable) TSAIContext *context;
// 当前绑定的助手
@property (nonatomic, strong, nullable) id<TSAIAssistantInterface> assistant;
// 当前设备回报接口
@property (nonatomic, strong, nullable) id<TSAIManagerInterface> deviceManager;
// 当前云端任务标识
@property (nonatomic, copy, nullable, readwrite) NSString *currentTaskId;
// 下一次设备请求使用的配置
@property (nonatomic, strong, readwrite) TSAIChatConfig *config;
// 当前会话非音频内容
@property (nonatomic, strong) NSMutableArray<TSAIChatContent *> *mutableContentHistory;
// 当前会话事件
@property (nonatomic, strong) NSMutableArray<TSAIChatEvent *> *mutableEventHistory;
// 最近一次最终报告
@property (nonatomic, strong, nullable, readwrite) TSAIChatReport *lastReport;
// 最近一次完成错误
@property (nonatomic, strong, nullable, readwrite) NSError *lastError;
// 当前代次是否已提交启动成功回报
@property (nonatomic, assign) BOOL hasSubmittedInitiateSuccess;

@end

@implementation TSAIChatDeviceSessionCoordinator

#pragma mark - 单例

/** 获取共享协调器 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gTSAIChatDeviceSessionCoordinator = [[super allocWithZone:NULL] initPrivate];
    });
    return gTSAIChatDeviceSessionCoordinator;
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
        _sessionState = [[TSAIChatDeviceSessionState alloc] init];
        _config = [TSAIChatConfig defaultConfig];
        _mutableContentHistory = [NSMutableArray array];
        _mutableEventHistory = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 公开方法

/** 绑定已完成最终鉴权的 AI Context */
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
        TSLog(@"[TSAIChatDeviceSessionCoordinator] bind ignored: context is not authenticated");
        return;
    }

    id<TSAIAssistantInterface> assistant = context.assistant;
    if (!assistant || ![context supportsAIFeatures:TSAIFeatureAIChat]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] bind ignored: AI Chat is unsupported");
        return;
    }

    if (self.assistant && self.assistant != assistant) {
        [self.assistant registerOnAIChatDeviceEvent:nil];
        [self closeCurrentSessionForOrigin:TSAIChatDeviceSessionEndOriginRuntimeError];
    }
    self.context = context;
    self.assistant = assistant;
    self.deviceManager = [TopStepComKit sharedInstance].aiDeviceManager;

    __weak typeof(self) weakSelf = self;
    [assistant registerOnAIChatDeviceEvent:^(TSAIChatDeviceEvent event) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDeviceEvent:event];
        });
    }];
    TSLog(@"[TSAIChatDeviceSessionCoordinator] device event listener registered");
    [self postPhaseDidChange];
}

/** 解绑失活的 Context */
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
    [self.assistant registerOnAIChatDeviceEvent:nil];
    [self closeCurrentSessionForOrigin:TSAIChatDeviceSessionEndOriginBleDisconnected];
    self.context = nil;
    self.assistant = nil;
    self.deviceManager = nil;
    TSLog(@"[TSAIChatDeviceSessionCoordinator] context unbound");
    [self postPhaseDidChange];
}

/** 更新下一次会话的配置 */
- (void)updateConfig:(TSAIChatConfig *)config {
    if (!config) {
        return;
    }
    self.config = config;
}

/** 由 App 主动停止当前会话 */
- (void)stopSessionFromApp {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopSessionFromApp];
        });
        return;
    }
    NSUInteger generation = self.sessionState.generation;
    if (self.sessionState.phase == TSAIChatDeviceSessionPhaseStartRequested) {
        [self reportStartFailureIfNeededForGeneration:generation
                                               origin:TSAIChatDeviceSessionEndOriginApp];
    } else if (self.sessionState.phase == TSAIChatDeviceSessionPhaseActive) {
        [self reportTerminationIfNeededForGeneration:generation
                                              origin:TSAIChatDeviceSessionEndOriginApp];
    }
    [self stopCurrentCloudTask];
}

/** 判断当前是否具备设备发起 AI 对话的全部条件 */
- (BOOL)isDeviceInitiatedChatAvailable {
    if (!self.context || self.context.state != TSAIContextStateActive ||
        self.context.authorizationState != TSAIAuthorizationStateAuthenticated ||
        !self.assistant || ![self.context supportsAIFeatures:TSAIFeatureAIChat] ||
        !self.deviceManager) {
        return NO;
    }
    TSPeripheralAIAbility *aiAbility =
        [TopStepComKit sharedInstance].connectedPeripheral.capability.aiAbility;
    BOOL supportsDeviceStart =
        [aiAbility supportDeviceInitiatedScene:TSPeripheralAISceneChat];
    TSAIChatAudioChannel audioChannel = [self.deviceManager aiChatAudioChannel];
    return supportsDeviceStart && audioChannel != TSAIChatAudioChannelUnknown;
}

/** 返回当前阶段 */
- (TSAIChatDeviceSessionPhase)phase {
    return self.sessionState.phase;
}

/** 返回非音频内容历史快照 */
- (NSArray<TSAIChatContent *> *)contentHistory {
    return [self.mutableContentHistory copy];
}

/** 返回事件历史快照 */
- (NSArray<TSAIChatEvent *> *)eventHistory {
    return [self.mutableEventHistory copy];
}

#pragma mark - 私有方法 - 设备事件

/** 处理设备侧 AI 对话事件 */
- (void)handleDeviceEvent:(TSAIChatDeviceEvent)event {
    switch (event) {
        case TSAIChatDeviceEventRequestStart:
            [self handleDeviceStartRequest];
            break;
        case TSAIChatDeviceEventRequestEnd:
            [self handleDeviceCloseWithOrigin:TSAIChatDeviceSessionEndOriginDevice];
            break;
        case TSAIChatDeviceEventInterrupted:
            [self handleDeviceCloseWithOrigin:TSAIChatDeviceSessionEndOriginDevice];
            break;
    }
}

/** 接受设备启动请求并立即启动云端会话 */
- (void)handleDeviceStartRequest {
    NSUInteger generation = 0;
    if (![self.sessionState beginDeviceStartWithGeneration:&generation]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] duplicate start ignored: generation=%lu, phase=%ld",
              (unsigned long)self.sessionState.generation, (long)self.sessionState.phase);
        return;
    }
    self.currentTaskId = nil;
    self.lastReport = nil;
    self.lastError = nil;
    self.hasSubmittedInitiateSuccess = NO;
    [self.mutableContentHistory removeAllObjects];
    [self.mutableEventHistory removeAllObjects];
    [self postPhaseDidChange];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIChatDeviceSessionDidRequestPresentationNotification
                      object:self];

    if (![self isDeviceInitiatedChatAvailable]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] start rejected: prerequisites unavailable");
        [self reportStartFailureIfNeededForGeneration:generation
                                               origin:TSAIChatDeviceSessionEndOriginRuntimeError];
        return;
    }
    [self startCloudSessionForGeneration:generation];
}

/** 处理设备主动结束或中断 */
- (void)handleDeviceCloseWithOrigin:(TSAIChatDeviceSessionEndOrigin)origin {
    [self.sessionState markClosedByDeviceWithOrigin:origin];
    [self postPhaseDidChange];
    [self stopCurrentCloudTask];
}

#pragma mark - 私有方法 - 云端会话

/** 为指定设备请求启动云端会话 */
- (void)startCloudSessionForGeneration:(NSUInteger)generation {
    TSAIChatConfig *chatConfig = self.config ?: [TSAIChatConfig defaultConfig];
    id<TSAIAssistantInterface> assistant = self.assistant;
    __weak typeof(self) weakSelf = self;
    NSString *taskId = [assistant startChatWithConfig:chatConfig
                                            onContent:^(TSAIChatContent *content) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleContent:content generation:generation];
        });
    }
                                               onEvent:^(TSAIChatEvent *event) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleEvent:event generation:generation];
        });
    }
                                            completion:^(TSAIChatReport *report, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleCompletionWithReport:report
                                           error:error
                                      generation:generation];
        });
    }];

    if (taskId.length == 0) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] startChat returned an empty taskId");
        [self reportStartFailureIfNeededForGeneration:generation
                                               origin:TSAIChatDeviceSessionEndOriginRuntimeError];
        return;
    }
    self.currentTaskId = taskId;
    if (![self.sessionState canAcceptTaskForGeneration:generation]) {
        [assistant stopChatWithTaskId:taskId];
        self.currentTaskId = nil;
        TSLog(@"[TSAIChatDeviceSessionCoordinator] late task cancelled: generation=%lu",
              (unsigned long)generation);
        return;
    }
    TSLog(@"[TSAIChatDeviceSessionCoordinator] cloud task accepted: generation=%lu, taskId=%@",
          (unsigned long)generation, taskId);
}

/** 处理当前会话的流式内容 */
- (void)handleContent:(TSAIChatContent *)content generation:(NSUInteger)generation {
    if (![self isCurrentCallbackTaskId:content.taskId generation:generation]) {
        return;
    }
    if (content.contentType != TSAIChatContentTypeAudioChunk) {
        [self.mutableContentHistory addObject:content];
        [self trimHistoryIfNeeded:self.mutableContentHistory];
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIChatDeviceSessionDidReceiveContentNotification
                      object:self
                    userInfo:@{TSAIChatDeviceSessionContentUserInfoKey: content}];
}

/** 处理当前会话的状态事件 */
- (void)handleEvent:(TSAIChatEvent *)event generation:(NSUInteger)generation {
    if (![self isCurrentCallbackTaskId:event.taskId generation:generation]) {
        return;
    }
    [self.mutableEventHistory addObject:event];
    [self trimHistoryIfNeeded:self.mutableEventHistory];

    switch (event.eventType) {
        case TSAIChatEventTypeSessionStarted:
            [self handleSessionStartedForGeneration:generation];
            break;
        case TSAIChatEventTypeAutoEnding:
            [self reportTerminationIfNeededForGeneration:generation
                                                  origin:TSAIChatDeviceSessionEndOriginAutoTimeout];
            break;
        case TSAIChatEventTypeNetworkError:
            [self reportTerminationIfNeededForGeneration:generation
                                                  origin:TSAIChatDeviceSessionEndOriginRuntimeError];
            [self stopCurrentCloudTask];
            break;
        case TSAIChatEventTypeBleDisconnected:
            [self.sessionState markClosedByDeviceWithOrigin:
                TSAIChatDeviceSessionEndOriginBleDisconnected];
            [self postPhaseDidChange];
            [self stopCurrentCloudTask];
            break;
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIChatDeviceSessionDidReceiveEventNotification
                      object:self
                    userInfo:@{TSAIChatDeviceSessionEventUserInfoKey: event}];
}

/** 在云端确认启动后向设备回报成功 */
- (void)handleSessionStartedForGeneration:(NSUInteger)generation {
    if (![self.sessionState markAIStartedForGeneration:generation]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] stale SessionStarted ignored: generation=%lu",
              (unsigned long)generation);
        return;
    }
    [self postPhaseDidChange];
    if (self.hasSubmittedInitiateSuccess) {
        return;
    }
    self.hasSubmittedInitiateSuccess = YES;
    id<TSAIManagerInterface> deviceManager = self.deviceManager;
    if (!deviceManager) {
        [self reportTerminationIfNeededForGeneration:generation
                                              origin:TSAIChatDeviceSessionEndOriginRuntimeError];
        [self stopCurrentCloudTask];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [deviceManager reportAIChatSessionInitiateSuccess:
        ^(BOOL success, BOOL deviceEncounteredException, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf || strongSelf.sessionState.generation != generation) {
                    return;
                }
                TSLog(@"[TSAIChatDeviceSessionCoordinator] initiate success report: "
                      @"generation=%lu, success=%d, deviceException=%d, error=%@",
                      (unsigned long)generation, success, deviceEncounteredException,
                      error.localizedDescription);
                if (!success || deviceEncounteredException) {
                    [strongSelf reportTerminationIfNeededForGeneration:generation
                                                                 origin:TSAIChatDeviceSessionEndOriginRuntimeError];
                    [strongSelf stopCurrentCloudTask];
                }
            });
        }];
}

/** 处理云端会话最终完成 */
- (void)handleCompletionWithReport:(TSAIChatReport *)report
                             error:(NSError *)error
                        generation:(NSUInteger)generation {
    if (self.sessionState.generation != generation) {
        return;
    }
    NSString *completionTaskId = report.taskId ?: self.currentTaskId;
    if (completionTaskId.length > 0 && self.currentTaskId.length > 0 &&
        ![completionTaskId isEqualToString:self.currentTaskId]) {
        return;
    }

    TSAIChatDeviceSessionEndOrigin origin =
        [self completionOriginForReport:report error:error];
    [self reportStartFailureIfNeededForGeneration:generation origin:origin];
    [self reportTerminationIfNeededForGeneration:generation origin:origin];

    self.lastReport = report;
    self.lastError = error;
    self.currentTaskId = nil;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (report) {
        userInfo[TSAIChatDeviceSessionReportUserInfoKey] = report;
    }
    if (error) {
        userInfo[TSAIChatDeviceSessionErrorUserInfoKey] = error;
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIChatDeviceSessionDidCompleteNotification
                      object:self
                    userInfo:userInfo];
    TSLog(@"[TSAIChatDeviceSessionCoordinator] cloud task completed: "
          @"generation=%lu, endReason=%ld, error=%@",
          (unsigned long)generation, (long)report.endReason, error.localizedDescription);
}

/** 判断回调是否仍属于当前任务 */
- (BOOL)isCurrentCallbackTaskId:(NSString *)taskId generation:(NSUInteger)generation {
    if (self.sessionState.generation != generation) {
        return NO;
    }
    if (taskId.length == 0 || self.currentTaskId.length == 0) {
        return NO;
    }
    return [taskId isEqualToString:self.currentTaskId];
}

/** 限制诊断历史条数 */
- (void)trimHistoryIfNeeded:(NSMutableArray *)history {
    if (history.count > kTSAIChatDeviceSessionMaximumHistoryCount) {
        [history removeObjectAtIndex:0];
    }
}

#pragma mark - 私有方法 - 设备回报

/** 在启动阶段按需回报失败 */
- (void)reportStartFailureIfNeededForGeneration:(NSUInteger)generation
                                          origin:(TSAIChatDeviceSessionEndOrigin)origin {
    TSAIChatDeviceSessionReportRequest *request =
        [self.sessionState prepareStartFailureWithOrigin:origin generation:generation];
    [self submitDeviceSessionReport:request];
}

/** 在活动阶段按需回报终止 */
- (void)reportTerminationIfNeededForGeneration:(NSUInteger)generation
                                         origin:(TSAIChatDeviceSessionEndOrigin)origin {
    TSAIChatDeviceSessionReportRequest *request =
        [self.sessionState prepareTerminationWithOrigin:origin generation:generation];
    [self submitDeviceSessionReport:request];
}

/** 提交设备会话失败或终止回报 */
- (void)submitDeviceSessionReport:(TSAIChatDeviceSessionReportRequest *)request {
    if (!request) {
        return;
    }
    [self postPhaseDidChange];
    id<TSAIManagerInterface> deviceManager = self.deviceManager;
    if (!deviceManager) {
        [self finishDeviceSessionReport:request success:NO error:nil];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [deviceManager reportAIChatSessionInitiateFailedOrTerminated:
        ^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf finishDeviceSessionReport:request success:success error:error];
            });
        }];
}

/** 完成设备回报并执行有限重试 */
- (void)finishDeviceSessionReport:(TSAIChatDeviceSessionReportRequest *)request
                           success:(BOOL)success
                             error:(NSError *)error {
    TSLog(@"[TSAIChatDeviceSessionCoordinator] device session report: "
          @"generation=%lu, kind=%ld, origin=%ld, attempt=%lu, success=%d, error=%@",
          (unsigned long)request.generation, (long)request.kind, (long)request.origin,
          (unsigned long)request.attempt, success, error.localizedDescription);
    TSAIChatDeviceSessionReportRequest *retryRequest =
        [self.sessionState completeReport:request success:success];
    [self postPhaseDidChange];
    if (retryRequest) {
        [self submitDeviceSessionReport:retryRequest];
    }
}

#pragma mark - 私有方法 - 清理与通知

/** 关闭当前任务并标记设备侧不可用 */
- (void)closeCurrentSessionForOrigin:(TSAIChatDeviceSessionEndOrigin)origin {
    [self.sessionState markClosedByDeviceWithOrigin:origin];
    [self postPhaseDidChange];
    [self stopCurrentCloudTask];
}

/** 停止当前云端任务 */
- (void)stopCurrentCloudTask {
    NSString *taskId = self.currentTaskId;
    if (taskId.length == 0 || !self.assistant) {
        return;
    }
    TSLog(@"[TSAIChatDeviceSessionCoordinator] stop cloud task: taskId=%@", taskId);
    [self.assistant stopChatWithTaskId:taskId];
}

/** 根据最终报告计算终止来源 */
- (TSAIChatDeviceSessionEndOrigin)completionOriginForReport:(TSAIChatReport *)report
                                                     error:(NSError *)error {
    if (error) {
        return TSAIChatDeviceSessionEndOriginRuntimeError;
    }
    switch (report.endReason) {
        case TSAIChatEndReasonTimeout:
            return TSAIChatDeviceSessionEndOriginAutoTimeout;
        case TSAIChatEndReasonUserStop:
            return self.sessionState.origin == TSAIChatDeviceSessionEndOriginNone
                ? TSAIChatDeviceSessionEndOriginApp
                : self.sessionState.origin;
        case TSAIChatEndReasonCancelled:
            return TSAIChatDeviceSessionEndOriginApp;
        case TSAIChatEndReasonError:
        case TSAIChatEndReasonUnknown:
        default:
            return TSAIChatDeviceSessionEndOriginRuntimeError;
    }
}

/** 发布当前阶段变化 */
- (void)postPhaseDidChange {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIChatDeviceSessionDidChangeNotification
                      object:self
                    userInfo:@{
                        TSAIChatDeviceSessionPhaseUserInfoKey: @(self.sessionState.phase)
                    }];
}

@end
