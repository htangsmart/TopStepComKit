//
//  TSKitConfigOptions.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/1/3.
//

/**
 * @brief SDK configuration options model
 * @chinese SDK配置选项模型
 *
 * @discussion
 * [EN]: This class manages all configuration options for the SDK, including:
 *       - SDK type and license management
 *       - Development mode settings
 *       - Bluetooth connection parameters
 *       - Device search and connection timeouts
 *       - Auto-connection behavior
 * 
 * [CN]: 该类管理SDK的所有配置选项，包括：
 *       - SDK类型和证书管理
 *       - 开发模式设置
 *       - 蓝牙连接参数
 *       - 设备搜索和连接超时设置
 *       - 自动连接行为
 */

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSKitConfigOptions : NSObject

/**
 * @brief SDK type
 * @chinese SDK类型
 *
 * @discussion
 * [EN]: Specifies the type of SDK being used.
 *       Determines the underlying Bluetooth stack and device compatibility.
 * 
 * [CN]: 指定使用的SDK类型。
 *       决定底层蓝牙协议栈和设备兼容性。
 *
 * @note
 * [EN]: - Default value is eTSSDKTypeFit
 *       - Affects device prefix and connection behavior
 *       - Must match the actual device SDK type
 * 
 * [CN]: - 默认值为eTSSDKTypeFit
 *       - 影响设备前缀和连接行为
 *       - 必须与实际设备SDK类型匹配
 */
@property (nonatomic,assign) TSSDKType sdkType;

/**
 * @brief SDK license key
 * @chinese SDK证书密钥
 *
 * @discussion
 * [EN]: The license key is a 32-character string used to validate SDK usage rights.
 *       Must be set before initializing the SDK.
 * 
 * [CN]: 证书密钥是一个32位字符串，用于验证SDK使用权限。
 *       必须在初始化SDK之前设置。
 *
 * @note
 * [EN]: - Length must be exactly 32 characters
 *       - Contains only letters (a-z, A-Z) and numbers (0-9)
 *       - SDK initialization will fail if license is invalid
 * 
 * [CN]: - 长度必须为32位字符
 *       - 只能包含字母(a-z, A-Z)和数字(0-9)
 *       - 证书无效将导致SDK初始化失败
 */
@property (nonatomic, copy, nullable) NSString *license;

/**
 * @brief Development mode flag
 * @chinese 开发模式标志
 *
 * @discussion
 * [EN]: Enables development mode features such as detailed logging and debugging.
 *       Should be disabled in production environment.
 * 
 * [CN]: 启用开发模式功能，如详细日志和调试信息。
 *       应在生产环境中禁用。
 *
 * @note
 * [EN]: - Default value is NO
 *       - Enables additional debug information
 *       - May impact performance
 * 
 * [CN]: - 默认值为NO
 *       - 启用额外的调试信息
 *       - 可能影响性能
 */
@property (nonatomic,assign) BOOL isDevelopModel;

/**
 * @brief Bluetooth permission check flag
 * @chinese 蓝牙权限检查标志
 *
 * @discussion
 * [EN]: Controls whether to check Bluetooth permissions before operations.
 *       When enabled, SDK will verify Bluetooth permissions before scanning or connecting.
 * 
 * [CN]: 控制是否在操作前检查蓝牙权限。
 *       启用时，SDK将在扫描或连接前验证蓝牙权限。
 *
 * @note
 * [EN]: - Default value is NO
 *       - Recommended to enable in production
 *       - Helps prevent permission-related crashes
 * 
 * [CN]: - 默认值为NO
 *       - 建议在生产环境中启用
 *       - 有助于防止权限相关的崩溃
 */
@property (nonatomic,assign) BOOL isCheckBluetoothAuthority;

/**
 * @brief Maximum connection timeout duration
 * @chinese 最大连接超时时间
 *
 * @discussion
 * [EN]: Maximum duration (in seconds) to wait for a device connection to complete.
 *       Connection attempts will timeout after this duration.
 * 
 * [CN]: 等待设备连接完成的最大持续时间（秒）。
 *       超过此时间后连接尝试将超时。
 *
 * @note
 * [EN]: - Default value is 30 seconds
 *       - Valid range is 0-120 seconds
 *       - 0 means no timeout（use default value 30 seconds）
 *
 * [CN]: - 默认值为30秒
 *       - 有效范围为0-120秒
 *       - 0表示无超时（使用默认30秒）
 */
@property (nonatomic,assign) NSInteger maxConnectTimeout;

/**
 * @brief Maximum device search duration
 * @chinese 最大设备搜索持续时间
 *
 * @discussion
 * [EN]: Maximum duration (in seconds) to search for devices.
 *       Search will automatically stop after this duration.
 * 
 * [CN]: 搜索设备的最大持续时间（秒）。
 *       超过此时间后搜索将自动停止。
 *
 * @note
 * [EN]: - Default value is 15 seconds
 *       - Valid range is 0-60 seconds
 *       - 0 will use default value （15 seconds）
 *
 * [CN]: - 默认值为15秒
 *       - 有效范围为0-60秒
 *       - 0则使用默认值（15秒）
 */
@property (nonatomic,assign) NSInteger maxScanSearchDuration;

/**
 * @brief Maximum reconnection attempts
 * @chinese 最大重连尝试次数
 *
 * @discussion
 * [EN]: Maximum number of attempts to reconnect to a device after disconnection.
 *       Reconnection will stop after reaching this limit.
 * 
 * [CN]: 断开连接后重新连接设备的最大尝试次数。
 *       达到此限制后重连将停止。
 *
 * @note
 * [EN]: - Default value is 5 attempts
 *       - Valid range is 1-10
 *       - Higher values may impact battery life
 * 
 * [CN]: - 默认值为5次尝试
 *       - 有效范围为1-10
 *       - 较高的值可能影响电池寿命
 */
@property (nonatomic,assign) NSInteger maxTryConnectCount;

/**
 * @brief Auto-connect on app launch
 * @chinese 应用启动时自动连接
 *
 * @discussion
 * [EN]: Controls whether to automatically attempt connection to the last connected device
 *       when the app launches.
 * 
 * [CN]: 控制是否在应用启动时自动尝试连接上次连接的设备。
 *
 * @note
 * [EN]: - Default value is NO
 *       - Requires previous successful connection
 *       - May impact app launch time
 * 
 * [CN]: - 默认值为NO
 *       - 需要之前有成功的连接
 *       - 可能影响应用启动时间
 */
@property (nonatomic,assign) BOOL autoConnectWhenAppLaunch;

/**
 * @brief Get default configuration options
 * @chinese 获取默认配置选项
 *
 * @return 
 * [EN]: Returns a TSKitConfigOptions object with default values:
 *       - SDK Type: eTSSDKTypeFit
 *       - Development Mode: NO
 *       - Bluetooth Authority Check: NO
 *       - Connect Timeout: 45 seconds
 *       - Search Duration: 30 seconds
 *       - Reconnect Attempts: 10
 * 
 * [CN]: 返回具有默认值的TSKitConfigOptions对象：
 *       - SDK类型：eTSSDKTypeFit
 *       - 开发模式：NO
 *       - 蓝牙权限检查：NO
 *       - 连接超时：45秒
 *       - 搜索持续时间：30秒
 *       - 重连尝试次数：10
 */
+ (TSKitConfigOptions *)defaultOption;

/**
 * @brief Get the device SDK prefix
 * @chinese 获取设备SDK前缀
 *
 */
- (nullable NSString *)periphSDKPrefixes;

/**
 * @brief Create configuration options with SDK type and license
 * @chinese 使用SDK类型和证书创建配置选项
 *
 * @param sdkType 
 * [EN]: The SDK type of the device
 * [CN]: 设备的SDK类型
 *
 * @param license
 * [EN]: SDK license key (Required)
 * [CN]: SDK证书密钥（必传）
 *
 * @return 
 * [EN]: Returns a new TSKitConfigOptions object initialized with the specified SDK type and license
 * [CN]: 返回使用指定SDK类型和证书初始化的新TSKitConfigOptions对象
 */
+ (TSKitConfigOptions *)configOptionWithSDKType:(TSSDKType)sdkType
                                      license:(NSString *)license;

@end

NS_ASSUME_NONNULL_END
