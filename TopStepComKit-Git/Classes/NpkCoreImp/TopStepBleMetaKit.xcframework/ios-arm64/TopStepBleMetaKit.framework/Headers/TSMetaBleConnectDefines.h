//
//  TSMetaBleConnectDefines.h
//  Pods
//
//  Created by 磐石 on 2025/11/17.
//

#ifndef TSMetaBleConnectDefines_h
#define TSMetaBleConnectDefines_h

#import <Foundation/Foundation.h>

#pragma mark - Authentication Response Enums

/**
 * @brief Authentication response result enumeration
 * @chinese 认证响应结果枚举
 *
 * @discussion
 * [EN]: Defines the possible result codes returned by device authentication (bind/login) operations.
 *       These codes help identify specific failure reasons and guide the app's next action.
 * [CN]: 定义设备认证（绑定/登录）操作返回的可能结果码。
 *       这些代码有助于识别具体的失败原因并指导应用的下一步操作。
 *
 * @note
 * [EN]: - Codes 1 applies only to login mode
 *       - Codes 2-3 apply only to bind mode
 *       - Code 6-7 indicate factory reset scenarios
 * [CN]: - 代码1仅适用于登录模式
 *       - 代码2-3仅适用于绑定模式
 *       - 代码6-7表示恢复出厂设置场景
 */
typedef NS_ENUM(NSInteger, TSMetaAuthResponseResult) {
    /**
     * @brief Authentication successful
     * @chinese 认证成功
     *
     * @discussion
     * [EN]: Authentication completed successfully. Device is ready for use.
     * [CN]: 认证成功完成。设备已准备就绪可以使用。
     */
    eTSMetaAuthResponseSuccess = 0,
    
    /**
     * @brief User ID mismatch (Login mode only)
     * @chinese 用户ID不匹配（仅登录模式）
     *
     * @discussion
     * [EN]: The userId provided doesn't match the one bound to the device.
     *       This typically indicates the device was factory reset or bound to another user.
     *       App should prompt user to rebind the device.
     * [CN]: 提供的userId与设备绑定的userId不匹配。
     *       这通常表示设备已恢复出厂设置或绑定到其他用户。
     *       应用应提示用户重新绑定设备。
     *
     * @note
     * [EN]: Only occurs in login mode
     * [CN]: 仅在登录模式下出现
     */
    eTSMetaAuthResponseUserIdMismatch = 1,
    
    /**
     * @brief User cancelled binding (Bind mode only)
     * @chinese 用户取消了绑定（仅绑定模式）
     *
     * @discussion
     * [EN]: User manually cancelled the binding operation on the device.
     *       App should display cancellation message and allow retry.
     * [CN]: 用户在设备上手动取消了绑定操作。
     *       应用应显示取消消息并允许重试。
     *
     * @note
     * [EN]: Only occurs in bind mode
     * [CN]: 仅在绑定模式下出现
     */
    eTSMetaAuthResponseBindCancelled = 2,
    
    /**
     * @brief Binding timeout (Bind mode only)
     * @chinese 绑定超时（仅绑定模式）
     *
     * @discussion
     * [EN]: User didn't respond to the binding request within the timeout period.
     *       App should prompt user to retry and respond more quickly.
     * [CN]: 用户在超时时间内未响应绑定请求。
     *       应用应提示用户重试并更快地响应。
     *
     * @note
     * [EN]: Only occurs in bind mode
     * [CN]: 仅在绑定模式下出现
     */
    eTSMetaAuthResponseBindTimeout = 3,
    
    /**
     * @brief Classic Bluetooth not connected (iOS 12 and below)
     * @chinese 经典蓝牙未连接（iOS 12及以下）
     *
     * @discussion
     * [EN]: On iOS 12 and below, binding succeeded but classic Bluetooth connection failed.
     *       Treat this as success (equivalent to code 0) for BLE functionality.
     *       Classic Bluetooth features may be unavailable.
     * [CN]: 在iOS 12及以下系统，绑定成功但经典蓝牙连接失败。
     *       对于BLE功能，将其视为成功（等同于代码0）。
     *       经典蓝牙功能可能不可用。
     *
     * @note
     * [EN]: Equivalent to success for BLE operations
     * [CN]: 对于BLE操作等同于成功
     */
    eTSMetaAuthResponseClassicBTNotConnected = 4,
    
    /**
     * @brief Low battery, cannot delete data
     * @chinese 电量不足，无法删除数据
     *
     * @discussion
     * [EN]: Device battery is too low to perform data deletion required for binding.
     *       App should prompt user to charge the device before retrying.
     * [CN]: 设备电量太低，无法执行绑定所需的数据删除操作。
     *       应用应提示用户在重试前给设备充电。
     *
     * @note
     * [EN]: Typically occurs during bind when device needs to clear previous data
     * [CN]: 通常在绑定时发生，当设备需要清除以前的数据时
     */
    eTSMetaAuthResponseLowBattery = 5,
    
    /**
     * @brief Device is performing factory reset
     * @chinese 设备正在恢复出厂设置
     *
     * @discussion
     * [EN]: Device is currently performing a factory reset operation.
     *       App should wait and retry connection after the reset completes.
     * [CN]: 设备当前正在执行恢复出厂设置操作。
     *       应用应等待并在重置完成后重试连接。
     *
     * @note
     * [EN]: Wait for factory reset to complete before retrying
     * [CN]: 在重试之前等待恢复出厂设置完成
     */
    eTSMetaAuthResponseFactoryResetting = 6,
    
    /**
     * @brief Factory reset required before rebinding
     * @chinese 需要用户操作恢复出厂设置后才能重新绑定
     *
     * @discussion
     * [EN]: Device requires user to manually perform factory reset before allowing rebinding.
     *       This occurs when device was previously bound and needs to be cleared.
     *       App should guide user through factory reset process.
     * [CN]: 设备要求用户手动执行恢复出厂设置后才允许重新绑定。
     *       当设备之前已绑定且需要清除时会出现此情况。
     *       应用应引导用户完成恢复出厂设置流程。
     *
     * @note
     * [EN]: User must perform factory reset on device before rebinding
     * [CN]: 用户必须在设备上执行恢复出厂设置后才能重新绑定
     */
    eTSMetaAuthResponseFactoryResetRequired = 7,
    
    /**
     * @brief Unknown failure
     * @chinese 未知失败
     *
     * @discussion
     * [EN]: An unknown error occurred during authentication.
     *       App should log the error and display a generic error message.
     * [CN]: 认证过程中发生未知错误。
     *       应用应记录错误并显示通用错误消息。
     */
    eTSMetaAuthResponseUnknownError = 127
};

#pragma mark - Helper Functions

/**
 * @brief Check if authentication response indicates success
 * @chinese 检查认证响应是否表示成功
 *
 * @param response Authentication response code
 *
 * @return YES if successful, NO otherwise
 *
 * @discussion
 * [EN]: Considers both code 0 (success) and code 4 (classic BT not connected) as success.
 * [CN]: 将代码0（成功）和代码4（经典蓝牙未连接）都视为成功。
 */
static inline BOOL TSMetaAuthResponseIsSuccess(TSMetaAuthResponseResult response) {
    return (response == eTSMetaAuthResponseSuccess || 
            response == eTSMetaAuthResponseClassicBTNotConnected);
}

/**
 * @brief Check if authentication response indicates factory reset scenario
 * @chinese 检查认证响应是否表示恢复出厂设置场景
 *
 * @param response Authentication response code
 *
 * @return YES if factory reset related, NO otherwise
 *
 * @discussion
 * [EN]: Returns YES for codes 6 and 7 which indicate factory reset scenarios.
 * [CN]: 对于代码6和7返回YES，这些代码表示恢复出厂设置场景。
 */
static inline BOOL TSMetaAuthResponseIsFactoryReset(TSMetaAuthResponseResult response) {
    return (response == eTSMetaAuthResponseFactoryResetting ||
            response == eTSMetaAuthResponseFactoryResetRequired);
}

/**
 * @brief Check if should retry with bind mode
 * @chinese 检查是否应以绑定模式重试
 *
 * @param response Authentication response code
 *
 * @return YES if should retry with bind mode, NO otherwise
 *
 * @discussion
 * [EN]: Returns YES for user ID mismatch, which indicates device needs rebinding.
 * [CN]: 对于用户ID不匹配返回YES，表示设备需要重新绑定。
 */
static inline BOOL TSMetaAuthResponseShouldRetryWithBind(TSMetaAuthResponseResult response) {
    return (response == eTSMetaAuthResponseUserIdMismatch);
}

#endif /* TSMetaBleConnectDefines_h */
