//
//  TSBleScanPeripheralParam.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSMetaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBleScanPeripheralParam : TSMetaBaseModel

/**
 * @brief User ID used for local MAC->UUID mapping (retrieve fallback)
 * @chinese 用户ID（用于本地 MAC->UUID 映射，在“已连接但不广播”场景下做 retrieve 兜底）
 *
 * @discussion
 * [EN]: iOS does NOT expose BLE MAC from CBPeripheral. If you want to locate a peripheral
 *       when the device is already connected (thus not advertising), you must rely on a
 *       persisted mapping (e.g. TSPeripheralTable: userID + macAddress -> uuidString),
 *       then call retrievePeripheralsWithIdentifiers / retrieveConnectedPeripherals.
 *       This userId is used to query that mapping.
 * [CN]: iOS 无法从 CBPeripheral 直接读取 MAC。若设备已连接导致不广播，想要“搜索”到它，
 *       必须依赖持久化映射（例如 TSPeripheralTable：userID + macAddress -> uuidString），
 *       再调用 retrievePeripheralsWithIdentifiers / retrieveConnectedPeripherals。
 *       此 userId 用于查询该映射。
 */
@property (nonatomic, copy, nullable) NSString *userId;

/**
 * @brief Service UUIDs to filter peripherals
 * @chinese 过滤外设的服务UUID数组
 *
 * @discussion
 * [EN]: Only peripherals advertising these service UUIDs will be discovered. Pass nil to discover all.
 * [CN]: 只发现广播中包含这些服务UUID的外设，传nil则不过滤。
 */
@property (nonatomic, copy, nullable) NSArray<CBUUID *> *serviceUUIDs;

/**
 * @brief Solicited Service UUIDs filter
 * @chinese Solicited Service UUID过滤
 *
 * @discussion
 * [EN]: Only peripherals advertising these solicited service UUIDs will be discovered. Pass nil to not filter.
 * [CN]: 只发现广播中包含这些Solicited Service UUID的外设，传nil则不过滤。
 */
@property (nonatomic, copy, nullable) NSArray<CBUUID *> *solicitedServiceUUIDs;

/**
 * @brief Device name filter
 * @chinese 设备名称过滤
 *
 * @discussion
 * [EN]: Only peripherals with this name will be discovered. Pass nil to discover all.
 * [CN]: 只发现名称为此值的外设，传nil则不过滤。
 */
@property (nonatomic, copy, nullable) NSString *deviceName;

/**
 * @brief MAC address filter
 * @chinese MAC地址过滤
 *
 * @discussion
 * [EN]: Only peripherals with this MAC address will be discovered. Pass nil to discover all.
 * [CN]: 只发现MAC地址为此值的外设，传nil则不过滤。
 *
 * @note
 * [EN]: MAC address matching is performed by extracting MAC from advertisement data.
 * [CN]: MAC地址匹配通过从广播数据中提取MAC地址进行。
 */
@property (nonatomic, copy, nullable) NSString *macAddress;

/**
 * @brief Only return unconnected peripherals
 * @chinese 是否只返回未连接的外设
 *
 * @discussion
 * [EN]: If YES, only peripherals not currently connected will be discovered.
 * [CN]: YES时只返回当前未连接的外设。
 *
 * @note
 * [EN]: Default is NO.
 * [CN]: 默认NO。
 */
@property (nonatomic, assign) BOOL onlyUnconnected;

/**
 * @brief Allow duplicate discovery
 * @chinese 是否允许重复发现同一设备
 *
 * @discussion
 * [EN]: If YES, the same peripheral may be discovered multiple times (recommended for real-time RSSI updates). If NO, each peripheral is only discovered once (default).
 * [CN]: YES时，同一设备可能被多次发现（适合实时获取信号强度）；NO时，每个设备只发现一次（默认）。
 *
 * @note
 * [EN]: This property will be automatically converted to CBCentralManagerScanOptionAllowDuplicatesKey in scan options.
 * [CN]: 此属性会自动转换为扫描参数字典中的CBCentralManagerScanOptionAllowDuplicatesKey。
 */
@property (nonatomic, assign) BOOL allowDuplicates;

/**
 * @brief Scan timeout in seconds
 * @chinese 扫描超时时间（秒）
 *
 * @discussion
 * [EN]: If greater than 0, scanning will automatically stop after this duration. If 0, scanning continues indefinitely until manually stopped.
 * [CN]: 大于0时，扫描将在此时间后自动停止。为0时，扫描将持续进行直到手动停止。
 *
 * @note
 * [EN]: Default is 0.0 (no timeout).
 * [CN]: 默认0.0（无超时）。
 */
@property (nonatomic, assign) NSTimeInterval scanTimeout;

/**
 * @brief Generate scan options dictionary for CoreBluetooth
 * @chinese 生成CoreBluetooth扫描参数字典
 *
 * @discussion
 * [EN]: Returns a dictionary suitable for scanForPeripheralsWithServices:options:, based on allowDuplicates and solicitedServiceUUIDs properties.
 * [CN]: 根据allowDuplicates和solicitedServiceUUIDs属性，生成适用于scanForPeripheralsWithServices:options:方法的字典。
 *
 * @return
 * EN: Options dictionary for CoreBluetooth scan
 * CN: CoreBluetooth扫描参数字典
 */
- (NSDictionary<NSString *, id> *)scanOptions;

/**
 * @brief Get default scan options dictionary
 * @chinese 获取默认扫描参数字典
 *
 * @discussion
 * [EN]: Returns a dictionary with default scan options (onlyUnconnected=YES, allowDuplicates=NO, others nil).
 * [CN]: 返回包含默认扫描参数的字典（只返回未连接设备，不允许重复发现，其他为nil）。
 *
 * @return
 * EN: Default options dictionary for CoreBluetooth scan
 * CN: CoreBluetooth默认扫描参数字典
 */
+ (NSDictionary<NSString *, id> *)defaultOptions;

@end

NS_ASSUME_NONNULL_END
