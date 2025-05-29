//
//  TSPeripheralSystem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

/**
 * @brief System information model for peripheral devices
 * @chinese 外设设备系统信息模型
 *
 * @discussion
 * [EN]: This class manages system-level information for peripheral devices, including:
 *       - Bluetooth connection and communication
 *       - Device identification and addressing
 *       - Signal strength monitoring
 *       - Advertisement data handling
 * 
 * [CN]: 该类管理外设设备的系统级信息，包括：
 *       - 蓝牙连接和通信
 *       - 设备标识和寻址
 *       - 信号强度监控
 *       - 广播数据处理
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralSystem : NSObject

#pragma mark - Bluetooth System Properties

/**
 * @brief Bluetooth peripheral object
 * @chinese 蓝牙外设对象
 *
 * @discussion
 * [EN]: Core object for Bluetooth communication with the device.
 *       Handles all direct interactions with the peripheral device.
 * 
 * [CN]: 与设备进行蓝牙通信的核心对象。
 *       处理所有与外设设备的直接交互。
 *
 */
@property (nonatomic, strong, nullable) CBPeripheral *peripheral;

/**
 * @brief Bluetooth central manager
 * @chinese 蓝牙中心管理器
 *
 * @discussion
 * [EN]: Core object for managing Bluetooth connections and scanning.
 *       Controls the overall Bluetooth state and connection lifecycle.
 * 
 * [CN]: 管理蓝牙连接和扫描的核心对象。
 *       控制蓝牙整体状态和连接生命周期。
 *
 */
@property (nonatomic, strong, nullable) CBCentralManager *central;

/**
 * @brief Device MAC address
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: Unique hardware address of the device.
 *       Used for device identification and connection management.
 * 
 * [CN]: 设备的唯一硬件地址。
 *       用于设备识别和连接管理。
 *
 */
@property (nonatomic, copy, nullable) NSString *mac;

/**
 * @brief Device Bluetooth name
 * @chinese 设备蓝牙名称
 *
 * @discussion
 * [EN]: The name broadcasted by the device for user identification.
 *       Used for device selection in user interface.
 * 
 * [CN]: 设备广播的名称，用于用户识别。
 *       用于用户界面中的设备选择。
 */
@property (nonatomic, copy, nullable) NSString *bleName;

/**
 * @brief Device product model
 * @chinese 设备产品型号
 *
 * @discussion
 * [EN]: The specific model identifier of the product.
 *       Used for device-specific feature support and compatibility checks.
 * 
 * [CN]: 产品的具体型号标识。
 *       用于设备特定功能支持和兼容性检查。
 *
 */
@property (nonatomic, strong, nullable) NSString *productName;

/**
 * @brief Bluetooth signal strength
 * @chinese 蓝牙信号强度
 *
 * @discussion
 * [EN]: RSSI (Received Signal Strength Indicator) value.
 *       Indicates the signal strength between the device and the peripheral.
 * 
 * [CN]: RSSI（接收信号强度指示器）值。
 *       表示设备与外设之间的信号强度。
 */
@property (nonatomic, strong, nullable) NSNumber *RSSI;

/**
 * @brief Advertisement data
 * @chinese 广播数据
 *
 * @discussion
 * [EN]: Raw data dictionary containing device advertisement information.
 *       Includes service UUIDs, manufacturer data, and other broadcast details.
 * 
 * [CN]: 包含设备广播信息的原始数据字典。
 *       包括服务UUID、制造商数据和其他广播详情。
 *
 */
@property (nonatomic, strong, nullable) NSDictionary *advertisementData;

/**
 * @brief Get the MTU (Maximum Transmission Unit) size
 * @chinese 获取MTU（最大传输单元）大小
 *
 * @return
 * [EN]: The MTU size in bytes, or 0 if not available
 * [CN]: MTU大小（字节），如果不可用则返回0
 *
 * @discussion
 * [EN]: Returns the maximum amount of data that can be transmitted in a single packet.
 *       Used for optimizing data transfer efficiency.
 * 
 * [CN]: 返回单个数据包可以传输的最大数据量。
 *       用于优化数据传输效率。
 */
- (NSInteger)peripheralMTU;

/**
 * @brief Check if the device is currently connected
 * @chinese 检查设备是否已连接
 *
 * @return
 * [EN]: YES if the device is connected, NO otherwise
 * [CN]: 设备已连接返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Provides a quick way to check the current connection state.
 *       Used for connection status verification.
 * 
 * [CN]: 提供一种快速检查当前连接状态的方法。
 *       用于连接状态验证。
 */
- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
