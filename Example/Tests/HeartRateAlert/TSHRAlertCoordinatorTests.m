//
//  TSHRAlertCoordinatorTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "../../TopStepComKit-Git/Source/AppDelegate/TSHRAlertCoordinator.h"

@interface TSHRAlertCoordinatorTests : XCTestCase

@end

@implementation TSHRAlertCoordinatorTests

#pragma mark - 文案测试

// 动态过高需要展示上限及运动场景建议
- (void)testDynamicHighIncludesUpperLimitAndExerciseAdvice {
    TSHRAlertModel *alert = [self alertWithType:TSHRAlertTypeDynamicHigh hrValue:168 threshold:@160];
    NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
    XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                          NSLocalizedString(@"hr.alert.notification.high", nil));
    [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_dynamic", @"hr.alert.message.upper",
                                              @"hr.alert.message.dynamic_advice"]];
    XCTAssertTrue([message containsString:@"168"]);
    XCTAssertTrue([message containsString:@"160"]);
    XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.static_advice", nil)]);
}

// 静态过高使用安静场景建议，不能混入运动建议
- (void)testStaticHighIncludesUpperLimitAndRestAdvice {
    TSHRAlertModel *alert = [self alertWithType:TSHRAlertTypeStaticHigh hrValue:126 threshold:@120];
    NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
    XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                          NSLocalizedString(@"hr.alert.notification.high", nil));
    [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_static", @"hr.alert.message.upper",
                                              @"hr.alert.message.static_advice"]];
    XCTAssertTrue([message containsString:@"126"]);
    XCTAssertTrue([message containsString:@"120"]);
    XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.dynamic_advice", nil)]);
}

// 动态过低展示下限，不复用过高告警的建议
- (void)testDynamicLowPreservesDirectionWithoutHighAdvice {
    TSHRAlertModel *alert = [self alertWithType:TSHRAlertTypeDynamicLow hrValue:48 threshold:@50];
    NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
    XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                          NSLocalizedString(@"hr.alert.notification.low", nil));
    [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_dynamic", @"hr.alert.message.lower"]];
    XCTAssertTrue([message containsString:@"48"]);
    XCTAssertTrue([message containsString:@"50"]);
    [self assertMessageHasNoAdvice:message];
}

// 静态过低保留静态场景和下限，不显示上限
- (void)testStaticLowPreservesDirectionWithoutHighAdvice {
    TSHRAlertModel *alert = [self alertWithType:TSHRAlertTypeStaticLow hrValue:42 threshold:@45];
    NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
    XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                          NSLocalizedString(@"hr.alert.notification.low", nil));
    [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_static", @"hr.alert.message.lower"]];
    XCTAssertTrue([message containsString:@"42"]);
    XCTAssertTrue([message containsString:@"45"]);
    XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.upper", nil)]);
    [self assertMessageHasNoAdvice:message];
}

// 缺失阈值只陈述设备方向，不虚构零值或上下限比较
- (void)testMissingThresholdDoesNotInventLimit {
    for (NSNumber *type in @[@(TSHRAlertTypeDynamicHigh), @(TSHRAlertTypeDynamicLow),
                             @(TSHRAlertTypeStaticHigh), @(TSHRAlertTypeStaticLow)]) {
        TSHRAlertModel *alert = [self alertWithType:type.unsignedIntegerValue hrValue:72 threshold:nil];
        NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
        XCTAssertTrue([message containsString:@"72"]);
        XCTAssertTrue([message containsString:[TSHRAlertCoordinator titleForAlert:alert]]);
        XCTAssertFalse([message containsString:@"0"]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.upper", nil)]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.lower", nil)]);
        [self assertMessageHasNoAdvice:message];
    }
}

// 最近配置与设备方向冲突时，保留设备事实并明确配置来源
- (void)testConflictingThresholdPreservesDeviceDirection {
    NSArray<TSHRAlertModel *> *alerts = @[
        [self alertWithType:TSHRAlertTypeDynamicHigh hrValue:168 threshold:@190],
        [self alertWithType:TSHRAlertTypeStaticLow hrValue:48 threshold:@40]
    ];
    for (TSHRAlertModel *alert in alerts) {
        [self assertDeviceFactAndConfirmedConfigurationForAlert:alert];
    }
}

// 等于配置值不能描述成已越过边界，仍保留设备上报方向
- (void)testEqualThresholdDoesNotClaimBoundaryCrossing {
    for (NSNumber *type in @[@(TSHRAlertTypeDynamicHigh), @(TSHRAlertTypeDynamicLow),
                             @(TSHRAlertTypeStaticHigh), @(TSHRAlertTypeStaticLow)]) {
        TSHRAlertModel *alert = [self alertWithType:type.unsignedIntegerValue hrValue:75 threshold:@75];
        [self assertDeviceFactAndConfirmedConfigurationForAlert:alert];
    }
}

// 组合类型仅用于能力查询，展示时不能误判为某个单一告警
- (void)testCombinedTypeDoesNotInventContextOrDirection {
    NSArray<NSNumber *> *types = @[
        @(TSHRAlertTypeDynamicHigh | TSHRAlertTypeStaticHigh),
        @(TSHRAlertTypeDynamicHigh | TSHRAlertTypeDynamicLow)
    ];
    for (NSNumber *type in types) {
        TSHRAlertModel *alert = [self alertWithType:type.unsignedIntegerValue hrValue:168 threshold:@160];
        NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
        XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                              NSLocalizedString(@"hr.alert.notification.unknown", nil));
        [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_unknown"]];
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.mode_dynamic", nil)]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.mode_static", nil)]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.upper", nil)]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.lower", nil)]);
        XCTAssertFalse([message containsString:@"160"]);
        [self assertMessageHasNoAdvice:message];
    }
}

// 未知方向使用中性标题，不将阈值解释为上限或下限
- (void)testUnknownTypeUsesNeutralFactWithoutInventedLimit {
    for (NSNumber *type in @[@(TSHRAlertTypeUnknown), @(1UL << 4)]) {
        TSHRAlertModel *alert = [self alertWithType:type.unsignedIntegerValue hrValue:72 threshold:@160];
        NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
        XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert],
                              NSLocalizedString(@"hr.alert.notification.unknown", nil));
        XCTAssertTrue([message containsString:@"72"]);
        XCTAssertTrue([message containsString:[TSHRAlertCoordinator titleForAlert:alert]]);
        [self assertMessage:message containsKeys:@[@"hr.alert.message.mode_unknown"]];
        XCTAssertFalse([message containsString:@"160"]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.upper", nil)]);
        XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.lower", nil)]);
        [self assertMessageHasNoAdvice:message];
    }
}

// 心率字节上限和超出字节范围的配置值均完整展示
- (void)testMaximumHeartRateAndLargeThresholdAreNotTruncated {
    for (NSNumber *type in @[@(TSHRAlertTypeDynamicHigh), @(TSHRAlertTypeDynamicLow)]) {
        TSHRAlertModel *alert = [self alertWithType:type.unsignedIntegerValue hrValue:255 threshold:@65535];
        NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
        XCTAssertTrue([message containsString:@"255"]);
        XCTAssertTrue([message containsString:@"65535"]);
        XCTAssertFalse([message containsString:@"-1"]);
    }
}

#pragma mark - 私有方法

// 所有测试仅构造事件，不启动协调器或系统通知
- (TSHRAlertModel *)alertWithType:(TSHRAlertType)type hrValue:(UInt8)hrValue threshold:(nullable NSNumber *)threshold {
    return [[TSHRAlertModel alloc] initWithType:type hrValue:hrValue threshold:threshold receiveTime:1792454400];
}

// 从宿主资源读取语义片段，避免测试依赖设备语言
- (void)assertMessage:(NSString *)message containsKeys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        NSString *text = NSLocalizedString(key, nil);
        XCTAssertNotEqualObjects(text, key, @"宿主缺少本地化资源：%@", key);
        XCTAssertTrue([message containsString:text], @"正文缺少语义片段：%@", key);
    }
    XCTAssertFalse([message containsString:@"hr.alert."]);
}

// 过低、未知及配置冲突文案不借用过高场景建议
- (void)assertMessageHasNoAdvice:(NSString *)message {
    XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.dynamic_advice", nil)]);
    XCTAssertFalse([message containsString:NSLocalizedString(@"hr.alert.message.static_advice", nil)]);
}

// 添加冲突或相等的配置值，只能在原设备事实后补充配置说明
- (void)assertDeviceFactAndConfirmedConfigurationForAlert:(TSHRAlertModel *)alert {
    TSHRAlertModel *withoutThreshold = [self alertWithType:alert.type hrValue:alert.hrValue threshold:nil];
    NSString *fact = [TSHRAlertCoordinator messageForAlert:withoutThreshold];
    NSString *message = [TSHRAlertCoordinator messageForAlert:alert];
    BOOL isHigh = alert.type == TSHRAlertTypeDynamicHigh || alert.type == TSHRAlertTypeStaticHigh;
    NSString *limitKey = isHigh ? @"hr.alert.message.upper" : @"hr.alert.message.lower";
    NSString *configuration = [NSString stringWithFormat:NSLocalizedString(@"hr.alert.message.config_format", nil),
                               NSLocalizedString(limitKey, nil), alert.threshold];
    NSString *titleKey = isHigh ?
                         @"hr.alert.notification.high" : @"hr.alert.notification.low";
    XCTAssertEqualObjects([TSHRAlertCoordinator titleForAlert:alert], NSLocalizedString(titleKey, nil));
    XCTAssertTrue([message hasPrefix:fact]);
    XCTAssertTrue([message hasSuffix:configuration]);
    XCTAssertEqual(message.length, fact.length + configuration.length);
    XCTAssertTrue([message containsString:alert.threshold.stringValue]);
    [self assertMessageHasNoAdvice:message];
}

@end
