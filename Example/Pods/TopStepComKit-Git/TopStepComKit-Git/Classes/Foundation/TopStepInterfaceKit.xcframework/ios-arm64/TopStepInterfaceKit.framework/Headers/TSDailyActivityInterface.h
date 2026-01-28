//
//  TSDailyActivityInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSKitBaseInterface.h"

#import "TSDailyActivityGoals.h"
#import "TSDailyActivityItem.h"
#import "TSDailyActivityReminder.h"
#import "TSActivityDailyModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily activity type enumeration
 * @chinese 每日活动类型枚举
 *
 * @discussion
 * [EN]: Defines the types of daily activities that can be displayed on the device.
 *       Used for configuring which activity metrics are shown in the main interface rings.
 * [CN]: 定义设备可以显示的每日活动类型。
 *       用于配置主界面三环显示哪些活动指标。
 */
typedef NS_ENUM(NSInteger, TSDailyActivityType) {
    /// 步数 (Step count)
    TSDailyActivityTypeStepCount        = 1,
    /// 锻炼时长 (Exercise duration)
    TSDailyActivityTypeExerciseDuration = 2,
    /// 活动次数 (Activity count)
    TSDailyActivityTypeActivityCount    = 3,
    /// 活动时长 (Active duration)
    TSDailyActivityTypeActiveDuration   = 4,
    /// 距离 (Distance)
    TSDailyActivityTypeDistance         = 5,
    /// 卡路里 (Calories)
    TSDailyActivityTypeCalories         = 6
};


/**
 * @brief Daily activity and exercise management interface
 * @chinese 每日活动和运动管理接口
 *
 * @discussion
 * [EN]: This interface provides methods for managing daily activity data, including:
 * - Getting and setting exercise goals
 * - Synchronizing today's activity data
 * - Retrieving historical activity data
 * Daily activity tracking includes steps, distance, calories, and exercise duration.
 * [CN]: 该接口提供管理每日活动数据的方法，包括：
 * - 获取和设置运动目标
 * - 同步今天的活动数据
 * - 检索历史活动数据
 * 每日活动跟踪包括步数、距离、卡路里和运动时长。
 */
@protocol TSDailyActivityInterface <TSKitBaseInterface>

/**
 * @brief Get supported daily activity types
 * @chinese 获取所支持的每日活动类型
 *
 * @param completion
 * [EN]: Completion block returning array of supported activity types or error
 * [CN]: 返回支持的活动类型数组或错误的完成回调
 *
 * @discussion
 * [EN]: Retrieves the list of daily activity types that the device supports and displays.
 *       The returned array contains TSDailyActivityType enum values representing
 *       which activity metrics are available on the device (e.g., step count, exercise duration, etc.).
 *       This information is used to configure which activity rings are shown in the main interface.
 * [CN]: 获取设备支持并显示的每日活动类型列表。
 *       返回的数组包含TSDailyActivityType枚举值，表示设备上可用的活动指标
 *       （例如：步数、锻炼时长等）。
 *       此信息用于配置主界面显示哪些活动环。
 */
- (void)fetchSupportedDailyActivityTypesWithCompletion:(void(^)(NSArray<NSNumber *> *_Nullable activityTypes, NSError *_Nullable error))completion;

/**
 * @brief Get the current daily exercise goals
 * @chinese 获取当前每日运动目标
 *
 * @param completion
 * [EN]: Completion block returning current goals or error
 * [CN]: 返回当前目标或错误的完成回调
 *
 * @discussion
 * [EN]: Retrieves the user's current daily exercise goals from the device, including steps, calories,
 * distance, activity/exercise durations and exercise frequency.
 * [CN]: 从设备读取用户的每日运动目标，包括步数、卡路里、距离、活动/运动时长和运动次数。
 */
- (void)fetchDailyExerciseGoalsWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals,NSError *_Nullable error))completion;

/**
 * @brief Set daily exercise goals
 * @chinese 设置每日运动目标
 *
 * @param goalsModel
 * [EN]: Model containing goals to set (see TSDailyActivityGoals)
 * [CN]: 包含需设置的目标模型（参见 TSDailyActivityGoals）
 *
 * @param completion
 * [EN]: Completion block indicating whether the operation succeeded and error info
 * [CN]: 指示操作是否成功及错误信息的完成回调
 *
 * @discussion
 * [EN]: Writes user's daily exercise goals to the device, including steps, calories, distance,
 * activity/exercise durations and exercise frequency.
 * [CN]: 将用户的每日运动目标写入设备，包括步数、卡路里、距离、活动/运动时长与运动次数。
 */
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                    completion:(TSCompletionBlock)completion;

/**
 * @brief Fetch daily exercise goals and reminders in one call
 * @chinese 一次性获取每日运动目标与提醒配置
 *
 * @param completion
 * [EN]: Completion block returning goals model, reminder model and error
 * [CN]: 返回目标模型、提醒模型与错误的完成回调
 *
 * @discussion
 * [EN]: Retrieves both daily exercise goals (steps, calories, distance, activity/exercise durations,
 * frequency) and their reminder switches in a single request for data consistency.
 * [CN]: 为保证数据一致性，一次性读取每日运动目标（步数、卡路里、距离、活动/运动时长、次数）及其提醒开关。
 */
- (void)fetchDailyExerciseAllWithCompletion:(void(^)(TSDailyActivityGoals *_Nullable goals,
                                                    TSDailyActivityReminder *_Nullable reminder,
                                                    NSError *_Nullable error))completion;

/**
 * @brief Push daily exercise goals and reminders atomically
 * @chinese 原子性写入每日运动目标与提醒配置
 *
 * @param goalsModel
 * [EN]: Goals model to set (see TSDailyActivityGoals)
 * [CN]: 需要设置的目标模型（参见 TSDailyActivityGoals）
 *
 * @param reminder
 * [EN]: Reminder switches model to set (see TSDailyActivityReminder)
 * [CN]: 需要设置的提醒开关模型（参见 TSDailyActivityReminder）
 *
 * @param completion
 * [EN]: Completion block indicating whether the operation succeeded and error info
 * [CN]: 指示操作是否成功及错误信息的完成回调
 *
 * @discussion
 * [EN]: Aggregates both goals and reminder switches into a single underlying write to avoid
 * intermediate inconsistent states.
 * [CN]: 将目标与提醒聚合为一次底层写入，避免出现中间不一致状态。
 */
- (void)pushDailyExerciseGoals:(TSDailyActivityGoals *)goalsModel
                       reminder:(TSDailyActivityReminder *)reminder
                      completion:(TSCompletionBlock)completion;

/**
 * @brief Get the current daily exercise reminder switches
 * @chinese 获取当前每日运动目标提醒配置
 *
 * @param completion
 * [EN]: Completion block returning reminder switches or error
 * [CN]: 返回提醒开关或错误的完成回调
 *
 * @discussion
 * [EN]: Retrieves reminder switches for goals: steps, calories, distance, activity duration,
 * exercise duration and exercise frequency.
 * [CN]: 获取目标对应的提醒开关：步数、卡路里、距离、活动时长、运动时长与运动次数。
 */
- (void)fetchDailyExerciseReminderConfigWithCompletion:(void(^)(TSDailyActivityReminder *_Nullable reminder, NSError *_Nullable error))completion;

/**
 * @brief Set daily exercise reminder switches
 * @chinese 设置每日运动目标提醒配置
 *
 * @param reminder
 * [EN]: Reminder switches model to set (see TSDailyActivityReminder)
 * [CN]: 需要设置的提醒开关模型（参见 TSDailyActivityReminder）
 *
 * @param completion
 * [EN]: Completion block indicating whether the operation succeeded and error info
 * [CN]: 指示操作是否成功及错误信息的完成回调
 *
 * @discussion
 * [EN]: Writes reminder switches for steps, calories, distance, activity/exercise durations and exercise frequency.
 * [CN]: 写入步数、卡路里、距离、活动/运动时长与运动次数的提醒开关。
 */
- (void)pushDailyExerciseReminder:(TSDailyActivityReminder *)reminder
                              completion:(TSCompletionBlock)completion;

/**
 * @brief Synchronize today's daily exercise data
 * @chinese 同步今天的每日运动数据
 *
 * @param completion
 * [EN]: Completion block with today's exercise data or error
 * [CN]: 包含今天的运动数据或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves the current day's activity data from the device, including:
 * - Step count
 * - Distance traveled
 * - Calories burned
 * - Activity duration
 * - Exercise sessions information
 * This provides a snapshot of the user's current day progress.
 * [CN]: 从设备获取当天的活动数据，包括：
 * - 步数
 * - 行走距离
 * - 消耗的卡路里
 * - 活动时长
 * - 运动会话信息
 * 这提供了用户当天进度的快照。
 */
- (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel *_Nullable todayActivity, NSError *_Nullable error))completion;


/**
 * @brief Synchronize raw daily activity data within a specified time range
 * @chinese 同步指定时间范围内的原始每日活动数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）
 *
 * @param endTime
 * [EN]: End time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的结束时间（1970年以来的秒数时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized raw daily activity measurement items or error
 * [CN]: 包含同步的原始每日活动测量条目或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves historical daily activity data for the specified time range.
 * Each day's data is represented as a separate TSDailyActivityItem object.
 * This is useful for analyzing trends and patterns in the user's activity over time.
 * [CN]: 检索指定时间范围内的历史每日活动数据。
 * 每天的数据表示为单独的TSDailyActivityItem对象。
 * 这对于分析用户活动随时间变化的趋势和模式很有用。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;


/**
 * @brief Synchronize raw daily activity data from a specified start time until now
 * @chinese 从指定开始时间同步至今的原始每日活动数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized raw daily activity measurement items or error
 * [CN]: 包含同步的原始每日活动测量条目或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves historical daily activity data from the specified start time until the current time.
 * This method is convenient for getting recent activity history without specifying an end date.
 * [CN]: 从指定开始时间到当前时间检索历史每日活动数据。
 * 这种方法便于获取最近的活动历史，而无需指定结束日期。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSDailyActivityItem *> *_Nullable activityItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily activity data within a specified time range
 * @chinese 同步指定时间范围内的每日活动数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970).
 *       Will be automatically normalized to 00:00:00 of the specified day.
 *       Must be earlier than endTime.
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 00:00:00。
 *       必须早于结束时间。
 *
 * @param endTime
 * [EN]: End time for data synchronization (timestamp in seconds since 1970).
 *       Will be automatically normalized to 23:59:59 of the specified day.
 *       Must be later than startTime and not in the future.
 * [CN]: 数据同步的结束时间（1970年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 23:59:59。
 *       必须晚于开始时间且不能在将来。
 *
 * @param completion
 * [EN]: Completion block with synchronized daily activity models or error.
 *       Each TSActivityDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日活动模型数组或错误。
 *       每个 TSActivityDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated activity data within the given time range.
 *       Time parameters are automatically normalized to day boundaries (00:00:00 to 23:59:59).
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法同步指定时间范围内的每日聚合活动数据。
 *       时间参数将自动规范化为日期边界（00:00:00 到 23:59:59）。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily activity data from a specified start time until now
 * @chinese 从指定开始时间同步至今的每日活动数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970).
 *       Will be automatically normalized to 00:00:00 of the specified day.
 *       Data will be synchronized from this time to the current time.
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 00:00:00。
 *       将同步从此时间到当前时间的数据。
 *
 * @param completion
 * [EN]: Completion block with synchronized daily activity models or error.
 *       Each TSActivityDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日活动模型数组或错误。
 *       每个 TSActivityDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated activity data from the start time to the current time.
 *       It is a convenience wrapper around syncDailyDataFromStartTime:endTime:completion: that
 *       automatically sets the end time to the current time.
 *       Start time is automatically normalized to 00:00:00 of the specified day.
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法从开始时间到当前时间同步每日聚合活动数据。
 *       它是syncDailyDataFromStartTime:endTime:completion:的便捷包装，
 *       自动将结束时间设置为当前时间。
 *       开始时间将自动规范化为指定日期的 00:00:00。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSActivityDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
