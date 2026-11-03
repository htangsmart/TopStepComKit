//
//  TSAIChatAuthorizationTests.m
//  TopStepComKit-Git_Tests
//
//  Created by Codex on 2026/10/29.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "../../TopStepComKit-Git/Source/Device/AIKit/Assistant/Aurora/TSAIChatRoundModel.h"
#import "../../TopStepComKit-Git/Source/Device/AIKit/Assistant/Session/TSAIChatDeviceSessionCoordinator.h"
#import "../../TopStepComKit-Git/Source/Device/AIKit/Assistant/TSAIChatVC.h"

@interface TSAIChatVC (AuthorizationTests)
- (void)beginVoiceRound;
- (void)sendTextQuestion:(NSString *)text;
- (void)startFlowSession;
- (void)showAIErrorBanner:(NSError *)error;
- (BOOL)ensureMicrophonePermissionForVoiceRound;
- (TSAIChatRoundModel *)appendRoundWithSource:(TSAIChatRoundSource)source;
- (void)refreshUI;
- (void)refreshRound:(TSAIChatRoundModel *)round;
- (void)handleChatCompletionWithReport:(TSAIChatReport *)report error:(NSError *)error;
- (void)exitVoiceRecordingWithOutcome:(NSString *)outcome releaseUptime:(NSTimeInterval)releaseUptime;
@end

// 只替换展示边界，不加载页面或弹系统麦克风权限；三个生产入口照常执行。
@interface TSAIChatAuthorizationVC : TSAIChatVC
@property (nonatomic, strong) NSError *displayedError;
@property (nonatomic, strong) TSAIChatRoundModel *displayedRound;
@property (nonatomic, assign) NSUInteger microphonePermissionRequestCount;
@property (nonatomic, assign) NSUInteger refreshCount;
@end

@implementation TSAIChatAuthorizationVC
- (void)showAIErrorBanner:(NSError *)error {
    self.displayedError = error;
}
- (BOOL)ensureMicrophonePermissionForVoiceRound {
    self.microphonePermissionRequestCount += 1;
    return NO;
}
- (TSAIChatRoundModel *)appendRoundWithSource:(TSAIChatRoundSource)source {
    self.displayedRound = [TSAIChatRoundModel roundWithSource:source];
    [self setValue:self.displayedRound forKey:@"currentRound"];
    return self.displayedRound;
}
- (void)refreshUI {
    self.refreshCount += 1;
}
- (void)refreshRound:(TSAIChatRoundModel *)round {
    self.displayedRound = round;
}
- (void)exitVoiceRecordingWithOutcome:(NSString *)outcome releaseUptime:(NSTimeInterval)releaseUptime {
    self.refreshCount += 1;
}
@end

// 测试只替换外部 Context/Assistant 边界，执行真实协调器和错误模型。
@interface TSAIChatDeviceSessionCoordinator (AuthorizationTests)
- (instancetype)initPrivate;
- (TSAIContext *)currentAIContext;
- (void)handleCompletionWithReport:(TSAIChatReport *)report error:(NSError *)error generation:(NSUInteger)generation;
@end

@interface TSAIChatAuthorizationAssistant : NSObject
@property (nonatomic, assign) NSUInteger startCount;
@property (nonatomic, assign) NSUInteger stopCount;
@property (nonatomic, copy) NSString *returnedTaskIdentifier;
@property (nonatomic, copy) TSAIChatCompletionBlock completion;
@property (nonatomic, copy) void (^deviceEventHandler)(TSAIChatDeviceEvent event);
@end

@implementation TSAIChatAuthorizationAssistant

// 记录事件绑定，不接触设备或麦克风。
- (void)registerOnAIChatDeviceEvent:(void (^)(TSAIChatDeviceEvent event))handler {
    self.deviceEventHandler = handler;
}

// 保存回调，允许测试控制完成顺序和错误身份。
- (NSString *)startChatWithConfig:(TSAIChatConfig *)config onContent:(TSAIChatContentBlock)content
                          onEvent:(TSAIChatEventBlock)event completion:(TSAIChatCompletionBlock)completion {
    self.startCount += 1;
    self.completion = completion;
    return self.returnedTaskIdentifier;
}

// 停止确认由测试显式提供，用于检查清理前不能发布终态。
- (void)stopChatWithTaskId:(NSString *)taskId {
    self.stopCount += 1;
}
@end

@interface TSAIChatAuthorizationContext : NSObject
@property (nonatomic, assign) TSAIContextState state;
@property (nonatomic, assign) TSAIAuthorizationState authorizationState;
@property (nonatomic, strong) id assistant;
@property (nonatomic, copy) NSString *contextIdentifier;
@end
@implementation TSAIChatAuthorizationContext
@end

@interface TSAIChatAuthorizationCoordinator : TSAIChatDeviceSessionCoordinator
@property (nonatomic, strong) TSAIChatAuthorizationContext *testContext;
@end

@implementation TSAIChatAuthorizationCoordinator

// 避免测试修改进程级单例；生产初始化逻辑仍完整执行。
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return class_createInstance(self, 0);
}

// 注入无硬件 Context，生产类仍使用 TSAIKit 的当前 Context。
- (TSAIContext *)currentAIContext {
    return (TSAIContext *)self.testContext;
}
@end

@interface TSAIChatAuthorizationTests : XCTestCase
@property (nonatomic, strong) TSAIChatAuthorizationCoordinator *coordinator;
@property (nonatomic, strong) TSAIChatAuthorizationContext *context;
@property (nonatomic, strong) TSAIChatAuthorizationAssistant *assistant;
@end

@implementation TSAIChatAuthorizationTests

#pragma mark - 生命周期

// 每个用例使用独立协调器和完成代次。
- (void)setUp {
    [super setUp];
    self.assistant = [[TSAIChatAuthorizationAssistant alloc] init];
    self.assistant.returnedTaskIdentifier = @"authorization-test-task";
    self.context = [[TSAIChatAuthorizationContext alloc] init];
    self.context.state = TSAIContextStateActive;
    self.context.authorizationState = TSAIAuthorizationStateAuthenticated;
    self.context.assistant = self.assistant;
    self.context.contextIdentifier = NSUUID.UUID.UUIDString;
    self.coordinator = [[TSAIChatAuthorizationCoordinator alloc] initPrivate];
    self.coordinator.testContext = self.context;
}

// 清除尚未触发的兜底计时器和假任务。
- (void)tearDown {
    NSUInteger generation = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    [self.coordinator handleCompletionWithReport:nil error:nil generation:generation];
    self.assistant.completion = nil;
    self.coordinator = nil;
    [super tearDown];
}

#pragma mark - 公开方法

// 尚未绑定 Assistant 的首次鉴权必须明确拒绝，不能向 nil 发送启动消息。
- (void)testUnauthenticatedStatesNeverStartAssistant {
    for (NSNumber *state in @[@(TSAIAuthorizationStateUnknown), @(TSAIAuthorizationStateAuthenticating),
                             @(TSAIAuthorizationStateFailed), @(TSAIAuthorizationStateDisconnected)]) {
        self.context.authorizationState = state.integerValue;
        [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
        XCTAssertEqual(self.coordinator.lastError.code, TSAIErrorCodeAuthorizationRequired);
        XCTAssertEqualObjects(self.coordinator.lastError.localizedDescription, @"AI 未鉴权");
        XCTAssertEqual(self.assistant.startCount, 0u);
        XCTAssertFalse(self.coordinator.isInputReady);
        XCTAssertFalse(self.coordinator.isSessionActive);
    }
}

// Context 尚未出现也不能报“空任务 ID”。
- (void)testMissingContextReportsAuthorizationRequired {
    self.coordinator.testContext = nil;
    XCTAssertEqual(self.coordinator.startAvailabilityError.code, TSAIErrorCodeAuthorizationRequired);
}

// 鉴权已完成但服务缺失时保留服务错误，不伪装成鉴权失败。
- (void)testAuthenticatedMissingAssistantReportsProviderUnavailable {
    self.context.assistant = nil;
    XCTAssertEqual(self.coordinator.startAvailabilityError.code, TSAIErrorCodeProviderUnavailable);
}

// 重新检查后状态已变也必须在真正启动前拒绝。
- (void)testAuthorizationLostBetweenPreflightAndStart {
    XCTAssertNil(self.coordinator.startAvailabilityError);
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    XCTAssertEqual(self.assistant.startCount, 0u);
    XCTAssertEqual(self.coordinator.lastError.code, TSAIErrorCodeAuthorizationRequired);
}

// 空任务标识后的原始异步错误必须保留，不能抢先合成为 InvalidResponse。
- (void)testEmptyTaskRetainsOriginalAsynchronousError {
    self.assistant.returnedTaskIdentifier = nil;
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    XCTAssertNil(self.coordinator.lastError);
    NSError *underlying = [NSError errorWithDomain:@"VendorAuthorization" code:401
        userInfo:@{NSLocalizedDescriptionKey: @"rejected"}];
    NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeAuthorizationRejected
        userInfo:@{NSLocalizedDescriptionKey: @"original authorization rejection", NSUnderlyingErrorKey: underlying}];
    XCTestExpectation *completed = [self expectationForNotification:TSAIChatDeviceSessionDidCompleteNotification
        object:self.coordinator handler:nil];
    self.assistant.completion(nil, error);
    [self waitForExpectations:@[completed] timeout:1];
    XCTAssertEqual(self.coordinator.lastError, error);
    XCTAssertEqual(self.coordinator.lastError.userInfo[NSUnderlyingErrorKey], underlying);
}

// 同一代次重复完成不能发出第二个通知，也不能覆盖第一次错误。
- (void)testDuplicateCompletionCannotReplaceOriginalError {
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    NSUInteger generation = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    NSError *original = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeNetworkUnavailable userInfo:nil];
    __block NSUInteger completionCount = 0;
    id observer = [NSNotificationCenter.defaultCenter addObserverForName:TSAIChatDeviceSessionDidCompleteNotification
        object:self.coordinator queue:nil usingBlock:^(NSNotification *notification) { completionCount += 1; }];
    [self.coordinator handleCompletionWithReport:nil error:original generation:generation];
    [self.coordinator handleCompletionWithReport:nil error:nil generation:generation];
    [NSNotificationCenter.defaultCenter removeObserver:observer];
    XCTAssertEqual(completionCount, 1u);
    XCTAssertEqual(self.coordinator.lastError, original);
}

// 会话内鉴权失效要等真实停止确认，并保留鉴权原因而不是普通取消。
- (void)testAuthorizationLossWaitsForCleanupAndSurvivesCancellation {
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    [self.coordinator authorizationDidChangeForContext:(TSAIContext *)self.context];
    XCTAssertEqual(self.assistant.stopCount, 1u);
    XCTAssertNotNil(self.coordinator.currentTaskId);
    XCTAssertNil(self.coordinator.lastError);
    NSUInteger generation = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    NSError *cancelled = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeCancelled userInfo:nil];
    [self.coordinator handleCompletionWithReport:nil error:cancelled generation:generation];
    XCTAssertEqual(self.coordinator.lastError.code, TSAIErrorCodeAuthorizationRequired);
    XCTAssertNil(self.coordinator.currentTaskId);
}

// SDK 完成先于 AppDelegate 转发鉴权通知时，也不能把鉴权失效显示为普通取消。
- (void)testCancellationBeforeAuthorizationRelayStillReportsAuthorizationRequired {
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    NSError *cancelled = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeCancelled userInfo:nil];
    NSUInteger generation = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    [self.coordinator handleCompletionWithReport:nil error:cancelled generation:generation];
    XCTAssertEqual(self.coordinator.lastError.code, TSAIErrorCodeAuthorizationRequired);
    XCTAssertEqual(self.coordinator.lastError.userInfo[NSUnderlyingErrorKey], cancelled);
}

// 鉴权引起停止但清理失败时，必须保留清理失败本身。
- (void)testCleanupFailureIsNotOverwrittenByAuthorizationState {
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    [self.coordinator authorizationDidChangeForContext:(TSAIContext *)self.context];
    NSError *cleanup = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeTimeout userInfo:nil];
    NSUInteger generation = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    [self.coordinator handleCompletionWithReport:nil error:cleanup generation:generation];
    XCTAssertEqual(self.coordinator.lastError, cleanup);
}

// 旧设备鉴权失败通知不能停止当前设备的会话。
- (void)testOldContextAuthorizationChangeIsIgnored {
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    TSAIChatAuthorizationContext *oldContext = [[TSAIChatAuthorizationContext alloc] init];
    oldContext.authorizationState = TSAIAuthorizationStateFailed;
    [self.coordinator authorizationDidChangeForContext:(TSAIContext *)oldContext];
    XCTAssertEqual(self.assistant.stopCount, 0u);
    XCTAssertNotNil(self.coordinator.currentTaskId);
}

// 鉴权成功只恢复资格，不自动发送先前的问题或新建会话。
- (void)testAuthorizationRecoveryDoesNotAutomaticallyStartChat {
    self.context.authorizationState = TSAIAuthorizationStateAuthenticating;
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    self.context.authorizationState = TSAIAuthorizationStateAuthenticated;
    [self.coordinator authorizationDidChangeForContext:(TSAIContext *)self.context];
    XCTAssertNil(self.coordinator.startAvailabilityError);
    XCTAssertEqual(self.assistant.startCount, 0u);
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    XCTAssertEqual(self.assistant.startCount, 1u);
}

// 上一代次迟到的成功不能清空当前错误。
- (void)testOldCompletionDoesNotOverwriteNewGenerationFailure {
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    NSUInteger previous = [[self.coordinator valueForKeyPath:@"sessionState.generation"] unsignedIntegerValue];
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    NSError *current = self.coordinator.lastError;
    [self.coordinator handleCompletionWithReport:nil error:nil generation:previous];
    XCTAssertEqual(self.coordinator.lastError, current);
}

// 原问题与 NSError 身份及底层错误都不因展示分类丢失。
- (void)testTextAuthorizationFailurePreservesQuestionAndOriginalError {
    TSAIChatRoundModel *round = [TSAIChatRoundModel roundWithSource:TSAIChatRoundSourceText];
    round.question = @"今天天气怎么样？";
    NSError *underlying = [NSError errorWithDomain:@"Vendor" code:401 userInfo:nil];
    NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeAuthorizationRejected
        userInfo:@{NSUnderlyingErrorKey: underlying}];
    [round failWithError:error];
    XCTAssertEqualObjects(round.question, @"今天天气怎么样？");
    XCTAssertEqual(round.error, error);
    XCTAssertEqual(round.error.userInfo[NSUnderlyingErrorKey], underlying);
    XCTAssertEqualObjects(round.errorText, @"AI 未鉴权");
    XCTAssertFalse([round.errorBodyText containsString:@"没听清"]);
}

// 文字、语音共用错误分类；网络、播放、超时均不能被解释成没听清。
- (void)testServiceFailuresNeverUseMissingSpeechCopyForEitherSource {
    for (NSNumber *source in @[@(TSAIChatRoundSourceText), @(TSAIChatRoundSourceVoice)]) {
        for (NSNumber *code in @[@(TSAIErrorCodeAuthorizationRequired), @(TSAIErrorCodeNetworkUnavailable),
                                @(TSAIErrorCodeAudioRouteUnavailable), @(TSAIErrorCodeTimeout),
                                @(TSAIErrorCodeInvalidResponse), @(TSAIErrorCodeProviderUnavailable)]) {
            TSAIChatRoundModel *round = [TSAIChatRoundModel roundWithSource:source.integerValue];
            NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:code.integerValue userInfo:nil];
            [round failWithError:error];
            XCTAssertFalse([round.errorBodyText containsString:@"没听清"]);
            XCTAssertFalse([round.errorBodyText containsString:@"按住"]);
            XCTAssertEqual(round.error, error);
        }
    }
}

// 保留启动时的鉴权快照建议，不能在稍后成功后改写这次失败原因。
- (void)testAuthorizationRecoverySuggestionIsRetained {
    NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeAuthorizationRequired
        userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"AI 正在鉴权，请稍候。"}];
    XCTAssertEqualObjects([TSAIChatRoundModel errorBodyForError:error], @"AI 正在鉴权，请稍候。");
}

// 真实文字入口在鉴权中直接保留失败轮及原问题，不等待一个永远不会开始的 SessionStarted。
- (void)testTextEntryKeepsQuestionWhenAuthorizationIsPending {
    self.context.authorizationState = TSAIAuthorizationStateAuthenticating;
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    [controller sendTextQuestion:@"今天天气怎么样？"];
    XCTAssertEqualObjects(controller.displayedRound.question, @"今天天气怎么样？");
    XCTAssertEqual(controller.displayedRound.error.code, TSAIErrorCodeAuthorizationRequired);
    XCTAssertEqualObjects(controller.displayedRound.errorText, @"AI 未鉴权");
    XCTAssertEqual(self.assistant.startCount, 0u);
    XCTAssertFalse(controller.isViewLoaded);
}

// 真实语音入口必须在请求系统录音权限或进入准备态之前拦截鉴权失败。
- (void)testVoiceEntryRejectsBeforeMicrophonePermissionOrRecording {
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    [controller beginVoiceRound];
    XCTAssertEqual(controller.displayedError.code, TSAIErrorCodeAuthorizationRequired);
    XCTAssertEqual(controller.microphonePermissionRequestCount, 0u);
    XCTAssertNil(controller.displayedRound);
    XCTAssertEqual(self.assistant.startCount, 0u);
    XCTAssertFalse(controller.isViewLoaded);
}

// 真实畅聊入口不清除原有问题记录，不进入连接或收听态。
- (void)testFlowEntryRejectsBeforeClearingExistingQuestions {
    self.context.authorizationState = TSAIAuthorizationStateFailed;
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    NSMutableArray *history = [NSMutableArray arrayWithObject:
        [TSAIChatRoundModel roundWithSource:TSAIChatRoundSourceVoice]];
    [controller setValue:history forKey:@"flowRounds"];
    [controller startFlowSession];
    XCTAssertEqual(history.count, 1u);
    XCTAssertEqual(controller.displayedError.code, TSAIErrorCodeAuthorizationRequired);
    XCTAssertEqual(self.assistant.startCount, 0u);
    XCTAssertFalse(controller.isViewLoaded);
}

// 接口异常不回调时有明确兜底；兜底不会带入拾音提示。
- (void)testMissingTaskWithoutCompletionHasBoundedFailure {
    self.assistant.returnedTaskIdentifier = nil;
    [self.coordinator startSessionFromAppWithConfig:[TSAIChatConfig defaultConfig]];
    NSTimer *timer = [self.coordinator valueForKey:@"missingTaskCompletionTimer"];
    XCTAssertNotNil(timer);
    [timer fire];
    XCTAssertEqual(self.coordinator.lastError.code, TSAIErrorCodeInvalidResponse);
    XCTAssertFalse(self.coordinator.isSessionActive);
    XCTAssertFalse([[TSAIChatRoundModel errorBodyForError:self.coordinator.lastError] containsString:@"没听清"]);
}

// 启动阶段标记不能把真实鉴权错误误分类为麦克风启动失败。
- (void)testVoiceCompletionPreservesAuthorizationErrorEvenWithAudioStartupMarker {
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    TSAIChatRoundModel *round = [controller appendRoundWithSource:TSAIChatRoundSourceVoice];
    round.state = TSAIChatRoundStateRecognizing;
    round.question = @"原问题";
    NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeAuthorizationRequired
        userInfo:@{@"audioFailurePhase": @"start"}];
    [controller handleChatCompletionWithReport:nil error:error];
    XCTAssertEqual(round.error, error);
    XCTAssertEqualObjects(round.errorText, @"AI 未鉴权");
    XCTAssertEqualObjects(round.question, @"原问题");
    XCTAssertFalse([round.errorBodyText containsString:@"没听清"]);
    XCTAssertFalse(controller.isViewLoaded);
}

// 没有 InputReady 的语音结束不能归因于用户没说清。
- (void)testVoiceCompletionBeforeInputReadyNeverUsesMissingSpeechCopy {
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    TSAIChatRoundModel *round = [controller appendRoundWithSource:TSAIChatRoundSourceVoice];
    round.state = TSAIChatRoundStateRecognizing;
    [controller handleChatCompletionWithReport:nil error:nil];
    XCTAssertFalse([round.errorBodyText containsString:@"没听清"]);
}

// 真正已就绪且没有有效语音时，仍保留准确的无语音提示。
- (void)testReadyVoiceWithNoRecognitionRetainsMissingSpeechPrompt {
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    [controller setValue:@100 forKey:@"voiceInputReadyUptime"];
    TSAIChatRoundModel *round = [controller appendRoundWithSource:TSAIChatRoundSourceVoice];
    round.state = TSAIChatRoundStateRecognizing;
    [controller handleChatCompletionWithReport:nil error:nil];
    XCTAssertTrue([round.errorBodyText containsString:@"没听清"]);
    XCTAssertEqual(round.state, TSAIChatRoundStateError);
}

// 切换模式请求停止后，真实鉴权失败仍写回原问题，不能被“主动丢弃”分支吞掉。
- (void)testModeSwitchCompletionRetainsAuthorizationFailureAndOriginalQuestion {
    TSAIChatAuthorizationVC *controller = [[TSAIChatAuthorizationVC alloc] init];
    [controller setValue:self.coordinator forKey:@"coordinator"];
    [controller setValue:@YES forKey:@"discardingRound"];
    TSAIChatRoundModel *round = [controller appendRoundWithSource:TSAIChatRoundSourceText];
    round.question = @"今天天气怎么样？";
    NSError *error = [NSError errorWithDomain:TSAIErrorDomain code:TSAIErrorCodeAuthorizationRequired userInfo:nil];
    [controller handleChatCompletionWithReport:nil error:error];
    XCTAssertEqual(round.error, error);
    XCTAssertEqualObjects(round.question, @"今天天气怎么样？");
    XCTAssertEqualObjects(round.errorText, @"AI 未鉴权");
}

@end
