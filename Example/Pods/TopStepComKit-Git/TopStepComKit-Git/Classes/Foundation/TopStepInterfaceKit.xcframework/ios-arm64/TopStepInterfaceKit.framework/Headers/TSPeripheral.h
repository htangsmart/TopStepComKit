//
//  TSPeripheral.h
//  TopStepComKit
//
//  Created by 磐石 on 2025/1/2.
//
//  文件说明:
//  该类用于描述外设设备的基本信息，包括蓝牙属性、屏幕参数、系统信息等

#import <Foundation/Foundation.h>
#import "TSPeripheralSystem.h"
#import "TSPeripheralProject.h"
#import "TSPeripheralScreen.h"
#import "TSPeripheralCapability.h"
#import "TSPeripheralLimitations.h"

#define TSEqualPeripheral(a, b) ({ \
    TSPeripheral *__peripheral1 = (a); \
    TSPeripheral *__peripheral2 = (b); \
    [TSPeripheral isEqualPeripheral:__peripheral1 another:__peripheral2]; \
})
/**
 * TSPeripheral
 * 外设设备信息类，用于管理和存储设备的基本参数
 * 包含设备的蓝牙信息、屏幕参数、系统信息等完整属性
 */
@interface TSPeripheral : NSObject

#pragma mark - 基础属性

/**
 * @brief System related information
 * @chinese 系统相关信息
 *
 * @discussion 
 * [EN]: Contains Bluetooth peripheral object, MAC address, Bluetooth name, and other system-level information
 * [CN]: 包含蓝牙外设对象、MAC地址、蓝牙名称等系统级信息
 */
@property (nonatomic,strong) TSPeripheralSystem * systemInfo;

/**
 * @brief Screen related information
 * @chinese 屏幕相关信息
 *
 * @discussion 
 * [EN]: Contains screen size, shape, preview size, and other display-related parameters
 * [CN]: 包含屏幕尺寸、形状、预览图尺寸等显示相关参数
 */
@property (nonatomic,strong) TSPeripheralScreen * screenInfo;

/**
 * @brief Project related information
 * @chinese 项目相关信息
 *
 * @discussion 
 * [EN]: Contains project ID, firmware version, device serial number, and other project-level information
 * [CN]: 包含项目ID、固件版本、设备序列号等项目级信息
 */
@property (nonatomic,strong) TSPeripheralProject * projectInfo;


/**
 * @brief Device capability information
 * @chinese 设备能力信息
 *
 * @discussion 
 * [EN]: Contains detailed information about supported features and functionalities of the device, 
 * such as heart rate monitoring, sleep tracking, alarms, notification support, and other hardware capabilities.
 * 
 * [CN]: 包含设备支持的功能和特性的详细信息，如心率监测、睡眠追踪、闹钟、通知支持和其他硬件能力。
 */
@property (nonatomic,strong) TSPeripheralCapability * capability;

/**
 * @brief Device feature limitations
 * @chinese 设备功能限制
 *
 * @discussion 
 * [EN]: Contains constraints and limitations for device features, such as maximum number of alarms, 
 * reminders, contacts, and watch faces that can be stored on the device.
 * 
 * [CN]: 包含设备功能的约束和限制，如设备上可以存储的最大闹钟数、提醒数、联系人数和表盘数。
 */
@property (nonatomic,strong) TSPeripheralLimitations * limitation;


#pragma mark - 方法
/**
 * @brief Create TSPeripheral instance using CBPeripheral
 * @chinese 使用CBPeripheral创建TSPeripheral实例
 *
 * @return 
 * EN: New TSPeripheral instance
 * CN: 新的TSPeripheral实例
 */
+ (TSPeripheral *)peripheralWithPeriperal:(CBPeripheral *)peripheral mac:(NSString *)mac RSSI:(NSNumber *)RSSI;

/**
 * @brief Compare two peripherals for equality
 * @chinese 比较两个外设是否相同
 *
 * @return
 * EN: Whether they are equal
 * CN: 是否相同
 */
+ (BOOL)isEqualPeripheral:(TSPeripheral *)peripheral another:(TSPeripheral *)another;

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

/**
 * @brief Print brief device information log
 * @chinese 打印设备简要信息日志
 *
 * @discussion
 * [EN]: Outputs a concise log containing essential device information including:
 *       - Device Bluetooth name
 *       - MAC address
 *       - Signal strength (RSSI)
 *       The log is formatted for quick debugging and device identification.
 *
 * [CN]: 输出包含以下基本设备信息的简洁日志：
 *       - 设备蓝牙名称
 *       - MAC地址
 *       - 信号强度（RSSI）
 *       日志格式便于快速调试和设备识别。
 */
- (void)shortLog;


+ (BOOL)isErrorPeripheral:(TSPeripheral *)peripheral;

@end


