//
//  TSPeripheralLimitations.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <Foundation/Foundation.h>

#define TSUnLimitNum UINT8_MAX

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device feature limitations class
 * @chinese 设备功能限制类
 *
 * @discussion
 * [EN]: Contains various device capability limitations such as maximum counts for alarms, reminders, 
 * contacts, and watch faces. These values define the hardware or firmware constraints of the device.
 *
 * [CN]: 包含各种设备能力限制，如闹钟、提醒、联系人和表盘的最大数量。
 * 这些值定义了设备的硬件或固件约束。
 */
@interface TSPeripheralLimitations : NSObject

/**
 * @brief Maximum number of alarm clocks supported by device
 * @chinese 设备支持的最大闹钟数量
 *
 * @discussion
 * [EN]: Defines the maximum number of alarm clocks that can be set on the device.
 * Value of 0 indicates the alarm clock function is not supported.
 *
 * [CN]: 定义设备上可以设置的最大闹钟数量。
 * 值为0表示不支持闹钟功能。
 */

@property (nonatomic,assign) UInt8 maxAlarmCount;

/**
 * @brief Maximum number of reminders supported by device
 * @chinese 设备支持的最大提醒数量
 *
 * @discussion
 * [EN]: Defines the maximum number of reminders that can be set on the device.
 * Value of 0 indicates the reminder function is not supported.
 *
 * [CN]: 定义设备上可以设置的最大提醒数量。
 * 值为0表示不支持提醒功能。
 */
@property (nonatomic,assign) UInt8 maxReminderCount;

/**
 * @brief Maximum number of contacts supported by device
 * @chinese 设备支持的最大联系人数量
 *
 * @discussion
 * [EN]: Defines the maximum number of contacts that can be stored on the device.
 * Value of 0 indicates the contact storage function is not supported.
 *
 * [CN]: 定义设备上可以存储的最大联系人数量。
 * 值为0表示不支持联系人存储功能。
 */
@property (nonatomic,assign) UInt8 maxContactCount;

/**
 * @brief Maximum number of emergency contacts supported by device
 * @chinese 设备支持的最大紧急联系人数量
 *
 * @discussion
 * [EN]: Defines the maximum number of emergency contacts that can be stored on the device.
 * Value of 0 indicates the emergency contact storage function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以存储的最大紧急联系人数量。
 * 值为0表示不支持紧急联系人存储功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic,assign) UInt8 maxEmergencyContactCount;

/**
 * @brief Maximum number of custom watch faces that can be pushed to device
 * @chinese 设备支持的最大可推送表盘位置个数
 *
 * @discussion
 * [EN]: Defines the maximum number of custom watch faces slots available on the device.
 * These slots can be filled with user-selected watch faces pushed from the app.
 * Value of 0 indicates custom watch faces cannot be pushed to the device.
 *
 * [CN]: 定义设备上可用的最大自定义表盘位置数量。
 * 这些位置可以被从应用推送的用户选择的表盘填充。
 * 值为0表示不能向设备推送自定义表盘。
 */
@property (nonatomic,assign) UInt8 maxPushDialCount;

/**
 * @brief Number of pre-installed watch faces on device
 * @chinese 设备预装的表盘数量
 *
 * @discussion
 * [EN]: Indicates the number of watch faces that come pre-installed on the device.
 * These cannot be removed and are part of the device firmware.
 *
 * [CN]: 表示设备上预装的表盘数量。
 * 这些表盘不能被移除，是设备固件的一部分。
 */
@property (nonatomic,assign) UInt8 innerDialCount;

/**
 * @brief Maximum number of world clocks supported by device
 * @chinese 设备支持的最大世界时钟数量
 *
 * @discussion
 * [EN]: Defines the maximum number of world clocks that can be set on the device.
 * Value of 0 indicates the world clock function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以设置的最大世界时钟数量。
 * 值为0表示不支持世界时钟功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic,assign) UInt8 maxWorldClockCount;

@end

NS_ASSUME_NONNULL_END
