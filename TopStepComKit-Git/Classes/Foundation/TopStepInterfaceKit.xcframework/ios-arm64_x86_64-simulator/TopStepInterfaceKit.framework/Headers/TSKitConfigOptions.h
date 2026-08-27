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
 * [EN]: This class manages global SDK configuration options, including:
 *       - SDK type and license management
 *       - Development mode and logging settings
 *       - Global Bluetooth permission policy
 *
 * [CN]: 该类管理 SDK 的全局配置选项，包括：
 *       - SDK类型和证书管理
 *       - 开发模式与日志设置
 *       - 全局蓝牙权限策略
 */

#import "TSKitBaseModel.h"
#import "TSComEnumDefines.h"
#import "TSLogConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSKitConfigOptions : TSKitBaseModel

#pragma mark - 基础配置 (Basic Configuration)

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
 */
@property (nonatomic,assign) TSSDKType sdkType;

/**
 * @brief SDK license key
 * @chinese SDK证书密钥
 */
@property (nonatomic, copy, nullable) NSString *license;

#pragma mark - 日志相关配置 (Log Configuration)

/**
 * @brief Logging configuration
 * @chinese 日志配置
 */
@property (nonatomic, strong) TSLogConfig *logConfig;

/**
 * @brief Custom watch-face style service URL
 * @chinese 自定义表盘样式服务地址
 *
 * @discussion
 * [EN]: NPK uses this HTTPS endpoint to fetch provider-owned style constraints and templates.
 * [CN]: NPK 使用该 HTTPS 地址获取 Provider 持有的样式约束和模板。
 */
@property (nonatomic, strong) NSURL *customDialStyleServiceURL;


/**
 * @brief Get default configuration options
 * @chinese 获取默认配置选项
 *
 * @return
 * [EN]: Returns a TSKitConfigOptions object with default values:
 *       - SDK Type: eTSSDKTypeFIT
 *       - Development Mode: NO
 *       - Bluetooth Authority Check: NO
 *
 * [CN]: 返回具有默认值的TSKitConfigOptions对象：
 *       - SDK类型：eTSSDKTypeFIT
 *       - 开发模式：NO
 *       - 蓝牙权限检查：NO
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
