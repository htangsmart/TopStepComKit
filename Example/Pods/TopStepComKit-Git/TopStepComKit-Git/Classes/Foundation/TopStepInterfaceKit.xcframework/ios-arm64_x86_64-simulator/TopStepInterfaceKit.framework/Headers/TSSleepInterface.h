//
//  TSSleepInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSKitBaseInterface.h"
#import "TSSleepDailyModel.h"
#import "TSAutoMonitorConfigs.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep data management interface
 * @chinese 睡眠数据管理接口
 *
 * @discussion
 * [EN]: This interface provides methods for synchronizing sleep data from the device,
 * including night sleep and daytime naps (if supported). The data includes detailed
 * sleep stages, quality metrics, and comprehensive sleep analysis.
 * [CN]: 该接口提供从设备同步睡眠数据的方法，包括夜间睡眠和日间小睡（如果支持）。
 * 数据包括详细的睡眠阶段、质量指标和全面的睡眠分析。
 */
@protocol TSSleepInterface <TSKitBaseInterface>

/**
 * @brief Set automatic sleep monitoring configuration
 * @chinese 设置自动睡眠监测配置
 *
 * @param configuration 
 * [EN]: Configuration object containing sleep monitoring settings
 * [CN]: 包含睡眠监测设置的配置对象
 *
 * @param completion 
 * [EN]: Completion block that returns success status or error
 * [CN]: 返回成功状态或错误的完成回调块
 *
 * @discussion 
 * [EN]: This method configures the automatic sleep monitoring features on the device,
 * including monitoring periods, sensitivity, and other related settings.
 * [CN]: 此方法配置设备上的自动睡眠监测功能，包括监测周期、灵敏度和其他相关设置。
 */
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                       completion:(nonnull TSCompletionBlock)completion;

/**
 * @brief Get current automatic sleep monitoring configuration
 * @chinese 获取当前自动睡眠监测配置
 *
 * @param completion 
 * [EN]: Completion block that returns the current configuration or error
 * [CN]: 返回当前配置或错误的完成回调块
 *
 * @discussion 
 * [EN]: This method retrieves the current sleep monitoring configuration from the device,
 * including all settings related to automatic sleep detection and monitoring.
 * [CN]: 此方法从设备获取当前的睡眠监测配置，包括与自动睡眠检测和监测相关的所有设置。
 */
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;

/**
 * @brief Sync raw sleep segments from start time
 * @chinese 从指定开始时间同步原始睡眠分段数据
 *
 * @param startTime 
 * [EN]: Unix timestamp (seconds) of the starting point.
 * [CN]: 起始时间的 Unix 时间戳（秒）。
 *
 * @param completion 
 * [EN]: Callback returning an array of TSSleepDetailItem or an error.
 * [CN]: 回调返回 TSSleepDetailItem 数组或错误信息。
 *
 * @discussion
 * [EN]: Returns raw sleep segments (start/end/duration/stage/period). Suitable for
 *       fine-grained timelines and custom analysis.
 * [CN]: 返回原始睡眠分段（开始/结束/时长/阶段/时段），适合做细粒度时间线与自定义分析。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;
/**
 * @brief Sync raw sleep segments within time range
 * @chinese 在指定时间区间内同步原始睡眠分段数据
 *
 * @param startTime 
 * [EN]: Unix timestamp (seconds) of range start (inclusive).
 * [CN]: 区间开始时间的 Unix 时间戳（秒，含）。
 *
 * @param endTime 
 * [EN]: Unix timestamp (seconds) of range end (exclusive). Range is [startTime, endTime).
 * [CN]: 区间结束时间的 Unix 时间戳（秒，不含）。时间区间为 [startTime, endTime)。
 *
 * @param completion 
 * [EN]: Callback returning an array of TSSleepDetailItem or an error.
 * [CN]: 回调返回 TSSleepDetailItem 数组或错误信息。
 *
 * @discussion
 * [EN]: Use this when you want to limit raw data to a specific time window.
 * [CN]: 适用于限定时间窗口获取原始分段数据的场景。
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSSleepDetailItem *> *_Nullable sleepItems, NSError *_Nullable error))completion;

/**
 * @brief Sync daily aggregated sleep data from start time
 * @chinese 从指定开始时间同步按天聚合的睡眠数据
 *
 * @param startTime 
 * [EN]: Unix timestamp (seconds) of the starting day.
 * [CN]: 起始“自然日”的 Unix 时间戳（秒）。
 *
 * @param completion 
 * [EN]: Callback returning an array of TSSleepDailyModel (daily) or an error.
 * [CN]: 回调返回按天聚合的 TSSleepDailyModel 数组或错误信息。
 *
 * @discussion
 * [EN]: Returns per-day sleep summaries (e.g., total duration, composition, quality).
 * [CN]: 返回每日睡眠汇总（总时长、结构构成、质量指标等）。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                       completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;

/**
 * @brief Sync daily aggregated sleep data within time range
 * @chinese 在指定时间区间内同步按天聚合的睡眠数据
 *
 * @param startTime 
 * [EN]: Unix timestamp (seconds) of range start day (inclusive).
 * [CN]: 区间起始“自然日”的 Unix 时间戳（秒，含）。
 *
 * @param endTime 
 * [EN]: Unix timestamp (seconds) of range end day (exclusive). Range is [startTime, endTime).
 * [CN]: 区间结束“自然日”的 Unix 时间戳（秒，不含）。日期区间为 [startTime, endTime)。
 *
 * @param completion 
 * [EN]: Callback returning an array of TSSleepDailyModel (daily) or an error.
 * [CN]: 回调返回按天聚合的 TSSleepDailyModel 数组或错误信息。
 *
 * @discussion
 * [EN]: Use this to fetch daily summaries limited to a specific date range.
 * [CN]: 适用于限定日期范围获取按天汇总数据。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSSleepDailyModel *> *_Nullable sleepModel, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
