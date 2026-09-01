//  TopStepComKit-GitTests.m
//  TopStepComKit-GitTests
//
//  Created by rd@hetangsmart.com on 05/08/2025.
//  Copyright (c) 2025 rd@hetangsmart.com. All rights reserved.
//

@import XCTest;

#import "../TopStepComKit-Git/Source/Device/AIKit/Assistant/Session/TSAIChatDeviceSessionState.h"
#import "../TopStepComKit-Git/Source/Ble/TSDeviceCoordinator.h"

@interface TSAIChatDeviceSessionStateTests : XCTestCase

@end

@interface TSDeviceConnectionSnapshotTests : XCTestCase

@end

@implementation TSDeviceConnectionSnapshotTests

/** 验证业务就绪必须同时满足 SDK、BLE、设备和会话准备条件 */
- (void)testReadyRequiresAllConnectionLayers {
    TSDeviceConnectionSnapshot *snapshot =
        [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateReady
                                            activeSDKType:eTSSDKTypeFIT
                                          connectionState:eTSBleStateConnected
                                               peripheral:[[TSPeripheral alloc] init]
                                                    error:nil
                                               hasBinding:YES
                                             sessionReady:YES
                                     connectionGeneration:1];

    XCTAssertTrue(snapshot.isReady);
    TSDeviceConnectionSnapshot *unpreparedSnapshot =
        [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateReady
                                            activeSDKType:eTSSDKTypeFIT
                                          connectionState:eTSBleStateConnected
                                               peripheral:snapshot.peripheral
                                                    error:nil
                                               hasBinding:YES
                                             sessionReady:NO
                                     connectionGeneration:1];
    XCTAssertFalse(unpreparedSnapshot.isReady);
}

/** 验证 SDK 初始化和 BLE 认证阶段都属于页面过渡态 */
- (void)testTransitioningIncludesSDKAndConnectionStates {
    TSDeviceConnectionSnapshot *snapshot =
        [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateInitializing
                                            activeSDKType:eTSSDKTypeFIT
                                          connectionState:eTSBleStateDisconnected
                                               peripheral:nil
                                                    error:nil
                                               hasBinding:NO
                                             sessionReady:NO
                                     connectionGeneration:0];
    XCTAssertTrue(snapshot.isTransitioning);

    TSDeviceConnectionSnapshot *authenticatingSnapshot =
        [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateReady
                                            activeSDKType:eTSSDKTypeFIT
                                          connectionState:eTSBleStateAuthenticating
                                               peripheral:nil
                                                    error:nil
                                               hasBinding:NO
                                             sessionReady:NO
                                     connectionGeneration:0];
    XCTAssertTrue(authenticatingSnapshot.isTransitioning);
}

@end

@implementation TSAIChatDeviceSessionStateTests

/** 验证活动代次内只接受一次设备启动请求 */
- (void)testDeviceStartAcceptsOnlyOneRequestPerActiveGeneration {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;

    XCTAssertTrue([state beginDeviceStartWithGeneration:&generation]);
    XCTAssertEqual(generation, 1u);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseStartRequested);
    XCTAssertFalse([state beginDeviceStartWithGeneration:NULL]);
    XCTAssertEqual(state.generation, 1u);
}

/** 验证仅当前代次可转换为活动会话 */
- (void)testSessionStartedTransitionsOnlyMatchingGenerationToActive {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;
    [state beginDeviceStartWithGeneration:&generation];

    XCTAssertFalse([state markAIStartedForGeneration:generation + 1]);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseStartRequested);
    XCTAssertTrue([state markAIStartedForGeneration:generation]);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseActive);
}

/** 验证启动失败不重复建单且最多重试一次 */
- (void)testStartFailureReportIsExactlyOnceAndRetriesOnlyOnce {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;
    [state beginDeviceStartWithGeneration:&generation];

    TSAIChatDeviceSessionReportRequest *firstRequest =
        [state prepareStartFailureWithOrigin:TSAIChatDeviceSessionEndOriginRuntimeError
                                  generation:generation];
    XCTAssertNotNil(firstRequest);
    XCTAssertEqual(firstRequest.attempt, 1u);
    XCTAssertNil([state prepareStartFailureWithOrigin:TSAIChatDeviceSessionEndOriginRuntimeError
                                           generation:generation]);

    TSAIChatDeviceSessionReportRequest *retryRequest =
        [state completeReport:firstRequest success:NO];
    XCTAssertEqual(retryRequest.attempt, 2u);
    XCTAssertNil([state completeReport:retryRequest success:YES]);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseTerminated);
}

/** 验证第二次回报失败后停止重试 */
- (void)testFailedSecondReportStopsRetrying {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;
    [state beginDeviceStartWithGeneration:&generation];
    TSAIChatDeviceSessionReportRequest *firstRequest =
        [state prepareStartFailureWithOrigin:TSAIChatDeviceSessionEndOriginRuntimeError
                                  generation:generation];

    TSAIChatDeviceSessionReportRequest *retryRequest =
        [state completeReport:firstRequest success:NO];
    XCTAssertNil([state completeReport:retryRequest success:NO]);
    XCTAssertEqual(state.reportAttempts, 2u);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseReportFailed);
}

/** 验证 App 仅能终止已启动的云端会话 */
- (void)testAppTerminationIsPreparedOnlyAfterCloudSessionStarted {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;
    [state beginDeviceStartWithGeneration:&generation];

    XCTAssertNil([state prepareTerminationWithOrigin:TSAIChatDeviceSessionEndOriginApp
                                          generation:generation]);
    [state markAIStartedForGeneration:generation];
    TSAIChatDeviceSessionReportRequest *request =
        [state prepareTerminationWithOrigin:TSAIChatDeviceSessionEndOriginApp
                                 generation:generation];
    XCTAssertEqual(request.kind, TSAIChatDeviceSessionReportKindTermination);
    XCTAssertEqual(request.origin, TSAIChatDeviceSessionEndOriginApp);
}

/** 验证设备主动关闭后不再回报 App 终止 */
- (void)testDeviceCloseSuppressesAppTerminationReport {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger generation = 0;
    [state beginDeviceStartWithGeneration:&generation];
    [state markAIStartedForGeneration:generation];

    [state markClosedByDeviceWithOrigin:TSAIChatDeviceSessionEndOriginDevice];

    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseClosedByDevice);
    XCTAssertNil([state prepareTerminationWithOrigin:TSAIChatDeviceSessionEndOriginApp
                                          generation:generation]);
}

/** 验证无活动会话时的解绑不改变空闲状态 */
- (void)testCloseWithoutOpenSessionKeepsIdleState {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];

    [state markClosedByDeviceWithOrigin:TSAIChatDeviceSessionEndOriginBleDisconnected];

    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseIdle);
    XCTAssertEqual(state.origin, TSAIChatDeviceSessionEndOriginNone);
}

/** 验证已完成的代次不阻塞下一次设备请求 */
- (void)testCompletedGenerationAllowsNextDeviceRequest {
    TSAIChatDeviceSessionState *state = [[TSAIChatDeviceSessionState alloc] init];
    NSUInteger firstGeneration = 0;
    [state beginDeviceStartWithGeneration:&firstGeneration];
    TSAIChatDeviceSessionReportRequest *request =
        [state prepareStartFailureWithOrigin:TSAIChatDeviceSessionEndOriginRuntimeError
                                  generation:firstGeneration];
    [state completeReport:request success:YES];

    NSUInteger nextGeneration = 0;
    XCTAssertTrue([state beginDeviceStartWithGeneration:&nextGeneration]);
    XCTAssertEqual(nextGeneration, firstGeneration + 1);
    XCTAssertEqual(state.phase, TSAIChatDeviceSessionPhaseStartRequested);
}

@end
