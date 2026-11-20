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
 * @brief Result of saving a project AI selection
 * @chinese 保存项目 AI 配置的结果
 */
typedef NS_ENUM(NSInteger, TSAIProviderSelectionSaveResult) {
    /// @brief Saving failed. @chinese 保存失败。
    TSAIProviderSelectionSaveResultFailed,
    /// @brief Saved for a connection to the project. @chinese 已保存，连接该项目设备后使用。
    TSAIProviderSelectionSaveResultSaved,
    /// @brief Saved and started authorization on the current connection. @chinese 已保存并在当前连接上开始鉴权。
    TSAIProviderSelectionSaveResultReauthenticating,
    /// @brief Saved with new native parameters for the next connection. @chinese 已保存新的建连参数，重连后使用。
    TSAIProviderSelectionSaveResultRequiresReconnect,
};

/**
 * @brief Host AI selection for a Buds project
 * @chinese Buds 项目的宿主 AI 配置
 * @discussion
 * [EN]: The Demo stores project credentials in the device Keychain.
 * [CN]: Demo 将项目凭证保存在本机钥匙串中。
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
 * @brief Return the project identifier of the last successful save
 * @chinese 返回上次成功保存的项目号
 *
 * @return
 * EN: Last project identifier, or nil before the first save.
 * CN: 最近项目号，首次保存前为 nil。
 */
+ (nullable NSString *)lastSavedProjectIdentifier;

/**
 * @brief Return the project associated with the current Buds connection
 * @chinese 返回当前 Buds 连接对应的项目号
 *
 * @return
 * EN: The reported or previously selected project identifier, or nil when unknown.
 * CN: 设备上报或建连前选定的项目号，未知时为 nil。
 */
+ (nullable NSString *)currentBudsConnectionProjectIdentifier;

/**
 * @brief Read the saved AI selection for a project
 * @chinese 读取指定项目已保存的 AI 配置
 *
 * @param projectIdentifier
 * EN: Device project identifier.
 * CN: 设备项目号。
 *
 * @param error
 * EN: Storage error, if any.
 * CN: 读取失败时返回的错误。
 *
 * @return
 * EN: Saved selection, or nil if absent or unreadable.
 * CN: 已保存配置，未找到或读取失败时为 nil。
 */
+ (nullable instancetype)savedSelectionForProjectIdentifier:(NSString *)projectIdentifier
                                                      error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Save the project selection and apply it to a compatible connection on main
 * @chinese 在主队列保存项目配置，并在当前连接兼容时触发鉴权
 *
 * @param selection
 * EN: Proposed selection.
 * CN: 待保存的配置。
 *
 * @param projectIdentifier
 * EN: Device project identifier.
 * CN: 设备项目号。
 *
 * @param error
 * EN: Configuration or storage error.
 * CN: 配置或存储错误。
 *
 * @return
 * EN: Save result and whether the current connection can use the selection.
 * CN: 保存结果及当前连接能否使用该配置。
 */
+ (TSAIProviderSelectionSaveResult)saveSelection:(TSAIProviderSelection *)selection
                            forProjectIdentifier:(NSString *)projectIdentifier
                                           error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Load the project selection and freeze its parameters for a Buds connection
 * @chinese 加载该项目的配置，并冻结本次 Buds 建连使用的参数
 *
 * @param parameters
 * EN: Parameters for the new connection.
 * CN: 新连接使用的参数。
 *
 * @param projectIdentifier
 * EN: Target project, or nil when it has not been reported.
 * CN: 目标项目号，尚未取得时为 nil。
 *
 * @return
 * EN: Preparation error, or nil on success.
 * CN: 建连准备错误，准备成功时为 nil。
 */
+ (nullable NSError *)prepareBudsConnectionParameters:(TSPeripheralConnectParam *)parameters
                                    projectIdentifier:(nullable NSString *)projectIdentifier;

/**
 * @brief Confirm the project reported by the connected Buds
 * @chinese 确认已连接 Buds 上报的项目号
 *
 * @param projectIdentifier
 * EN: Reported device project, or nil when unavailable.
 * CN: 设备上报的项目号，尚未取得时为 nil。
 *
 * @return
 * EN: The confirmed project, or the project chosen before connecting when unavailable.
 * CN: 已确认的项目号，未上报时返回建连前选定的项目号。
 */
+ (nullable NSString *)finishBudsConnectionForProjectIdentifier:(nullable NSString *)projectIdentifier;

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
