//
//  TSDailyActivityInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSKitBaseInterface.h"

#import "TSDailyActivityGoalsModel.h"
#import "TSDailyActivityValueModel.h"

NS_ASSUME_NONNULL_BEGIN

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
 * @brief Get the current daily exercise goals
 * @chinese 获取当前每日运动目标
 *
 * @param completion
 * [EN]: Completion block with the current exercise goals or error
 * [CN]: 包含当前运动目标或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves the user's current exercise goals from the device, including:
 * - Steps goal
 * - Calories goal
 * - Distance goal
 * - Activity duration goal
 * - Exercise duration goal
 * - Exercise frequency goal
 * [CN]: 从设备获取用户当前的运动目标，包括：
 * - 步数目标
 * - 卡路里目标
 * - 距离目标
 * - 活动时长目标
 * - 运动时长目标
 * - 运动次数目标
 */
- (void)getDailyExerciseGoalsWithCompletion:(void(^)(TSDailyActivityGoalsModel *_Nullable goalsModel,NSError *_Nullable error))completion;


/**
 * @brief Set daily exercise goals
 * @chinese 设置每日运动目标
 *
 * @param goalsModel
 * [EN]: Model containing the exercise goals to be set
 * [CN]: 包含要设置的运动目标的模型
 *
 * @param completion
 * [EN]: Completion block called when the goals are set or fail to set
 * [CN]: 当目标设置成功或失败时调用的完成回调块
 *
 * @discussion
 * [EN]: Sets the user's daily exercise goals on the device. The goals model should contain
 * appropriate values for steps, calories, distance, and activity durations.
 * [CN]: 在设备上设置用户的每日运动目标。目标模型应包含步数、卡路里、距离和活动时长的适当值。
 */
- (void)setDailyExerciseGoals:(TSDailyActivityGoalsModel *)goalsModel
                   completion:(nullable TSCompletionBlock)completion;


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
- (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSDailyActivityValueModel *_Nullable dailyExerValues, NSError *_Nullable error))completion;


/**
 * @brief Synchronize daily exercise history data within a specified time range
 * @chinese 同步指定时间范围内的每日运动历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param endTime
 * [EN]: End time for data synchronization (timestamp)
 * [CN]: 数据同步的结束时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized daily exercise values or error
 * [CN]: 包含同步的每日运动值或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves historical daily activity data for the specified time range.
 * Each day's data is represented as a separate TSDailyExerciseValueModel object.
 * This is useful for analyzing trends and patterns in the user's activity over time.
 * [CN]: 检索指定时间范围内的历史每日活动数据。
 * 每天的数据表示为单独的TSDailyExerciseValueModel对象。
 * 这对于分析用户活动随时间变化的趋势和模式很有用。
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSDailyActivityValueModel *> *_Nullable dailyExerValues, NSError *_Nullable error))completion;


/**
 * @brief Synchronize daily exercise history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的每日运动历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized daily exercise values or error
 * [CN]: 包含同步的每日运动值或错误的完成回调块
 *
 * @discussion
 * [EN]: Retrieves historical daily activity data from the specified start time until the current time.
 * This method is convenient for getting recent activity history without specifying an end date.
 * [CN]: 从指定开始时间到当前时间检索历史每日活动数据。
 * 这种方法便于获取最近的活动历史，而无需指定结束日期。
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSDailyActivityValueModel *> *_Nullable dailyExerValues, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
