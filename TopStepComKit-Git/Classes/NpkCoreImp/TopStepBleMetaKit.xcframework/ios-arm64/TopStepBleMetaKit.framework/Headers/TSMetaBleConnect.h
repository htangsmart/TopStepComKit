//
//  TSMetaBleConnect.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "TSBleManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PbConnectParam.pbobjc.h"
#import "TSMetaBleConnectDefines.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief BLE connection manager
 * @chinese 蓝牙连接管理器
 *
 * @discussion
 * [EN]: Provides high-level BLE connection management including scanning, connecting, 
 *       authentication, binding, and device management operations.
 * [CN]: 提供高级蓝牙连接管理，包括扫描、连接、认证、绑定和设备管理等操作。
 */
@interface TSMetaBleConnect : TSBusinessBase

#pragma mark - Scanning Methods

/**
 * @brief Scan for BLE peripherals with filter parameters
 * @chinese 按参数扫描蓝牙外设
 *
 * @param scanParam
 * [EN]: Scan filter parameter object (e.g. service UUIDs, device name, allowDuplicates, etc.)
 * [CN]: 扫描过滤参数对象（如服务UUID、设备名、是否允许重复发现等）
 *
 * @param discoverBlock
 * [EN]: Callback when a peripheral is discovered, returns peripheral, advertisement data, and RSSI
 * [CN]: 发现外设时的回调，返回外设、广播数据和信号强度
 *
 * @param completion
 * [EN]: Callback when scan starts successfully or fails to start
 * [CN]: 扫描启动成功或启动失败时的回调
 *
 * @discussion
 * [EN]: - Delegates to TSBleManager for actual scanning implementation
 *       - This method acts as a business layer wrapper around TSBleManager
 *       - All scan parameters, callbacks, and timeout handling are managed by TSBleManager
 *       - Use stopScan to stop scanning manually
 * [CN]: - 委托给TSBleManager进行实际的扫描实现
 *       - 此方法作为TSBleManager的业务层包装
 *       - 所有扫描参数、回调和超时处理都由TSBleManager管理
 *       - 使用stopScan手动停止扫描
 */
+ (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
      didDiscoverPeripheral:(DidDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 *
 * @discussion
 * [EN]: - Safely stops the current BLE scan
 *       - Can be called multiple times without issues
 *       - Should be called to save battery when scanning is no longer needed
 * [CN]: - 安全停止当前蓝牙扫描
 *       - 可以多次调用而不会出现问题
 *       - 当不再需要扫描时应调用以节省电量
 */
+ (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral with options
 * @chinese 连接蓝牙外设（支持连接参数）
 *
 * @param peripheral
 * [EN]: The peripheral to connect
 * [CN]: 要连接的外设
 *
 * @param param
 * [EN]: Connection parameter object (e.g. notification options, delay, etc.)
 * [CN]: 连接参数对象（如通知选项、延迟等）
 *
 * @param completion
 * [EN]: Callback for connection result
 * [CN]: 连接结果回调
 *
 * @discussion
 * [EN]: - Establishes connection to the specified peripheral
 *       - Automatically handles authentication after successful connection
 *       - Calls completion with success/failure result
 *       - If connection succeeds, begins authentication process
 * [CN]: - 建立与指定外设的连接
 *       - 连接成功后自动处理认证
 *       - 调用completion返回成功/失败结果
 *       - 如果连接成功，开始认证过程
 */
+ (void)connectPeripheral:(CBPeripheral *_Nonnull)peripheral
                    param:(TSMetaAuthParam *_Nullable)param
               completion:(TSMetaCompletionBlock)completion;


/**
 * @brief Disconnect from the currently connected peripheral
 * @chinese 断开当前连接的外设
 *
 * @param completion
 * [EN]: Callback for disconnection result
 * [CN]: 断开连接结果的回调
 *
 * @discussion
 * [EN]: - Safely disconnects from the connected peripheral
 *       - Preserves binding information for future reconnection
 *       - Calls completion with disconnection result
 * [CN]: - 安全断开与已连接外设的连接
 *       - 保留绑定信息以便将来重连
 *       - 调用completion返回断开连接结果
 */
+ (void)disConnectPeripheralCompletion:(TSMetaCompletionBlock _Nonnull)completion;

#pragma mark - Authentication Methods

+ (void)beginAuthWithParam:(TSMetaAuthParam *)param isBind:(BOOL)isBind completion:(TSMetaCompletionBlock)completion ;
/**
 * @brief Login to BLE device
 * @chinese 登录蓝牙设备
 *
 * @param param 
 * [EN]: Connection parameters containing user credentials
 * [CN]: 包含用户凭据的连接参数
 *
 * @param completion 
 * [EN]: Completion callback with login result
 * [CN]: 登录结果的完成回调
 *
 * @discussion
 * [EN]: - Authenticates user with the connected BLE device
 *       - Requires valid connection parameters
 *       - Calls completion with success/failure result
 *       - Used for already bound devices
 * [CN]: - 向已连接的蓝牙设备验证用户身份
 *       - 需要有效的连接参数
 *       - 调用completion返回成功/失败结果
 *       - 用于已绑定的设备
 */
+ (void)loginWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Bind BLE device
 * @chinese 绑定蓝牙设备
 *
 * @param param 
 * [EN]: Connection parameters for device binding
 * [CN]: 用于设备绑定的连接参数
 *
 * @param completion 
 * [EN]: Completion callback with binding result
 * [CN]: 绑定结果的完成回调
 *
 * @discussion
 * [EN]: - Establishes binding relationship with the BLE device
 *       - Requires valid connection parameters
 *       - Calls completion with success/failure result
 *       - Used for first-time device connections
 * [CN]: - 与蓝牙设备建立绑定关系
 *       - 需要有效的连接参数
 *       - 调用completion返回成功/失败结果
 *       - 用于首次设备连接
 */
+ (void)bindWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Unbind peripheral
 * @chinese 解绑外设
 *
 * @param completion 
 * [EN]: Completion callback with unbinding result
 * [CN]: 解绑结果的完成回调
 *
 * @discussion
 * [EN]: - Removes binding relationship with the BLE device
 *       - Clears all pairing and binding information
 *       - Calls completion with success/failure result
 *       - Device must be re-bound after unbinding
 * [CN]: - 移除与蓝牙设备的绑定关系
 *       - 清除所有配对和绑定信息
 *       - 调用completion返回成功/失败结果
 *       - 解绑后设备必须重新绑定
 */
+ (void)unbindPeripheral:(TSMetaCompletionBlock)completion;

#pragma mark - Device Management Methods

/**
 * @brief Check if a peripheral is currently connected
 * @chinese 检查外设是否已连接
 *
 * @return
 * [EN]: YES if connected, NO otherwise
 * [CN]: 已连接返回YES，否则返回NO
 *
 * @discussion
 * [EN]: - Lightweight method to check connection status
 *       - Returns current connection state
 *       - Thread-safe, can be called from any thread
 * [CN]: - 轻量级方法检查连接状态
 *       - 返回当前连接状态
 *       - 线程安全，可从任何线程调用
 */
+ (BOOL)isConnected;

/**
 * @brief Request peripheral device information
 * @chinese 请求外设设备信息
 *
 * @param completion
 * [EN]: Completion callback with device information and error
 * [CN]: 设备信息的完成回调，包含设备信息和错误信息
 *
 * @discussion
 * [EN]: - Retrieves detailed information about the connected peripheral
 *       - Information includes device model, firmware version, shape, limits, etc.
 *       - Calls completion with TSMetaPeripheralInfo object or error
 *       - Requires active connection to peripheral
 * [CN]: - 获取已连接外设的详细信息
 *       - 信息包括设备型号、固件版本、外形尺寸、限制等
 *       - 调用completion返回TSMetaPeripheralInfo对象或错误
 *       - 需要与外设的活跃连接
 */
+ (void)requestPeripheralInfoCompletion:(void(^)(TSMetaPeripheralInfo * _Nullable peripheralInfo, NSError * _Nullable error))completion;

#pragma mark - Device Discovery Business Methods

/**
 * @brief Search peripheral by MAC address or existing peripheral object (unified business interface)
 * @chinese 查找外设（统一业务接口）
 *
 * @param macAddress 
 * [EN]: MAC address of the device (optional, can be nil)
 * [CN]: 设备的MAC地址（可选，可为nil）
 *
 * @param existingPeripheral 
 * [EN]: Existing CBPeripheral object (optional, can be nil)
 * [CN]: 现有的CBPeripheral对象（可选，可为nil）
 *
 * @param completion 
 * [EN]: Callback with found CBPeripheral or error
 * [CN]: 回调返回找到的CBPeripheral或错误
 *
 * @discussion
 * [EN]: This is the unified interface for device discovery:
 *       1. If existingPeripheral is provided, returns it directly (trusts user input)
 *       2. If MAC address is provided, searches in connected peripherals first
 *       3. If not found in connected peripherals, checks historical records
 *       4. If still not found, starts scanning for new peripherals (15s timeout)
 *       5. Uses fixed service UUID from TSBleManager
 * [CN]: 这是设备查找的统一接口：
 *       1. 如果提供了现有外设对象，直接返回（信任用户输入）
 *       2. 如果提供了MAC地址，首先在已连接外设中查找
 *       3. 如果未在已连接外设中找到，检查历史记录
 *       4. 如果仍未找到，开始扫描新外设（15秒超时）
 *       5. 使用TSBleManager中固定的服务UUID
 */
+ (void)searchPeripheralWithExistingPeripheral:(CBPeripheral * _Nullable)existingPeripheral
                                    macAddress:(NSString * _Nullable)macAddress
                                        userId:(NSString *)userId
                                    completion:(void(^)(CBPeripheral * _Nullable peripheral, NSError * _Nullable error))completion;



+(CBPeripheral *)findPeripheralFromRetrieveConnectedPeripheralsWithDefaultServiceWithUUid:(NSString *)uuidString;

+(CBPeripheral *)findPeripheralFromretRievePeripheralsWithIdentifiersWithUUid:(NSString *)uuidString;

@end

NS_ASSUME_NONNULL_END
