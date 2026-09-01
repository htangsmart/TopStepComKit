//
//  TSDeviceBindingStore.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import "TSDeviceBindingStore.h"

static NSString * const kTSDeviceBindingRecordKey = @"TSDeviceBindingRecord";
static NSString * const kTSLegacyHasBoundDeviceKey = @"TSHasBoundDevice";
static NSString * const kTSLegacySDKTypeKey = @"TSSavedSDKType";
static NSString * const kTSLegacyMacAddressKey = @"kCurrentMac";
static NSString * const kTSLegacyUserIdentifierKey = @"kUserId";

@implementation TSDeviceBindingRecord
@end

@interface TSDeviceBindingStore ()

- (nullable TSDeviceBindingRecord *)recordWithDictionary:(nullable NSDictionary *)dictionary;

@end

@implementation TSDeviceBindingStore

#pragma mark - 公开方法

/** 读取绑定记录，并迁移旧版分散字段 */
- (TSDeviceBindingRecord *)bindingRecord {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [defaults dictionaryForKey:kTSDeviceBindingRecordKey];
    TSDeviceBindingRecord *record = [self recordWithDictionary:dictionary];
    if (record) {
        return record;
    }

    BOOL hasLegacyBinding = [defaults boolForKey:kTSLegacyHasBoundDeviceKey];
    NSString *macAddress = [defaults stringForKey:kTSLegacyMacAddressKey];
    if (!hasLegacyBinding || macAddress.length == 0) {
        return nil;
    }
    record = [[TSDeviceBindingRecord alloc] init];
    record.schemaVersion = 1;
    record.sdkType = [defaults objectForKey:kTSLegacySDKTypeKey] ?
        (TSSDKType)[defaults integerForKey:kTSLegacySDKTypeKey] : eTSSDKTypeTPB;
    record.macAddress = macAddress;
    record.userIdentifier = [defaults stringForKey:kTSLegacyUserIdentifierKey] ?: @"";
    if (record.userIdentifier.length == 0) {
        return nil;
    }
    [self saveBindingRecord:record];
    return record;
}

/** 原子保存绑定记录并同步兼容字段 */
- (void)saveBindingRecord:(TSDeviceBindingRecord *)record {
    if (record.macAddress.length == 0 || record.userIdentifier.length == 0) {
        return;
    }
    NSDictionary *dictionary = @{
        @"schemaVersion": @(record.schemaVersion),
        @"sdkType": @(record.sdkType),
        @"macAddress": record.macAddress,
        @"userIdentifier": record.userIdentifier,
    };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dictionary forKey:kTSDeviceBindingRecordKey];
    [defaults setBool:YES forKey:kTSLegacyHasBoundDeviceKey];
    [defaults setInteger:record.sdkType forKey:kTSLegacySDKTypeKey];
    [defaults setObject:record.macAddress forKey:kTSLegacyMacAddressKey];
    [defaults setObject:record.userIdentifier forKey:kTSLegacyUserIdentifierKey];
}

/** 删除新旧绑定字段 */
- (void)clearBindingRecord {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kTSDeviceBindingRecordKey];
    [defaults removeObjectForKey:kTSLegacyMacAddressKey];
    [defaults removeObjectForKey:kTSLegacyUserIdentifierKey];
    [defaults removeObjectForKey:kTSLegacySDKTypeKey];
    [defaults setBool:NO forKey:kTSLegacyHasBoundDeviceKey];
}

#pragma mark - 私有方法

/** 从字典恢复有效绑定记录 */
- (TSDeviceBindingRecord *)recordWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *macAddress = dictionary[@"macAddress"];
    NSString *userIdentifier = dictionary[@"userIdentifier"];
    if (macAddress.length == 0 || userIdentifier.length == 0) {
        return nil;
    }
    TSDeviceBindingRecord *record = [[TSDeviceBindingRecord alloc] init];
    record.schemaVersion = [dictionary[@"schemaVersion"] unsignedIntegerValue] ?: 1;
    record.sdkType = (TSSDKType)[dictionary[@"sdkType"] unsignedIntegerValue];
    record.macAddress = macAddress;
    record.userIdentifier = userIdentifier;
    return record;
}

@end
