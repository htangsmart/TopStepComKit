//
//  TSBluetoothInfo.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/28.
//

#import <Foundation/Foundation.h>
#import <TopStepToolKit/TopStepToolKit.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bluetooth connection status enumeration
 * @chinese 蓝牙连接状态枚举
 *
 * @discussion
 * [EN]: Defines the connection status of Bluetooth (Classic Bluetooth or BLE).
 *       Used to indicate the current connection state of the Bluetooth adapter.
 * [CN]: 定义蓝牙的连接状态（经典蓝牙或BLE）。
 *       用于指示蓝牙适配器的当前连接状态。
 */
typedef NS_ENUM(NSInteger, TSBluetoothConnectionStatus) {
    /// 未连接（Not connected）
    TSBluetoothConnectionStatusDisconnected = 0,
    /// 已连接（Connected）
    TSBluetoothConnectionStatusConnected = 1,
    /// 已就绪（Ready - Connected and Notify/SPP opened）
    TSBluetoothConnectionStatusReady = 2
};

/**
 * @brief Bluetooth information model
 * @chinese 蓝牙信息模型
 *
 * @discussion
 * [EN]: Contains Bluetooth information including MAC address, name, and connection status.
 *       This is a generic class used for both Classic Bluetooth and BLE.
 * [CN]: 包含蓝牙信息，包括MAC地址、名称和连接状态。
 *       这是一个通用类，用于经典蓝牙和BLE。
 */
@interface TSBluetoothInfo : NSObject

/**
 * @brief Bluetooth MAC address
 * @chinese 蓝牙MAC地址
 *
 * @discussion
 * [EN]: MAC address of Bluetooth (colon-separated format, e.g. "DE:82:47:15:28:B0").
 *       May be nil if not available or on platforms where MAC address is restricted.
 * [CN]: 蓝牙的MAC地址（冒号分隔格式，例如 "DE:82:47:15:28:B0"）。
 *       如果不可用或在MAC地址受限的平台上可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *macAddress;

/**
 * @brief Bluetooth name
 * @chinese 蓝牙名称
 *
 * @discussion
 * [EN]: Name of the Bluetooth.
 *       May be nil if not available.
 * [CN]: 蓝牙的名称。
 *       如果不可用可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 * @brief Bluetooth connection status
 * @chinese 蓝牙连接状态
 *
 * @discussion
 * [EN]: Current connection status of Bluetooth.
 *       - TSBluetoothConnectionStatusDisconnected (0): Not connected
 *       - TSBluetoothConnectionStatusConnected (1): Connected
 *       - TSBluetoothConnectionStatusReady (2): Ready (Connected and Notify/SPP opened)
 *       Default is TSBluetoothConnectionStatusDisconnected.
 * [CN]: 蓝牙的当前连接状态。
 *       - TSBluetoothConnectionStatusDisconnected (0): 未连接
 *       - TSBluetoothConnectionStatusConnected (1): 已连接
 *       - TSBluetoothConnectionStatusReady (2): 已就绪（已连接且打开了Notify/SPP）
 *       默认为 TSBluetoothConnectionStatusDisconnected。
 */
@property (nonatomic, assign) TSBluetoothConnectionStatus status;

@end

/**
 * @brief Complete Bluetooth information model
 * @chinese 完整的蓝牙信息模型
 *
 * @discussion
 * [EN]: Contains comprehensive Bluetooth information including both Classic Bluetooth (BT) and BLE information.
 *       This class represents the complete Bluetooth system status with both BLE and BT adapters.
 * [CN]: 包含完整的蓝牙信息，包括经典蓝牙（BT）和BLE信息。
 *       此类表示完整的蓝牙系统状态，包含BLE和BT两个适配器。
 */
@interface TSBluetoothSystem : NSObject

/**
 * @brief BLE (Bluetooth Low Energy) information
 * @chinese BLE（低功耗蓝牙）信息
 *
 * @discussion
 * [EN]: Information about BLE including MAC address, name, and connection status.
 *       Connection status indicates: 0=Not connected, 1=Connected, 2=Ready (Connected and Notify opened).
 * [CN]: 关于BLE的信息，包括MAC地址、名称和连接状态。
 *       连接状态表示：0=未连接，1=已连接，2=已就绪（已连接且打开了Notify）。
 */
@property (nonatomic, strong, nullable) TSBluetoothInfo *bleInfo;

/**
 * @brief BT (Classic Bluetooth) information
 * @chinese BT（经典蓝牙）信息
 *
 * @discussion
 * [EN]: Information about Classic Bluetooth including MAC address, name, and connection status.
 *       Connection status indicates: 0=Not connected, 1=Connected, 2=Ready (Connected and SPP opened).
 * [CN]: 关于经典蓝牙的信息，包括MAC地址、名称和连接状态。
 *       连接状态表示：0=未连接，1=已连接，2=已就绪（已连接且打开了SPP）。
 */
@property (nonatomic, strong, nullable) TSBluetoothInfo *btInfo;

@end

NS_ASSUME_NONNULL_END
