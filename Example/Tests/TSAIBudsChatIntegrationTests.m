#import <XCTest/XCTest.h>
#import "../TopStepComKit-Git/Source/Device/AIKit/Configuration/TSAIBudsIntegrationAvailability.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE
#import <TopStepAIKit/TopStepAIKit.h>
#import "../TopStepComKit-Git/Source/Device/AIKit/Assistant/Session/TSAIChatDeviceSessionCoordinator.h"

// 只替换公开 Assistant 消息，保留 Demo 协调器的真实流程。
@interface TSBudsDemoAssistantSpy : NSObject
@property (nonatomic, copy) void (^deviceHandler)(TSAIChatDeviceEvent);
@property (nonatomic, copy) TSAIChatEventBlock eventHandler;
@property (nonatomic, copy) TSAIChatCompletionBlock completionHandler;
@property (nonatomic, strong) TSAIChatConfig *receivedConfig;
@property (nonatomic, copy) NSString *taskIdentifier;
@property (nonatomic, assign) NSUInteger startCount;
@property (nonatomic, assign) NSUInteger stopCount;
@property (nonatomic, assign) NSUInteger finishInputCount;
@end
@implementation TSBudsDemoAssistantSpy
- (void)registerOnAIChatDeviceEvent:(void (^)(TSAIChatDeviceEvent))handler { self.deviceHandler = handler; }
- (NSString *)startChatWithConfig:(TSAIChatConfig *)config onContent:(TSAIChatContentBlock)content
                        onEvent:(TSAIChatEventBlock)event completion:(TSAIChatCompletionBlock)completion {
    self.receivedConfig = [config copy];
    self.eventHandler = event;
    self.completionHandler = completion;
    self.taskIdentifier = NSUUID.UUID.UUIDString;
    self.startCount += 1;
    return self.taskIdentifier;
}
- (void)stopChatWithTaskId:(NSString *)taskId { self.stopCount += 1; }
- (void)finishChatInputWithTaskId:(NSString *)taskId { self.finishInputCount += 1; }
@end

// Context 替身仅提供已鉴权状态和精确能力，不模拟硬件成功。
@interface TSBudsDemoContextSpy : NSObject
@property (nonatomic, copy) NSString *contextIdentifier;
@property (nonatomic, strong) TSBudsDemoAssistantSpy *assistant;
@property (nonatomic, strong) TSAIStartRequest *pendingRequest;
@property (nonatomic, copy) NSArray<TSAIAudioRouteCapability *> *routes;
@property (nonatomic, assign) BOOL rejectsAppStart;
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, assign) NSUInteger rejectedRequests;
@end
@implementation TSBudsDemoContextSpy
- (instancetype)init {
    self = [super init];
    if (self) {
        _contextIdentifier = NSUUID.UUID.UUIDString;
        _assistant = [[TSBudsDemoAssistantSpy alloc] init];
        _authenticated = YES;
    }
    return self;
}
- (NSString *)platformIdentifier { return TSAIPlatformIdentifierBuds; }
- (TSAIContextState)state { return TSAIContextStateActive; }
- (TSAIAuthorizationState)authorizationState {
    return self.authenticated ? TSAIAuthorizationStateAuthenticated : TSAIAuthorizationStateFailed;
}
- (id)audioRouting { return self; }
- (NSArray *)audioRouteCapabilitiesForFeature:(TSAIFeatureOptions)feature { return self.routes; }
- (TSAIStartRequest *)pendingDeviceAISessionRequestForUseCase:(TSAIUseCase)useCase { return self.pendingRequest; }
- (TSAIStartEligibility *)startEligibilityForRequest:(TSAIStartRequest *)request {
    if (!self.rejectsAppStart) { return [TSAIStartEligibility supportedEligibility]; }
    return [TSAIStartEligibility unsupportedEligibilityWithError:[NSError errorWithDomain:TSAIErrorDomain
        code:TSAIErrorCodeNotSupported userInfo:@{NSLocalizedDescriptionKey: @"Device has no App chat capability"}]];
}
- (void)cancelDeviceAISessionStartWithRequest:(TSAIStartRequest *)request reason:(NSError *)reason
                                 completion:(TSAICompletionBlock)completion {
    self.rejectedRequests += 1;
    if (self.pendingRequest == request) { self.pendingRequest = nil; }
    if (completion) { completion(YES, nil); }
}
- (void)updateCurrentLocation:(CLLocation *)location { }
@end

@interface TSAIBudsChatIntegrationTests : XCTestCase
@property (nonatomic, strong) TSAIChatDeviceSessionCoordinator *coordinator;
@property (nonatomic, strong) TSBudsDemoContextSpy *context;
@end
@implementation TSAIBudsChatIntegrationTests
#pragma mark - 生命周期
- (void)setUp {
    [super setUp];
    XCTAssertTrue(NSThread.isMainThread);
    self.coordinator = [TSAIChatDeviceSessionCoordinator sharedInstance];
    [self.coordinator unbindContext:nil];
    [self.coordinator updateConfig:[TSAIChatConfig defaultConfig]];
    self.context = [[TSBudsDemoContextSpy alloc] init];
    self.context.routes = @[[TSAIAudioRouteCapability capabilityWithInputChannel:TSAIAudioInputChannelSCO
        outputChannel:TSAIAudioOutputChannelSCO supportedFeatures:TSAIFeatureAIChat isAvailable:YES
        supportsFullDuplex:YES echoCancellationMode:TSAIAudioEchoCancellationModeNone unavailableReason:nil]];
    [self.coordinator bindAuthenticatedContext:(id)self.context];
}
- (void)tearDown {
    [self.coordinator unbindContext:(id)self.context];
    [self drainMainQueue];
    [super tearDown];
}

#pragma mark - App 发起
// App 路由来自精确能力交集，单轮仍明确要求启动设备。
- (void)testAppVoiceStartsSingleRoundWithExactSCO {
    [self.coordinator startSessionFromApp];
    TSAIChatConfig *config = self.context.assistant.receivedConfig;
    XCTAssertEqual(self.context.assistant.startCount, 1u);
    XCTAssertEqual(config.conversationMode, TSAIChatConversationModeSingleRound);
    XCTAssertTrue(config.opensDeviceChatSession);
    XCTAssertNil(config.expectedDeviceRequestIdentifier);
    XCTAssertEqual(config.audioRouteConfiguration.inputChannel, TSAIAudioInputChannelSCO);
    XCTAssertEqual(config.audioRouteConfiguration.outputChannel, TSAIAudioOutputChannelSCO);
    XCTAssertEqual(config.audioRouteConfiguration.routeUnavailablePolicy, TSAIAudioRouteUnavailablePolicyFail);
    XCTAssertFalse(self.coordinator.activeSessionDeviceInitiated);
}
// 尚未获得通道/PCM 契约时不退回手机麦克风。
- (void)testMissingRouteFailsWithoutStartingProvider {
    self.context.routes = @[];
    [self.coordinator startSessionFromApp];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
    XCTAssertNotNil(self.coordinator.lastError);
    XCTAssertFalse(self.coordinator.isSessionActive);
}
// 设备声明音频路由不等于存在 App 启动 AiChat 的能力。
- (void)testMissingAppCapabilityRejectsStart {
    self.context.rejectsAppStart = YES;
    [self.coordinator startSessionFromApp];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
    XCTAssertNotNil(self.coordinator.lastError);
}
// 防止 App 按键偷偷接受尚待决策的设备请求。
- (void)testAppStartDoesNotConsumePendingDeviceRequest {
    self.context.pendingRequest = [self deviceRequest];
    [self.coordinator startSessionFromApp];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
    XCTAssertNotNil(self.context.pendingRequest);
}
// 连续模式不能绕过 SDK 单轮约束。
- (void)testContinuousBudsRequestFailsBeforeProvider {
    TSAIChatConfig *config = [self.coordinator sessionConfigForMode:TSAIChatConversationModeContinuous
        voiceInput:YES endsInputOnSilence:YES];
    [self.coordinator startSessionFromAppWithConfig:config];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
    XCTAssertNotNil(self.coordinator.lastError);
}

#pragma mark - 设备请求与会话归属
// 设备请求路由原样进入单轮配置；不会写成 Opus/Opus 或改掉请求 ID。
- (void)testDeviceStartPreservesRequestAndRoute {
    [self emitDeviceStart];
    TSAIChatConfig *config = self.context.assistant.receivedConfig;
    XCTAssertEqualObjects(config.expectedDeviceRequestIdentifier, self.context.pendingRequest.requestIdentifier);
    XCTAssertEqual(config.conversationMode, TSAIChatConversationModeSingleRound);
    XCTAssertEqual(config.audioRouteConfiguration.inputChannel, TSAIAudioInputChannelOpus);
    XCTAssertEqual(config.audioRouteConfiguration.outputChannel, TSAIAudioOutputChannelA2DP);
    XCTAssertTrue(config.endsInputOnSilence);
    XCTAssertTrue(self.coordinator.activeSessionDeviceInitiated);
}
// 消息已排队后原请求被替换，不能接受新的对象或复用旧 ID。
- (void)testReplacedDeviceRequestIsNotAccepted {
    self.context.pendingRequest = [self deviceRequest];
    self.context.assistant.deviceHandler(TSAIChatDeviceEventRequestStart);
    self.context.pendingRequest = [self deviceRequest];
    [self drainMainQueue];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
}
// 重复唤醒不得终止同一个已受理请求或重复建云任务。
- (void)testDuplicateWakeDoesNotCancelActiveRequest {
    [self emitDeviceStart];
    self.context.assistant.deviceHandler(TSAIChatDeviceEventRequestStart);
    [self drainMainQueue];
    XCTAssertEqual(self.context.assistant.startCount, 1u);
    XCTAssertEqual(self.context.rejectedRequests, 0u);
}
// 双端真正启动前不请求弹页；SessionStarted 与 InputReady 分别更新状态。
- (void)testPresentationWaitsForSessionStartedAndInputReadyIsSeparate {
    __block NSUInteger presentations = 0;
    id observer = [NSNotificationCenter.defaultCenter addObserverForName:TSAIChatDeviceSessionDidRequestPresentationNotification
        object:self.coordinator queue:nil usingBlock:^(NSNotification *notification) { presentations += 1; }];
    [self emitDeviceStart];
    XCTAssertEqual(presentations, 0u);
    [self emitEvent:TSAIChatEventTypeSessionStarted];
    XCTAssertEqual(presentations, 1u);
    XCTAssertFalse(self.coordinator.isInputReady);
    [self emitEvent:TSAIChatEventTypeInputReady];
    XCTAssertTrue(self.coordinator.isInputReady);
    [NSNotificationCenter.defaultCenter removeObserver:observer];
}
// 解绑时旧任务取消；旧完成事件不能清空新 Context 的任务。
- (void)testOldCompletionCannotClearNewContextTask {
    [self.coordinator startSessionFromApp];
    TSBudsDemoAssistantSpy *oldAssistant = self.context.assistant;
    TSAIChatCompletionBlock oldCompletion = oldAssistant.completionHandler;
    [self.coordinator unbindContext:(id)self.context];
    XCTAssertEqual(oldAssistant.stopCount, 1u);
    NSArray *routes = self.context.routes;
    self.context = [[TSBudsDemoContextSpy alloc] init];
    self.context.routes = routes;
    [self.coordinator bindAuthenticatedContext:(id)self.context];
    [self.coordinator startSessionFromApp];
    NSString *newTask = self.coordinator.currentTaskId;
    oldCompletion(nil, nil);
    [self drainMainQueue];
    XCTAssertEqualObjects(self.coordinator.currentTaskId, newTask);
    XCTAssertNil(self.coordinator.lastError);
}
// 旧绑定排队的唤醒不会在重新绑定后启动任务。
- (void)testQueuedWakeAfterUnbindIsDiscarded {
    self.context.pendingRequest = [self deviceRequest];
    self.context.assistant.deviceHandler(TSAIChatDeviceEventRequestStart);
    [self.coordinator unbindContext:(id)self.context];
    [self.coordinator bindAuthenticatedContext:(id)self.context];
    [self drainMainQueue];
    XCTAssertEqual(self.context.assistant.startCount, 0u);
}
// 输入结束保留回答过程；停止等待真实完成，不能立即开启下一轮。
- (void)testFinishInputAndStopKeepTaskUntilCompletion {
    [self.coordinator startSessionFromApp];
    [self.coordinator finishInputFromApp];
    XCTAssertEqual(self.context.assistant.finishInputCount, 1u);
    XCTAssertTrue(self.coordinator.isSessionActive);
    [self.coordinator stopSessionFromApp];
    [self.coordinator startSessionFromApp];
    XCTAssertEqual(self.context.assistant.startCount, 1u);
    self.context.assistant.completionHandler(nil, nil);
    [self drainMainQueue];
    XCTAssertFalse(self.coordinator.isSessionActive);
}
// 未鉴权不能注册设备启动观察者。
- (void)testUnauthenticatedContextCannotBind {
    [self.coordinator unbindContext:(id)self.context];
    self.context.authenticated = NO;
    [self.coordinator bindAuthenticatedContext:(id)self.context];
    XCTAssertFalse(self.coordinator.isChatInterfaceReady);
    XCTAssertNil(self.context.assistant.deviceHandler);
}

#pragma mark - 私有方法
- (TSAIStartRequest *)deviceRequest {
    TSAIAudioRouteConfiguration *route = [TSAIAudioRouteConfiguration
        configurationWithInputChannel:TSAIAudioInputChannelOpus outputChannel:TSAIAudioOutputChannelA2DP
        routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
    TSAIDeviceCoordination *coordination = [TSAIDeviceCoordination coordinationWithScene:TSAIDeviceAISceneChat
        initiator:TSAISessionInitiatorDevice audioRouteConfiguration:route];
    return [TSAIStartRequest requestWithIdentifier:NSUUID.UUID.UUIDString useCase:TSAIUseCaseChat
        parameters:nil deviceCoordination:coordination];
}
- (void)emitDeviceStart {
    self.context.pendingRequest = [self deviceRequest];
    self.context.assistant.deviceHandler(TSAIChatDeviceEventRequestStart);
    [self drainMainQueue];
}
- (void)emitEvent:(TSAIChatEventType)type {
    TSAIChatEvent *event = [[TSAIChatEvent alloc] init];
    event.taskId = self.context.assistant.taskIdentifier;
    event.eventType = type;
    self.context.assistant.eventHandler(event);
    [self drainMainQueue];
}
- (void)drainMainQueue {
    XCTestExpectation *drained = [self expectationWithDescription:@"Demo main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drained fulfill]; });
    [self waitForExpectations:@[drained] timeout:2.0];
}
@end
#endif
