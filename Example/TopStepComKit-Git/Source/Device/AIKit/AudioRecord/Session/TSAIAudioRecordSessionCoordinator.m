//
//  TSAIAudioRecordSessionCoordinator.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordSessionCoordinator.h"

#import <math.h>
#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIAudioRouteConfiguration.h>
#import <TopStepAIKit/TSAIAudioRecordConfig.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioRecordAppCapture.h"
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
// 波形显示的静音下限，单位为 dBFS
static const double kTSAIAudioRecordWaveformMinimumDecibels = -60.0;
static TSAIAudioRecordSessionCoordinator *gTSAIAudioRecordSessionCoordinator = nil;

@interface TSAIAudioRecordSessionCoordinator ()

// 当前可变会话状态
@property (nonatomic, strong, readwrite) TSAIAudioRecordSessionState *sessionState;
// 当前录音草稿
@property (nonatomic, strong, nullable, readwrite) TSAIAudioRecordDraft *currentDraft;
// App 下一次主动录音时使用的配置
@property (nonatomic, strong, readwrite) TSAIAudioRecordConfig *preferredConfig;
// 当前或最近一次会话的拾音方式
@property (nonatomic, assign, readwrite) TSAIAudioRecordPickupSource currentPickupSource;
// 手机或蓝牙耳机拾音时的 App 侧采集器
@property (nonatomic, strong, nullable) TSAIAudioRecordAppCapture *appCapture;
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
        // Demo 默认把转写同步到设备屏幕，与录音页开关的初始值一致
        _preferredConfig.deliversTranscriptToDevice = YES;
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

/** 更新下一次 App 主动录音使用的配置 */
- (void)updatePreferredConfig:(TSAIAudioRecordConfig *)config {
    if (!config) {
        return;
    }
    [self performOnMainThread:^{
        self.preferredConfig = [config copy];
    }];
}

/** 启动 App 发起的录音，按配置中的音频提供方推断拾音方式 */
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    TSAIAudioRecordPickupSource pickupSource = config.inputSource == TSAIAudioRecordInputSourceApp
        ? TSAIAudioRecordPickupSourcePhone
        : TSAIAudioRecordPickupSourceDevice;
    [self startRecordingWithConfig:config pickupSource:pickupSource completion:completion];
}

/** 使用指定拾音方式启动 App 发起的录音，App 采集前先获取麦克风权限 */
- (void)startRecordingWithConfig:(TSAIAudioRecordConfig *)config
                    pickupSource:(TSAIAudioRecordPickupSource)pickupSource
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    TSAIAudioRecordConfig *sessionConfig = [config copy] ?: [TSAIAudioRecordConfig defaultConfig];
    [self applyPickupSource:pickupSource toConfig:sessionConfig];
    [self performOnMainThread:^{
        if (pickupSource == TSAIAudioRecordPickupSourceDevice) {
            [self beginRecordingWithConfig:sessionConfig
                                    source:TSAIAudioRecordSessionSourceApp
                              pickupSource:pickupSource
                                completion:completion];
            return;
        }
        [TSAIAudioRecordAppCapture requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                NSError *error = [self errorWithCode:TSAIErrorCodeAuthorizationRequired
                                         description:@"麦克风权限已关闭，请在系统设置中开启后再使用手机或耳机拾音"];
                [self completeStart:completion success:NO error:error];
                return;
            }
            [self beginRecordingWithConfig:sessionConfig
                                    source:TSAIAudioRecordSessionSourceApp
                              pickupSource:pickupSource
                                completion:completion];
        }];
    }];
}

/** 返回拾音方式当前是否可选 */
- (BOOL)isPickupSourceAvailable:(TSAIAudioRecordPickupSource)pickupSource
                         reason:(NSString **)reason {
    NSString *unavailableReason = nil;
    if (![self isAudioRecordContextReady]) {
        unavailableReason = @"AI 服务未就绪，请先连接设备";
    } else if (pickupSource == TSAIAudioRecordPickupSourceDevice) {
        if (![self.context supportsAIFeatures:TSAIFeatureAIAudioRecording]) {
            unavailableReason = @"当前设备不支持设备拾音";
        }
    } else if ([TSAIAudioRecordAppCapture isRecordPermissionDenied]) {
        unavailableReason = @"麦克风权限已关闭，请在系统设置中开启";
    } else if (pickupSource == TSAIAudioRecordPickupSourceBluetoothHeadset &&
               ![TSAIAudioRecordAppCapture isBluetoothHeadsetInputAvailable]) {
        unavailableReason = @"未检测到支持通话的蓝牙耳机";
    }
    if (reason) {
        *reason = unavailableReason;
    }
    return unavailableReason == nil;
}

/** 停止当前录音 */
- (void)stopRecording {
    [self performOnMainThread:^{
        [self requestStopForGeneration:self.sessionState.generation];
    }];
}

/** 暂停当前录音：SDK 暂停成功后再切换本地阶段并停止 App 采集投递 */
- (void)pauseRecordingWithCompletion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self changePauseState:YES completion:completion];
}

/** 继续当前录音 */
- (void)resumeRecordingWithCompletion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self changePauseState:NO completion:completion];
}

/** 返回设备是否支持同步暂停/继续 */
- (BOOL)isDevicePauseResumeSupported {
    return [self isAudioRecordContextReady] &&
        [self.audioRecord isDeviceAIAudioRecordingPauseResumeSupported];
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
    // 使用携带输入通道与请求标识的回调；仅带场景的旧回调不再注册，避免同一请求触发两次
    [self.audioRecord registerOnDeviceRequestStartAIAudioRecording:^(TSAIAudioRecordDeviceRequest *request) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleDeviceStartRequest:request];
        }];
    }];
    [self.audioRecord registerOnRequestPauseAIAudioRecording:^{
        [weakSelf performOnMainThread:^{
            [weakSelf pauseRecordingWithCompletion:nil];
        }];
    }];
    [self.audioRecord registerOnRequestResumeAIAudioRecording:^{
        [weakSelf performOnMainThread:^{
            [weakSelf resumeRecordingWithCompletion:nil];
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
    [self.audioRecord registerAIAudioRecordingStateDidChanged:^(TSAIAudioRecordState state) {
        [weakSelf performOnMainThread:^{
            [weakSelf handleSDKState:state];
        }];
    }];
}

/** 清空设备侧录音回调 */
- (void)unregisterAudioRecordCallbacks {
    [self.audioRecord registerOnDeviceRequestStartAIAudioRecording:nil];
    [self.audioRecord registerOnRequestPauseAIAudioRecording:nil];
    [self.audioRecord registerOnRequestResumeAIAudioRecording:nil];
    [self.audioRecord registerOnRequestStopAIAudioRecording:nil];
    [self.audioRecord registerAIAudioRecordingDidInterrupt:nil];
    [self.audioRecord registerAIAudioRecordingStateDidChanged:nil];
}

/** 处理已通过 TopStepAIKit 精确门禁的设备录音开始请求，拾音方式取自设备选择的输入通道 */
- (void)handleDeviceStartRequest:(TSAIAudioRecordDeviceRequest *)request {
    if ([self.sessionState isActive]) {
        TSLog(@"[TSAIAudioRecordSessionCoordinator] duplicate device start ignored: %@", request);
        return;
    }
    TSAIAudioRecordConfig *config = [self.preferredConfig copy];
    config.recordingScene = request.scene;
    config.expectedDeviceRequestIdentifier = request.requestIdentifier;
    TSAIAudioRecordPickupSource pickupSource = [self pickupSourceForInputChannel:request.inputChannel];
    // 设备发起时音频由 SDK 按设备选择的通道采集，App 只记录拾音方式用于展示
    config.inputSource = TSAIAudioRecordInputSourceDevice;
    config.audioRouteConfiguration = nil;
    // 转写同步沿用页面最近一次的开关（preferredConfig）
    TSLog(@"[TSAIAudioRecordSessionCoordinator] device start request: %@, pickup=%ld, syncTranscript=%d",
          request, (long)pickupSource, config.deliversTranscriptToDevice);
    [self beginRecordingWithConfig:config
                            source:TSAIAudioRecordSessionSourceDevice
                      pickupSource:pickupSource
                        completion:nil];
}

/** 将设备选择的输入通道映射为 Demo 拾音方式：SCO=耳机，Opus=充电仓，BuiltInMic=手机 */
- (TSAIAudioRecordPickupSource)pickupSourceForInputChannel:(TSAIAudioInputChannel)inputChannel {
    switch (inputChannel) {
        case TSAIAudioInputChannelSCO:
            return TSAIAudioRecordPickupSourceBluetoothHeadset;
        case TSAIAudioInputChannelBuiltInMic:
            return TSAIAudioRecordPickupSourcePhone;
        case TSAIAudioInputChannelOpus:
        case TSAIAudioInputChannelAutomatic:
        case TSAIAudioInputChannelUnknown:
        default:
            return TSAIAudioRecordPickupSourceDevice;
    }
}

/** 创建状态和草稿并调用 SDK 开始接口 */
- (void)beginRecordingWithConfig:(TSAIAudioRecordConfig *)config
                          source:(TSAIAudioRecordSessionSource)source
                    pickupSource:(TSAIAudioRecordPickupSource)pickupSource
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
    self.currentPickupSource = pickupSource;
    [self postSessionDidChangeWithAudioLevel:nil];

    // App 发起且用手机/耳机拾音时由 App 采集；设备发起时 SDK 自行按设备通道采集
    if (source == TSAIAudioRecordSessionSourceApp &&
        pickupSource != TSAIAudioRecordPickupSourceDevice) {
        NSError *captureError = nil;
        if (![self startAppCaptureWithPickupSource:pickupSource
                                        generation:generation
                                             error:&captureError]) {
            [self handleStartCompletionSuccess:NO
                                         error:captureError
                                    generation:generation
                                     completion:completion];
            return;
        }
    }

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
        [self stopAppCapture];
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

/** 切换暂停态；只在录音中允许暂停、暂停中允许继续 */
- (void)changePauseState:(BOOL)paused completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self performOnMainThread:^{
        TSAIAudioRecordSessionPhase phase = self.sessionState.phase;
        NSUInteger generation = self.sessionState.generation;
        BOOL allowed = paused
            ? phase == TSAIAudioRecordSessionPhaseRecording
            : phase == TSAIAudioRecordSessionPhasePaused;
        if (!allowed) {
            NSError *error = [self errorWithCode:TSAIErrorCodeInvalidResponse
                                     description:paused ? @"当前不在录音中，无法暂停" : @"当前未暂停，无法继续"];
            [self completeStart:completion success:NO error:error];
            return;
        }
        __weak typeof(self) weakSelf = self;
        void (^handleResult)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
            [weakSelf performOnMainThread:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (generation != strongSelf.sessionState.generation) {
                    NSError *staleError = [strongSelf errorWithCode:TSAIErrorCodeCancelled
                                                        description:@"录音会话已结束"];
                    [strongSelf completeStart:completion success:NO error:staleError];
                    return;
                }
                if (!success) {
                    TSLog(@"[TSAIAudioRecordSessionCoordinator] %@ failed: %@",
                          paused ? @"pause" : @"resume", error);
                    [strongSelf completeStart:completion success:NO error:error];
                    return;
                }
                if (paused) {
                    [strongSelf.sessionState markPausedForGeneration:generation];
                } else {
                    [strongSelf.sessionState markResumedForGeneration:generation];
                }
                strongSelf.appCapture.isPaused = paused;
                [strongSelf postSessionDidChangeWithAudioLevel:nil];
                [strongSelf completeStart:completion success:YES error:nil];
            }];
        };
        if (paused) {
            [self.audioRecord pauseAIAudioRecording:handleResult];
        } else {
            [self.audioRecord resumeAIAudioRecording:handleResult];
        }
    }];
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
    // 先停止 App 采集，SDK 停止时会排空已接收的数据
    [self stopAppCapture];
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

/** 处理 SDK 录音状态辅助信号：中断即收尾，暂停/录音中则同步本地阶段 */
- (void)handleSDKState:(TSAIAudioRecordState)state {
    NSUInteger generation = self.sessionState.generation;
    if (state == TSAIAudioRecordStateInterrupted && [self.sessionState isActive]) {
        [self handleInterruption:TSAIAudioRecordInterruptReasonOther];
        return;
    }
    if (state == TSAIAudioRecordStatePaused &&
        [self.sessionState markPausedForGeneration:generation]) {
        self.appCapture.isPaused = YES;
        [self postSessionDidChangeWithAudioLevel:nil];
        return;
    }
    if (state == TSAIAudioRecordStateRecording &&
        [self.sessionState markResumedForGeneration:generation]) {
        self.appCapture.isPaused = NO;
        [self postSessionDidChangeWithAudioLevel:nil];
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
    [self stopAppCapture];
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

/** 按小端 Int16 PCM 计算 RMS 音量，并将 -60～0 dBFS 映射为波形高度 */
- (void)handleAudioData:(NSData *)audioData generation:(NSUInteger)generation {
    NSUInteger sampleCount = audioData.length / sizeof(int16_t);
    if (sampleCount == 0 || generation != self.sessionState.generation ||
        ![self.sessionState isActive]) {
        return;
    }
    const uint8_t *bytes = audioData.bytes;
    double squareSum = 0;
    for (NSUInteger sampleIndex = 0; sampleIndex < sampleCount; sampleIndex++) {
        NSUInteger byteOffset = sampleIndex * sizeof(int16_t);
        uint16_t encodedSample = (uint16_t)bytes[byteOffset] |
            ((uint16_t)bytes[byteOffset + 1] << 8);
        int32_t signedSample = encodedSample >= 0x8000
            ? (int32_t)encodedSample - 0x10000 : (int32_t)encodedSample;
        double normalizedSample = signedSample / 32768.0;
        squareSum += normalizedSample * normalizedSample;
    }
    double rootMeanSquare = sqrt(squareSum / sampleCount);
    double decibels = rootMeanSquare > 0
        ? 20.0 * log10(rootMeanSquare) : kTSAIAudioRecordWaveformMinimumDecibels;
    double level = MIN(1.0, MAX(0.0,
        (decibels - kTSAIAudioRecordWaveformMinimumDecibels) /
        -kTSAIAudioRecordWaveformMinimumDecibels));
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
    // 时长与页面计时共用状态机的起点与终点，且不含暂停
    NSTimeInterval duration = [self.sessionState activeDuration];
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
    [self stopAppCapture];
    self.currentDraft.isIncomplete = YES;
    self.lastError = [self errorWithCode:TSAIErrorCodeContextInactive
                             description:@"The AI context disconnected during recording."];
    self.currentDraft.runtimeError = self.lastError;
    [self captureSessionEndDateIfNeeded];
    [self.sessionState markFinalizingForGeneration:generation];
    [self persistCurrentDraftForGeneration:generation];
}

/** 将拾音方式写入录音配置：充电仓拾音走设备 Opus，手机与耳机由 App 提供 PCM；转写同步开关由页面决定 */
- (void)applyPickupSource:(TSAIAudioRecordPickupSource)pickupSource
                 toConfig:(TSAIAudioRecordConfig *)config {
    config.expectedDeviceRequestIdentifier = nil;
    if (pickupSource == TSAIAudioRecordPickupSourceDevice) {
        config.inputSource = TSAIAudioRecordInputSourceDevice;
        config.audioRouteConfiguration =
            [TSAIAudioRouteConfiguration configurationWithInputChannel:TSAIAudioInputChannelOpus
                                                           outputChannel:TSAIAudioOutputChannelNone
                                                  routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
        return;
    }
    config.inputSource = TSAIAudioRecordInputSourceApp;
}

/** 启动手机或蓝牙耳机采集，并把 PCM 持续推送给 SDK */
- (BOOL)startAppCaptureWithPickupSource:(TSAIAudioRecordPickupSource)pickupSource
                             generation:(NSUInteger)generation
                                  error:(NSError **)error {
    [self stopAppCapture];
    TSAIAudioRecordAppCaptureInput input = pickupSource == TSAIAudioRecordPickupSourceBluetoothHeadset
        ? TSAIAudioRecordAppCaptureInputBluetoothHeadset
        : TSAIAudioRecordAppCaptureInputPhoneMicrophone;
    TSAIAudioRecordAppCapture *capture = [[TSAIAudioRecordAppCapture alloc] init];
    id<TSAudioRecordInterface> audioRecord = self.audioRecord;
    __weak typeof(self) weakSelf = self;
    BOOL started = [capture startWithInput:input pcmHandler:^(NSData *pcmData) {
        // 采集线程直接推送；SDK 本地会话就绪前会返回 NO 并丢弃数据
        [audioRecord appendAIAudioRecordingPCMData:pcmData error:nil];
    } errorHandler:^(NSError *captureError) {
        [weakSelf handleAppCaptureError:captureError generation:generation];
    } error:error];
    if (started) {
        self.appCapture = capture;
    }
    return started;
}

/** App 采集意外停止时结束当前录音并保留原因 */
- (void)handleAppCaptureError:(NSError *)error generation:(NSUInteger)generation {
    if (generation != self.sessionState.generation || ![self.sessionState isActive]) {
        return;
    }
    self.appCapture = nil;
    self.lastError = error;
    self.currentDraft.runtimeError = error;
    [self handleInterruption:TSAIAudioRecordInterruptReasonOther];
}

/** 停止 App 侧采集，可重复调用 */
- (void)stopAppCapture {
    [self.appCapture stop];
    self.appCapture = nil;
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
