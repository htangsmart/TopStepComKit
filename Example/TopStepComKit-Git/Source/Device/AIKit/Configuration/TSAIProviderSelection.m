#import "TSAIProviderSelection.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE

#import <Security/Security.h>

#import <TopStepAIKit/TSAIBudsManager.h>
#import <TopStepAIKit/TSAIWoQiConfiguration.h>
#import <TopStepAIKit/TSAIDeviceBridgeRegistry.h>
#import <TopStepInterfaceKit/TSPeripheralConnectParam.h>
#import "TSDeviceCoordinator.h"

NSNotificationName const TSAIProviderSelectionDidChangeNotification = @"TSAIProviderSelectionDidChangeNotification";
static NSErrorDomain const TSAIProviderSelectionErrorDomain = @"TSAIProviderSelectionErrorDomain";
static NSString * const kTSAIProjectKeychainService = @"com.topstep.demo.buds-ai.project";
static NSString * const kTSAILastSavedProjectIdentifierKey = @"TSAILastSavedProjectIdentifier";
// 离线保存的项目用于尚未上报项目号的首次连接。
static NSString *TSAIPreselectedProjectIdentifier;
// 项目号与原生参数随建连确定，独立于运行中的 AI 配置。
static NSString *TSAIBudsConnectionProjectIdentifier;
static TSAIProviderSelection *TSAIBudsConnectionSelection;
// 可在本次建连就绪后使用的配置，允许在连接准备期间更新。
static TSAIProviderSelection *TSAIBudsSelectionOnReady;
static TSAIProviderSelection *TSAICurrentProviderSelection;

typedef NS_ENUM(NSInteger, TSAIProviderSelectionErrorCode) {
    TSAIProviderSelectionErrorCodeInvalidConfiguration = 2201,
    TSAIProviderSelectionErrorCodeProjectMissing = 2203,
    TSAIProviderSelectionErrorCodeStorage = 2204,
};

// 只读取已知类型的配置字段。
static id TSAIStoredValue(NSDictionary *record, NSString *key, Class valueClass) {
    id value = record[key];
    return [value isKindOfClass:valueClass] ? value : nil;
}

@implementation TSAIProviderSelection

@synthesize providerConfiguration = _providerConfiguration;

#pragma mark - 生命周期

// 创建配置快照，版本标识不包含参数内容。
- (instancetype)initWithProviderType:(TSAIProviderType)type configuration:(id<NSCopying>)configuration {
    return [self initWithProviderType:type configuration:configuration chatPCMFormat:TSBudsAIChatPCMFormatUnknown];
}

// 格式只用于声明契约，不检测或转换输入 PCM。
- (instancetype)initWithProviderType:(TSAIProviderType)type configuration:(id<NSCopying>)configuration
                      chatPCMFormat:(TSBudsAIChatPCMFormat)format {
    self = [super init];
    if (self) {
        _chatPCMFormat = format;
        _providerType = type;
        _providerConfiguration = [configuration copyWithZone:NULL];
        _revisionIdentifier = NSUUID.UUID.UUIDString;
    }
    return self;
}

#pragma mark - 公开方法

// Demo 的配置读写由主队列串行执行。
+ (instancetype)currentSelection {
    NSAssert(NSThread.isMainThread, @"Host provider selection requires the main queue");
    return TSAICurrentProviderSelection;
}

// 读取最近保存的项目号，用于没有设备上下文的配置入口。
+ (NSString *)lastSavedProjectIdentifier {
    return [NSUserDefaults.standardUserDefaults stringForKey:kTSAILastSavedProjectIdentifierKey];
}

// 优先使用设备上报的项目号，缺失时沿用本次建连使用的项目号。
+ (NSString *)currentBudsConnectionProjectIdentifier {
    TSDeviceConnectionSnapshot *snapshot = TSDeviceCoordinator.sharedInstance.snapshot;
    if (snapshot.activeSDKType != eTSSDKTypeBuds || snapshot.connectionState == eTSBleStateDisconnected) {
        return nil;
    }
    NSString *projectIdentifier = [snapshot.peripheral.projectInfo.projectId
        stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return projectIdentifier.length > 0 ? projectIdentifier : TSAIBudsConnectionProjectIdentifier;
}

// 从指定项目的钥匙串条目恢复已校验的配置。
+ (instancetype)savedSelectionForProjectIdentifier:(NSString *)projectIdentifier error:(NSError **)error {
    projectIdentifier = [projectIdentifier stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (projectIdentifier.length == 0) {
        return nil;
    }
    NSMutableDictionary *query = [[self keychainQueryForProjectIdentifier:projectIdentifier] mutableCopy];
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    NSData *data = CFBridgingRelease(result);
    if (status == errSecItemNotFound) {
        return nil;
    }
    id record = status == errSecSuccess && data.length > 0
        ? [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL]
        : nil;
    TSAIProviderSelection *selection = [record isKindOfClass:NSDictionary.class] ? [self selectionFromRecord:record] : nil;
    if (!selection && error) {
        *error = [self storageErrorWithDescription:@"读取项目 AI 配置失败"];
    }
    return selection;
}

// 始终先保存，当前项目及建连参数匹配时再更新运行配置。
+ (TSAIProviderSelectionSaveResult)saveSelection:(TSAIProviderSelection *)selection
                            forProjectIdentifier:(NSString *)projectIdentifier
                                           error:(NSError **)error {
    NSAssert(NSThread.isMainThread, @"Host provider selection requires the main queue");
    projectIdentifier = [projectIdentifier stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (projectIdentifier.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:TSAIProviderSelectionErrorDomain
                code:TSAIProviderSelectionErrorCodeProjectMissing
                userInfo:@{NSLocalizedDescriptionKey: @"请输入设备项目号"}];
        }
        return TSAIProviderSelectionSaveResultFailed;
    }
    NSError *validationError = [selection validationError];
    if (selection == nil || validationError != nil) {
        if (error) { *error = validationError ?: [self invalidConfigurationError]; }
        return TSAIProviderSelectionSaveResultFailed;
    }
    if (![selection saveForProjectIdentifier:projectIdentifier]) {
        if (error) {
            *error = [self storageErrorWithDescription:@"保存项目 AI 配置失败"];
        }
        return TSAIProviderSelectionSaveResultFailed;
    }
    [NSUserDefaults.standardUserDefaults setObject:projectIdentifier forKey:kTSAILastSavedProjectIdentifierKey];

    TSDeviceConnectionSnapshot *snapshot = TSDeviceCoordinator.sharedInstance.snapshot;
    if (snapshot.activeSDKType != eTSSDKTypeBuds || snapshot.connectionState == eTSBleStateDisconnected) {
        TSAIPreselectedProjectIdentifier = projectIdentifier;
        return TSAIProviderSelectionSaveResultSaved;
    }
    NSString *connectedProject = [self currentBudsConnectionProjectIdentifier];
    if (![projectIdentifier isEqualToString:connectedProject]) {
        return TSAIProviderSelectionSaveResultSaved;
    }
    if (selection.providerType != TSAIProviderTypeAIWoQi && ![selection matchesBudsConnectionSelection]) {
        return TSAIProviderSelectionSaveResultRequiresReconnect;
    }
    TSAIBudsConnectionProjectIdentifier = connectedProject;
    TSAIBudsSelectionOnReady = selection;
    if (snapshot.isReady) {
        [self publishSelection:selection];
        [[NSNotificationCenter defaultCenter] postNotificationName:TSAIProviderSelectionDidChangeNotification object:nil];
        return TSAIProviderSelectionSaveResultReauthenticating;
    }
    return TSAIProviderSelectionSaveResultSaved;
}

// 每次新建连接都读取目标项目最新保存的配置。
+ (NSError *)prepareBudsConnectionParameters:(TSPeripheralConnectParam *)parameters
                            projectIdentifier:(NSString *)projectIdentifier {
    NSAssert(NSThread.isMainThread, @"Host provider selection requires the main queue");
    NSString *targetProject = [projectIdentifier
        stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (targetProject.length == 0) {
        targetProject = TSAIPreselectedProjectIdentifier;
    }
    NSError *error = nil;
    TSAIProviderSelection *selection = targetProject.length > 0
        ? [self savedSelectionForProjectIdentifier:targetProject error:&error] : nil;
    if (!error) {
        error = [selection prepareConnectionParameters:parameters];
    }
    if (error) {
        return error;
    }
    TSAIBudsConnectionProjectIdentifier = targetProject;
    TSAIBudsConnectionSelection = selection.providerType == TSAIProviderTypeAIBuds ? selection : nil;
    TSAIBudsSelectionOnReady = selection;
    return nil;
}

// 设备上报的项目号优先，丢弃与实际项目不符的运行配置。
+ (NSString *)finishBudsConnectionForProjectIdentifier:(NSString *)projectIdentifier {
    NSString *reportedProject = [projectIdentifier
        stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (reportedProject.length > 0 && ![reportedProject isEqualToString:TSAIBudsConnectionProjectIdentifier]) {
        TSAIBudsConnectionProjectIdentifier = reportedProject;
        TSAIBudsSelectionOnReady = nil;
    }
    TSAIPreselectedProjectIdentifier = nil;
    [self publishSelection:TSAIBudsSelectionOnReady];
    return TSAIBudsConnectionProjectIdentifier;
}

// Bridge 只按平台注册；Provider 的选择完全来自宿主。
- (TSAIContextConfiguration *)contextConfiguration {
    return [TSAIContextConfiguration configurationWithPlatformIdentifier:TSAIPlatformIdentifierBuds
        providerType:self.providerType providerConfiguration:self.providerConfiguration];
}

// AIBuds 原生连接插件须在 BLE 连接前准备，WoQi 不参与此原生认证通道。
- (NSError *)prepareConnectionParameters:(TSPeripheralConnectParam *)parameters {
    NSError *error = [self validationError];
    if (error != nil || self.providerType != TSAIProviderTypeAIBuds) {
        return error;
    }
    if (![TSAIBudsManager prepareRuntimeWithError:&error]) {
        return error ?: [self.class invalidConfigurationError];
    }
    TSBudsConnectExtraParam *extra = nil;
    if (parameters.extraParam == nil) {
        extra = [[TSBudsConnectExtraParam alloc] init];
    } else if ([parameters.extraParam isKindOfClass:TSBudsConnectExtraParam.class]) {
        extra = (id)parameters.extraParam;
    } else {
        return [self.class invalidConfigurationError];
    }
    TSAIBudsConfiguration *configuration = (id)self.providerConfiguration;
    extra.starBurstAuthSDK = configuration.starBurstAuthSDK;
    extra.starBurstProductId = configuration.starBurstProductId;
    extra.starBurstPPEEnvironment = configuration.starBurstPPEEnvironment;
    extra.mltCloudChannelId = configuration.mltCloudChannelId;
    extra.mltCloudStagingEnvironment = configuration.mltCloudStagingEnvironment;
    parameters.extraParam = extra;
    return [extra validateAIAuthenticationParameters];
}

#pragma mark - 私有方法

// 每次应用生成新的配置版本，使 Demo 用当前连接重建 AI Context。
+ (void)publishSelection:(nullable TSAIProviderSelection *)selection {
    if (!selection) {
        TSAICurrentProviderSelection = nil;
        return;
    }
    TSAICurrentProviderSelection = [[self alloc] initWithProviderType:selection.providerType
        configuration:selection.providerConfiguration chatPCMFormat:selection.chatPCMFormat];
    TSBudsAIChatPCMFormat format = selection.chatPCMFormat;
    [[TSAIDeviceBridgeRegistry sharedRegistry] registerFactory:^id<TSAIDeviceBridge> {
        return [[TSBudsAIDeviceBridge alloc] initWithChatPCMFormat:format];
    } forPlatformIdentifier:TSAIPlatformIdentifierBuds];
}

// 只比较当前方案真正传给 Buds SDK 的建连字段。
- (BOOL)matchesBudsConnectionSelection {
    if (TSAIBudsConnectionSelection.providerType != TSAIProviderTypeAIBuds) {
        return NO;
    }
    TSAIBudsConfiguration *proposed = (id)_providerConfiguration;
    TSAIBudsConfiguration *connected = (id)TSAIBudsConnectionSelection->_providerConfiguration;
    if (proposed.preferredVendor != connected.preferredVendor) {
        return NO;
    }
    if (proposed.preferredVendor == TSAIBudsVendorTypeMltCloud) {
        return [proposed.mltCloudChannelId isEqualToString:connected.mltCloudChannelId] &&
            proposed.mltCloudStagingEnvironment == connected.mltCloudStagingEnvironment;
    }
    return [proposed.starBurstAuthSDK isEqualToNumber:connected.starBurstAuthSDK] &&
        [proposed.starBurstProductId isEqualToString:connected.starBurstProductId] &&
        (proposed.starBurstPPEEnvironment == connected.starBurstPPEEnvironment ||
         [proposed.starBurstPPEEnvironment isEqualToString:connected.starBurstPPEEnvironment]);
}

// 使用完整项目号区分同一 App 内的钥匙串条目。
+ (NSDictionary *)keychainQueryForProjectIdentifier:(NSString *)projectIdentifier {
    return @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kTSAIProjectKeychainService,
        (__bridge id)kSecAttrAccount: projectIdentifier,
    };
}

// 一次更新整个项目配置，避免凭证与方案只保存一部分。
- (BOOL)saveForProjectIdentifier:(NSString *)projectIdentifier {
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[self storageRecord]
        format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    if (!data) {
        return NO;
    }
    NSDictionary *query = [self.class keychainQueryForProjectIdentifier:projectIdentifier];
    NSDictionary *attributes = @{(__bridge id)kSecValueData: data};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
    if (status == errSecItemNotFound) {
        NSMutableDictionary *item = [query mutableCopy];
        [item addEntriesFromDictionary:attributes];
        item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
        status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
    }
    return status == errSecSuccess;
}

// 保存表单中所选方案的输入与开关。
- (NSDictionary *)storageRecord {
    NSMutableDictionary *record = [@{
        @"providerType": @(self.providerType),
        @"chatPCMFormat": @(self.chatPCMFormat),
    } mutableCopy];
    if (self.providerType == TSAIProviderTypeAIWoQi) {
        TSAIWoQiConfiguration *configuration = (id)_providerConfiguration;
        record[@"appKey"] = configuration.appKey;
        record[@"appSecret"] = configuration.appSecret;
    } else {
        TSAIBudsConfiguration *configuration = (id)_providerConfiguration;
        record[@"vendor"] = @(configuration.preferredVendor);
        record[@"authSDK"] = configuration.starBurstAuthSDK;
        record[@"product"] = configuration.starBurstProductId;
        record[@"environment"] = configuration.starBurstPPEEnvironment;
        record[@"channel"] = configuration.mltCloudChannelId;
        record[@"staging"] = @(configuration.mltCloudStagingEnvironment);
    }
    return record;
}

// 从钥匙串数据重建对应方案，忽略已失效的配置。
+ (instancetype)selectionFromRecord:(NSDictionary *)record {
    NSNumber *providerType = TSAIStoredValue(record, @"providerType", NSNumber.class);
    NSNumber *chatPCMFormat = TSAIStoredValue(record, @"chatPCMFormat", NSNumber.class);
    TSAIProviderType type = providerType.integerValue;
    id<NSCopying> configuration = nil;
    if (type == TSAIProviderTypeAIWoQi) {
        TSAIWoQiConfiguration *woqi = [[TSAIWoQiConfiguration alloc] init];
        woqi.appKey = TSAIStoredValue(record, @"appKey", NSString.class) ?: @"";
        woqi.appSecret = TSAIStoredValue(record, @"appSecret", NSString.class) ?: @"";
        configuration = woqi;
    } else if (type == TSAIProviderTypeAIBuds) {
        NSNumber *vendor = TSAIStoredValue(record, @"vendor", NSNumber.class);
        TSAIBudsConfiguration *buds = [TSAIBudsConfiguration configurationWithPreferredVendor:vendor.integerValue];
        buds.starBurstAuthSDK = TSAIStoredValue(record, @"authSDK", NSNumber.class);
        buds.starBurstProductId = TSAIStoredValue(record, @"product", NSString.class);
        buds.starBurstPPEEnvironment = TSAIStoredValue(record, @"environment", NSString.class);
        buds.mltCloudChannelId = TSAIStoredValue(record, @"channel", NSString.class);
        NSNumber *staging = TSAIStoredValue(record, @"staging", NSNumber.class);
        buds.mltCloudStagingEnvironment = staging.boolValue;
        configuration = buds;
    }
    if (!configuration || !chatPCMFormat) {
        return nil;
    }
    TSAIProviderSelection *selection = [[self alloc] initWithProviderType:type
        configuration:configuration chatPCMFormat:chatPCMFormat.integerValue];
    return [selection validationError] ? nil : selection;
}

// 存储错误仅包含操作说明。
+ (NSError *)storageErrorWithDescription:(NSString *)description {
    return [NSError errorWithDomain:TSAIProviderSelectionErrorDomain
        code:TSAIProviderSelectionErrorCodeStorage userInfo:@{NSLocalizedDescriptionKey: description}];
}

// 不把不同 Provider 的空配置合并为一个默认方案。
- (NSError *)validationError {
    if (self.chatPCMFormat != TSBudsAIChatPCMFormatUnknown &&
        self.chatPCMFormat != TSBudsAIChatPCMFormatSigned16LittleEndianMono16kHz) {
        return [self.class invalidConfigurationError];
    }
    if (self.providerType == TSAIProviderTypeAIBuds &&
        [(id)self.providerConfiguration isKindOfClass:TSAIBudsConfiguration.class]) {
        TSAIBudsConfiguration *configuration = (id)self.providerConfiguration;
        NSCharacterSet *whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet;
        if (configuration.preferredVendor == TSAIBudsVendorTypeStarBurst) {
            NSNumber *mode = configuration.starBurstAuthSDK;
            if (mode.integerValue >= 1 && mode.integerValue <= 5 && mode.doubleValue == mode.integerValue &&
                [configuration.starBurstProductId stringByTrimmingCharactersInSet:whitespace].length > 0) { return nil; }
        } else if (configuration.preferredVendor == TSAIBudsVendorTypeMltCloud &&
                   [configuration.mltCloudChannelId stringByTrimmingCharactersInSet:whitespace].length > 0) { return nil; }
    } else if (self.providerType == TSAIProviderTypeAIWoQi &&
               [(id)self.providerConfiguration isKindOfClass:TSAIWoQiConfiguration.class]) {
        TSAIWoQiConfiguration *configuration = (id)self.providerConfiguration;
        if (configuration.appKey.length > 0 && configuration.appSecret.length > 0 &&
            [configuration.bundleIdentifier isEqual:NSBundle.mainBundle.bundleIdentifier]) { return nil; }
    }
    return [self.class invalidConfigurationError];
}

// 错误不包含参数值或密钥。
+ (NSError *)invalidConfigurationError {
    return [NSError errorWithDomain:TSAIProviderSelectionErrorDomain
        code:TSAIProviderSelectionErrorCodeInvalidConfiguration
        userInfo:@{NSLocalizedDescriptionKey: @"请填写所选 AI 方案的有效授权参数"}];
}

#pragma mark - 属性 Getter

// 读取也复制，防止外部更改配置却沿用旧版本标识。
- (id<NSCopying>)providerConfiguration {
    return [_providerConfiguration copyWithZone:NULL];
}
@end
#endif
