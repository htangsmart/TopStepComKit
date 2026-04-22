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
 * @brief Bluetooth adapter connection status enumeration
 * @chinese 蓝牙适配器连接状态枚举
 *
 * @discussion
 * [EN]: Defines the connection status of Bluetooth adapter (Classic Bluetooth or BLE).
 *       This status represents the current state of the Bluetooth adapter, not the connection process.
 *       Used to indicate whether the adapter is connected and ready for communication.
 * [CN]: 定义蓝牙适配器的连接状态（经典蓝牙或BLE）。
 *       此状态表示蓝牙适配器的当前状态，而非连接过程。
 *       用于指示适配器是否已连接并准备好进行通信。
 *
 * @note
 * [EN]: This is different from TSBleConnectionState which describes the connection process lifecycle.
 *       TSBleConnectionState includes intermediate states like Connecting, Authenticating, etc.
 *       TSBluetoothConnectionStatus only represents the final adapter state.
 * [CN]: 这与描述连接过程生命周期的 TSBleConnectionState 不同。
 *       TSBleConnectionState 包含连接中、认证中等中间状态。
 *       TSBluetoothConnectionStatus 仅表示适配器的最终状态。
 */
typedef NS_ENUM(NSInteger, TSBleStatus) {
    /// 未连接（Not connected）
    TSBleDisconnected = 0,
    /// 已连接（Connected - physical connection established）
    TSBleConnected = 1,
    /// 已就绪（Ready - Connected and Notify/SPP opened, ready for data communication）
    TSBleReady = 2
};

/**
 * @brief Bluetooth information model
 * @chinese 蓝牙信息模型
 *
 * @discussion
 * [EN]: Contains Bluetooth information including MAC address, name, and connection status.
 *       This is a generic class used for both Classic Bluetooth and BLE.
 *       The status property represents the current state of the Bluetooth adapter.
 * [CN]: 包含蓝牙信息，包括MAC地址、名称和连接状态。
 *       这是一个通用类，用于经典蓝牙和BLE。
 *       status 属性表示蓝牙适配器的当前状态。
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
 * @brief Bluetooth adapter connection status
 * @chinese 蓝牙适配器连接状态
 *
 */
@property (nonatomic, assign) TSBleStatus status;

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
 */
@property (nonatomic, strong, nullable) TSBluetoothInfo *bleInfo;

/**
 * @brief BT (Classic Bluetooth) information
 * @chinese BT（经典蓝牙）信息
 */
@property (nonatomic, strong, nullable) TSBluetoothInfo *btInfo;

@end

NS_ASSUME_NONNULL_END
