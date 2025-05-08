//
//  TSPeripheralSystem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * TSPeripheralSystem
 * 外设系统信息类，用于管理和存储设备的系统级参数
 * 包含蓝牙连接、设备标识等基础系统信息
 */
@interface TSPeripheralSystem : NSObject

#pragma mark - 蓝牙系统相关属性

/**
 * @brief Bluetooth peripheral object.
 * @chinese 蓝牙外设对象
 *
 * @discussion
 * [EN]: The core object for Bluetooth communication with the device.
 * [CN]: 用于与设备进行蓝牙通信的核心对象。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, strong, nullable) CBPeripheral *peripheral;

/**
 * @brief Bluetooth central manager.
 * @chinese 蓝牙中心管理器
 *
 * @discussion
 * [EN]: The core object for managing Bluetooth connections and scanning.
 * [CN]: 用于管理蓝牙连接和扫描的核心对象。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, strong, nullable) CBCentralManager *central;

/**
 * @brief Device MAC address.
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: MAC address string without colon separators.
 * [CN]: 不带冒号分隔符的MAC地址字符串。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *mac;

/**
 * @brief Device Bluetooth name.
 * @chinese 设备蓝牙名称
 *
 * @discussion
 * [EN]: The Bluetooth name broadcasted by the device.
 * [CN]: 设备广播的蓝牙名称。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, copy, nullable) NSString *bleName;

/**
 * @brief Device product model.
 * @chinese 设备产品型号
 *
 * @discussion
 * [EN]: The specific model identifier of the product.
 * [CN]: 产品的具体型号标识。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, strong, nullable) NSString *productName;

/**
 * @brief Bluetooth signal strength.
 * @chinese 蓝牙信号强度
 *
 * @discussion
 * [EN]: RSSI value indicating signal strength in dBm.
 * [CN]: RSSI值，表示信号强度，单位dBm。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, strong, nullable) NSNumber *RSSI;

/**
 * @brief Advertisement data.
 * @chinese 广播数据
 *
 * @discussion
 * [EN]: The raw data dictionary broadcasted by the device.
 * [CN]: 设备广播的原始数据字典。
 *
 * @note
 * [EN]: This value can be nil.
 * [CN]: 该值可以为nil。
 */
@property (nonatomic, strong, nullable) NSDictionary *advertisementData;

- (NSInteger)peripheralMTU;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
