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

/**
 * @brief Default BLE scan timeout used inside TopStepBleMetaKit, in seconds. Current value: 30 seconds.
 * @chinese TopStepBleMetaKit 内部默认 BLE 扫描超时时间，单位秒。当前值：30秒。
 */
FOUNDATION_EXPORT NSTimeInterval const TSBleDefaultScanTimeout;

@interface TSBleScanPeripheralParam : TSMetaBaseModel

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
 * @brief BLE name filter
 * @chinese 蓝牙名称过滤
 *
 * @discussion
 * [EN]: Only peripherals whose BLE name equals this value will be discovered. Pass nil to discover all.
 *       The SDK prefers CBAdvertisementDataLocalNameKey and falls back to CBPeripheral.name.
 * [CN]: 只发现蓝牙名称等于此值的外设，传nil则不过滤。
 *       SDK 优先使用广播数据中的 CBAdvertisementDataLocalNameKey，没有时回退到 CBPeripheral.name。
 */
@property (nonatomic, copy, nullable) NSString *bleName;

/**
 * @brief Only return peripherals with a non-empty BLE name
 * @chinese 是否只返回蓝牙名称非空的外设
 *
 * @discussion
 * [EN]: If YES, peripherals without a valid BLE name are ignored.
 * [CN]: YES时，会忽略蓝牙名称为空的外设。
 *
 * @note
 * [EN]: Default is NO.
 * [CN]: 默认NO。
 */
@property (nonatomic, assign) BOOL onlyNamedPeripherals;

/**
 * @brief Scan timeout in seconds
 * @chinese 扫描超时时间（秒）
 *
 * @discussion
 * [EN]: If greater than 0, scanning will automatically stop after this duration.
 *       If 0 or negative, TSBleManager uses TSBleDefaultScanTimeout (30 seconds).
 * [CN]: 大于0时，扫描将在此时间后自动停止。
 *       为0或负数时，TSBleManager 使用 TSBleDefaultScanTimeout（30秒）。
 *
 * @note
 * [EN]: Default is TSBleDefaultScanTimeout (30 seconds).
 * [CN]: 默认值为 TSBleDefaultScanTimeout（30秒）。
 */
@property (nonatomic, assign) NSTimeInterval scanTimeout;


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
