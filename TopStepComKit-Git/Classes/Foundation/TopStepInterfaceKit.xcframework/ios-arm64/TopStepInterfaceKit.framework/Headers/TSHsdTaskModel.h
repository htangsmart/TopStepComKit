//
//  TSHsdTaskModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"
#import "TSAlarmClockModel.h"
#import "TSHsdDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Task model of the task & reward feature
 * @chinese 任务&奖励功能中的任务模型
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Tasks are carried inside TSHsdTaskInfoModel and exchanged through
 *      TSHuashengdaInterface.fetchTaskInfo: / setTaskInfo:completion:.
 * [CN]: 华盛达定制能力。
 *      任务包含在 TSHsdTaskInfoModel 中，通过 TSHuashengdaInterface.fetchTaskInfo: / setTaskInfo:completion: 读写。
 */
@interface TSHsdTaskModel : TSKitBaseModel <NSCopying>

/**
 * @brief Task identifier
 * @chinese 任务 ID
 *
 * @discussion
 * [EN]: Assigned by the App and kept unique within the task list.
 * [CN]: 由 App 分配，在任务列表内保持唯一。
 */
@property (nonatomic, assign) NSInteger taskId;

/**
 * @brief Execution time of the task
 * @chinese 任务执行时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 11:30 = 11 * 60 + 30 = 690).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 11:30 = 11 * 60 + 30 = 690）。
 */
@property (nonatomic, assign) NSInteger minuteOfDay;

/**
 * @brief Task label
 * @chinese 任务标签
 *
 * @discussion
 * [EN]: At most TSHsdTaskLabelMaxBytes (32) UTF-8 bytes; longer values fail validation.
 * [CN]: UTF-8 最多 TSHsdTaskLabelMaxBytes（32）字节，超出时校验失败。
 */
@property (nonatomic, copy, nullable) NSString *label;

/**
 * @brief Whether the task is enabled
 * @chinese 任务是否启用
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Weekly repeat options
 * @chinese 星期重复选项
 *
 * @discussion
 * [EN]: Uses TSAlarmRepeat; combine days with |, e.g. TSAlarmRepeatMonday | TSAlarmRepeatFriday. TSAlarmRepeatNone means one-off.
 * [CN]: 使用闹钟的 TSAlarmRepeat，多天用 | 组合，如 TSAlarmRepeatMonday | TSAlarmRepeatFriday。TSAlarmRepeatNone 表示仅一次。
 */
@property (nonatomic, assign) TSAlarmRepeat repeatOptions;

/**
 * @brief Task type
 * @chinese 任务类型
 *
 * @discussion
 * [EN]: See TSHsdTaskType (alias of TSAlarmType, use TSAlarmTypeXxx). The value is passed through to the device without whitelist validation.
 * [CN]: 见 TSHsdTaskType（TSAlarmType 的别名，使用 TSAlarmTypeXxx 常量）。取值原样透传给设备，不做白名单校验。
 */
@property (nonatomic, assign) TSHsdTaskType type;

/**
 * @brief Task state of the current day
 * @chinese 当天任务状态
 *
 * @discussion
 * [EN]: Maintained by the device; the App normally leaves it as TSHsdTaskStateNotStarted when setting tasks.
 * [CN]: 由设备维护；App 下发时通常保持为 TSHsdTaskStateNotStarted。
 */
@property (nonatomic, assign) TSHsdTaskState state;

/**
 * @brief Coins rewarded when the task is completed
 * @chinese 完成任务后奖励的金币数
 */
@property (nonatomic, assign) NSInteger coins;

/**
 * @brief Task description
 * @chinese 任务详细描述
 *
 * @discussion
 * [EN]: At most TSHsdTaskDescriptionMaxBytes (100) UTF-8 bytes; longer values fail validation.
 * [CN]: UTF-8 最多 TSHsdTaskDescriptionMaxBytes（100）字节，超出时校验失败。
 */
@property (nonatomic, copy, nullable) NSString *taskDescription;

/**
 * @brief Whether the task has an execution time
 * @chinese 任务是否需要设置时间
 *
 * @discussion
 * [EN]: When NO, the device does not display a time for this task and minuteOfDay is ignored.
 * [CN]: 为 NO 时设备不显示该任务的时间，minuteOfDay 被忽略。
 */
@property (nonatomic, assign, getter=isTimeEnabled) BOOL timeEnabled;

@end

/**
 * @brief Task info model: total coins plus the task list
 * @chinese 任务信息模型：当前总金币数与任务列表
 *
 * @discussion
 * [EN]: Returned by TSHuashengdaInterface.fetchTaskInfo: and accepted by setTaskInfo:completion:.
 * [CN]: 由 TSHuashengdaInterface.fetchTaskInfo: 返回，并作为 setTaskInfo:completion: 的入参。
 */
@interface TSHsdTaskInfoModel : TSKitBaseModel <NSCopying>

/**
 * @brief Current total coins
 * @chinese 当前总金币数
 *
 * @discussion
 * [EN]: Accumulated by the device as tasks are completed; reset by exchangeTaskReward:.
 * [CN]: 设备随任务完成累计，通过 exchangeTaskReward: 兑换。
 */
@property (nonatomic, assign) NSInteger totalCoins;

/**
 * @brief Task list
 * @chinese 任务列表
 *
 * @discussion
 * [EN]: At most TSHsdTaskMaxCount (5) tasks; more tasks fail validation.
 * [CN]: 最多 TSHsdTaskMaxCount（5）条任务，超出时校验失败。
 */
@property (nonatomic, copy) NSArray<TSHsdTaskModel *> *tasks;

@end

NS_ASSUME_NONNULL_END
