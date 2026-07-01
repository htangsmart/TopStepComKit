//
//  TSHeartRateVarInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/05/29.
//

#import "TSHealthBaseInterface.h"
#import "TSAutoMonitorConfigs.h"
#import "TSHRVValueItem.h"
#import "TSHRVDailyModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Heart Rate Variability (HRV) monitoring interface
 * @chinese 心率变异性（HRV）监测接口
 *
 * @discussion
 * [EN]: This interface provides methods for HRV automatic monitoring configuration
 *       and historical data synchronization. HRV measures the variation in time
 *       between consecutive heartbeats and reflects autonomic nervous system balance,
 *       commonly used as an indicator of recovery, stress, and overall well-being.
 *       Manual on-demand measurement is intentionally omitted as HRV requires
 *       multi-minute stable RR intervals to be clinically meaningful.
 * [CN]: 该接口提供 HRV 自动监测配置和历史数据同步的方法。HRV 衡量连续心跳之间
 *       的时间变化，反映自主神经系统的平衡状态，常用于衡量恢复程度、压力水平
 *       和整体健康状况。本接口不提供手动单次测量方法，因 HRV 需要持续数分钟
 *       稳定的 RR 间期才有临床意义。
 */
@protocol TSHeartRateVarInterface <TSHealthBaseInterface>

#pragma mark - Capability Check

/**
 * @brief Check if the device supports automatic HRV monitoring
 * @chinese 检查设备是否支持自动 HRV 监测
 *
 * @return
 * [EN]: YES if the device supports automatic HRV monitoring, NO otherwise.
 * [CN]: 如果设备支持自动 HRV 监测返回 YES，否则返回 NO。
 */
- (BOOL)isSupportAutomaticMonitoring;

/**
 * @brief Check if the device supports configuring monitor time range
 * @chinese 检查设备是否支持配置 HRV 监测时间段
 *
 * @return
 * [EN]: YES if the device supports configuring start/end time, NO otherwise.
 * [CN]: 如果设备支持配置开始/结束时间返回 YES，否则返回 NO。
 *
 * @discussion
 * [EN]: When YES, the startTime and endTime fields of TSMonitorSchedule are effective.
 * [CN]: 返回 YES 时，TSMonitorSchedule 的 startTime 和 endTime 字段生效。
 */
- (BOOL)isSupportMonitorScheduleTime;

/**
 * @brief Check if the device supports configuring monitor interval
 * @chinese 检查设备是否支持配置 HRV 监测时间间隔
 *
 * @return
 * [EN]: YES if the device supports configuring monitoring interval, NO otherwise.
 * [CN]: 如果设备支持配置监测时间间隔返回 YES，否则返回 NO。
 *
 * @discussion
 * [EN]: When YES, the interval field of TSMonitorSchedule is effective.
 * [CN]: 返回 YES 时，TSMonitorSchedule 的 interval 字段生效。
 */
- (BOOL)isSupportMonitorScheduleInterval;

#pragma mark - Auto Monitor Configuration

/**
 * @brief Configure automatic HRV monitoring
 * @chinese 配置自动 HRV 监测
 *
 * @param configuration
 * [EN]: Configuration parameters for automatic HRV monitoring.
 *       - `schedule`: standard usage — enable / start / end / interval.
 *       - `alert`: only the `enabled` flag toggles HRV reminders.
 *         `upperLimit` / `lowerLimit` are NOT used — HRV alerting is an
 *         on/off switch, not threshold-based. Pass nil to disable reminders.
 * [CN]: 自动 HRV 监测的配置参数。
 *       - `schedule`：标准用法——开关 / 起止时间 / 间隔。
 *       - `alert`：仅 `enabled` 字段控制 HRV 提醒开关。`upperLimit` /
 *         `lowerLimit` 不生效——HRV 提醒是开关式，不基于阈值。如需关闭
 *         提醒，传 nil 即可。
 *
 * @param completion
 * [EN]: Completion block called when the configuration is set or fails to set.
 * [CN]: 当配置设置成功或失败时调用的完成回调块。
 */
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;

/**
 * @brief Get the current automatic HRV monitoring configuration
 * @chinese 获取当前自动 HRV 监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error.
 * [CN]: 包含当前配置或错误的完成回调块。
 */
- (void)fetchAutoMonitorConfigsWithCompletion:
(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration,
                  NSError *_Nullable error))completion;

#pragma mark - Raw Data Sync

/**
 * @brief Synchronize raw HRV data within a specified time range
 * @chinese 同步指定时间范围内的原始 HRV 数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (Unix timestamp in seconds).
 * [CN]: 数据同步的开始时间（1970 年以来的秒数时间戳）。
 *
 * @param endTime
 * [EN]: End time for data synchronization (Unix timestamp in seconds).
 * [CN]: 数据同步的结束时间（1970 年以来的秒数时间戳）。
 *
 * @param completion
 * [EN]: Completion block with synchronized raw HRV measurement items or error.
 * [CN]: 包含同步的原始 HRV 测量条目或错误的完成回调块。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSHRVValueItem *> *_Nullable hrvItems,
                                                   NSError *_Nullable error))completion;

/**
 * @brief Synchronize raw HRV data from a specified start time until now
 * @chinese 从指定开始时间同步至今的原始 HRV 数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (Unix timestamp in seconds).
 * [CN]: 数据同步的开始时间（1970 年以来的秒数时间戳）。
 *
 * @param completion
 * [EN]: Completion block with synchronized raw HRV measurement items or error.
 * [CN]: 包含同步的原始 HRV 测量条目或错误的完成回调块。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSHRVValueItem *> *_Nullable hrvItems,
                                                   NSError *_Nullable error))completion;

#pragma mark - Daily Data Sync

/**
 * @brief Synchronize daily HRV data within a specified time range
 * @chinese 同步指定时间范围内的每日 HRV 数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (Unix timestamp in seconds).
 *       Will be automatically normalized to 00:00:00 of the specified day.
 *       Must be earlier than endTime.
 * [CN]: 数据同步的开始时间（1970 年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 00:00:00。必须早于结束时间。
 *
 * @param endTime
 * [EN]: End time for data synchronization (Unix timestamp in seconds).
 *       Will be automatically normalized to 23:59:59 of the specified day.
 *       Must be later than startTime and not in the future.
 * [CN]: 数据同步的结束时间（1970 年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 23:59:59。必须晚于开始时间且不能在将来。
 *
 * @param completion
 * [EN]: Completion block with synchronized daily HRV models or error.
 *       Each TSHRVDailyModel represents one day's aggregated data including
 *       personal baseline (with upper/lower bounds), daily status, and the
 *       day's manual / automatic measurement series.
 * [CN]: 完成回调，返回同步的每日 HRV 模型数组或错误。
 *       每个 TSHRVDailyModel 代表一天的聚合数据，含个人基线（上下限）、
 *       当日状态、以及当日的主动 / 自动测量序列。
 *
 * @discussion
 * [EN]: Time parameters are automatically normalized to day boundaries
 *       (00:00:00 to 23:59:59). Data is returned in ascending time order.
 *       The completion handler is called on the main thread.
 * [CN]: 时间参数将自动规范化为日期边界（00:00:00 到 23:59:59）。
 *       数据按时间升序返回。完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSHRVDailyModel *> *_Nullable dailyModels,
                                                     NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily HRV data from a specified start time until now
 * @chinese 从指定开始时间同步至今的每日 HRV 数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (Unix timestamp in seconds).
 *       Will be automatically normalized to 00:00:00 of the specified day.
 * [CN]: 数据同步的开始时间（1970 年以来的秒数时间戳）。
 *       将自动规范化为指定日期的 00:00:00。
 *
 * @param completion
 * [EN]: Completion block with synchronized daily HRV models or error.
 * [CN]: 完成回调，返回同步的每日 HRV 模型数组或错误。
 *
 * @discussion
 * [EN]: Convenience wrapper around syncDailyDataFromStartTime:endTime:completion:
 *       that automatically sets the end time to the current time.
 * [CN]: syncDailyDataFromStartTime:endTime:completion: 的便捷包装，
 *       自动将结束时间设置为当前时间。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSHRVDailyModel *> *_Nullable dailyModels,
                                                     NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
