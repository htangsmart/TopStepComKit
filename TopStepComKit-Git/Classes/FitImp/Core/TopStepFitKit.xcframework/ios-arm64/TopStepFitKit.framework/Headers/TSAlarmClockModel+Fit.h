//
//  TSAlarmClockModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudAlarmObject;
@class FitCloudScheduleObject;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief alarmId base for alarms that live in the watch schedule list
 * @chinese 存放在手表「日程」列表中的闹钟的 alarmId 起始值
 *
 * @discussion
 * [EN]: FitCloud schedules carry no id, so the SDK derives alarmId = base + index in the schedule list.
 *       Ids below the base belong to the FitCloud alarm list (0–7).
 * [CN]: FitCloud 日程没有 id，SDK 以「起始值 + 日程列表下标」合成 alarmId；小于起始值的 id 属于 FitCloud 闹钟列表（0–7）。
 */
FOUNDATION_EXPORT const UInt8 TSFitScheduleAlarmIdBase;

@interface TSAlarmClockModel (Fit)

/**
 * @brief Convert FitCloudAlarmObject array to TSAlarmClockModel array
 * @chinese 将FitCloudAlarmObject数组转换为TSAlarmClockModel数组
 * 
 * @param fitAlarmObjects 
 * EN: Array of FitCloudAlarmObject objects to be converted
 * CN: 需要转换的FitCloudAlarmObject对象数组
 * 
 * @return 
 * EN: Array of converted TSAlarmClockModel objects
 * CN: 转换后的TSAlarmClockModel对象数组
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFitCloudAlarmObjects:(NSArray<FitCloudAlarmObject *> *)fitAlarmObjects;

/**
 * @brief Convert single FitCloudAlarmObject to TSAlarmClockModel
 * @chinese 将单个FitCloudAlarmObject转换为TSAlarmClockModel
 * 
 * @param fitAlarmObject 
 * EN: Single FitCloudAlarmObject object to be converted
 * CN: 需要转换的单个FitCloudAlarmObject对象
 * 
 * @return 
 * EN: Converted TSAlarmClockModel object
 * CN: 转换后的TSAlarmClockModel对象
 */
+ (TSAlarmClockModel *)alarmModelFromFitCloudAlarmObject:(FitCloudAlarmObject *)fitAlarmObject;

/**
 * @brief Convert TSAlarmClockModel array to FitCloudAlarmObject array
 * @chinese 将TSAlarmClockModel数组转换为FitCloudAlarmObject数组
 * 
 * @param alarmModels 
 * EN: Array of TSAlarmClockModel objects to be converted
 * CN: 需要转换的TSAlarmClockModel对象数组
 * 
 * @return 
 * EN: Array of converted FitCloudAlarmObject objects
 * CN: 转换后的FitCloudAlarmObject对象数组
 */
+ (NSArray<FitCloudAlarmObject *> *)fitCloudAlarmObjectsFromAlarmModels:(NSArray<TSAlarmClockModel *> *)alarmModels;

/**
 * @brief Convert single TSAlarmClockModel to FitCloudAlarmObject
 * @chinese 将单个TSAlarmClockModel转换为FitCloudAlarmObject
 * 
 * @param alarmModel 
 * EN: Single TSAlarmClockModel object to be converted
 * CN: 需要转换的单个TSAlarmClockModel对象
 * 
 * @return 
 * EN: Converted FitCloudAlarmObject object
 * CN: 转换后的FitCloudAlarmObject对象
 */
+ (FitCloudAlarmObject *)fitCloudAlarmObjectFromAlarmModel:(TSAlarmClockModel *)alarmModel;

#pragma mark - 类型闹钟 <-> FitCloud 日程

/**
 * @brief Whether the model should be stored as a watch schedule rather than a plain alarm
 * @chinese 该模型应存为手表「日程」而不是普通闹钟
 *
 * @discussion
 * [EN]: YES when alarmId >= TSFitScheduleAlarmIdBase (it was read from the schedule list) or when
 *       alarmType is neither TSAlarmTypeAlarm nor the default 0. A new model with alarmType 0 stays a plain alarm.
 * [CN]: alarmId >= TSFitScheduleAlarmIdBase（来自日程列表）或 alarmType 既不是 TSAlarmTypeAlarm 也不是默认 0 时为 YES；
 *       新建且 alarmType 为 0 的模型仍按普通闹钟处理。
 */
+ (BOOL)fitIsScheduleAlarm:(TSAlarmClockModel *)alarmModel;

/**
 * @brief Convert FitCloudScheduleObject array to TSAlarmClockModel array
 * @chinese 将 FitCloudScheduleObject 数组转换为 TSAlarmClockModel 数组（alarmId = 起始值 + 下标，alarmType = scheduleType）
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromFitCloudScheduleObjects:(NSArray<FitCloudScheduleObject *> *)scheduleObjects;

/**
 * @brief Convert TSAlarmClockModel array to FitCloudScheduleObject array
 * @chinese 将 TSAlarmClockModel 数组转换为 FitCloudScheduleObject 数组
 */
+ (NSArray<FitCloudScheduleObject *> *)fitCloudScheduleObjectsFromAlarmModels:(NSArray<TSAlarmClockModel *> *)alarmModels;

@end

NS_ASSUME_NONNULL_END
