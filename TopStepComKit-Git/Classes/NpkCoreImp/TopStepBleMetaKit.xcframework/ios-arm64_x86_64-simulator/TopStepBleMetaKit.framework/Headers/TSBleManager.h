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
#import "TSMetaBleConnectDefines.h"

NS_ASSUME_NONNULL_BEGIN


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
 */
@property (nonatomic, strong, readonly, nullable) CBPeripheral *connectedPeripheral;

/**
 * @brief Connection state
 * @chinese 连接状态
 */
@property (nonatomic, assign, readonly) BOOL isConnected;

/**
 * @brief Maximum write value length for connected peripheral
 * @chinese 已连接外设的最大写入值长度
 */
@property (nonatomic, assign, readonly) NSInteger maximumWriteValueLength;

/**
 * @brief BLE manager state
 * @chinese 蓝牙管理器状态
 */
@property (nonatomic, assign, readonly) CBManagerState bleManagerState;

#pragma mark - Initialization & Status Methods
/**
 * @brief Get the shared instance of TSBleManager
 * @chinese 获取TSBleManager的共享实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Check if BLE is ready for operations
 * @chinese 检查蓝牙是否准备好进行操作
 */
- (BOOL)isBleReady;

#pragma mark - Scanning Methods

/**
 * @brief Scan for BLE peripherals with complete callback support
 * @chinese 带完整回调支持的蓝牙外设扫描
 */
- (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
     didDiscoverPeripheral:(DidDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 */
- (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral with options
 * @chinese 连接蓝牙外设（支持连接参数）
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
                  option:(TSBleConnectOption * _Nullable)connectOption
              completion:(TSMetaBleConnectionCompletionBlock _Nonnull)completion;

/**
 * @brief Disconnect from the current BLE peripheral
 * @chinese 断开当前蓝牙外设
 */
- (void)disconnectPeripheralCompletion:(TSMetaCompletionBlock)completion;

#pragma mark - Data Transmission Methods

/**
 * @brief Write data to BLE peripheral (batch mode)
 * @chinese 向蓝牙外设批量写入数据
 */
- (void)writeData:(NSArray<NSData *> * _Nonnull)needWriteDataArray 
         progress:(void(^_Nullable)(CGFloat progress))progress 
       completion:(TSMetaCompletionBlock _Nonnull)completion;

/**
 * @brief Cancel all pending write operations
 * @chinese 取消所有待发送的写入操作
 */
- (void)cancelAllWriteData;

#pragma mark - Utility Methods

/**
 * @brief Get connected peripherals with default service UUID
 * @chinese 获取默认服务UUID的已连接外设
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithDefaultService;

/**
 * @brief Get all connected peripherals with specified services
 * @chinese 获取所有已连接的指定服务的外设
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> * _Nullable)serviceUUIDs;

/**
 * @brief Get peripherals by their identifiers
 * @chinese 通过标识符获取外设
 */
- (NSArray<CBPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;




@end

NS_ASSUME_NONNULL_END
