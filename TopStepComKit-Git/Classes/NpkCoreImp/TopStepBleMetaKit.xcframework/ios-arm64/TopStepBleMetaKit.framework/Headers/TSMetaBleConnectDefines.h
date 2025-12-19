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
     */
    eTSMetaAuthResponseSuccess = 0,
    
    /**
     * @brief User ID mismatch (Login mode only)
     * @chinese 用户ID不匹配（仅登录模式）
     */
    eTSMetaAuthResponseUserIdMismatch = 1,
    
    /**
     * @brief User cancelled binding (Bind mode only)
     * @chinese 用户取消了绑定（仅绑定模式）
     */
    eTSMetaAuthResponseBindCancelled = 2,
    
    /**
     * @brief Binding timeout (Bind mode only)
     * @chinese 绑定超时（仅绑定模式）
     */
    eTSMetaAuthResponseBindTimeout = 3,
    
    /**
     * @brief Classic Bluetooth not connected (iOS 12 and below)
     * @chinese 经典蓝牙未连接（iOS 12及以下）
     */
    eTSMetaAuthResponseClassicBTNotConnected = 4,
    
    /**
     * @brief Low battery, cannot delete data
     * @chinese 电量不足，无法删除数据
     */
    eTSMetaAuthResponseLowBattery = 5,
    
    /**
     * @brief Device is performing factory reset，Wait for factory reset to complete before retrying
     * @chinese 设备正在恢复出厂设置，在重试之前等待恢复出厂设置完成
     */
    eTSMetaAuthResponseFactoryResetting = 6,
    
    /**
     * @brief Factory reset required before rebinding
     * @chinese 需要用户操作恢复出厂设置后才能重新绑定
     */
    eTSMetaAuthResponseFactoryResetRequired = 7,
    
    /**
     * @brief Unknown failure
     * @chinese 未知失败
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


/**
 * @brief Scan complete reasons enumeration
 * @chinese 扫描失败原因枚举
 *
 * @discussion
 * [EN]: Defines various reasons why BLE scanning might fail
 * [CN]: 定义蓝牙扫描可能失败的各种原因
 */
typedef NS_ENUM(NSInteger, TSMetaScanCompletionReason) {
    eTSScanCompleteReasonTimeout = 1000,      // 扫描超时
    eTSScanCompleteReasonBleNotReady,         // 蓝牙未准备好
    eTSScanCompleteReasonPermissionDenied,    // 权限被拒绝
    eTSScanCompleteReasonUserStopped,         // 用户主动停止
    eTSScanCompleteReasonSystemError          // 系统错误
};

#pragma mark - Callback Block Definitions

/**
 * @brief Scan failed callback block
 * @chinese 扫描失败回调块
 *
 * @param reason
 * [EN]: The specific reason for scan failure
 * [CN]: 扫描失败的具体原因
 *
 * @param error
 * [EN]: Additional error information (may be nil)
 * [CN]: 额外的错误信息（可能为nil）
 *
 * @discussion
 * [EN]: Called when BLE scanning fails for any reason
 * [CN]: 当蓝牙扫描因任何原因失败时调用
 */
typedef void(^TSMetaScanCompletionBlock)(TSMetaScanCompletionReason reason, NSError * _Nullable error);

/**
 * @brief Peripheral discovery callback block
 * @chinese 外设发现回调块
 *
 * @param peripheral
 * [EN]: The discovered BLE peripheral
 * [CN]: 发现的蓝牙外设
 *
 * @param advertisementData
 * [EN]: Advertisement data from the peripheral
 * [CN]: 来自外设的广播数据
 *
 * @param RSSI
 * [EN]: Received Signal Strength Indicator
 * [CN]: 接收信号强度指示器
 *
 * @discussion
 * [EN]: Called when a BLE peripheral is discovered during scanning
 * [CN]: 在扫描过程中发现蓝牙外设时调用
 */
typedef void(^DidDiscoverPeripheralBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);


typedef NS_ENUM(NSUInteger, TSMetaBleConnectionState) {
    /// 未连接
    eTSMetaBleStateDisconnected = 0,
    /// 连接中
    eTSMetaBleStateConnecting,
    /// 已连接
    eTSMetaBleStateConnected
};

typedef void (^TSMetaBleConnectionCompletionBlock)(TSMetaBleConnectionState conncetionState,NSError *error);

#endif /* TSMetaBleConnectDefines_h */
