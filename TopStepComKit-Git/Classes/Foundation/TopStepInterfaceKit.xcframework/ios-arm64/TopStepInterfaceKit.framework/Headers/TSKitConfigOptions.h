//
//  TSKitConfigOptions.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/1/3.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSKitConfigOptions : NSObject

/**
 * @brief SDK type
 * @chinese SDK类型
 */
@property (nonatomic,assign) TSSDKType sdkType;

/**
 * @brief SDK license key (Required)
 * @chinese SDK证书密钥（必传参数）
 *
 * @discussion
 * [EN]: The license key is a 32-character string used to validate SDK usage rights.
 *       Must be set before initializing the SDK.
 * [CN]: 证书密钥是一个32位字符串，用于验证SDK使用权限。
 *       必须在初始化SDK之前设置。
 *
 * @note
 * [EN]: - Length must be exactly 32 characters
 *       - Contains only letters (a-z, A-Z) and numbers (0-9)
 *       - SDK initialization will fail if license is invalid
 * [CN]: - 长度必须为32位字符
 *       - 只能包含字母(a-z, A-Z)和数字(0-9)
 *       - 证书无效将导致SDK初始化失败
 */
@property (nonatomic, copy, nullable) NSString *license;

/**
 * @brief Development mode flag
 * @chinese 开发模式标志
 */
@property (nonatomic,assign) BOOL isDevelopModel;

/**
 * @brief Bluetooth permission check flag
 * @chinese 蓝牙权限检查标志
 */
@property (nonatomic,assign) BOOL isCheckBluetoothAuthority;

/**
 * @brief Maximum duration for maintaining a connection
 * @chinese 最大连接绑定持续时间
 *
 * @discussion
 * [EN]: Maximum duration for maintaining a connection.
 * [CN]: 维持连接的最大持续时间。
 *
 * @note
 * [EN]: Valid range is 0-120 seconds.
 * [CN]: 有效范围为0-30秒。
 */
@property (nonatomic,assign) NSInteger maxConnectTimeout;

/**
 * @brief Maximum duration for searching devices
 * @chinese 最大搜索持续时间
 *
 * @discussion
 * [EN]: Maximum duration for searching devices.
 * [CN]: 搜索设备的最大持续时间。
 *
 * @note
 * [EN]: Valid range is 0-60 seconds.
 * [CN]: 有效范围为0-30秒。
 */
@property (nonatomic,assign) NSInteger maxScanSearchDuration;

/**
 * @brief Maximum number of attempts to reconnect
 * @chinese 最大重连尝试次数
 *
 * @discussion
 * [EN]: Maximum number of attempts to reconnect.
 * [CN]: 最大重连尝试次数。
 *
 * @note
 * [EN]: Valid range is 1-10.
 * [CN]: 有效范围为1-10。
 */
@property (nonatomic,assign) NSInteger maxTryConnectCount;

/**
 * @brief Whether to auto-connect at startup
 * @chinese 启动时是否自动连接
 */
@property (nonatomic,assign) BOOL autoConnectWhenAppLaunch;

/**
 * @brief Get default configuration options
 * @chinese 获取默认配置选项
 * 
 * @return 
 * EN: Returns the default TSKitConfigOptions object
 * CN: 返回默认的TSKitConfigOptions对象
 */
+ (TSKitConfigOptions *)defaultOption;

/**
 * @brief Get the device SDK prefix
 * @chinese 获取设备SDK前缀
 * 
 * @return 
 * EN: Returns the prefix identifier corresponding to the SDK type
 * CN: 返回对应SDK类型的前缀标识符
 * 
 * @discussion Returns the prefix based on the device SDK type:
 * - TSFIT: 瑞昱SDK
 * - TSFW: 恒玄SDK
 * - TSSJ: 伸聚SDK
 * - Empty string: Unknown type
 */
- (nullable NSString *)periphSDKPrefixes;

/**
 * @brief Get configuration options based on SDK type and license
 * @chinese 根据SDK类型和证书获取配置选项
 * 
 * @param sdkType 
 * EN: The SDK type of the device
 * CN: 设备的SDK类型
 *
 * @param license
 * EN: SDK license key (Required)
 * CN: SDK证书密钥（必传）
 * 
 * @return 
 * EN: Returns the TSKitConfigOptions object corresponding to the SDK type
 * CN: 返回对应SDK类型的TSKitConfigOptions对象
 */
+ (TSKitConfigOptions *)configOptionWithSDKType:(TSSDKType)sdkType
                                      license:(NSString *)license;

@end

NS_ASSUME_NONNULL_END
