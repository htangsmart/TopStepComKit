//
//  TSAIAudioRecordSessionCoordinator.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordSessionCoordinator.h"

#import <math.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIAudioRecordConfig.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioRecordDraft.h"
#import "TSAIAudioRecordDraftStore.h"
#import "TSAIAudioRecordPCMFileWriter.h"

NSNotificationName const TSAIAudioRecordSessionDidRequestPresentationNotification =
    @"TSAIAudioRecordSessionDidRequestPresentationNotification";
NSNotificationName const TSAIAudioRecordSessionDidChangeNotification =
    @"TSAIAudioRecordSessionDidChangeNotification";
NSNotificationName const TSAIAudioRecordSessionDidReceiveResultNotification =
    @"TSAIAudioRecordSessionDidReceiveResultNotification";
NSNotificationName const TSAIAudioRecordSessionDidCompleteNotification =
    @"TSAIAudioRecordSessionDidCompleteNotification";

NSString * const TSAIAudioRecordSessionStateUserInfoKey = @"TSAIAudioRecordSessionState";
NSString * const TSAIAudioRecordSessionDraftUserInfoKey = @"TSAIAudioRecordSessionDraft";
NSString * const TSAIAudioRecordSessionErrorUserInfoKey = @"TSAIAudioRecordSessionError";
NSString * const TSAIAudioRecordSessionAudioLevelUserInfoKey = @"TSAIAudioRecordSessionAudioLevel";

static const NSTimeInterval kTSAIAudioRecordFinalResultTimeout = 8.0;
static TSAIAudioRecordSessionCoordinator *gTSAIAudioRecordSessionCoordinator = nil;

@interface TSAIAudioRecordSessionCoordinator ()

// 当前可变会话状态
@property (nonatomic, strong, readwrite) TSAIAudioRecordSessionState *sessionState;
// 当前录音草稿
@property (nonatomic, strong, nullable, readwrite) TSAIAudioRecordDraft *currentDraft;
// 设备下一次发起录音时使用的配置
@property (nonatomic, strong, readwrite) TSAIAudioRecordConfig *preferredConfig;
// 最近一次错误
@property (nonatomic, strong, nullable, readwrite) NSError *lastError;
// 当前绑定的 AI Context
@property (nonatomic, strong, nullable) TSAIContext *context;
// 当前录音接口
@property (nonatomic, strong, nullable) id<TSAudioRecordInterface> audioRecord;
// Demo 草稿存储
@property (nonatomic, strong) TSAIAudioRecordDraftStore *draftStore;
// 文件保存串行队列
@property (nonatomic, strong) dispatch_queue_t persistenceQueue;
// 已进入保存流程的代次
@property (nonatomic, assign) NSUInteger persistingGeneration;
// 当前录音实际结束时间
@property (nonatomic, strong, nullable) NSDate *sessionEndDate;
// 当前解码 PCM 的临时 WAV 写入器
@property (nonatomic, strong, nullable) TSAIAudioRecordPCMFileWriter *pcmFileWriter;

@end

@implementation TSAIAudioRecordSessionCoordinator

#pragma mark - 单例

/** 获取共享协调器 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gTSAIAudioRecordSessionCoordinator = [[super allocWithZone:NULL] initPrivate];
    });
    return gTSAIAudioRecordSessionCoordinator;
}

/** 保证 alloc 返回共享实例 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

/** 保证复制返回共享实例 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

/** 保证可变复制返回共享实例 */
- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - 生命周期

/** 初始化共享协调器 */
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _sessionState = [[TSAIAudioRecordSessionState alloc] init];
        _preferredConfig = [TSAIAudioRecordConfig defaultConfig];
        _draftStore = [[TSAIAudioRecordDraftStore alloc] init];
        _persistenceQueue = dispatch_queue_create("com.topstep.example.ai-audio-record.persistence",
                                                  DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - 公开方法

/** 绑定已激活的 Context，确保不丢失设备发起的鉴权前事件 */
- (void)bindActiveContext:(TSAIContext *)context {
    [self performOnMainThread:^{
        if (!context || context.state != TSAIContextStateActive ||
            context.audioRecord == nil) {
            TSLog(@"[TSAIAudioRecordSessionCoordinator] bind ignored: context unavailable");
            return;
        }
        if (self.audioRecord && self.audioRecord != context.audioRecord) {
            [self unregisterAudioRecordCallbacks];
            [self finishDisconnectedSessionIfNeeded];
        }
        self.context = context;
        self.audioRecord = context.audioRecord;
        [self registerAudioRecordCallbacks];
        TSLog(@"[TSAIAudioRecordSessionCoordinator] device callbacks registered: authorizationState=%ld",
              (long)context.authorizationState);
        [self postSessionDidChangeWithAudioLevel:nil];
    }];
}

/** 解绑失活的 Context */
- (void)unbindContext:(TSAIContext *)context {
    [self performOnMainThread:^{
        if (context && self.context &&
            ![context.contextIdentifier isEqualToString:self.context.contextIdentifier]) {
            return;
        }
        [self unregisterAudioRecordCallbacks];
        [self finishDisconnectedSessionIfNeeded];
        self.audioRecord = nil;
        self.context = nil;
        TSLog(@"[TSAIAudioRecordSessionCoordinator] context unbound");
        [self postSessionDidChangeWithAudioLevel:nil];
    }];
}

/** 更新下一次设备请求使用的配置 */
- (void)updatePreferredConfig:(TSAIAudioRecordConfig *)config {
    if (!config) {
        return;
    }
    [self performOnMainThread:^{
        self.preferredConfig = [config copy];
    }];
}

/** 启动 App 发起的录音 */
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self performOnMainThread:^{
        [self beginRecordingWithConfig:config
                                source:TSAIAudioRecordSessionSourceApp
                            completion:completion];
    }];
}

/** 停止当前录音 */
- (void)stopRecording {
    [self performOnMainThread:^{
        [self requestStopForGeneration:self.sessionState.generation];
    }];
}

/** 清除已完成会话并返回准备状态 */
- (void)prepareForNewSession {
    [self performOnMainThread:^{
        if (![self.sessionState resetToIdle]) {
            return;
        }
        self.currentDraft = nil;
        self.lastError = nil;
        self.sessionEndDate = nil;
        [self postSessionDidChangeWithAudioLevel:nil];
    }];
}

/** 检查录音接口是否就绪，精确启动资格由 Adapter 原子校验 */
- (BOOL)isRecordingInterfaceReady {
    if (![NSThread isMainThread]) {
        return NO;
    }
    return [self isAudioRecordContextReady];
}

#pragma mark - 私有方法

/** 注册所有设备侧录音回调 */
- (void)registerAudioRecordCallbacks {
    __weak typeof(self) weakSelf = self;
    [self.audioRecord registerOnRequestStartAIAudioRecording:^(TSAIAudioRecordScene scene) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleDeviceStartRequestWithScene:scene];
        }];
    }];
    [self.audioRecord registerOnRequestStopAIAudioRecording:^{
        [weakSelf performOnMainThread:^{
            [weakSelf requestStopForGeneration:weakSelf.sessionState.generation];
        }];
    }];
    [self.audioRecord registerAIAudioRecordingDidInterrupt:^(TSAIAudioRecordInterruptReason reason) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleInterruption:reason];
        }];
    }];
    [self.audioRecord registerOnAIAudioRecordingVoiceDataReceived:^(NSData *opusData, NSData *pcmData) {
        NSData *levelData = pcmData ?: opusData;
        [weakSelf performOnMainThread:^{
            [weakSelf handleAudioData:levelData generation:weakSelf.sessionState.generation];
        }];
    }];
    [self.audioRecord registerAIAudioRecordingStateDidChanged:^(TSAIAudioRecordState state) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleSDKState:state];
        }];
    }];
}

/** 清空设备侧录音回调 */
- (void)unregisterAudioRecordCallbacks {
    [self.audioRecord registerOnRequestStartAIAudioRecording:nil];
    [self.audioRecord registerOnRequestStopAIAudioRecording:nil];
    [self.audioRecord registerAIAudioRecordingDidInterrupt:nil];
    [self.audioRecord registerOnAIAudioRecordingVoiceDataReceived:nil];
    [self.audioRecord registerAIAudioRecordingStateDidChanged:nil];
}

/** 处理已通过 TopStepAIKit 精确门禁的设备录音开始请求 */
- (void)handleDeviceStartRequestWithScene:(TSAIAudioRecordScene)scene {
    if ([self.sessionState isActive]) {
        TSLog(@"[TSAIAudioRecordSessionCoordinator] duplicate device start ignored");
        return;
    }
    TSAIAudioRecordConfig *config = [self.preferredConfig copy];
    config.recordingScene = scene;
    [self beginRecordingWithConfig:config
                            source:TSAIAudioRecordSessionSourceDevice
                        completion:nil];
}

/** 创建状态和草稿并调用 SDK 开始接口 */
- (void)beginRecordingWithConfig:(TSAIAudioRecordConfig *)config
                          source:(TSAIAudioRecordSessionSource)source
                      completion:(void (^ _Nullable)(BOOL, NSError * _Nullable))completion {
    TSAIAudioRecordConfig *effectiveConfig = config ?: [TSAIAudioRecordConfig defaultConfig];
    if (![self isAudioRecordContextReady]) {
        NSError *error = [self errorWithCode:TSAIErrorCodeContextInactive
                                 description:@"The AI audio recording Adapter is unavailable."];
        [self completeStart:completion success:NO error:error];
        return;
    }
    if ([self.sessionState isActive]) {
        NSError *error = [self errorWithCode:TSAIErrorCodeBusy
                                 description:@"Another AI audio recording session is active."];
        [self completeStart:completion success:NO error:error];
        return;
    }

    NSUInteger generation = [self.sessionState beginWithSource:source
                                                          scene:effectiveConfig.recordingScene];
    if (generation == 0) {
        NSError *error = [self errorWithCode:TSAIErrorCodeBusy
                                 description:@"Unable to create an AI audio recording session."];
        [self completeStart:completion success:NO error:error];
        return;
    }

    self.persistingGeneration = 0;
    self.sessionEndDate = nil;
    self.lastError = nil;
    self.preferredConfig = [effectiveConfig copy];
    self.currentDraft = [TSAIAudioRecordDraft draftWithScene:effectiveConfig.recordingScene
                                                    language:effectiveConfig.language
                                                      source:source
                                                   startDate:self.sessionState.startDate ?: [NSDate date]];
    [self.pcmFileWriter removeTemporaryFile];
    self.pcmFileWriter = [[TSAIAudioRecordPCMFileWriter alloc]
        initWithRecordIdentifier:self.currentDraft.recordIdentifier];
    [self postSessionDidChangeWithAudioLevel:nil];

    __weak typeof(self) weakSelf = self;
    [self.audioRecord startAIAudioRecordingWithConfig:effectiveConfig
                                      startCompletion:^(BOOL success, NSError *error) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleStartCompletionSuccess:success
                                             error:error
                                        generation:generation
                                         completion:completion];
        }];
    } didReceiveAudioData:^(NSData *audioData) {
        [weakSelf performOnMainThread:^{
            [weakSelf capturePCMData:audioData generation:generation];
            [weakSelf handleAudioData:audioData generation:generation];
        }];
    } didReceiveSessionResult:^(TSAIAudioRecordSessionResult *result) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleSessionResult:result generation:generation];
        }];
    } finishHandler:^(TSAudioRecordStopReason stopReason, NSError *error) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleAudioFinishWithReason:stopReason error:error generation:generation];
        }];
    }];
}

/** 检查当前 Context 是否可接收并处理设备录音请求 */
- (BOOL)isAudioRecordContextReady {
    return self.context != nil &&
        self.audioRecord != nil &&
        self.context.state == TSAIContextStateActive;
}

/** 处理开始命令结果 */
- (void)handleStartCompletionSuccess:(BOOL)success
                               error:(NSError *)error
                          generation:(NSUInteger)generation
                           completion:(void (^ _Nullable)(BOOL, NSError * _Nullable))completion {
    if (generation != self.sessionState.generation) {
        return;
    }
    if (!success) {
        self.lastError = error ?: [self errorWithCode:TSAIErrorCodeTaskFailed
                                          description:@"Failed to start AI audio recording."];
        self.currentDraft.runtimeError = self.lastError;
        self.currentDraft.isIncomplete = YES;
        [self.sessionState markFailedForGeneration:generation];
        [self postSessionDidChangeWithAudioLevel:nil];
        [self postCompletionNotification];
        [self.pcmFileWriter removeTemporaryFile];
        self.pcmFileWriter = nil;
        [self completeStart:completion success:NO error:self.lastError];
        return;
    }
    if (![self.sessionState markStartedForGeneration:generation]) {
        NSError *cancelError = [self errorWithCode:TSAIErrorCodeCancelled
                                       description:@"The AI audio recording start was superseded."];
        [self.pcmFileWriter removeTemporaryFile];
        self.pcmFileWriter = nil;
        [self completeStart:completion success:NO error:cancelError];
        return;
    }
    self.currentDraft.startDate = [NSDate date];
    [self postSessionDidChangeWithAudioLevel:nil];
    if (self.sessionState.source == TSAIAudioRecordSessionSourceDevice) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:TSAIAudioRecordSessionDidRequestPresentationNotification
                          object:self
                        userInfo:[self notificationUserInfoWithAudioLevel:nil]];
    }
    [self completeStart:completion success:YES error:nil];
}

/** 提交当前停止请求 */
- (void)requestStopForGeneration:(NSUInteger)generation {
    if (![self.sessionState markStopRequestedForGeneration:generation]) {
        return;
    }
    [self captureSessionEndDateIfNeeded];
    [self postSessionDidChangeWithAudioLevel:nil];
    [self performStopCommandForGeneration:generation];
}

/** 调用 SDK 停止接口并等待语义最终结果 */
- (void)performStopCommandForGeneration:(NSUInteger)generation {
    __weak typeof(self) weakSelf = self;
    [self.audioRecord stopAIAudioRecording:^(BOOL success, NSError *error) {
        [weakSelf performOnMainThread:^{
            if (generation != weakSelf.sessionState.generation) {
                return;
            }
            if (!success) {
                weakSelf.lastError = error ?: [weakSelf errorWithCode:TSAIErrorCodeTaskFailed
                                                             description:@"Failed to stop AI audio recording."];
                weakSelf.currentDraft.runtimeError = weakSelf.lastError;
                weakSelf.currentDraft.isIncomplete = YES;
            }
            [weakSelf.sessionState markFinalizingForGeneration:generation];
            [weakSelf postSessionDidChangeWithAudioLevel:nil];
            [weakSelf scheduleFinalResultTimeoutForGeneration:generation];
        }];
    }];
}

/** 处理中断并进入结果收尾 */
- (void)handleInterruption:(TSAIAudioRecordInterruptReason)reason {
    NSUInteger generation = self.sessionState.generation;
    if (![self.sessionState markInterruptedWithReason:reason generation:generation]) {
        return;
    }
    [self captureSessionEndDateIfNeeded];
    self.currentDraft.isIncomplete = YES;
    [self postSessionDidChangeWithAudioLevel:nil];
    [self performStopCommandForGeneration:generation];
}

/** 处理 SDK 录音状态辅助信号 */
- (void)handleSDKState:(TSAIAudioRecordState)state {
    if (state == TSAIAudioRecordStateInterrupted && [self.sessionState isActive]) {
        [self handleInterruption:TSAIAudioRecordInterruptReasonOther];
    }
}

/** 合并一条语义结果 */
- (void)handleSessionResult:(TSAIAudioRecordSessionResult *)result
                 generation:(NSUInteger)generation {
    if (!result || generation != self.sessionState.generation ||
        ![self.sessionState isActive]) {
        return;
    }
    [self.currentDraft applySessionResult:result];
    if (result.type == TSAIAudioRecordSessionResultTypeError) {
        self.lastError = result.error;
        self.currentDraft.isIncomplete = YES;
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIAudioRecordSessionDidReceiveResultNotification
        object:self
        userInfo:[self notificationUserInfoWithAudioLevel:nil]];

    if (result.type == TSAIAudioRecordSessionResultTypeFinish) {
        [self captureSessionEndDateIfNeeded];
        [self.sessionState markSessionFinishedForGeneration:generation];
        [self postSessionDidChangeWithAudioLevel:nil];
        [self persistCurrentDraftForGeneration:generation];
    }
}

/** 处理底层音频流结束 */
- (void)handleAudioFinishWithReason:(TSAudioRecordStopReason)stopReason
                              error:(NSError *)error
                         generation:(NSUInteger)generation {
    if (![self.sessionState markAudioStreamFinishedWithReason:stopReason
                                                   generation:generation]) {
        return;
    }
    [self captureSessionEndDateIfNeeded];
    if (error) {
        self.lastError = error;
        self.currentDraft.runtimeError = error;
        self.currentDraft.isIncomplete = YES;
    }
    [self.sessionState markFinalizingForGeneration:generation];
    [self postSessionDidChangeWithAudioLevel:nil];
    if (self.sessionState.hasSessionFinished) {
        [self persistCurrentDraftForGeneration:generation];
    } else {
        [self scheduleFinalResultTimeoutForGeneration:generation];
    }
}

/** 计算轻量音量值供波形展示 */
- (void)handleAudioData:(NSData *)audioData generation:(NSUInteger)generation {
    if (audioData.length == 0 || generation != self.sessionState.generation ||
        ![self.sessionState isActive]) {
        return;
    }
    const uint8_t *bytes = audioData.bytes;
    NSUInteger stride = MAX((NSUInteger)1, audioData.length / 512);
    NSUInteger sampleCount = 0;
    double amplitudeSum = 0;
    for (NSUInteger sampleIndex = 0; sampleIndex < audioData.length; sampleIndex += stride) {
        amplitudeSum += fabs((double)bytes[sampleIndex] - 128.0) / 128.0;
        sampleCount += 1;
    }
    double level = sampleCount > 0 ? MIN(1.0, amplitudeSum / sampleCount * 2.4) : 0;
    [self postSessionDidChangeWithAudioLevel:@(level)];
}

/** 将开始接口回调的 Int16 PCM 写入 Example 临时 WAV */
- (void)capturePCMData:(NSData *)pcmData generation:(NSUInteger)generation {
    if (pcmData.length == 0 || generation != self.sessionState.generation ||
        ![self.sessionState isActive]) {
        return;
    }
    [self.pcmFileWriter appendPCMData:pcmData];
}

/** 最终结果超时后保存不完整草稿 */
- (void)scheduleFinalResultTimeoutForGeneration:(NSUInteger)generation {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(kTSAIAudioRecordFinalResultTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (generation != weakSelf.sessionState.generation ||
            ![weakSelf.sessionState isActive] ||
            weakSelf.persistingGeneration == generation) {
            return;
        }
        weakSelf.currentDraft.isIncomplete = YES;
        if (!weakSelf.lastError) {
            weakSelf.lastError = [weakSelf errorWithCode:TSAIErrorCodeTimeout
                                              description:@"Timed out while waiting for the final recording result."];
            weakSelf.currentDraft.runtimeError = weakSelf.lastError;
        }
        [weakSelf persistCurrentDraftForGeneration:generation];
    });
}

/** 首次记录实际录音结束时间 */
- (void)captureSessionEndDateIfNeeded {
    if (!self.sessionEndDate) {
        self.sessionEndDate = [NSDate date];
    }
}

/** 在后台保存当前草稿 */
- (void)persistCurrentDraftForGeneration:(NSUInteger)generation {
    if (generation == 0 || generation != self.sessionState.generation ||
        self.persistingGeneration == generation || !self.currentDraft) {
        return;
    }
    self.persistingGeneration = generation;
    NSDate *endDate = self.sessionEndDate ?: [NSDate date];
    NSTimeInterval duration = [endDate timeIntervalSinceDate:self.currentDraft.startDate];
    self.currentDraft.durationMilliseconds = MAX(0, (NSInteger)llround(duration * 1000.0));
    TSAIAudioRecordPCMFileWriter *pcmFileWriter = self.pcmFileWriter;
    NSURL *fallbackAudioURL = [pcmFileWriter finishWriting];
    BOOL sdkAudioExists = self.currentDraft.rawAudioFilePath.length > 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:self.currentDraft.rawAudioFilePath];
    if (!sdkAudioExists && fallbackAudioURL) {
        self.currentDraft.rawAudioFilePath = fallbackAudioURL.path;
    }
    TSAIAudioRecordDraft *draftSnapshot = [self.currentDraft copy];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.persistenceQueue, ^{
        NSError *saveError = nil;
        BOOL didSave = [weakSelf.draftStore saveDraft:draftSnapshot error:&saveError];
        [pcmFileWriter removeTemporaryFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != weakSelf.sessionState.generation) {
                return;
            }
            weakSelf.currentDraft.storedAudioRelativePath = draftSnapshot.storedAudioRelativePath;
            weakSelf.currentDraft.durationMilliseconds = draftSnapshot.durationMilliseconds;
            if (weakSelf.pcmFileWriter == pcmFileWriter) {
                weakSelf.pcmFileWriter = nil;
            }
            if (!didSave) {
                weakSelf.currentDraft.isIncomplete = YES;
                weakSelf.lastError = saveError;
                weakSelf.currentDraft.runtimeError = saveError;
            }
            [weakSelf.sessionState markCompletedForGeneration:generation];
            [weakSelf postSessionDidChangeWithAudioLevel:nil];
            [weakSelf postCompletionNotification];
        });
    });
}

/** Context 断开时保存不完整草稿 */
- (void)finishDisconnectedSessionIfNeeded {
    if (![self.sessionState isActive]) {
        return;
    }
    NSUInteger generation = self.sessionState.generation;
    self.currentDraft.isIncomplete = YES;
    self.lastError = [self errorWithCode:TSAIErrorCodeContextInactive
                             description:@"The AI context disconnected during recording."];
    self.currentDraft.runtimeError = self.lastError;
    [self captureSessionEndDateIfNeeded];
    [self.sessionState markFinalizingForGeneration:generation];
    [self persistCurrentDraftForGeneration:generation];
}

/** 广播状态和可选音量 */
- (void)postSessionDidChangeWithAudioLevel:(NSNumber *)audioLevel {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIAudioRecordSessionDidChangeNotification
        object:self
        userInfo:[self notificationUserInfoWithAudioLevel:audioLevel]];
}

/** 广播会话完成 */
- (void)postCompletionNotification {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSAIAudioRecordSessionDidCompleteNotification
        object:self
        userInfo:[self notificationUserInfoWithAudioLevel:nil]];
}

/** 创建只包含非空值的通知参数 */
- (NSDictionary<NSString *, id> *)notificationUserInfoWithAudioLevel:(NSNumber *)audioLevel {
    NSMutableDictionary<NSString *, id> *userInfo = [NSMutableDictionary dictionary];
    userInfo[TSAIAudioRecordSessionStateUserInfoKey] = [self.sessionState copy];
    if (self.currentDraft) {
        userInfo[TSAIAudioRecordSessionDraftUserInfoKey] = [self.currentDraft copy];
    }
    if (self.lastError) {
        userInfo[TSAIAudioRecordSessionErrorUserInfoKey] = self.lastError;
    }
    if (audioLevel) {
        userInfo[TSAIAudioRecordSessionAudioLevelUserInfoKey] = audioLevel;
    }
    return [userInfo copy];
}

/** 创建 Demo 使用的 SDK 公共错误 */
- (NSError *)errorWithCode:(TSAIErrorCode)code description:(NSString *)description {
    return [NSError errorWithDomain:TSAIErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

/** 在主线程执行状态变更 */
- (void)performOnMainThread:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 回调 App 发起的启动结果 */
- (void)completeStart:(void (^ _Nullable)(BOOL, NSError * _Nullable))completion
               success:(BOOL)success
                 error:(NSError *)error {
    if (completion) {
        completion(success, error);
    }
}

@end
