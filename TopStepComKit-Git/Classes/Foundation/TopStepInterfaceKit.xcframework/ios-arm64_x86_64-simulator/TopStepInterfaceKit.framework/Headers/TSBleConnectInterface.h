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

#import "TSComConstDefines.h"
#import "TSKitBaseInterface.h"
#import "TSPeripheral.h"
#import "TSPeripheralConnectParam.h"
#import "TSPeripheralScanParam.h"
#import "TSComEnumDefines.h"
#import "TSBluetoothSystem.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Bluetooth connection state enumeration (Enhanced)
 * @chinese 蓝牙连接状态枚举（增强版）
 *
 * @discussion
 * [EN]: Defines the complete states during Bluetooth connection and authentication process.
 *       Provides granular tracking of the connection lifecycle from initial connection
 *       through authentication to full readiness.
 *
 *       Error handling: Any failure at any stage returns to eTSBleStateDisconnected with
 *       error details passed through the completion callback.
 * [CN]: 定义蓝牙连接和认证过程中的完整状态。
 *       提供从初始连接、认证到完全就绪的连接生命周期的细粒度跟踪。
 *
 *       错误处理：任何阶段的失败都会返回到 eTSBleStateDisconnected 状态，
 *       错误详情通过完成回调的 error 参数传递。
 *
 * @note
 * [EN]: State flow: Disconnected → Connecting → Authenticating → PreparingData → Connected
 *                         ↑              ↓              ↓                ↓
 *                         └──────────────┴──────────────┴────────────────┘
 *       Any failure returns to Disconnected state.
 * [CN]: 状态流转：未连接 → 连接中 → 认证中 → 准备数据 → 已连接
 *                    ↑          ↓          ↓            ↓
 *                    └──────────┴──────────┴────────────┘
 *       任何失败都返回未连接状态。
 */
typedef NS_ENUM(NSUInteger, TSBleConnectionState) {
    /// 未连接 （Not connected - initial state or after any failure）
    eTSBleStateDisconnected = 0,
    
    /// 连接中 （Connecting - establishing BLE physical connection）
    eTSBleStateConnecting,
    
    /// 认证中 （Authenticating - performing bind/login after connection established）
    eTSBleStateAuthenticating,
    
    /// 准备数据中 （Preparing data - fetching device information after authentication）
    eTSBleStatePreparingData,
    
    /// 已连接且就绪 （Connected and ready - fully functional, can perform data operations）
    eTSBleStateConnected
};

/**
 * @brief Scan complete reasons enumeration
 * @chinese 扫描完成原因枚举
 *
 * @discussion
 * [EN]: Defines various reasons why BLE scanning completes
 * [CN]: 定义蓝牙扫描完成的各种原因
 */
typedef NS_ENUM(NSInteger, TSScanCompletionReason) {
    eTSScanCompleteReasonTimeout = 1000,      // 扫描超时
    eTSScanCompleteReasonBleNotReady,         // 蓝牙未准备好
    eTSScanCompleteReasonPermissionDenied,    // 权限被拒绝
    eTSScanCompleteReasonUserStopped,         // 用户主动停止
    eTSScanCompleteReasonSystemError,         // 系统错误
    eTSScanCompleteReasonNotSupport           // 不支持
};

/**
 * @brief Bluetooth device discovery callback block type
 * @chinese 蓝牙设备发现回调块类型
 *
 * @param peripheral
 * [EN]: Discovered peripheral with device name, ID and other information
 * [CN]: 扫描到的外设对象，包含设备名称、ID等信息
 *
 * @discussion
 * [EN]: This callback is triggered when a new Bluetooth device is discovered during scanning.
 *       It is called on the main thread and can be used to update UI or process device information.
 * [CN]: 当扫描过程中发现新的蓝牙设备时触发此回调。
 *       回调在主线程上执行，可用于更新UI或处理设备信息。
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
 * @param conncetionState
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
 * @discussion
 * [EN]: This callback is triggered when the Bluetooth connection state changes during the connection process.
 *       It provides granular visibility into each stage: connection → authentication → data preparation → ready.
 *       
 *       State flow (success):
 *       Disconnected → Connecting → Authenticating → PreparingData → Connected
 *       
 *       State flow (failure at any stage):
 *       Any state → Disconnected (error details passed through completion callback)
 *       
 *       The callback is executed on the main thread and is suitable for updating UI progress indicators.
 *       Error information is not included in this callback; errors are passed through completion callbacks.
 * [CN]: 当蓝牙连接状态在连接过程中发生变化时触发此回调。
 *       提供每个阶段的细粒度可见性：连接 → 认证 → 数据准备 → 就绪。
 *       
 *       状态流转（成功）：
 *       未连接 → 连接中 → 认证中 → 准备数据 → 已连接
 *       
 *       状态流转（任何阶段失败）：
 *       任何状态 → 未连接（错误详情通过完成回调传递）
 *       
 *       回调在主线程上执行，适合用于更新UI进度指示器。
 *       此回调不包含错误信息；错误通过完成回调传递。
 *
 * @note
 * [EN]: - This callback may be triggered multiple times during a single connection attempt
 *       - Final result (success/failure) is delivered via the completion callback
 *       - Use this for progress UI updates; use completion for business logic
 * [CN]: - 单次连接尝试中此回调可能被触发多次
 *       - 最终结果（成功/失败）通过完成回调传递
 *       - 此回调用于进度UI更新；使用完成回调处理业务逻辑
 */
typedef void (^TSBleConnectionStateCallback)(TSBleConnectionState conncetionState);

typedef void (^TSBleConnectionCompletionBlock)(TSBleConnectionState conncetionState,NSError *_Nullable error);


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
 * @brief Get current Bluetooth connection state
 * @chinese 获取当前蓝牙连接状态
 *
 * @param completion 
 * [EN]: Callback that returns current connection state
 * [CN]: 返回当前连接状态的回调
 *
 * @discussion 
 * [EN]: - Can be safely called from any thread
 *       - Callback always executes on main thread
 *       - Possible states:
 *         • eTSBleStateDisconnected: Not connected
 *         • eTSBleStateConnecting: Establishing BLE connection
 *         • eTSBleStateAuthenticating: Performing authentication
 *         • eTSBleStatePreparingData: Fetching device info
 *         • eTSBleStateConnected: Fully ready
 *       - Returns current connection state without error details
 * [CN]: - 可从任何线程安全调用
 *       - 回调始终在主线程执行
 *       - 可能的状态：
 *         • eTSBleStateDisconnected: 未连接
 *         • eTSBleStateConnecting: 正在建立BLE连接
 *         • eTSBleStateAuthenticating: 正在认证
 *         • eTSBleStatePreparingData: 正在获取设备信息
 *         • eTSBleStateConnected: 完全就绪
 *       - 返回当前连接状态，不包含错误详情
 */
- (void)getConnectState:(TSBleConnectionStateCallback)completion;

/**
 * @brief Start searching for Bluetooth devices
 * @chinese 开始搜索蓝牙设备
 *
 * @param timeout 
 * [EN]: Scan timeout in seconds, use default timeout (30s) if 0
 * [CN]: 扫描超时时间（秒），0表示使用默认超时时间（30秒）
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
 * [EN]: - Search continues until timeout (default 30s if 0), stopSearchPeripheral is called, or connection succeeds
 *       - Call stopSearchPeripheral when not needed to save battery
 *       - All callbacks execute on main thread
 * [CN]: - 搜索过程持续进行，直到超时（0表示默认30秒）、调用stopSearchPeripheral或连接成功
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
 * [EN]: Scan parameters including filters (UUIDs, name, MAC), timeout, duplicates, etc.
 * [CN]: 扫描参数，包含过滤条件（UUID、名称、MAC）、超时、是否允许重复等。
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
 *  - If param.scanTimeout == 0, scanning continues until stopSearchPeripheral is called
 *  - All callbacks execute on main thread
 * [CN]:
 *  - 当 param.scanTimeout > 0 时，到时会自动停止扫描
 *  - 当 param.scanTimeout == 0 时，将持续扫描直到调用 stopSearchPeripheral
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

/**
 * @brief Connect to a Bluetooth device
 * @chinese 连接蓝牙设备
 *
 * @param peripheral 
 * [EN]: Peripheral device to connect to
 * [CN]: 要连接的外设
 *
 * @param param 
 * [EN]: Connection parameters with binding info including user ID
 * [CN]: 包含用户ID等绑定信息的连接参数
 *
 * @param stateChange 
 * [EN]: Callback for real-time connection state changes (optional).
 *       This callback will be triggered multiple times during the connection process:
 *       1. eTSBleStateConnecting: Starting BLE physical connection
 *       2. eTSBleStateAuthenticating: Performing bind/login authentication
 *       3. eTSBleStatePreparingData: Fetching device information
 *       4. eTSBleStateConnected: Fully connected and ready
 *       On failure at any stage: eTSBleStateDisconnected (with error in completion)
 * [CN]: 实时连接状态变化的回调（可选）。
 *       此回调在连接过程中会被多次触发：
 *       1. eTSBleStateConnecting: 开始建立BLE物理连接
 *       2. eTSBleStateAuthenticating: 执行绑定/登录认证
 *       3. eTSBleStatePreparingData: 获取设备信息
 *       4. eTSBleStateConnected: 完全连接且就绪
 *       任何阶段失败时：eTSBleStateDisconnected（错误通过完成回调传递）
 *
 * @param completion 
 * [EN]: Callback for final connection result. Called once with success or error.
 * [CN]: 最终连接结果的回调。成功或失败时调用一次。
 *
 * @discussion 
 * [EN]: - Use for first-time device connections or after factory reset
 *       - Complete connection process includes 4 stages:
 *         1. BLE Physical Connection
 *         2. Authentication (bind for first-time, login for subsequent)
 *         3. Data Preparation (fetch device info)
 *         4. Ready for Use
 *       - stateChange callback (optional): Use for UI progress indicators
 *       - completion callback (required): Use for final business logic handling
 *       - On failure, state returns to eTSBleStateDisconnected
 * [CN]: - 用于首次设备连接或恢复出厂设置后的连接
 *       - 完整连接过程包含4个阶段：
 *         1. BLE物理连接
 *         2. 认证（首次绑定，后续登录）
 *         3. 数据准备（获取设备信息）
 *         4. 就绪可用
 *       - stateChange回调（可选）：用于UI进度指示
 *       - completion回调（必需）：用于最终业务逻辑处理
 *       - 失败时，状态返回到 eTSBleStateDisconnected
 */
- (void)connectWithPeripheral:(TSPeripheral *)peripheral
                         param:(TSPeripheralConnectParam *)param
                    completion:(TSBleConnectionCompletionBlock)completion;

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
 * @param stateChange 
 * [EN]: Callback for real-time connection state changes (optional).
 *       This callback will be triggered multiple times during the reconnection process:
 *       1. eTSBleStateConnecting: Starting BLE physical connection
 *       2. eTSBleStateAuthenticating: Performing login authentication (no bind needed)
 *       3. eTSBleStatePreparingData: Fetching device information
 *       4. eTSBleStateConnected: Fully connected and ready
 *       On failure at any stage: eTSBleStateDisconnected (with error in completion)
 * [CN]: 实时连接状态变化的回调（可选）。
 *       此回调在重连过程中会被多次触发：
 *       1. eTSBleStateConnecting: 开始建立BLE物理连接
 *       2. eTSBleStateAuthenticating: 执行登录认证（无需绑定）
 *       3. eTSBleStatePreparingData: 获取设备信息
 *       4. eTSBleStateConnected: 完全连接且就绪
 *       任何阶段失败时：eTSBleStateDisconnected（错误通过完成回调传递）
 *
 * @param completion 
 * [EN]: Callback for final reconnection result. Called once with success or error.
 * [CN]: 最终重连结果的回调。成功或失败时调用一次。
 *
 * @discussion 
 * [EN]: - Use for reconnecting to previously bound devices
 *       - Reconnection uses login instead of bind (faster authentication)
 *       - Same 4-stage process as initial connection but typically faster:
 *         1. BLE Physical Connection
 *         2. Authentication (login with existing credentials)
 *         3. Data Preparation (fetch device info)
 *         4. Ready for Use
 *       - User ID in param must match original binding user
 *       - Fails with specific error codes (out of range, authentication failed, etc.)
 *       - stateChange callback (optional): Use for UI progress indicators
 *       - completion callback (required): Use for final business logic handling
 *       - On failure, state returns to eTSBleStateDisconnected
 * [CN]: - 用于重连之前绑定的设备
 *       - 重连使用登录而非绑定（认证更快）
 *       - 与初始连接相同的4阶段流程但通常更快：
 *         1. BLE物理连接
 *         2. 认证（使用现有凭据登录）
 *         3. 数据准备（获取设备信息）
 *         4. 就绪可用
 *       - param中的userId必须与原绑定用户匹配
 *       - 失败时会返回相应错误码（设备不在范围、认证失败等）
 *       - stateChange回调（可选）：用于UI进度指示
 *       - completion回调（必需）：用于最终业务逻辑处理
 *       - 失败时，状态返回到 eTSBleStateDisconnected
 */
- (void)reconnectWithPeripheral:(TSPeripheral *)peripheral
                         param:(TSPeripheralConnectParam *)param
                    completion:(TSBleConnectionCompletionBlock)completion;

/**
 * @brief Disconnect from the currently connected device
 * @chinese 断开当前连接的设备
 *
 * @param completion 
 * [EN]: Callback that returns disconnection result
 * [CN]: 返回断开结果的回调
 *
 * @discussion 
 * [EN]: - Safely disconnects while preserving binding information
 *       - Can reconnect later using reconnectWithPeripheral method
 *       - Useful for temporary disconnection or battery saving
 *       - All callbacks execute on main thread
 * [CN]: - 安全断开连接但保留绑定信息
 *       - 可以之后使用reconnectWithPeripheral方法重新连接
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
 * [EN]: - Completely unbinds device, clearing all pairing information
 *       - After unbinding, must use connectWithPeripheral to rebind
 *       - Used for changing users, transferring device, or troubleshooting
 *       - All callbacks execute on main thread
 * [CN]: - 完全解除设备绑定，清除所有配对信息
 *       - 解绑后需要使用connectWithPeripheral重新绑定
 *       - 适用于更换用户、设备转移或故障排除
 *       - 所有回调都在主线程执行
 */
- (void)unbindPeripheralCompletion:(TSCompletionBlock)completion;

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
 *       - For detailed status including errors, use getConnectState:
 *       - Thread-safe, can be called from any thread
 * [CN]: - 轻量级方法，仅检查基本连接状态
 *       - 适用于UI状态更新或简单连接检查
 *       - 不提供错误信息，需要详细状态请使用getConnectState:
 *       - 线程安全，可从任何线程调用
 */
- (BOOL)isConnected;

/**
 * @brief Get Bluetooth adapter information
 * @chinese 获取蓝牙适配器信息
 *
 * @param completion
 * [EN]: Callback that returns Bluetooth system information including Classic Bluetooth and BLE adapter details.
 *       Called on main thread.
 * [CN]: 返回蓝牙系统信息的回调，包括经典蓝牙和BLE适配器详情。在主线程回调。
 *
 * @discussion 
 * [EN]: - Returns comprehensive Bluetooth adapter information including:
 *       • BLE (Bluetooth Low Energy): MAC address, name, and connection status (bleInfo)
 *       • BT (Classic Bluetooth): MAC address, name, and connection status (btInfo)
 *       - Connection status values: 0=Not connected, 1=Connected, 2=Ready (Connected and Notify/SPP opened)
 *       - MAC addresses may be nil on platforms where MAC address access is restricted (e.g., iOS)
 *       - Can be safely called from any thread
 *       - Callback always executes on main thread
 *       - Returns nil for unavailable information (e.g., Classic Bluetooth on iOS devices)
 * [CN]: - 返回完整的蓝牙适配器信息，包括：
 *       • BLE（低功耗蓝牙）：MAC地址、名称和连接状态（bleInfo）
 *       • BT（经典蓝牙）：MAC地址、名称和连接状态（btInfo）
 *       - 连接状态值：0=未连接，1=已连接，2=已就绪（已连接且打开了Notify/SPP）
 *       - 在MAC地址访问受限的平台上（如iOS），MAC地址可能为nil
 *       - 可从任何线程安全调用
 *       - 回调始终在主线程执行
 *       - 不可用的信息返回nil（如iOS设备上的经典蓝牙）
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
