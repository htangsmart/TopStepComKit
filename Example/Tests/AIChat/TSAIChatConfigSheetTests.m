//
//  TSAIChatConfigSheetTests.m
//  TopStepComKit-Git_Tests
//
//  Created by Codex on 2026/10/28.
//

#import <XCTest/XCTest.h>

#import <TopStepAIKit/TSAIChatAudioProcessingConfiguration.h>
#import <TopStepAIKit/TSAIChatConfig.h>

#import "../../TopStepComKit-Git/Source/Device/AIKit/Assistant/Chat/TSAIChatConfigSheet.h"

// 只在测试中读取编辑快照，不增加正式公开接口。
@interface TSAIChatConfigSheet (AudioProcessingTests)

@property (nonatomic, strong, readonly) TSAIChatConfig *editingConfig;

@end

@interface TSAIChatConfigSheetTests : XCTestCase

@end

@implementation TSAIChatConfigSheetTests

#pragma mark - 公开方法

// 打开配置表不能共享调用方的可变处理偏好，取消后外部配置仍保持原值。
- (void)testEditingSnapshotDoesNotMutateCallerProcessingPreferences {
    TSAIChatConfig *original = [TSAIChatConfig defaultConfig];
    original.audioProcessingConfiguration = [TSAIChatAudioProcessingConfiguration defaultConfiguration];
    original.audioProcessingConfiguration.echoControlPolicy = TSAIChatEchoControlPolicyRequireAEC;
    TSAIChatConfigSheet *sheet = [[TSAIChatConfigSheet alloc] initWithConfig:original];

    sheet.editingConfig.audioProcessingConfiguration.echoControlPolicy = TSAIChatEchoControlPolicyAutomatic;
    sheet.editingConfig.audioProcessingConfiguration.speechDetectionSensitivity = TSAIChatSpeechDetectionSensitivityLow;

    XCTAssertEqual(original.audioProcessingConfiguration.echoControlPolicy, TSAIChatEchoControlPolicyRequireAEC);
    XCTAssertEqual(original.audioProcessingConfiguration.speechDetectionSensitivity,
                   TSAIChatSpeechDetectionSensitivityNormal);
}

// 复制表单快照时不能丢失当前没有控件的会话边界和单轮参数。
- (void)testEditingSnapshotPreservesHiddenSessionBoundaries {
    TSAIChatConfig *original = [TSAIChatConfig defaultConfig];
    original.conversationMode = TSAIChatConversationModeSingleRound;
    original.endsInputOnSilence = NO;
    original.maximumInputDuration = 12.0;
    original.roundIdleTimeout = 0;
    original.expectedDeviceRequestIdentifier = @"expected-device-request";
    original.opensDeviceChatSession = YES;
    TSAIChatConfigSheet *sheet = [[TSAIChatConfigSheet alloc] initWithConfig:original];

    XCTAssertEqual(sheet.editingConfig.conversationMode, TSAIChatConversationModeSingleRound);
    XCTAssertFalse(sheet.editingConfig.endsInputOnSilence);
    XCTAssertEqual(sheet.editingConfig.maximumInputDuration, 12.0);
    XCTAssertEqual(sheet.editingConfig.roundIdleTimeout, 0);
    XCTAssertTrue(sheet.editingConfig.opensDeviceChatSession);
    XCTAssertEqualObjects(sheet.editingConfig.expectedDeviceRequestIdentifier, @"expected-device-request");
}

// nil 初始配置仍采用现有默认会话，处理偏好交由 SDK 启动时解析。
- (void)testNilInitialConfigurationKeepsDefaultProcessingRequest {
    TSAIChatConfigSheet *sheet = [[TSAIChatConfigSheet alloc] initWithConfig:nil];

    XCTAssertNotNil(sheet.editingConfig);
    XCTAssertNil(sheet.editingConfig.audioProcessingConfiguration);
    XCTAssertTrue(sheet.editingConfig.enableVoiceOutput);
}

@end
