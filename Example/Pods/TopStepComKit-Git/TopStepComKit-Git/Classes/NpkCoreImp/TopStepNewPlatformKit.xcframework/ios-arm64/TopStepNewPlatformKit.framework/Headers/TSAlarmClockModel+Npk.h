//
//  TSAlarmClockModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAlarmClockModel (Npk)

/**
 * @brief 从AlarmItem创建TSAlarmClockModel对象
 * @chinese 将protobuf的AlarmItem转换为TSAlarmClockModel对象
 *
 * @param alarmItem protobuf闹钟项对象
 *        EN: Protobuf alarm item object
 *        CN: protobuf闹钟项对象
 *
 * @return TSAlarmClockModel对象
 *        EN: TSAlarmClockModel object
 *        CN: TSAlarmClockModel对象
 *
 * @discussion
 * EN: Converts a protobuf AlarmItem to TSAlarmClockModel.
 *     Maps all properties including ID, time, repeat options, label, and enabled status.
 * CN: 将protobuf的AlarmItem转换为TSAlarmClockModel。
 *     映射所有属性包括ID、时间、重复选项、标签和启用状态。
 */
+ (TSAlarmClockModel *)alarmModelFromAlarmItem:(TSMetaAlarmItem *)alarmItem;

/**
 * @brief 从AlarmList创建TSAlarmClockModel数组
 * @chinese 将protobuf的AlarmList转换为TSAlarmClockModel对象数组
 *
 * @param alarmList protobuf闹钟列表对象
 *        EN: Protobuf alarm list object
 *        CN: protobuf闹钟列表对象
 *
 * @return TSAlarmClockModel对象数组
 *        EN: Array of TSAlarmClockModel objects
 *        CN: TSAlarmClockModel对象数组
 *
 * @discussion
 * EN: Converts a protobuf AlarmList to an array of TSAlarmClockModel objects.
 *     Each AlarmItem in the list is converted to a corresponding TSAlarmClockModel.
 * CN: 将protobuf的AlarmList转换为TSAlarmClockModel对象数组。
 *     列表中的每个AlarmItem都会被转换为对应的TSAlarmClockModel。
 */
+ (NSArray<TSAlarmClockModel *> *)alarmModelsFromAlarmList:(TSMetaAlarmList *)alarmList;

/**
 * @brief 从TSAlarmClockModel数组创建AlarmList
 * @chinese 将TSAlarmClockModel对象数组转换为protobuf的AlarmList
 *
 * @param alarmModels TSAlarmClockModel对象数组
 *        EN: Array of TSAlarmClockModel objects
 *        CN: TSAlarmClockModel对象数组
 *
 * @return AlarmList对象
 *        EN: AlarmList object
 *        CN: AlarmList对象
 *
 * @discussion
 * EN: Converts an array of TSAlarmClockModel objects to a protobuf AlarmList.
 *     Each TSAlarmClockModel is converted to a corresponding AlarmItem.
 * CN: 将TSAlarmClockModel对象数组转换为protobuf的AlarmList。
 *     每个TSAlarmClockModel都会被转换为对应的AlarmItem。
 */
+ (TSMetaAlarmList *)alarmListFromAlarmModels:(NSArray<TSAlarmClockModel *> *)alarmModels;

@end

NS_ASSUME_NONNULL_END
