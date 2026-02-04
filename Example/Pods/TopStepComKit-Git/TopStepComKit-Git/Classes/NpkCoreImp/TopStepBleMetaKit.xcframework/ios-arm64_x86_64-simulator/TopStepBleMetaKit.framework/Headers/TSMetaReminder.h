//
//  TSMetaReminder.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 提醒操作完成回调
 * @chinese 提醒操作完成时的回调
 *
 * @param reminderList 提醒列表数据，成功时不为nil
 *        EN: Reminder list data, not nil when successful
 *        CN: 提醒列表数据，成功时不为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSRemindersCompletionBlock)(TSMetaRemindList * _Nullable reminderList, NSError * _Nullable error);

@interface TSMetaReminder : TSBusinessBase

/**
 * @brief 获取提醒列表
 * @chinese 从设备获取当前设置的提醒列表
 *
 * @param completion 完成回调，返回提醒列表或错误信息
 *        EN: Completion callback with reminder list or error information
 *        CN: 完成回调，返回提醒列表或错误信息
 *
 * @discussion
 * EN: Retrieves the current reminder list from the connected device.
 *     The callback will return a RemindList object containing all configured reminders on success,
 *     or an error on failure.
 * CN: 从已连接的设备获取当前的提醒列表。
 *     成功时回调将返回包含所有已配置提醒的RemindList对象，失败时返回错误信息。
 */
+ (void)getRemindersCompletion:(TSRemindersCompletionBlock _Nullable)completion;

/**
 * @brief 设置提醒列表
 * @chinese 向设备设置提醒列表
 *
 * @param reminderList 要设置的提醒列表
 *        EN: Reminder list to be set
 *        CN: 要设置的提醒列表
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the reminder list to the connected device.
 *     The device will replace existing reminders with the provided list.
 *     Use empty list to clear all reminders.
 * CN: 向已连接的设备设置提醒列表。
 *     设备将用提供的列表替换现有提醒。
 *     使用空列表可清除所有提醒。
 */
+ (void)setReminders:(TSMetaRemindList * _Nullable)reminderList completion:(TSMetaCompletionBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
