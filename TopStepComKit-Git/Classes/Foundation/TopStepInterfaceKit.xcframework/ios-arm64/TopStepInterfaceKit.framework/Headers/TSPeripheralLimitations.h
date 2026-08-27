//
//  TSPeripheralLimitations.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <Foundation/Foundation.h>

#define TSUnLimitNum UINT8_MAX

/**
 * @brief Default maximum UTF-8 byte count for AI response text
 * @chinese AI 应答文本的默认最大 UTF-8 字节数
 */
FOUNDATION_EXPORT NSUInteger const TSPeripheralDefaultAIResponseTextMaxBytes;

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
@property (nonatomic, readonly) UInt8 maxAlarmCount;

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
@property (nonatomic, readonly) UInt8 maxContactCount;

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
@property (nonatomic, readonly) UInt8 maxEmergencyContactCount;

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
@property (nonatomic, readonly) UInt8 maxPushDialCount;

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
@property (nonatomic, readonly) UInt8 maxInnerDialCount;

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
@property (nonatomic, readonly) UInt8 maxWorldClockCount;

/**
 * @brief Maximum number of sedentary reminders supported by device
 * @chinese 设备支持的最大久坐提醒数量
 *
 * @discussion
 * [EN]: Defines the maximum number of sedentary reminders that can be set on the device.
 * Value of 0 indicates the sedentary reminder function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以设置的最大久坐提醒数量。
 * 值为0表示不支持久坐提醒功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic, readonly) UInt8 maxSedentaryReminderCount;

/**
 * @brief Maximum number of water drinking reminders supported by device
 * @chinese 设备支持的最大喝水提醒数量
 *
 * @discussion
 * [EN]: Defines the maximum number of water drinking reminders that can be set on the device.
 * Value of 0 indicates the water drinking reminder function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以设置的最大喝水提醒数量。
 * 值为0表示不支持喝水提醒功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic, readonly) UInt8 maxWaterDrinkingReminderCount;

/**
 * @brief Maximum number of medication reminders supported by device
 * @chinese 设备支持的最大吃药提醒数量
 *
 * @discussion
 * [EN]: Defines the maximum number of medication reminders that can be set on the device.
 * Value of 0 indicates the medication reminder function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以设置的最大吃药提醒数量。
 * 值为0表示不支持吃药提醒功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic, readonly) UInt8 maxMedicationReminderCount;

/**
 * @brief Maximum number of custom reminders supported by device
 * @chinese 设备支持的最大自定义提醒数量
 *
 * @discussion
 * [EN]: Defines the maximum number of custom reminders that can be set on the device.
 * Value of 0 indicates the custom reminder function is not supported.
 * The valid range is 1-255, where 0 means not supported and 255 means unlimited.
 *
 * [CN]: 定义设备上可以设置的最大自定义提醒数量。
 * 值为0表示不支持自定义提醒功能。
 * 有效范围为1-255，其中0表示不支持，255表示无限制。
 */
@property (nonatomic, readonly) UInt8 maxCustomReminderCount;

/**
 * @brief Maximum UTF-8 byte count supported for AI response text
 * @chinese AI 应答文本支持的最大 UTF-8 字节数
 *
 * @discussion
 * [EN]: A value of 0 means that response text must be sent as an empty string.
 * [CN]: 值为0表示应答文本必须以空字符串发送。
 */
@property (nonatomic, assign, readonly) NSUInteger maxAIResponseTextBytes;

/**
 * @brief Initialize existing limitations with the default AI response text limit
 * @chinese 使用既有限制及默认 AI 应答文本上限初始化
 *
 * @discussion
 * [EN]: maxAIResponseTextBytes is initialized to TSPeripheralDefaultAIResponseTextMaxBytes.
 * [CN]: maxAIResponseTextBytes 初始化为 TSPeripheralDefaultAIResponseTextMaxBytes。
 *
 * @param maxAlarm Maximum number of alarms (Required)
 * @param maxContact Maximum number of contacts (Required)
 * @param maxEmergencyContact Maximum number of emergency contacts (Required)
 * @param maxPushDial Maximum number of pushable watch faces (Required)
 * @param maxInnerDialCount Number of pre-installed watch faces (Required)
 * @param maxWorldClock Maximum number of world clocks (Required)
 * @param maxSedentaryReminder Maximum number of sedentary reminders (Required)
 * @param maxWaterDrinkingReminder Maximum number of water drinking reminders (Required)
 * @param maxMedicationReminder Maximum number of medication reminders (Required)
 * @param maxCustomReminder Maximum number of custom reminders (Required)
 * @return Initialized instance
 * @throws NSInvalidArgumentException if any required parameter is invalid
 */
- (instancetype)initWithMaxAlarm:(UInt8)maxAlarm
                      maxContact:(UInt8)maxContact
             maxEmergencyContact:(UInt8)maxEmergencyContact
                     maxPushDial:(UInt8)maxPushDial
               maxInnerDialCount:(UInt8)maxInnerDialCount
                   maxWorldClock:(UInt8)maxWorldClock
            maxSedentaryReminder:(UInt8)maxSedentaryReminder
        maxWaterDrinkingReminder:(UInt8)maxWaterDrinkingReminder
           maxMedicationReminder:(UInt8)maxMedicationReminder
               maxCustomReminder:(UInt8)maxCustomReminder NS_DESIGNATED_INITIALIZER;

/**
 * @brief Initialize with all limitations and the AI response text byte limit
 * @chinese 使用所有限制及 AI 应答文本字节上限初始化
 *
 * @param maxAlarm EN: Maximum alarm count. CN: 最大闹钟数量。
 * @param maxContact EN: Maximum contact count. CN: 最大联系人数量。
 * @param maxEmergencyContact EN: Maximum emergency contact count. CN: 最大紧急联系人数量。
 * @param maxPushDial EN: Maximum pushable watch face count. CN: 最大可推送表盘数量。
 * @param maxInnerDialCount EN: Pre-installed watch face count. CN: 预装表盘数量。
 * @param maxWorldClock EN: Maximum world clock count. CN: 最大世界时钟数量。
 * @param maxSedentaryReminder EN: Maximum sedentary reminder count. CN: 最大久坐提醒数量。
 * @param maxWaterDrinkingReminder EN: Maximum drinking reminder count. CN: 最大喝水提醒数量。
 * @param maxMedicationReminder EN: Maximum medication reminder count. CN: 最大吃药提醒数量。
 * @param maxCustomReminder EN: Maximum custom reminder count. CN: 最大自定义提醒数量。
 * @param maxAIResponseTextBytes
 * EN: Maximum UTF-8 bytes for AI response text.
 * An explicit 0 does not use the default value.
 * CN: AI 应答文本最大 UTF-8 字节数；明确传入0时不使用默认值。
 * @return EN: Initialized instance. CN: 初始化后的实例。
 */
- (instancetype)initWithMaxAlarm:(UInt8)maxAlarm
                      maxContact:(UInt8)maxContact
             maxEmergencyContact:(UInt8)maxEmergencyContact
                     maxPushDial:(UInt8)maxPushDial
               maxInnerDialCount:(UInt8)maxInnerDialCount
                   maxWorldClock:(UInt8)maxWorldClock
            maxSedentaryReminder:(UInt8)maxSedentaryReminder
        maxWaterDrinkingReminder:(UInt8)maxWaterDrinkingReminder
           maxMedicationReminder:(UInt8)maxMedicationReminder
               maxCustomReminder:(UInt8)maxCustomReminder
          maxAIResponseTextBytes:(NSUInteger)maxAIResponseTextBytes;

/**
 * @brief Disable default init method
 * @chinese 禁用默认初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用new方法
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Disable copy method
 * @chinese 禁用copy方法
 */
- (id)copy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
