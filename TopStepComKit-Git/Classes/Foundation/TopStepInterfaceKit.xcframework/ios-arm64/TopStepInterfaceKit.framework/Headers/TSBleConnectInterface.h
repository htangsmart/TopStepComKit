//
//  TSBleConnect.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/30.
//
//  文件说明:
//  蓝牙连接管理协议，定义了蓝牙设备搜索、连接、绑定等基本操作

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSBleConnectDefines.h"
#import "TSComConstDefines.h"
#import "TSKitBaseInterface.h"
#import "TSPeripheral.h"
#import "TSPeripheralConnectParam.h"
#import "TSPeripheralScanParam.h"
#import "TSComEnumDefines.h"
#import "TSBluetoothSystem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bluetooth device discovery callback block type
 * @chinese 蓝牙设备发现回调块类型
 *
 * @param peripheral
 * [EN]: Discovered peripheral with device name, ID and other information
 * [CN]: 扫描到的外设对象，包含设备名称、ID等信息
 */
typedef void(^TSScanDiscoveryBlock)(TSPeripheral *_Nonnull peripheral);

/**
 * @brief Scan completion callback block type
 * @chinese 扫描完成回调块类型
 *
 * @discussion
 * [EN]: Invoked when a scan completes (success/timeout/stop/error), with a reason and optional error
 * [CN]: 扫描完成（成功/超时/停止/错误）时回调，包含完成原因与可选错误
 */
typedef void(^TSScanCompletionBlock)(TSScanCompletionReason reason, NSError * _Nullable error);

/**
 * @brief Bluetooth connection state callback block type
 * @chinese 蓝牙连接状态回调块类型
 *
 * @param connectionState
 * [EN]: Current connection state of the Bluetooth device during the connection lifecycle:
 *       - eTSBleStateDisconnected (0): Device is not connected (initial state or after any failure/disconnection)
 *       - eTSBleStateConnecting (1): Establishing BLE physical connection
 *       - eTSBleStateAuthenticating (2): Performing bind/login authentication
 *       - eTSBleStatePreparingData (3): Fetching device information after authentication
 *       - eTSBleStateConnected (4): Fully connected and ready for data operations
 * [CN]: 蓝牙设备连接生命周期的当前状态：
 *       - eTSBleStateDisconnected (0): 设备未连接（初始状态或任何失败/断开后）
 *       - eTSBleStateConnecting (1): 正在建立BLE物理连接
 *       - eTSBleStateAuthenticating (2): 正在执行绑定/登录认证
 *       - eTSBleStatePreparingData (3): 认证成功后正在获取设备信息
 *       - eTSBleStateConnected (4): 完全连接且就绪，可进行数据操作
 *
 * @param error
 * [EN]: Optional error for failed state query or failed state transition.
 * [CN]: 状态查询失败或状态变化失败时的错误信息。
 */
typedef void (^TSBleConnectionStateBlock)(TSBleConnectionState connectionState, NSError *_Nullable error);

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

#pragma mark - Connection State

/**
 * @brief Get current Bluetooth connection state
 * @chinese 获取当前蓝牙连接状态
 *
 * @param completion
 * [EN]: Callback that returns current connection state. Pass nil to ignore.
 * [CN]: 返回当前连接状态的回调。传 nil 表示忽略。
 */
- (void)getConnectState:(nullable TSBleConnectionStateBlock)completion;

/**
 * @brief Register connection state change callback
 * @chinese 注册连接状态变化回调
 *
 * @param completion
 * [EN]: Connection state change callback. Pass nil to unregister.
 * [CN]: 连接状态变化回调。传 nil 表示取消监听。
 *
 * @discussion
 * [EN]: This callback is global for the connector and is not tied to a single
 *       connect request. It reports connection progress and later state changes
 *       such as device/system disconnection.
 * [CN]: 该回调是连接器级别的全局监听，不绑定某一次 connect 请求。它会回调
 *       连接过程状态，也会回调后续设备或系统断连等状态变化。
 */
- (void)registerConnectionStateDidChanged:(nullable TSBleConnectionStateBlock)completion;

#pragma mark - Device Discovery

/**
 * @brief Start searching for Bluetooth devices
 * @chinese 开始搜索蓝牙设备
 *
 * @param timeout
 * [EN]: Scan timeout in seconds. If 0, TSDefaultPeripheralScanTimeout (30 seconds) is used.
 * [CN]: 扫描超时时间（秒）。为0时使用 TSDefaultPeripheralScanTimeout（30秒）。
 *
 * @param discoverPeripheral
 * [EN]: Callback triggered when a new device is discovered
 * [CN]: 发现新设备时触发的回调
 *
 * @param completion
 * [EN]: Callback when scan completes or times out
 * [CN]: 扫描完成或超时时的回调
 *
 * @discussion
 * [EN]: - Search continues until timeout (TSDefaultPeripheralScanTimeout, 30 seconds, if 0), stopSearchPeripheral is called, or connection succeeds
 *       - Call stopSearchPeripheral when not needed to save battery
 *       - All callbacks execute on main thread
 * [CN]: - 搜索过程持续进行，直到超时（0表示使用 TSDefaultPeripheralScanTimeout，30秒）、调用stopSearchPeripheral或连接成功
 *       - 不需要搜索时应调用stopSearchPeripheral以节省电量
 *       - 所有回调都在主线程执行
 */
- (void)startSearchPeripheral:(NSTimeInterval)timeout
           discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                   completion:(TSScanCompletionBlock)completion;

/**
 * @brief Start searching for Bluetooth devices with advanced parameters
 * @chinese 使用高级参数开始搜索蓝牙设备
 *
 * @param param
 * [EN]: Scan parameters including filters (UUIDs, BLE name, MAC), timeout, duplicates, etc.
 * [CN]: 扫描参数，包含过滤条件（UUID、蓝牙名称、MAC）、超时、是否允许重复等。
 *
 * @param discoverPeripheral
 * [EN]: Callback triggered when a new device is discovered
 * [CN]: 发现新设备时触发的回调
 *
 * @param completion
 * [EN]: Callback when scan completes with reason and optional error
 * [CN]: 扫描完成回调，包含完成原因与可选错误
 *
 * @discussion
 * [EN]:
 *  - If param.scanTimeout > 0, scanning stops automatically after the duration
 *  - If param.scanTimeout == 0, the SDK uses TSDefaultPeripheralScanTimeout (30 seconds)
 *  - All callbacks execute on main thread
 * [CN]:
 *  - 当 param.scanTimeout > 0 时，到时会自动停止扫描
 *  - 当 param.scanTimeout == 0 时，SDK 使用 TSDefaultPeripheralScanTimeout（30秒）
 *  - 所有回调均在主线程执行
 */
- (void)startSearchPeripheralWithParam:(TSPeripheralScanParam *)param
                    discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                            completion:(TSScanCompletionBlock)completion;

/**
 * @brief Stop searching for Bluetooth devices
 * @chinese 停止搜索蓝牙设备
 *
 * @discussion
 * [EN]: - Safe to call even if not scanning
 *       - Should be called after successful connection or when exiting search UI
 *       - Automatically called when scan timeout occurs
 * [CN]: - 即使未在扫描也可安全调用
 *       - 应在连接成功后或退出搜索界面时调用
 *       - 扫描超时时会自动调用
 */
- (void)stopSearchPeripheral;

#pragma mark - Connection Session

/**
 * @brief Connect to a Bluetooth device discovered by the SDK
 * @chinese 连接由SDK发现的蓝牙设备
 *
 * @param peripheral
 * [EN]: Peripheral device to connect to. Prefer passing a TSPeripheral returned by SDK scanning
 *       or a TSPeripheral restored by the SDK. Manually constructed TSPeripheral instances are
 *       only valid when they contain a reconnectable identifier such as systemInfo.mac.
 * [CN]: 要连接的外设。推荐传入SDK扫描返回的TSPeripheral或SDK恢复的历史设备。
 *       手动构造的TSPeripheral仅在包含systemInfo.mac等可重新发现标识时有效。
 *
 * @param param
 * [EN]: Connection parameters. See TSPeripheralConnectParam for required field rules.
 * [CN]: 连接参数。字段必填规则见 TSPeripheralConnectParam。
 *
 * @param completion
 * [EN]: Callback for the final result of this connect request. It is invoked
 *       only when the request finally succeeds or fails. Intermediate states
 *       such as Connecting, Authenticating and PreparingData are reported by
 *       registerConnectionStateDidChanged:.
 * [CN]: 本次连接请求的最终结果回调，仅在本次请求最终成功或失败时触发。
 *       Connecting、Authenticating、PreparingData 等中间状态通过
 *       registerConnectionStateDidChanged: 回调。
 *
 * @discussion
 * [EN]: Invalid parameters or errors before entering the connection flow only
 *       invoke this completion and do not emit a connection state change.
 * [CN]: 参数错误或尚未进入连接流程前发生的错误，只回调本 completion，
 *       不触发连接状态变化监听。
 */
- (void)connectWithPeripheral:(TSPeripheral *)peripheral
                        param:(TSPeripheralConnectParam *)param
                   completion:(TSCompletionBlock)completion;

/**
 * @brief Connect to a Bluetooth device by MAC address
 * @chinese 通过MAC地址连接蓝牙设备
 *
 * @param macAddress
 * [EN]: Target device MAC address. The SDK will scan internally for a matching device before connecting.
 * [CN]: 目标设备MAC地址。SDK会在内部扫描匹配设备，找到后再发起连接。
 *
 * @param param
 * [EN]: Connection parameters. See TSPeripheralConnectParam for required field rules.
 * [CN]: 连接参数。字段必填规则见 TSPeripheralConnectParam。
 *
 * @param completion
 * [EN]: Callback for the final result of this connect request. Intermediate states
 *       are reported by registerConnectionStateDidChanged:.
 * [CN]: 本次连接请求最终结果回调。中间状态通过 registerConnectionStateDidChanged: 回调。
 *
 */
- (void)connectWithMacAddress:(NSString *)macAddress
                        param:(TSPeripheralConnectParam *)param
                   completion:(TSCompletionBlock)completion;

/**
 * @brief Disconnect from the currently connected device
 * @chinese 断开当前连接的设备
 *
 * @param completion
 * [EN]: Callback that returns disconnection result
 * [CN]: 返回断开结果的回调
 *
 * @discussion
 * [EN]: State callback rule:
 *       - This completion reports only the result of the disconnect operation.
 *       - A successful disconnect should also emit eTSBleStateDisconnected through
 *         registerConnectionStateDidChanged:.
 * [EN]: - Safely disconnects while preserving binding information
 *       - Can connect again later using connectWithPeripheral method
 *       - Useful for temporary disconnection or battery saving
 *       - All callbacks execute on main thread
 * [CN]: 状态回调规则：
 *       - 本 completion 只表示断开操作本身的结果。
 *       - 断开成功后，应同时通过 registerConnectionStateDidChanged: 回调
 *         eTSBleStateDisconnected 状态。
 * [CN]: - 安全断开连接但保留绑定信息
 *       - 可以之后使用connectWithPeripheral方法重新连接
 *       - 适用于临时断开连接或节省电量的场景
 *       - 所有回调都在主线程执行
 */
- (void)disconnectCompletion:(TSCompletionBlock)completion;

/**
 * @brief Unbind the currently connected device
 * @chinese 解除当前设备的绑定
 *
 * @param completion
 * [EN]: Callback that returns unbinding result
 * [CN]: 返回解绑结果的回调
 *
 * @discussion
 * [EN]: State callback rule:
 *       - This completion reports only the result of the unbind operation.
 *       - A successful unbind should also emit eTSBleStateDisconnected through
 *         registerConnectionStateDidChanged:.
 * [EN]: - Completely unbinds device, clearing all pairing information
 *       - After unbinding, must use connectWithPeripheral to rebind
 *       - Used for changing users, transferring device, or troubleshooting
 *       - All callbacks execute on main thread
 * [CN]: 状态回调规则：
 *       - 本 completion 只表示解绑操作本身的结果。
 *       - 解绑成功后，应同时通过 registerConnectionStateDidChanged: 回调
 *         eTSBleStateDisconnected 状态。
 * [CN]: - 完全解除设备绑定，清除所有配对信息
 *       - 解绑后需要使用connectWithPeripheral重新绑定
 *       - 适用于更换用户、设备转移或故障排除
 *       - 所有回调都在主线程执行
 */
- (void)unbindPeripheralCompletion:(TSCompletionBlock)completion;

#pragma mark - Connection State Query

/**
 * @brief Check if a device is currently connected
 * @chinese 检查设备是否已连接
 *
 * @return
 * [EN]: YES if device is connected, NO otherwise
 * [CN]: 设备已连接返回YES，否则返回NO
 *
 * @discussion
 * [EN]: - Returns YES only when the connector is fully ready for business commands
 *       - Semantically equivalent to current state being eTSBleStateConnected
 *       - Physical BLE connection without authentication/data preparation is not considered connected
 *       - Useful for UI updates or simple connection checks
 *       - For detailed status including errors, use getConnectState:
 *       - Thread-safe, can be called from any thread
 * [CN]: - 仅当连接器已完全就绪、可以执行业务命令时返回 YES
 *       - 语义上等价于当前状态为 eTSBleStateConnected
 *       - 仅完成 BLE 物理连接但尚未完成认证/数据准备时，不视为已连接
 *       - 适用于UI状态更新或简单连接检查
 *       - 不提供错误信息，需要详细状态请使用getConnectState:
 *       - 线程安全，可从任何线程调用
 */
- (BOOL)isConnected;

#pragma mark - Bluetooth System Info

/**
 * @brief Get Bluetooth adapter information
 * @chinese 获取蓝牙适配器信息
 *
 * @param completion
 * [EN]: Callback that returns Bluetooth system information including Classic Bluetooth and BLE adapter details.
 *       Called on main thread.
 * [CN]: 返回蓝牙系统信息的回调，包括经典蓝牙和BLE适配器详情。在主线程回调。
 *
 * @note
 * [EN]: - On iOS, Classic Bluetooth (BT) information may be limited or unavailable
 *       - MAC address access is restricted on iOS for privacy reasons
 *       - BLE status: 0=Not connected, 1=Connected, 2=Ready (Connected and Notify opened)
 *       - BT status: 0=Not connected, 1=Connected, 2=Ready (Connected and SPP opened)
 * [CN]: - 在iOS上，经典蓝牙（BT）信息可能受限或不可用
 *       - 出于隐私原因，iOS上MAC地址访问受限
 *       - BLE状态：0=未连接，1=已连接，2=已就绪（已连接且打开了Notify）
 *       - BT状态：0=未连接，1=已连接，2=已就绪（已连接且打开了SPP）
 */
- (void)getBluetoothInfo:(void(^)(TSBluetoothSystem * _Nullable bluetoothInfo, NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
