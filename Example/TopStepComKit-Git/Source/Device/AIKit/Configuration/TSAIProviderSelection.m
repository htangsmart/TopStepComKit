#import "TSAIProviderSelection.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE

#import <TopStepAIKit/TSAIBudsManager.h>
#import <TopStepAIKit/TSAIWoQiConfiguration.h>
#import <TopStepAIKit/TSAIDeviceBridgeRegistry.h>
#import <TopStepInterfaceKit/TSPeripheralConnectParam.h>
#import "TSDeviceCoordinator.h"

NSNotificationName const TSAIProviderSelectionDidChangeNotification = @"TSAIProviderSelectionDidChangeNotification";
static TSAIProviderSelection *TSAICurrentProviderSelection;

typedef NS_ENUM(NSInteger, TSAIProviderSelectionErrorCode) {
    TSAIProviderSelectionErrorCodeInvalidConfiguration = 2201,
    TSAIProviderSelectionErrorCodeConnectionActive = 2202,
};

@implementation TSAIProviderSelection

@synthesize providerConfiguration = _providerConfiguration;

#pragma mark - 生命周期

// 凭证只保存在内存副本中，版本标识不包含参数内容。
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

// 无默认示例授权；只保存通过完整字段校验的配置。
+ (BOOL)applySelection:(TSAIProviderSelection *)selection error:(NSError **)error {
    NSAssert(NSThread.isMainThread, @"Host provider selection requires the main queue");
    TSBleConnectionState state = [TSDeviceCoordinator sharedInstance].snapshot.connectionState;
    if (state == eTSBleStateConnected || state == eTSBleStateConnecting) {
        if (error) {
            *error = [NSError errorWithDomain:@"TSAIProviderSelectionErrorDomain"
                code:TSAIProviderSelectionErrorCodeConnectionActive
                userInfo:@{NSLocalizedDescriptionKey: @"请先断开设备，再保存 AI 配置并重新连接"}];
        }
        return NO;
    }
    NSError *validationError = [selection validationError];
    if (selection == nil || validationError != nil) {
        if (error) { *error = validationError ?: [self invalidConfigurationError]; }
        return NO;
    }
    TSAICurrentProviderSelection = [[self alloc] initWithProviderType:selection.providerType
        configuration:selection.providerConfiguration chatPCMFormat:selection.chatPCMFormat];
    TSBudsAIChatPCMFormat format = TSAICurrentProviderSelection.chatPCMFormat;
    [[TSAIDeviceBridgeRegistry sharedRegistry] registerFactory:^id<TSAIDeviceBridge> {
        return [[TSBudsAIDeviceBridge alloc] initWithChatPCMFormat:format];
    } forPlatformIdentifier:TSAIPlatformIdentifierBuds];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSAIProviderSelectionDidChangeNotification object:nil];
    return YES;
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

// 不把不同 Provider 的空配置合并为一个默认方案。
- (NSError *)validationError {
    if (self.chatPCMFormat != TSBudsAIChatPCMFormatUnknown &&
        self.chatPCMFormat != TSBudsAIChatPCMFormatSigned16LittleEndianMono16kHz) {
        return [self.class invalidConfigurationError];
    }
    if (self.providerType == TSAIProviderTypeAIBuds &&
        [(id)self.providerConfiguration isKindOfClass:TSAIBudsConfiguration.class]) {
        TSAIBudsConfiguration *configuration = (id)self.providerConfiguration;
        if (configuration.preferredVendor == TSAIBudsVendorTypeStarBurst) {
            NSNumber *mode = configuration.starBurstAuthSDK;
            if (mode.integerValue >= 1 && mode.integerValue <= 5 && mode.doubleValue == mode.integerValue &&
                configuration.starBurstProductId.length > 0) { return nil; }
        } else if (configuration.preferredVendor == TSAIBudsVendorTypeMltCloud &&
                   configuration.mltCloudChannelId.length > 0) { return nil; }
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
    return [NSError errorWithDomain:@"TSAIProviderSelectionErrorDomain"
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
