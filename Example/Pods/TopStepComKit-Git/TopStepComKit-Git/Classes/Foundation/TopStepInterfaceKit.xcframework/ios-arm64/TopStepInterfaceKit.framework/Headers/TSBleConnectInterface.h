//
//  TSBleConnect.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/30.
//
//  文件说明:
//  蓝牙连接管理协议，定义了蓝牙设备搜索、连接、绑定等基本操作

#import <Foundation/Foundation.h>
#import "TSComConstDefines.h"
#import "TSKitBaseInterface.h"
#import "TSPeripheral.h"
#import "TSPeripheralConnectParam.h"



NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Connection result callback type
 * @chinese 连接结果回调类型
 *
 * @param conncetionState
 * [EN]: Connection state (connected/disconnected/connecting)
 * [CN]: 连接状态（已连接/未连接/连接中）
 *
 * @param errorCode
 * [EN]: Error code, TSBleErrorNone if successful
 * [CN]: 错误码，连接成功时为TSBleErrorNone
 */
typedef void (^TSBleConnectionCallback)(TSBleConnectionState conncetionState, TSBleConnectionError errorCode);

/**
 * @brief Scan peripheral callback type 
 * @chinese 扫描外设回调类型
 *
 * @param peripheral 
 * [EN]: Discovered peripheral with device name, ID and other information
 * [CN]: 扫描到的外设对象，包含设备名称、ID等信息
 */
typedef void (^TSBleScanCallback)(TSPeripheral *peripheral);

/**
 * @brief Bluetooth connection management protocol
 * @chinese 蓝牙连接管理协议
 *
 * @discussion 
 * [EN]: Defines methods for Bluetooth device connection management including search, connect, and binding.
 *       All callbacks are executed on the main thread.
 * [CN]: 定义了管理蓝牙设备连接的所有方法，包括设备搜索、连接、绑定等操作。
 *       所有回调均在主线程上执行。
 */
@protocol TSBleConnectInterface <TSKitBaseInterface>

@required

/**
 * @brief Request current Bluetooth connection state
 * @chinese 获取当前蓝牙连接状态
 *
 * @param completion 
 * [EN]: Callback that returns current connection state and error
 * [CN]: 返回当前连接状态和错误的回调
 *
 * @discussion 
 * [EN]: - Can be safely called from any thread
 *       - Callback always executes on main thread
 *       - Possible states: disconnected/connecting/connected
 *       - For disconnected state, error may contain reason
 * [CN]: - 可从任何线程安全调用
 *       - 回调始终在主线程执行
 *       - 可能的状态: 未连接/连接中/已连接
 *       - 断开连接状态时，error可能包含断开原因
 */
- (void)requestConnectState:(TSBleConnectionCallback)completion;

/**
 * @brief Start searching for Bluetooth devices
 * @chinese 开始搜索蓝牙设备
 *
 * @param scanCompletion 
 * [EN]: Callback triggered when a new device is discovered
 * [CN]: 发现新设备时触发的回调
 *
 * @param errorCompletion
 * [EN]: Callback for scan errors, called once when an error occurs
 * [CN]: 扫描出错时触发的回调，仅当出错时调用一次
 *
 * @discussion 
 * [EN]: - Search continues until stopSearchPeripheral is called or connection succeeds
 *       - Call stopSearchPeripheral when not needed to save battery
 * [CN]: - 搜索过程持续进行，直到调用stopSearchPeripheral或连接成功
 *       - 不需要搜索时应调用stopSearchPeripheral以节省电量
 */
- (void)startSearchPeripheral:(TSBleScanCallback)scanCompletion
                errorHandler:(nullable void(^)(TSBleConnectionError errorCode))errorCompletion;

/**
 * @brief Stop searching for Bluetooth devices
 * @chinese 停止搜索蓝牙设备
 *
 * @discussion 
 * [EN]: - Safe to call even if not scanning
 *       - Should be called after successful connection or when exiting search UI
 * [CN]: - 即使未在扫描也可安全调用
 *       - 应在连接成功后或退出搜索界面时调用
 */
- (void)stopSearchPeripheral;

/**
 * @brief Connect and bind to a Bluetooth device
 * @chinese 连接并绑定蓝牙设备
 *
 * @param peripheral 
 * [EN]: Peripheral device to connect to
 * [CN]: 要连接的外设
 *
 * @param param 
 * [EN]: Connection parameters with binding info including user ID
 * [CN]: 包含用户ID等绑定信息的连接参数
 *
 * @param completion 
 * [EN]: Callback that returns connection state changes
 * [CN]: 返回连接状态变化的回调
 *
 * @discussion 
 * [EN]: - Use for first-time device connections
 *       - Process includes: connection, authentication, service discovery and binding
 *       - Callback triggers multiple times to reflect different states
 * [CN]: - 用于首次连接设备
 *       - 连接过程包括：连接建立、认证、服务发现和设备绑定
 *       - 回调会多次触发以反映连接过程的不同状态
 */
- (void)connectAndBindWithPeripheral:(TSPeripheral *)peripheral
                              param:(TSPeripheralConnectParam *)param
                        completion:(TSBleConnectionCallback)completion;

/**
 * @brief Reconnect to a previously bound device
 * @chinese 重新连接之前绑定的设备
 *
 * @param peripheral 
 * [EN]: Peripheral device to reconnect to
 * [CN]: 要重连的外设
 *
 * @param param 
 * [EN]: Connection parameters with same user ID as original binding
 * [CN]: 包含与原绑定相同用户ID的连接参数
 *
 * @param completion 
 * [EN]: Callback that returns connection state changes
 * [CN]: 返回连接状态变化的回调
 *
 * @discussion 
 * [EN]: - Reconnection is typically faster than initial connection
 *       - User ID in param must match original binding user
 *       - Fails with specific error codes (out of range, authentication failed, etc.)
 * [CN]: - 重连过程通常比首次连接更快
 *       - param中的userId必须与原绑定用户匹配
 *       - 失败时会返回相应错误码（设备不在范围、认证失败等）
 */
- (void)reconnectWithPeripheral:(TSPeripheral *)peripheral
                         param:(TSPeripheralConnectParam *)param
                   completion:(TSBleConnectionCallback)completion;

/**
 * @brief Disconnect from the currently connected device
 * @chinese 断开当前连接的设备
 *
 * @param completion 
 * [EN]: Callback that returns disconnection result with error if any
 * [CN]: 返回断开结果的回调
 *
 * @discussion 
 * [EN]: - Safely disconnects while preserving binding information
 *       - Can reconnect later using reconnectWithPeripheral method
 *       - Useful for temporary disconnection or battery saving
 * [CN]: - 安全断开连接但保留绑定信息
 *       - 可以之后使用reconnectWithPeripheral方法重新连接
 *       - 适用于临时断开连接或节省电量的场景
 */
- (void)disconnectWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Unbind the currently connected device
 * @chinese 解除当前设备的绑定
 *
 * @param completion 
 * [EN]: Callback that returns unbinding result with error if any
 * [CN]: 返回解绑结果的回调
 *
 * @discussion 
 * [EN]: - Completely unbinds device, clearing all pairing information
 *       - After unbinding, must use connectAndBindWithPeripheral to rebind
 *       - Used for changing users, transferring device, or troubleshooting
 * [CN]: - 完全解除设备绑定，清除所有配对信息
 *       - 解绑后需要使用connectAndBindWithPeripheral重新绑定
 *       - 适用于更换用户、设备转移或故障排除
 */
- (void)unbindPeripheralWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Check if a device is currently connected
 * @chinese 检查设备是否已连接
 *
 * @return 
 * [EN]: YES if device is connected, NO otherwise
 * [CN]: 设备已连接返回YES，否则返回NO
 *
 * @discussion 
 * [EN]: - Lightweight method checking only basic connection status
 *       - Useful for UI updates or simple connection checks
 *       - For detailed status including errors, use requestConnectState:
 * [CN]: - 轻量级方法，仅检查基本连接状态
 *       - 适用于UI状态更新或简单连接检查
 *       - 不提供错误信息，需要详细状态请使用requestConnectState:
 */
- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
