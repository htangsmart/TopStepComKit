//
//  TSAIAudioRecordSessionStateTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>

#import "../../TopStepComKit-Git/Source/Device/AIKit/AudioRecord/Session/TSAIAudioRecordSessionState.h"

@interface TSAIAudioRecordSessionStateTests : XCTestCase

@end


@implementation TSAIAudioRecordSessionStateTests

/** 验证 App 发起会话的基础状态流转 */
- (void)testAppSessionLifecycle {
    TSAIAudioRecordSessionState *state = [[TSAIAudioRecordSessionState alloc] init];
    NSUInteger generation = [state beginWithSource:TSAIAudioRecordSessionSourceApp
                                              scene:TSAIAudioRecordSceneOnSite];

    XCTAssertEqual(generation, 1u);
    XCTAssertEqual(state.phase, TSAIAudioRecordSessionPhaseStarting);
    XCTAssertTrue([state markStartedForGeneration:generation]);
    XCTAssertEqual(state.phase, TSAIAudioRecordSessionPhaseRecording);
    XCTAssertTrue([state markStopRequestedForGeneration:generation]);
    XCTAssertEqual(state.phase, TSAIAudioRecordSessionPhaseStopping);
    XCTAssertTrue([state markFinalizingForGeneration:generation]);
    XCTAssertTrue([state markCompletedForGeneration:generation]);
    XCTAssertEqual(state.phase, TSAIAudioRecordSessionPhaseCompleted);
}

/** 验证设备回报在单代次内只能消费一次 */
- (void)testDeviceReportsAreConsumedExactlyOnce {
    TSAIAudioRecordSessionState *state = [[TSAIAudioRecordSessionState alloc] init];
    NSUInteger generation = [state beginWithSource:TSAIAudioRecordSessionSourceDevice
                                              scene:TSAIAudioRecordSceneCall];

    XCTAssertTrue([state consumeStartReportForGeneration:generation]);
    XCTAssertFalse([state consumeStartReportForGeneration:generation]);
    XCTAssertTrue([state consumeStopReportForGeneration:generation]);
    XCTAssertFalse([state consumeStopReportForGeneration:generation]);
}

/** 验证过期代次不能改变当前会话 */
- (void)testStaleGenerationIsIgnored {
    TSAIAudioRecordSessionState *state = [[TSAIAudioRecordSessionState alloc] init];
    NSUInteger firstGeneration = [state beginWithSource:TSAIAudioRecordSessionSourceApp
                                                   scene:TSAIAudioRecordSceneOnSite];
    XCTAssertTrue([state markFailedForGeneration:firstGeneration]);
    NSUInteger currentGeneration = [state beginWithSource:TSAIAudioRecordSessionSourceApp
                                                     scene:TSAIAudioRecordSceneOnSite];

    XCTAssertNotEqual(firstGeneration, currentGeneration);
    XCTAssertFalse([state markStartedForGeneration:firstGeneration]);
    XCTAssertEqual(state.phase, TSAIAudioRecordSessionPhaseStarting);
}

/** 验证音频流结束与语义 Finish 是两个独立信号 */
- (void)testAudioAndSemanticFinishAreIndependent {
    TSAIAudioRecordSessionState *state = [[TSAIAudioRecordSessionState alloc] init];
    NSUInteger generation = [state beginWithSource:TSAIAudioRecordSessionSourceApp
                                              scene:TSAIAudioRecordSceneOnSite];
    XCTAssertTrue([state markStartedForGeneration:generation]);
    XCTAssertTrue([state markAudioStreamFinishedWithReason:TSAudioRecordStopReasonUserInitiated
                                                 generation:generation]);

    XCTAssertTrue(state.hasAudioStreamFinished);
    XCTAssertFalse(state.hasSessionFinished);
    XCTAssertTrue([state markSessionFinishedForGeneration:generation]);
    XCTAssertTrue(state.hasSessionFinished);
}

@end
