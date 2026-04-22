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
 * @brief Get the sleep statistics rule (algorithm) used by the current device
 * @chinese 获取当前设备使用的睡眠统计规则（算法）
 *
 * @return
 * [EN]: The TSSleepStatisticsRule enum value indicating which algorithm is used for sleep data processing
 * [CN]: TSSleepStatisticsRule 枚举值，表示当前设备使用的睡眠数据处理算法
 *
 * @discussion
 * [EN]: Different devices/platforms may use different sleep statistics algorithms:
 *       - WithoutNap: No nap support, sensor active 20:00-12:00, all sleep treated as night sleep
 *       - WithNap: Nap support enabled, sensor active 24h, distinguishes night/day sleep
 *       - LongestNight: Uses longest continuous night sleep segment (20:00-08:00), valid naps counted
 *       - LongestOnly: No distinction between night/day, uses longest continuous sleep segment only
 *       Use this method to determine how the device processes sleep data before calling sync methods.
 * [CN]: 不同设备/平台可能使用不同的睡眠统计算法：
 *       - WithoutNap: 不带小睡功能，传感器20:00-12:00激活，所有睡眠视为夜间睡眠
 *       - WithNap: 带小睡功能，传感器24小时激活，区分夜间和日间睡眠
 *       - LongestNight: 使用最长连续夜间睡眠段（20:00-08:00），有效小睡计入统计
 *       - LongestOnly: 不区分夜间和日间，仅使用最长连续睡眠段
 *       在调用同步方法之前，可使用此方法确定设备如何处理睡眠数据。
 */
- (TSSleepStatisticsRule)sleepStatisticsRule;

/**
 * @brief Check if the device supports REM (Rapid Eye Movement) sleep stage
 * @chinese 检查设备是否支持 REM（快速眼动）睡眠阶段
 *
 * @return
 * [EN]: YES if the device can identify and record REM sleep stages, NO otherwise
 * [CN]: 如果设备支持识别并记录 REM 睡眠阶段返回YES，否则返回NO
 *
 * @discussion
 * [EN]: REM sleep is a distinct sleep phase characterized by rapid eye movements and vivid dreaming.
 *       It plays a key role in memory consolidation and emotional processing.
 *       When YES, TSSleepDetailItem data may include REM stage segments.
 * [CN]: REM 睡眠是以快速眼球运动和生动梦境为特征的独特睡眠阶段。
 *       在记忆巩固和情绪处理中起关键作用。
 *       返回YES时，TSSleepDetailItem 数据中可能包含 REM 阶段分段。
 */
- (BOOL)isSupportREMSleep;

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
