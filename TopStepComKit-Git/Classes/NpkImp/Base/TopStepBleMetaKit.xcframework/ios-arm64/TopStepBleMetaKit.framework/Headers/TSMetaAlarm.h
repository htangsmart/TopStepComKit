//
//  TSMetaAlarm.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 闹钟操作完成回调
 * @chinese 闹钟操作完成时的回调
 *
 * @param alarmList 闹钟列表数据，成功时不为nil
 *        EN: Alarm list data, not nil when successful
 *        CN: 闹钟列表数据，成功时不为nil
 *
 * @param error 错误信息，成功时为nil
 *        EN: Error information, nil when successful
 *        CN: 错误信息，成功时为nil
 */
typedef void(^TSAlarmsCompletionBlock)(TSMetaAlarmList * _Nullable alarmList, NSError * _Nullable error);

@interface TSMetaAlarm : TSBusinessBase

/**
 * @brief 获取闹钟列表
 * @chinese 从设备获取当前设置的闹钟列表
 *
 * @param completion 完成回调，返回闹钟列表或错误信息
 *        EN: Completion callback with alarm list or error information
 *        CN: 完成回调，返回闹钟列表或错误信息
 *
 * @discussion
 * EN: Retrieves the current alarm list from the connected device.
 *     The callback will return an AlarmList object containing all configured alarms on success,
 *     or an error on failure.
 * CN: 从已连接的设备获取当前的闹钟列表。
 *     成功时回调将返回包含所有已配置闹钟的AlarmList对象，失败时返回错误信息。
 */
+ (void)fetchAllAlarmsCompletion:(TSAlarmsCompletionBlock _Nullable)completion;

/**
 * @brief 设置闹钟列表
 * @chinese 向设备设置闹钟列表
 *
 * @param alarmList 要设置的闹钟列表
 *        EN: Alarm list to be set
 *        CN: 要设置的闹钟列表
 *
 * @param completion 完成回调，返回设置结果或错误信息
 *        EN: Completion callback with setting result or error information
 *        CN: 完成回调，返回设置结果或错误信息
 *
 * @discussion
 * EN: Sets the alarm list to the connected device.
 *     The device will replace existing alarms with the provided list.
 *     Use empty list to clear all alarms.
 * CN: 向已连接的设备设置闹钟列表。
 *     设备将用提供的列表替换现有闹钟。
 *     使用空列表可清除所有闹钟。
 */
+ (void)pushAllAlarms:(TSMetaAlarmList * _Nullable)alarmList completion:(TSMetaCompletionBlock _Nullable)completion;

/**
 * @brief 注册闹钟变化通知
 * @chinese 注册接收设备闹钟变化通知
 *
 * @param completion 完成回调，当闹钟变化时返回最新的闹钟列表或错误信息
 *        EN: Completion callback, returns latest alarm list or error when alarms change
 *        CN: 完成回调，当闹钟变化时返回最新的闹钟列表或错误信息
 *
 * @discussion
 * EN: Registers a notification to receive alarm change events from the device.
 *     The completion block will be called whenever the device reports alarm changes.
 * CN: 注册通知以接收来自设备的闹钟变更事件。
 *     当设备上报闹钟变化时，完成回调将被调用。
 */
+ (void)registerAlarmDidChangedNotification:(TSAlarmsCompletionBlock _Nullable)completion;

/**
 * @brief Fetch the complete list using a frozen physical connection.
 * @chinese 使用冻结的物理连接读取完整列表。
 * @param context EN: Original connection, or nil for the current connection. CN: 原连接上下文，nil 使用当前连接。
 * @param completion EN: Complete list or error. CN: 完整列表或错误。
 */
+ (void)fetchAllAlarmsWithContext:(nullable TSBleWriteContext *)context
                         completion:(nullable TSAlarmsCompletionBlock)completion;

/**
 * @brief Replace the full list on the original physical connection.
 * @chinese 在原物理连接上替换完整列表。
 * @param list EN: Records to snapshot; nil clears the list. CN: 需要快照的记录，nil 表示清空。
 * @param context EN: Frozen target connection, or nil for current connection. CN: 冻结的目标连接，nil 使用当前连接。
 * @param completion EN: Device result or failure. CN: 设备执行结果或错误。
 */
+ (void)pushAllAlarms:(nullable TSMetaAlarmList *)list
                    context:(nullable TSBleWriteContext *)context
                 completion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
