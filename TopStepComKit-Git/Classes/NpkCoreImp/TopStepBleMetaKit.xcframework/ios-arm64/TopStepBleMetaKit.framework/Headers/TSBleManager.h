//
//  TSBleManager.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/5.
//

#import "TSBusinessBase.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSBleScanPeripheralParam.h"
#import "TSBleConnectOption.h"
#import <TopStepToolKit/TopStepToolKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Scan Failure Reasons

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


#pragma mark - TSBleManager Interface

/**
 * @brief BLE Manager - Core Bluetooth Low Energy management class
 * @chinese 蓝牙管理器 - 核心蓝牙低功耗管理类
 *
 * @discussion
 * [EN]: Singleton class that manages BLE operations including scanning, connecting, 
 *       data transmission, and peripheral management. Acts as the "parts factory" 
 *       in the architecture, providing fundamental BLE capabilities.
 * [CN]: 单例类，管理蓝牙操作包括扫描、连接、数据传输和外设管理。在架构中作为"零件生产厂"，
 *       提供基础的蓝牙功能。
 */
@interface TSBleManager : TSBusinessBase

#pragma mark - Connection Properties

/**
 * @brief Current connected peripheral
 * @chinese 当前已连接的外设
 *
 * @discussion
 * [EN]: The currently connected BLE peripheral. Returns nil if no peripheral is connected.
 * [CN]: 当前已连接的蓝牙外设。如果没有连接外设则返回nil。
 *
 * @note
 * [EN]: This property is read-only and automatically managed by the manager.
 * [CN]: 此属性为只读，由管理器自动管理。
 */
@property (nonatomic, strong, readonly, nullable) CBPeripheral *connectedPeripheral;

/**
 * @brief Connection state
 * @chinese 连接状态
 *
 * @discussion
 * [EN]: Returns YES if a peripheral is currently connected, NO otherwise.
 * [CN]: 如果当前有外设连接则返回YES，否则返回NO。
 *
 * @note
 * [EN]: This is a convenience property that checks if connectedPeripheral is not nil.
 * [CN]: 这是一个便利属性，检查connectedPeripheral是否为nil。
 */
@property (nonatomic, assign, readonly) BOOL isConnected;

/**
 * @brief Maximum write value length for connected peripheral
 * @chinese 已连接外设的最大写入值长度
 *
 * @discussion
 * [EN]: The maximum number of bytes that can be written to the connected peripheral
 *       in a single write operation. This value is determined by the peripheral's
 *       capabilities and connection parameters.
 * [CN]: 在单次写入操作中可以写入已连接外设的最大字节数。此值由外设的能力和连接参数决定。
 *
 * @note
 * [EN]: Returns 20 bytes as default if no peripheral is connected or value is not available.
 * [CN]: 如果没有连接外设或值不可用，则默认返回20字节。
 */
@property (nonatomic, assign, readonly) NSInteger maximumWriteValueLength;

/**
 * @brief BLE manager state
 * @chinese 蓝牙管理器状态
 *
 * @discussion
 * [EN]: Current state of the CBCentralManager. This property reflects the underlying
 *       CoreBluetooth manager's state and determines what operations are available.
 * [CN]: CBCentralManager的当前状态。此属性反映底层CoreBluetooth管理器的状态，
 *       并决定哪些操作可用。
 *
 * @note
 * [EN]: Common states include CBManagerStatePoweredOn (ready), CBManagerStatePoweredOff,
 *       CBManagerStateUnauthorized, etc.
 * [CN]: 常见状态包括CBManagerStatePoweredOn（就绪）、CBManagerStatePoweredOff、
 *       CBManagerStateUnauthorized等。
 */
@property (nonatomic, assign, readonly) CBManagerState bleManagerState;

#pragma mark - Initialization & Status Methods
/**
 * @brief Get the shared instance of TSBleManager
 * @chinese 获取TSBleManager的共享实例
 *
 * @return
 * [EN]: The singleton instance of TSBleManager
 * [CN]: TSBleManager的单例实例
 *
 * @discussion
 * [EN]: TSBleManager is implemented as a singleton to ensure there's only one
 *       instance managing BLE operations throughout the app.
 * [CN]: TSBleManager实现为单例，确保整个应用中只有一个实例管理BLE操作。
 *
 * @note
 * [EN]: Use this method to access the shared manager instance.
 * [CN]: 使用此方法访问共享管理器实例。
 */
+ (instancetype)sharedInstance;

/**
 * @brief Check if BLE is ready for operations
 * @chinese 检查蓝牙是否准备好进行操作
 *
 * @return
 * [EN]: YES if BLE is ready (powered on), NO otherwise
 * [CN]: 蓝牙准备好返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method checks if the BLE manager is in CBManagerStatePoweredOn state,
 *       which is required for all BLE operations.
 * [CN]: 此方法检查BLE管理器是否处于CBManagerStatePoweredOn状态，
 *       这是所有BLE操作所必需的。
 */
- (BOOL)isBleReady;

#pragma mark - Scanning Methods

/**
 * @brief Scan for BLE peripherals with complete callback support
 * @chinese 带完整回调支持的蓝牙外设扫描
 *
 * @param scanParam 
 * [EN]: Scan filter parameter object (includes timeout, service UUIDs, MAC address, etc.)
 * [CN]: 扫描过滤参数对象（包含超时、服务UUID、MAC地址等）
 *
 * @param discoverBlock 
 * [EN]: Callback when a peripheral is discovered during scanning
 * [CN]: 扫描过程中发现外设时的回调
 *
 * @param completion
 * [EN]: Callback when scan starts successfully or fails to start
 * [CN]: 扫描启动成功或启动失败时的回调
 *
 * @discussion
 * [EN]: This is the primary scanning method that provides comprehensive callback support.
 *       It handles timeout management, MAC address filtering, and various failure scenarios.
 *       The scan will automatically stop after the timeout period specified in scanParam.
 * [CN]: 这是提供完整回调支持的主要扫描方法。它处理超时管理、MAC地址过滤和各种失败场景。
 *       扫描将在scanParam中指定的超时时间后自动停止。
 *
 * @note
 * [EN]: - Timeout is handled automatically if scanParam.scanTimeout > 0
 *       - MAC address filtering is performed if scanParam.macAddress is set
 *       - Failed block is called for timeout, BLE not ready, etc.
 *       - Completion block is called once when scan starts or fails to start
 * [CN]: - 如果scanParam.scanTimeout > 0，超时会自动处理
 *       - 如果设置了scanParam.macAddress，会执行MAC地址过滤
 *       - 超时、蓝牙未准备好等会调用失败回调
 *       - 扫描启动成功或启动失败时调用一次完成回调
 */
- (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
     didDiscoverPeripheral:(DidDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 *
 * @discussion
 * [EN]: Safely stops the current BLE scan and cleans up all related callbacks.
 *       This method can be called multiple times without issues.
 * [CN]: 安全停止当前蓝牙扫描并清理所有相关回调。此方法可以多次调用而不会出现问题。
 *
 * @note
 * [EN]: - Automatically cancels any pending timeout timers
 *       - Clears all scan-related callback blocks
 *       - Can be called even when no scan is active
 * [CN]: - 自动取消任何待处理的超时计时器
 *       - 清理所有扫描相关的回调块
 *       - 即使没有活跃的扫描也可以调用
 */
- (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral with options
 * @chinese 连接蓝牙外设（支持连接参数）
 *
 * @param peripheral 
 * [EN]: The peripheral to connect
 * [CN]: 要连接的外设
 *
 * @param connectOption
 * [EN]: Connection parameter object (e.g. notification options, delay, etc.)
 * [CN]: 连接参数对象（如通知选项、延迟等）
 *
 * @param completion 
 * [EN]: Callback for connection result
 * [CN]: 连接结果回调
 *
 * @discussion
 * [EN]: Establishes a connection to the specified BLE peripheral. The connection process
 *       includes discovering services and characteristics, and setting up notifications.
 * [CN]: 建立与指定蓝牙外设的连接。连接过程包括发现服务和特征，以及设置通知。
 *
 * @note
 * [EN]: - Connection will fail if BLE is not ready
 *       - The peripheral must be in range and advertising
 *       - Connection timeout is handled internally
 * [CN]: - 如果蓝牙未准备好，连接将失败
 *       - 外设必须在范围内并广播
 *       - 连接超时在内部处理
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
                  option:(TSBleConnectOption * _Nullable)connectOption
              completion:(TSMetaCompletionBlock _Nonnull)completion;

/**
 * @brief Disconnect from the current BLE peripheral
 * @chinese 断开当前蓝牙外设
 *
 * @param completion 
 * [EN]: Callback for disconnection result
 * [CN]: 断开结果回调
 *
 * @discussion
 * [EN]: Safely disconnects from the currently connected peripheral and cleans up
 *       all related resources and callbacks.
 * [CN]: 安全断开与当前已连接外设的连接，并清理所有相关资源和回调。
 *
 * @note
 * [EN]: - Will fail if no peripheral is currently connected
 *       - Automatically cleans up characteristics and callbacks
 *       - The peripheral can be reconnected later
 * [CN]: - 如果当前没有连接外设，将失败
 *       - 自动清理特征和回调
 *       - 外设可以稍后重新连接
 */
- (void)disconnectPeripheralCompletion:(TSMetaCompletionBlock)completion;

#pragma mark - Data Transmission Methods

/**
 * @brief Write data to BLE peripheral
 * @chinese 向蓝牙外设写入数据
 *
 * @param needWriteData 
 * [EN]: Data to write to the connected peripheral
 * [CN]: 要写入已连接外设的数据
 *
 * @param completion 
 * [EN]: Callback for write operation result
 * [CN]: 写入操作结果回调
 *
 * @discussion
 * [EN]: Writes data to the connected peripheral using the write characteristic.
 *       This method uses CBCharacteristicWriteWithoutResponse for efficient data transmission.
 * [CN]: 使用写入特征向已连接的外设写入数据。此方法使用CBCharacteristicWriteWithoutResponse
 *       进行高效的数据传输。
 *
 * @note
 * [EN]: - Requires an active connection to a peripheral
 *       - Data size is limited by maximumWriteValueLength
 *       - Uses write without response for better performance
 *       - Completion is called immediately after write request
 * [CN]: - 需要与外设的活跃连接
 *       - 数据大小受maximumWriteValueLength限制
 *       - 使用无响应写入以获得更好的性能
 *       - 写入请求后立即调用完成回调
 */
- (void)writeData:(NSData * _Nonnull)needWriteData completion:(TSMetaCompletionBlock _Nonnull)completion;

#pragma mark - Utility Methods

/**
 * @brief Get connected peripherals with default service UUID
 * @chinese 获取默认服务UUID的已连接外设
 *
 * @return
 * [EN]: Array of connected CBPeripheral objects with kServiceUUID
 * [CN]: 具有kServiceUUID的已连接CBPeripheral对象数组
 *
 * @discussion
 * [EN]: This method uses the fixed kServiceUUID (000001FF-3C17-D293-8E48-14FE2E4DA212)
 *       to retrieve connected peripherals. It's a convenience method that calls
 *       retrieveConnectedPeripheralsWithServices with the default service UUID.
 * [CN]: 此方法使用固定的kServiceUUID (000001FF-3C17-D293-8E48-14FE2E4DA212) 获取已连接的外设。
 *       这是一个便利方法，使用默认服务UUID调用retrieveConnectedPeripheralsWithServices。
 *
 * @note
 * [EN]: - Returns empty array if BLE is not ready
 *       - Uses the fixed service UUID defined in the implementation
 *       - Equivalent to calling retrieveConnectedPeripheralsWithServices with kServiceUUID
 * [CN]: - 如果蓝牙未准备好，返回空数组
 *       - 使用实现中定义的固定服务UUID
 *       - 等同于使用kServiceUUID调用retrieveConnectedPeripheralsWithServices
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithDefaultService;

/**
 * @brief Get all connected peripherals with specified services
 * @chinese 获取所有已连接的指定服务的外设
 *
 * @param serviceUUIDs 
 * [EN]: Array of service UUIDs to filter peripherals. Pass nil to get all connected peripherals.
 * [CN]: 用于过滤外设的服务UUID数组。传nil获取所有已连接的外设。
 *
 * @return 
 * [EN]: Array of connected CBPeripheral objects
 * [CN]: 已连接的CBPeripheral对象数组
 *
 * @discussion
 * [EN]: Retrieves peripherals that are currently connected to the system and have
 *       the specified services. This method queries the system-level connection state.
 * [CN]: 获取当前连接到系统并具有指定服务的外设。此方法查询系统级连接状态。
 *
 * @note
 * [EN]: - Returns empty array if BLE is not ready
 *       - These are system-level connections, not necessarily from this app
 *       - No advertisement data is available for these peripherals
 * [CN]: - 如果蓝牙未准备好，返回空数组
 *       - 这些是系统级连接，不一定来自此应用
 *       - 这些外设没有广播数据可用
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> * _Nullable)serviceUUIDs;

/**
 * @brief Get peripherals by their identifiers
 * @chinese 通过标识符获取外设
 *
 * @param identifiers 
 * [EN]: Array of NSUUID identifiers
 * [CN]: NSUUID标识符数组
 *
 * @return 
 * [EN]: Array of CBPeripheral objects
 * [CN]: CBPeripheral对象数组
 *
 * @discussion
 * [EN]: Retrieves peripherals that have been previously discovered by their unique
 *       identifiers. These peripherals may or may not be currently connected.
 * [CN]: 通过唯一标识符获取之前发现的外设。这些外设可能当前连接也可能未连接。
 *
 * @note
 * [EN]: - Returns empty array if BLE is not ready
 *       - Identifiers are persistent for the same device on the same iOS system
 *       - No advertisement data is available for these peripherals
 * [CN]: - 如果蓝牙未准备好，返回空数组
 *       - 标识符在同一iOS系统的同一设备上是持久的
 *       - 这些外设没有广播数据可用
 */
- (NSArray<CBPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;




@end

NS_ASSUME_NONNULL_END
