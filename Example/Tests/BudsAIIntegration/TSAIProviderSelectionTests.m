#import <XCTest/XCTest.h>
#import "../../TopStepComKit-Git/Source/Device/AIKit/Configuration/TSAIProviderSelection.h"

#if TS_BUDS_AI_INTEGRATION_AVAILABLE
#import <TopStepAIKit/TSAIBudsConfiguration.h>
#import <TopStepAIKit/TSAIWoQiConfiguration.h>
#import <TopStepInterfaceKit/TSPeripheralConnectParam.h>

@interface TSAIProviderSelection (Testing)
- (NSError *)validationError;
@end

@interface TSAIProviderSelectionTests : XCTestCase
@end

@implementation TSAIProviderSelectionTests

// 配置来源和读取副本均不可变更已创建的选择，平台不随 Provider 变化。
- (void)testSelectionFreezesProviderConfiguration {
    TSAIBudsConfiguration *configuration = [TSAIBudsConfiguration configurationWithPreferredVendor:TSAIBudsVendorTypeStarBurst];
    configuration.starBurstAuthSDK = @4;
    configuration.starBurstProductId = @"original-product";
    TSAIProviderSelection *selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIBuds
        configuration:configuration];
    configuration.starBurstProductId = @"changed-product";
    TSAIBudsConfiguration *readCopy = (id)selection.providerConfiguration;
    XCTAssertEqualObjects(readCopy.starBurstProductId, @"original-product");
    readCopy.starBurstProductId = @"changed-read-copy";
    TSAIContextConfiguration *context = selection.contextConfiguration;
    XCTAssertEqualObjects(context.platformIdentifier, TSAIPlatformIdentifierBuds);
    XCTAssertEqual(context.providerType, TSAIProviderTypeAIBuds);
    XCTAssertEqualObjects([(TSAIBudsConfiguration *)context.providerConfiguration starBurstProductId], @"original-product");
}

// 空配置、组合厂商和无效 SDK 模式必须在连接前被识别。
- (void)testAIBudsSelectionRequiresExactExplicitConfiguration {
    TSAIBudsConfiguration *configuration = [TSAIBudsConfiguration configurationWithPreferredVendor:TSAIBudsVendorTypeStarBurst];
    TSAIProviderSelection *selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIBuds
        configuration:configuration];
    XCTAssertNotNil([selection validationError]);
    configuration.starBurstProductId = @"product";
    configuration.starBurstAuthSDK = @4.5;
    selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIBuds configuration:configuration];
    XCTAssertNotNil([selection validationError]);
    configuration.starBurstAuthSDK = @4;
    selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIBuds configuration:configuration];
    XCTAssertNil([selection validationError]);
    configuration.preferredVendor = TSAIBudsVendorTypeAll;
    selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIBuds configuration:configuration];
    XCTAssertNotNil([selection validationError]);
}

// WoQi 仅交给 AI Provider；连接参数中不能出现云端凭证或厂商选择。
- (void)testWoQiDoesNotAddNativeAuthenticationParameters {
    TSAIWoQiConfiguration *configuration = [[TSAIWoQiConfiguration alloc] init];
    configuration.appKey = @"fixture-key";
    configuration.appSecret = @"fixture-secret";
    TSAIProviderSelection *selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIWoQi
        configuration:configuration];
    XCTAssertNil([selection validationError]);
    TSPeripheralConnectParam *parameters = [TSPeripheralConnectParam paramWithUserId:@"fixture-user"];
    XCTAssertNil([selection prepareConnectionParameters:parameters]);
    XCTAssertNil(parameters.extraParam);
    XCTAssertEqual(selection.contextConfiguration.providerType, TSAIProviderTypeAIWoQi);
    XCTAssertEqualObjects(selection.contextConfiguration.platformIdentifier, TSAIPlatformIdentifierBuds);
    configuration.bundleIdentifier = @"different.bundle";
    selection = [[TSAIProviderSelection alloc] initWithProviderType:TSAIProviderTypeAIWoQi configuration:configuration];
    XCTAssertNotNil([selection validationError]);
}
@end
#endif
