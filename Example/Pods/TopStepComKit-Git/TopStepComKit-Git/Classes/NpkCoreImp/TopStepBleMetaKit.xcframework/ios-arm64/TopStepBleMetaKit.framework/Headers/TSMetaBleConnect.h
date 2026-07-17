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
 */
+ (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
      didDiscoverPeripheral:(TSDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 */
+ (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral
 * @chinese 连接蓝牙外设（仅建立物理连接，认证参数由 beginAuthWithParam: 单独传入）
 *
 * @param peripheral 目标外设
 * @param purpose    连接目的（绑定/登录），由上层根据本地绑定记录判定；
 *                   决定 code 7 断开后是否自动重连，认证成功后内部翻转为 Login
 * @param completion 连接状态回调
 */
+ (void)connectPeripheral:(CBPeripheral *_Nonnull)peripheral
                  purpose:(TSMetaBleConnectPurpose)purpose
               completion:(TSMetaBleConnectionCompletionBlock _Nullable)completion;


/**
 * @brief Disconnect from the currently connected peripheral
 * @chinese 断开当前连接的外设
 */
+ (void)disConnectPeripheralCompletion:(TSMetaCompletionBlock _Nonnull)completion;

#pragma mark - BT Connection

/**
 * @brief Notify device to start sending BT connection / pairing
 * @chinese 通知设备开始发送 BT 配对/连接
 *
 * @param isBind     YES = 绑定流程，仅尝试一次；NO = 登录流程，失败立即重发，最多 kTSStartBtConnectionLoginMaxRetry 次
 * @param completion 结果回调
 */
+ (void)startSendBtConnectionForBind:(BOOL)isBind
                          completion:(TSMetaCompletionBlock)completion;

#pragma mark - Authentication Methods

/**
 * @brief Begin authentication (bind or login), mode decided by current connect purpose
 * @chinese 执行认证（绑定或登录），模式由当前连接目的决定
 *
 * @discussion
 * [EN]: Reads the live value of TSBleManager.connectPurpose instead of taking a flag:
 *       initial value is determined by upper layer before connecting; flipped to Login
 *       once auth succeeds, so reconnect replays automatically pick the correct mode.
 * [CN]: 认证模式不由调用方传入，直接读 TSBleManager.connectPurpose 现值：
 *       初值由上层在连接发起前查定；认证成功后翻转为 Login，重连重放时自动取到正确模式。
 */
+ (void)beginAuthWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;
/**
 * @brief Login to BLE device
 * @chinese 登录蓝牙设备
 */
+ (void)loginWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Bind BLE device
 * @chinese 绑定蓝牙设备
 */
+ (void)bindWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Unbind peripheral
 * @chinese 解绑外设
 */
+ (void)unbindPeripheral:(TSMetaCompletionBlock)completion;

#pragma mark - Device Management Methods

/**
 * @brief Check if a peripheral is currently connected
 * @chinese 检查外设是否已连接
 */
+ (BOOL)isConnected;

/**
 * @brief Request peripheral device information
 * @chinese 请求外设设备信息
 */
+ (void)requestPeripheralInfoCompletion:(void(^)(TSMetaPeripheralInfo * _Nullable peripheralInfo, NSError * _Nullable error))completion;

/**
 * @brief Get Bluetooth information (BLE and Classic Bluetooth)
 * @chinese 获取蓝牙信息（BLE和经典蓝牙）
 */
+ (void)requestBluetoothInfoCompletion:(void(^)(TSMetaBluetoothInfo * _Nullable bluetoothInfo, NSError * _Nullable error))completion;

#pragma mark - Device Discovery Business Methods

/**
 * @brief Search peripheral by MAC address or existing peripheral object (unified business interface)
 * @chinese 查找外设（统一业务接口）
 */
+ (void)searchPeripheralWithExistingPeripheral:(CBPeripheral * _Nullable)existingPeripheral
                                    macAddress:(NSString * _Nullable)macAddress
                                        userId:(NSString *)userId
                                    completion:(void(^)(CBPeripheral * _Nullable peripheral, NSError * _Nullable error))completion;



+(CBPeripheral *)findPeripheralFromRetrieveConnectedPeripheralsWithDefaultServiceWithUUid:(NSString *)uuidString;

+(CBPeripheral *)findPeripheralFromretRievePeripheralsWithIdentifiersWithUUid:(NSString *)uuidString;


+ (void)saveUuidToKeychain:(NSString *)uuid forMac:(NSString *)mac ;

+ (void)removeUuidFromKeychainWithMac:(NSString *)mac ;

@end

NS_ASSUME_NONNULL_END
