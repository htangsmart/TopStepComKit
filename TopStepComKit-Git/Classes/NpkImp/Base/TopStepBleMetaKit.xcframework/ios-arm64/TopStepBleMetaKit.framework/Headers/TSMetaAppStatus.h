//
//  TSMetaAppStatus.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSBusinessBase.h"
#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief App status management class
 * @chinese App状态管理类
 *
 * @discussion
 * [EN]: Provides methods to update and synchronize app status with connected devices.
 *       Used to notify devices about app foreground state and permission changes.
 * [CN]: 提供更新和同步应用状态与连接设备的方法。
 *       用于通知设备应用前台状态和权限变化。
 */
@interface TSMetaAppStatus : TSBusinessBase

/**
 * @brief Update app status to device
 * @chinese 更新App状态到设备
 *
 * @param appStatus
 * EN: App status model containing foreground state and permissions
 * CN: 包含前台状态和权限信息的App状态模型
 *
 * @param completion
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 *
 * @discussion
 * [EN]: Sends the current app status (foreground state, SMS permission, location permission)
 *       to the connected device using eCommandEnvSetting with eAppStatusChanged key.
 *       The device can adjust its behavior based on app status.
 *
 * [CN]: 使用 eCommandEnvSetting 命令和 eAppStatusChanged 键将当前应用状态
 *       （前台状态、短信权限、定位权限）发送到已连接的设备。
 *       设备可以根据应用状态调整其行为。
 */
+ (void)updateAppStatus:(TSMetaAppStatusModel *)appStatus
             completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Register listener for device requesting app status refresh
 * @chinese 注册外设主动获取App状态的监听
 *
 * @param completion
 * EN: Callback invoked when device sends eDeviceRefreshAppStatus command.
 *     Called on main thread. Handler remains active until explicitly removed.
 * CN: 当外设发送 eDeviceRefreshAppStatus 指令时触发的回调。
 *     在主线程调用。处理器保持活动直到显式移除。
 *
 * @discussion
 * [EN]: Registers a listener for eDeviceRefreshAppStatus command from the device.
 *       When the device sends this command, the completion callback will be invoked.
 *       The handler remains active until explicitly removed with removeObserverWithCommand:key:.
 *
 * [CN]: 注册监听外设发送的 eDeviceRefreshAppStatus 指令。
 *       当外设发送此指令时，会调用 completion 回调。
 *       处理器保持活动直到使用 removeObserverWithCommand:key: 显式移除。
 *
 * @note
 * [EN]: Multiple registrations for the same command+key will override previous ones.
 *       Remember to call removeObserverWithCommand:key: when done to avoid memory leaks.
 *       The completion block is retained, so avoid capturing self strongly to prevent retain cycles.
 * [CN]: 对相同 command+key 的多次注册会覆盖之前的注册。
 *       使用完毕后记得调用 removeObserverWithCommand:key: 以避免内存泄漏。
 *       完成回调会被保持，避免强引用 self 以防止循环引用。
 */
+ (void)registerDeviceRefreshAppStatusListener:(void(^)(void))completion;

/**
 * @brief Remove listener for device requesting app status refresh
 * @chinese 移除外设主动获取App状态的监听
 *
 * @discussion
 * [EN]: Removes the previously registered listener for eDeviceRefreshAppStatus command.
 *       After calling this method, the completion callback will no longer be invoked
 *       when the device sends eDeviceRefreshAppStatus command.
 *       
 *       Best practices:
 *       - Call this method when the listener is no longer needed
 *       - Always call before the observer object is deallocated
 *       - Safe to call even if no listener was registered
 *
 * [CN]: 移除之前注册的 eDeviceRefreshAppStatus 指令监听。
 *       调用此方法后，当外设发送 eDeviceRefreshAppStatus 指令时，
 *       完成回调将不再被调用。
 *       
 *       最佳实践：
 *       - 当不再需要监听时调用此方法
 *       - 在观察者对象销毁前始终调用
 *       - 即使没有注册监听，调用也是安全的
 */
+ (void)removeDeviceRefreshAppStatusListener;

@end

NS_ASSUME_NONNULL_END
