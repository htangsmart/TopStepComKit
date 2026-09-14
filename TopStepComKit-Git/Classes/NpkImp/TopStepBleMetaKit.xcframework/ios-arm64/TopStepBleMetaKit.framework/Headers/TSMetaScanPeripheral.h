//
//  TSMetaScanPeripheral.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/1/16.
//
#import "TSMetaBaseModel.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Scanned peripheral model
 * @chinese 扫描到的外设模型
 *
 * @discussion
 * [EN]: Represents a BLE peripheral discovered during scanning, containing all relevant information
 *       including CoreBluetooth peripheral object, device information, and signal strength.
 * [CN]: 表示扫描过程中发现的蓝牙外设，包含所有相关信息，包括CoreBluetooth外设对象、设备信息和信号强度。
 */
@interface TSMetaScanPeripheral : TSMetaBaseModel

#pragma mark - Core Bluetooth Peripheral

/**
 * @brief CoreBluetooth peripheral object
 * @chinese CoreBluetooth外设对象
 *
 * @discussion
 * [EN]: The CBPeripheral object from CoreBluetooth framework, used for connection operations.
 * [CN]: 来自CoreBluetooth框架的CBPeripheral对象，用于连接操作。
 */
@property (nonatomic, strong, nullable) CBPeripheral *peripheral;

#pragma mark - Device Information

/**
 * @brief Device Bluetooth name
 * @chinese 设备蓝牙名称
 *
 * @discussion
 * [EN]: Bluetooth broadcast name of the peripheral, may be nil if device doesn't advertise a name.
 * [CN]: 外设的蓝牙广播名称，如果设备不广播名称可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *bleName;

/**
 * @brief Device MAC address
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: MAC address extracted from advertisement data (manufacturer data).
 *       Format: "AA:BB:CC:DD:EE:FF"
 * [CN]: 从广播数据（制造商数据）中提取的MAC地址。
 *       格式："AA:BB:CC:DD:EE:FF"
 */
@property (nonatomic, copy, nullable) NSString *macAddress;

/**
 * @brief Device UUID string
 * @chinese 设备UUID字符串
 *
 * @discussion
 * [EN]: UUID identifier of the peripheral (peripheral.identifier.UUIDString).
 *       This is the unique identifier assigned by iOS system for this peripheral.
 * [CN]: 外设的UUID标识符（peripheral.identifier.UUIDString）。
 *       这是iOS系统为该外设分配的唯一标识符。
 */
@property (nonatomic, copy, nullable) NSString *uuidString;

/**
 * @brief Advertisement data dictionary
 * @chinese 广播数据字典
 *
 * @discussion
 * [EN]: Complete advertisement data dictionary from CoreBluetooth discovery callback.
 *       Contains keys like CBAdvertisementDataLocalNameKey, CBAdvertisementDataManufacturerDataKey, etc.
 * [CN]: 来自CoreBluetooth发现回调的完整广播数据字典。
 *       包含CBAdvertisementDataLocalNameKey、CBAdvertisementDataManufacturerDataKey等键。
 */
@property (nonatomic, copy, nullable) NSDictionary *advertisementData;

/**
 * @brief Signal strength (RSSI)
 * @chinese 信号强度（RSSI）
 *
 * @discussion
 * [EN]: Received Signal Strength Indicator in dBm. Typically ranges from -100 to 0,
 *       where values closer to 0 indicate stronger signal. May be nil if not available.
 * [CN]: 接收信号强度指示器（单位：dBm）。通常范围在 -100 到 0 之间，
 *       值越接近 0 表示信号越强。如果不可用可能为 nil。
 *
 * @note
 * [EN]: RSSI values are typically negative numbers (e.g., -50, -80).
 * [CN]: RSSI 值通常是负数（例如 -50、-80）。
 */
@property (nonatomic, strong, nullable) NSNumber *RSSI;

#pragma mark - Initialization

/**
 * @brief Initialize with peripheral, advertisement data and RSSI
 * @chinese 使用外设、广播数据和RSSI初始化
 */
- (instancetype)initWithPeripheral:(CBPeripheral * _Nullable)peripheral
                  advertisementData:(NSDictionary<NSString *, id> * _Nullable)advertisementData
                               RSSI:(NSNumber * _Nullable)RSSI;

@end

NS_ASSUME_NONNULL_END
