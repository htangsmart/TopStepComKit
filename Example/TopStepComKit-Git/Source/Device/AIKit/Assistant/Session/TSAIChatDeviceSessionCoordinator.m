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

#import "TSAIChatAudioPreference.h"
#import "TSAIChatIntentCoordinator.h"
#import "TSDeviceCoordinator.h"

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
NSNotificationName const TSAIChatDeviceSessionDidIgnoreDeviceRequestNotification =
    @"TSAIChatDeviceSessionDidIgnoreDeviceRequestNotification";

NSString * const TSAIChatDeviceSessionPhaseUserInfoKey = @"TSAIChatDeviceSessionPhase";
NSString * const TSAIChatDeviceSessionContentUserInfoKey = @"TSAIChatDeviceSessionContent";
NSString * const TSAIChatDeviceSessionEventUserInfoKey = @"TSAIChatDeviceSessionEvent";
NSString * const TSAIChatDeviceSessionReportUserInfoKey = @"TSAIChatDeviceSessionReport";
NSString * const TSAIChatDeviceSessionErrorUserInfoKey = @"TSAIChatDeviceSessionError";

static const NSUInteger kTSAIChatDeviceSessionMaximumHistoryCount = 200;
static TSAIChatDeviceSessionCoordinator *gTSAIChatDeviceSessionCoordinator = nil;

/// 等待 App 处理定位意图的时长（秒）
static const NSTimeInterval kTSAIChatIntentActionTimeout = 30.0;

@interface TSAIChatDeviceSessionCoordinator ()

// 当前会话状态机
@property (nonatomic, strong) TSAIChatDeviceSessionState *sessionState;
// 当前绑定的 Context
@property (nonatomic, strong, nullable) TSAIContext *context;
// App 最近一次提供的位置（绑定 Context 时补发）
@property (nonatomic, strong, nullable) CLLocation *cachedLocation;
// 是否显式设置过位置（含 nil 清除）
@property (nonatomic, assign) BOOL hasCachedLocation;
// 当前绑定的助手
@property (nonatomic, strong, nullable) id<TSAIAssistantInterface> assistant;
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
// 当前会话是否由设备发起
@property (nonatomic, assign) BOOL currentSessionDeviceInitiated;
// 当前会话实际使用的配置
@property (nonatomic, strong, nullable, readwrite) TSAIChatConfig *activeSessionConfig;
// 待启动会话的配置（beginSession 前设置）
@property (nonatomic, strong, nullable) TSAIChatConfig *pendingSessionConfig;
// 当前会话的麦克风是否已出数据（InputReady）
@property (nonatomic, assign, readwrite, getter=isInputReady) BOOL inputReady;
// 当前会话开始启动的时刻（systemUptime，日志用）
@property (nonatomic, assign) NSTimeInterval sessionBeginUptime;

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
        _config.audioRouteConfiguration = [TSAIAudioRouteConfiguration
            configurationWithInputChannel:TSAIAudioInputChannelOpus
                              outputChannel:TSAIAudioOutputChannelOpus
                     routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
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
    if (!assistant) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] bind ignored: assistant route is unavailable");
        return;
    }

    if (self.assistant && self.assistant != assistant) {
        [self.assistant registerOnAIChatDeviceEvent:nil];
        [self closeCurrentSessionForOrigin:TSAIChatDeviceSessionEndOriginRuntimeError];
    }
    self.context = context;
    self.assistant = assistant;
    if (self.hasCachedLocation) {
        [context updateCurrentLocation:self.cachedLocation];
    }

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

/** 由 App 发起对话，启动资格与设备同步交由 Assistant Adapter */
- (void)startSessionFromApp {
    [self startSessionFromAppWithConfig:[self sessionConfigForMode:TSAIChatConversationModeContinuous
                                                        voiceInput:YES
                                                endsInputOnSilence:YES]];
}

/** 以指定配置由 App 发起对话 */
- (void)startSessionFromAppWithConfig:(TSAIChatConfig *)config {
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf startSessionFromAppWithConfig:config];
        });
        return;
    }
    self.pendingSessionConfig = [config copy];
    [self beginSessionDeviceInitiated:NO];
}

/** 结束本次输入（按住说话松手） */
- (void)finishInputFromApp {
    NSString *taskId = self.currentTaskId;
    if (taskId.length == 0 || !self.assistant) {
        return;
    }
    TSLog(@"[TSAIChatDeviceSessionCoordinator] finish input: taskId=%@", taskId);
    [self.assistant finishChatInputWithTaskId:taskId];
}

/** 向当前会话发送文字提问 */
- (BOOL)sendTextFromApp:(NSString *)text {
    NSString *taskId = self.currentTaskId;
    if (taskId.length == 0 || !self.assistant || text.length == 0) {
        return NO;
    }
    BOOL accepted = [self.assistant sendChatText:text taskId:taskId];
    TSLog(@"[TSAIChatDeviceSessionCoordinator] send text: taskId=%@, accepted=%d", taskId, accepted);
    return accepted;
}

/** 重发等待客户端补充信息的轮次 */
- (BOOL)replayPendingIntentRoundFromApp:(NSString *)text {
    NSString *taskId = self.currentTaskId;
    if (taskId.length == 0 || !self.assistant || text.length == 0) {
        return NO;
    }
    BOOL accepted = [self.assistant replayPendingIntentRoundWithText:text taskId:taskId];
    TSLog(@"[TSAIChatDeviceSessionCoordinator] replay pending intent round: taskId=%@, textLength=%lu, accepted=%d",
          taskId, (unsigned long)text.length, accepted);
    return accepted;
}

/** 更新 AI 上下文中的用户位置：本地缓存，Context 已绑定时立即转发 */
- (void)updateCurrentLocationFromApp:(nullable CLLocation *)location {
    self.cachedLocation = location;
    self.hasCachedLocation = YES;
    TSAIContext *context = self.context;
    TSLog(@"[TSAIChatDeviceSessionCoordinator] update location: hasLocation=%d, hasContext=%d",
          location != nil, context != nil);
    [context updateCurrentLocation:location];
}

/** 打断 AI 回复播放 */
- (void)interruptPlaybackFromApp {
    NSString *taskId = self.currentTaskId;
    if (taskId.length == 0 || !self.assistant) {
        return;
    }
    TSLog(@"[TSAIChatDeviceSessionCoordinator] interrupt playback: taskId=%@", taskId);
    [self.assistant interruptChatPlaybackWithTaskId:taskId];
}

/** 是否有会话在启动中或进行中 */
- (BOOL)isSessionActive {
    if (self.currentTaskId.length > 0) {
        return YES;
    }
    TSAIChatDeviceSessionPhase phase = self.sessionState.phase;
    return phase == TSAIChatDeviceSessionPhaseStartRequested ||
           phase == TSAIChatDeviceSessionPhaseActive;
}

/** 已绑定的耳机是否连接就绪 */
- (BOOL)isHeadsetConnected {
    return [TSDeviceCoordinator sharedInstance].snapshot.isReady;
}

/** 当前会话是否由设备发起 */
- (BOOL)activeSessionDeviceInitiated {
    return self.currentSessionDeviceInitiated && [self isSessionActive];
}

/** 以基础配置 + 音频偏好构造一次会话的配置 */
- (TSAIChatConfig *)sessionConfigForMode:(TSAIChatConversationMode)mode
                              voiceInput:(BOOL)voiceInput
                      endsInputOnSilence:(BOOL)endsInputOnSilence {
    TSAIChatConfig *config = [(self.config ?: [TSAIChatConfig defaultConfig]) copy];
    config.conversationMode = mode;
    config.endsInputOnSilence = endsInputOnSilence;
    config.maximumInputDuration = 60;
    config.audioRouteConfiguration = voiceInput ? [self voiceRouteConfigurationForMode:mode] : [self textRouteConfigurationForMode:mode];
    config.enableVoiceOutput = config.audioRouteConfiguration.outputChannel != TSAIAudioOutputChannelNone;
    // AI 畅聊始终打开设备端 AI 对话（FitCloud startAIChatSession），与拾音 / 播放选择无关；
    // AI 对话（文字提问、按住说话）从不拉起设备
    config.opensDeviceChatSession = mode == TSAIChatConversationModeContinuous;
    // 定位意图需要覆盖「系统权限弹窗 + 一次定位 + 逆地理」，比 SDK 默认 20s 再宽一些
    config.intentActionTimeout = kTSAIChatIntentActionTimeout;
    return config;
}

/** 语音输入路由：按该线路自己的音频偏好解析（AI 对话 / AI 畅聊各存各的，互不影响）。
 *  AI 对话线路没有「耳机仓」选项：自动 = 蓝牙耳机 > 手机；AI 畅聊线路：自动 = 蓝牙耳机 > 耳机仓 > 手机；
 *  依赖的链路未连接时回落手机。
 *  手机麦克风拾音 +「耳机仓」(Opus) 播放：SDK 已声明 BuiltInMic/Opus 完整路由，PCM 经设备通道下发到耳机仓，原样请求。
 *  手机麦克风拾音 +「耳机」(A2DP) 播放改走系统音频（SystemDefault）：BuiltInMic/A2DP 要求设备当前通道为
 *  OpusInA2DPOut（手表固件是 OpusInOpusOut），直接请求会被 SDK 回退；系统音频本身会路由到已配对的蓝牙耳机。 */
- (TSAIAudioRouteConfiguration *)voiceRouteConfigurationForMode:(TSAIChatConversationMode)mode {
    BOOL headset = [self isHeadsetConnected];
    TSAIChatAudioPreference *preference = [TSAIChatAudioPreference preferenceForConversationMode:mode];
    TSAIAudioInputChannel input = [preference inputChannelWithHeadset:headset];
    TSAIAudioOutputChannel output = [preference outputChannelWithHeadset:headset];
    if (input == TSAIAudioInputChannelBuiltInMic && output == TSAIAudioOutputChannelA2DP) {
        output = TSAIAudioOutputChannelSystemDefault;
    }
    return [TSAIAudioRouteConfiguration configurationWithInputChannel:input
                                                        outputChannel:output
                                               routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute];
}

/** 文字输入路由：不拾音，只按该线路的「语音播放」偏好。文字轮只存在于 AI 对话线路，该线路本就没有「耳机仓」播放；
 *  这里再兜底把 Opus 与「耳机」（A2DP）都改走系统音频（SystemDefault）——Opus 播放需要拉起设备会话，
 *  A2DP 的可用性取决于设备当前通道，文字轮不拉起设备会话，系统音频自会路由到已配对的蓝牙耳机，保持纯 App ↔ SDK。
 *  policy 保持 UseAutomaticRoute：SDK 对 None 输入的自动回落只会更换播放通道、不会升级为拾音（TSAIAudioRouteCoordinator / TSAIKitAssistantAdapter 双重保证），这样系统播放不可用时文字轮仍能静默完成 */
- (TSAIAudioRouteConfiguration *)textRouteConfigurationForMode:(TSAIChatConversationMode)mode {
    BOOL headset = [self isHeadsetConnected];
    TSAIChatAudioPreference *preference = [TSAIChatAudioPreference preferenceForConversationMode:mode];
    TSAIAudioOutputChannel output = [preference outputChannelWithHeadset:headset];
    if (output == TSAIAudioOutputChannelOpus || output == TSAIAudioOutputChannelA2DP) {
        output = TSAIAudioOutputChannelSystemDefault;
    }
    return [TSAIAudioRouteConfiguration configurationWithInputChannel:TSAIAudioInputChannelNone
                                                        outputChannel:output
                                               routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute];
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
    [self.sessionState markClosedByDeviceWithOrigin:TSAIChatDeviceSessionEndOriginApp];
    [self postPhaseDidChange];
    [self stopCurrentCloudTask];
}

/** 判断当前对话接口是否就绪 */
- (BOOL)isChatInterfaceReady {
    if (!self.context || self.context.state != TSAIContextStateActive ||
        self.context.authorizationState != TSAIAuthorizationStateAuthenticated ||
        !self.assistant) {
        return NO;
    }
    return YES;
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

/** 处理已通过 TopStepAIKit 精确门禁的设备启动请求：设备发起固定为 AI 畅聊，拾音与播放固定耳机仓 */
- (void)handleDeviceStartRequest {
    if ([self isSessionActive]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] device start ignored: a session is already active");
        [[NSNotificationCenter defaultCenter]
            postNotificationName:TSAIChatDeviceSessionDidIgnoreDeviceRequestNotification
                          object:self];
        return;
    }
    // 耳机仓没有松手动作，静默即算说完；其余（超时、意图等待等）与 App 发起的畅聊一致
    TSAIChatConfig *config = [self sessionConfigForMode:TSAIChatConversationModeContinuous
                                             voiceInput:YES
                                     endsInputOnSilence:YES];
    // 路由直接固定为耳机仓（Opus / Opus），不依赖连接快照的时序；耳机仓播放不可用时由 SDK 自动回退
    config.audioRouteConfiguration = [TSAIAudioRouteConfiguration configurationWithInputChannel:TSAIAudioInputChannelOpus
                                                                                   outputChannel:TSAIAudioOutputChannelOpus
                                                                          routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyUseAutomaticRoute];
    config.enableVoiceOutput = YES;
    TSLog(@"[TSAIChatDeviceSessionCoordinator] device start: conversationMode=Continuous, input=Opus, output=Opus");
    self.pendingSessionConfig = config;
    [self beginSessionDeviceInitiated:YES];
}

/** 设备发起畅聊时把「AI 畅聊」线路的拾音 / 播放选为耳机仓：胶囊、选择面板与「重新开始」都与本次会话一致 */
- (void)selectCaseRouteForFlowLine {
    TSAIChatAudioPreference *preference =
        [TSAIChatAudioPreference preferenceForConversationMode:TSAIChatConversationModeContinuous];
    if (preference.input != TSAIChatAudioInputOptionDevice) {
        preference.input = TSAIChatAudioInputOptionDevice;
    }
    if (preference.output != TSAIChatAudioOutputOptionDevice) {
        preference.output = TSAIChatAudioOutputOptionDevice;
    }
}

/** 建立新对话，具体资格校验由 Assistant Adapter 在开始接口内完成 */
- (void)beginSessionDeviceInitiated:(BOOL)deviceInitiated {
    if (self.currentTaskId.length > 0) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] start ignored while the previous task is finishing");
        self.pendingSessionConfig = nil;
        return;
    }
    NSUInteger generation = 0;
    if (![self.sessionState beginDeviceStartWithGeneration:&generation]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] duplicate start ignored: generation=%lu, phase=%ld",
              (unsigned long)self.sessionState.generation, (long)self.sessionState.phase);
        self.pendingSessionConfig = nil;
        return;
    }
    if (deviceInitiated) {
        // 设备发起已受理：AI 畅聊线路的拾音 / 播放同步选为耳机仓
        [self selectCaseRouteForFlowLine];
    }
    TSAIChatConfig *sessionConfig = self.pendingSessionConfig ?: [self.config copy];
    // 启动前把已知地名写进 initialPrompt：星芒只在会话 start 时读取位置上下文
    sessionConfig.initialPrompt =
        [TSAIChatIntentCoordinator initialPromptByAppendingLocationToPrompt:sessionConfig.initialPrompt];
    self.activeSessionConfig = sessionConfig;
    self.pendingSessionConfig = nil;
    self.currentTaskId = nil;
    self.lastReport = nil;
    self.lastError = nil;
    self.currentSessionDeviceInitiated = deviceInitiated;
    self.inputReady = NO;
    self.sessionBeginUptime = NSProcessInfo.processInfo.systemUptime;
    [self.mutableContentHistory removeAllObjects];
    [self.mutableEventHistory removeAllObjects];
    [self postPhaseDidChange];
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
    TSAIChatConfig *chatConfig = self.activeSessionConfig ?: self.config ?: [TSAIChatConfig defaultConfig];
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
        NSError *error = [NSError
            errorWithDomain:TSAIErrorDomain
                       code:TSAIErrorCodeInvalidResponse
                   userInfo:@{NSLocalizedDescriptionKey :
                                  @"The AI chat Adapter returned an empty task identifier."}];
        [self handleCompletionWithReport:nil error:error generation:generation];
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
        case TSAIChatEventTypeInputReady:
            [self handleInputReadyEvent:event];
            break;
        case TSAIChatEventTypeAutoEnding:
            break;
        case TSAIChatEventTypeNetworkError:
            [self.sessionState markClosedByDeviceWithOrigin:
                TSAIChatDeviceSessionEndOriginRuntimeError];
            [self postPhaseDidChange];
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

/** 在 Adapter 完成本地启动与设备同步后激活 Demo 会话 */
- (void)handleSessionStartedForGeneration:(NSUInteger)generation {
    if (![self.sessionState markAIStartedForGeneration:generation]) {
        TSLog(@"[TSAIChatDeviceSessionCoordinator] stale SessionStarted ignored: generation=%lu",
              (unsigned long)generation);
        return;
    }
    [self postPhaseDidChange];
    if (self.currentSessionDeviceInitiated) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:TSAIChatDeviceSessionDidRequestPresentationNotification
                          object:self];
    }
}

/** 麦克风已开始出数据：记录状态（事件随后照常转发给页面） */
- (void)handleInputReadyEvent:(TSAIChatEvent *)event {
    self.inputReady = YES;
    TSLog(@"[TSAIChatDeviceSessionCoordinator] input ready: taskId=%@, sinceBegin=%.0f ms",
          event.taskId, (NSProcessInfo.processInfo.systemUptime - self.sessionBeginUptime) * 1000.0);
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
    [self.sessionState markClosedByDeviceWithOrigin:origin];
    [self postPhaseDidChange];

    self.lastReport = report;
    self.lastError = error;
    self.currentTaskId = nil;
    self.activeSessionConfig = nil;
    self.inputReady = NO;
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
        case TSAIChatEndReasonRoundCompleted:
        case TSAIChatEndReasonDialogExit:
            // 语音「退出对话」由 App 侧 SDK 结束，按 App 结束处理（会通知设备退出）
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
