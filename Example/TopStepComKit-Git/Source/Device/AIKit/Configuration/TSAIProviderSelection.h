#import "TSAIBudsIntegrationAvailability.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE
#import <Foundation/Foundation.h>
#import <TopStepAIKit/TSAIContextConfiguration.h>
#import <TopStepBudsKit/TSBudsAIDeviceBridge.h>

@class TSPeripheralConnectParam;

NS_ASSUME_NONNULL_BEGIN

/** @brief Host AI selection changed @chinese 宿主 AI 配置已变更 */
FOUNDATION_EXPORT NSNotificationName const TSAIProviderSelectionDidChangeNotification;

/**
 * @brief In-memory host selection for BudsDemoIntegration
 * @chinese Buds 联调的宿主内存配置
 * @discussion EN: Credentials are never persisted or logged. Platform and AI provider are independent.
 *             CN: 凭证不落盘、不记录日志，设备平台与 AI Provider 独立。
 */
@interface TSAIProviderSelection : NSObject
/** @brief Selected provider @chinese 所选 Provider */
@property (nonatomic, assign, readonly) TSAIProviderType providerType;
/** @brief Verified PCM contract; Unknown by default @chinese 已核实的 PCM 契约，默认 Unknown */
@property (nonatomic, assign, readonly) TSBudsAIChatPCMFormat chatPCMFormat;
/** @brief Configuration revision, without credentials @chinese 不含凭证的配置版本标识 */
@property (nonatomic, copy, readonly) NSString *revisionIdentifier;
/** @brief Independent copy of provider configuration @chinese Provider 配置的独立副本 */
@property (nonatomic, copy, readonly) id<NSCopying> providerConfiguration;

/**
 * @brief Freeze a host provider selection
 * @chinese 冻结宿主 Provider 选择
 * @param type EN: Provider product. CN: Provider 产品。
 * @param configuration EN: Typed provider configuration. CN: 强类型 Provider 配置。
 * @return EN: Independent selection. CN: 独立配置。
 */
- (instancetype)initWithProviderType:(TSAIProviderType)type configuration:(id<NSCopying>)configuration;
/**
 * @brief Freeze provider settings and a verified native PCM contract
 * @chinese 冻结供应商配置与已核实的原生 PCM 契约
 * @param type EN: Provider product. CN: Provider 产品。
 * @param configuration EN: Provider settings. CN: Provider 配置。
 * @param format EN: Verified format, or Unknown without evidence. CN: 有依据的格式，无依据为 Unknown。
 * @return EN: Immutable selection. CN: 不可变配置。
 */
- (instancetype)initWithProviderType:(TSAIProviderType)type configuration:(id<NSCopying>)configuration
                      chatPCMFormat:(TSBudsAIChatPCMFormat)format;
/** @brief Current session selection, nil until configured @chinese 本次运行的配置，未设置时为 nil
 * @return EN: Current immutable selection. CN: 当前不可变配置。
 */
+ (nullable instancetype)currentSelection;
/**
 * @brief Validate and publish the host selection on main
 * @chinese 在主队列校验并发布宿主配置
 * @param selection EN: Proposed selection. CN: 待应用的配置。
 * @param error EN: Configuration error. CN: 配置错误。
 * @return EN: YES on success. CN: 成功时为 YES。
 */
+ (BOOL)applySelection:(TSAIProviderSelection *)selection error:(NSError * _Nullable * _Nullable)error;
/** @brief Create the Buds platform Context configuration @chinese 创建 Buds 平台 Context 配置
 * @return EN: Provider-independent platform configuration. CN: 平台与 Provider 独立的配置。
 */
- (TSAIContextConfiguration *)contextConfiguration;
/**
 * @brief Add only native connection metadata before connecting
 * @chinese 在连接前补充原生连接元数据
 * @param parameters EN: Host connection parameters. CN: 宿主连接参数。
 * @return EN: Parameter/runtime error, or nil. CN: 参数或运行库错误，成功为 nil。
 */
- (nullable NSError *)prepareConnectionParameters:(TSPeripheralConnectParam *)parameters;
@end

NS_ASSUME_NONNULL_END
#endif
