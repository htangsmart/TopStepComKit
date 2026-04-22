//
//  TSHeartRateInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSHealthBaseInterface.h"
#import "TSAutoMonitorHRConfigs.h"
#import "TSHRValueItem.h"
#import "TSHRDailyModel.h"
#import "TSPeripheralCapability.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Heart rate measurement and monitoring interface
 * @chinese 心率测量和监测接口
 *
 * @discussion
 * [EN]: This interface provides methods for heart rate measurement, automatic monitoring,
 * historical data synchronization, and resting heart rate analysis.
 * [CN]: 该接口提供心率测量、自动监测、历史数据同步和静息心率分析的方法。
 */
@protocol TSHeartRateInterface <TSHealthBaseInterface>

/**
 * @brief Check if the device supports heart rate alert monitoring
 * @chinese 检查设备是否支持心率预警监测
 *
 * @return
 * [EN]: YES if the device supports heart rate alert monitoring, NO otherwise
 * [CN]: 如果设备支持心率预警监测返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Heart rate alert monitoring allows the device to notify users when their heart rate
 * exceeds normal ranges or reaches potentially dangerous levels. This feature is particularly
 * useful for users with cardiovascular conditions or during intensive physical activities.
 * This method checks if the connected device has the capability to monitor and alert on heart rate anomalies.
 * [CN]: 心率预警监测允许设备在用户心率超出正常范围或达到潜在危险水平时通知用户。
 * 此功能对于有心血管疾病的用户或在剧烈体育活动期间特别有用。
 * 此方法检查连接的设备是否具有监测心率异常并发出预警的能力。
 */
- (BOOL)isSupportHeartRateAlert;

/**
 * @brief Check if the device supports enhanced heart rate monitoring
 * @chinese 检查设备是否支持加强心率监测
 *
 * @return
 * [EN]: YES if the device supports enhanced heart rate monitoring, NO otherwise
 * [CN]: 如果设备支持加强心率监测返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Enhanced heart rate monitoring provides more frequent and accurate heart rate measurements
 * with higher precision and faster response times. This mode typically consumes more battery
 * but offers better data quality for users who require detailed heart rate tracking.
 * This method checks if the connected device has the capability to perform enhanced monitoring.
 * [CN]: 加强心率监测提供更频繁和准确的心率测量，具有更高的精度和更快的响应时间。
 * 此模式通常消耗更多电池，但为需要详细心率跟踪的用户提供更好的数据质量。
 * 此方法检查连接的设备是否具有执行加强监测的能力。
 */
- (BOOL)isSupportEnhancedMonitoring;

/**
 * @brief Check if the device supports manual heart rate measurement
 * @chinese 检查设备是否支持手动心率测量
 *
 * @return
 * [EN]: YES if the device supports manual heart rate measurement, NO otherwise
 * [CN]: 如果设备支持手动心率测量返回YES，否则返回NO
 */
- (BOOL)isSupportActivityMeasureByUser;

/**
 * @brief Start heart rate measurement with specified parameters
 * @chinese 使用指定参数开始心率测量
 *
 * @param measureParam
 * [EN]: Parameters for the measurement activity
 * [CN]: 测量活动的参数
 *
 * @param startHandler
 * [EN]: Block called when measurement starts or fails to start
 *       - success: Whether the measurement started successfully
 *       - error: Error information if failed, nil if successful
 * [CN]: 测量开始或失败时调用的回调块
 *       - success: 测量是否成功开始
 *       - error: 失败时的错误信息，成功时为nil
 *
 * @param dataHandler
 * [EN]: Block to receive real-time measurement data
 *       - data: Real-time heart rate measurement data, nil if error occurs
 *       - error: Error information if data reception fails, nil if successful
 * [CN]: 接收实时测量数据的回调块
 *       - data: 实时心率测量数据，发生错误时为nil
 *       - error: 数据接收失败时的错误信息，成功时为nil
 *
 * @param endHandler
 * [EN]: Block called when measurement ends (normally or abnormally)
 *       - success: Whether the measurement ended normally (YES) or was interrupted (NO)
 *       - error: Error information if measurement ended abnormally, nil if normal end
 * [CN]: 测量结束时调用的回调块（正常结束或异常结束）
 *       - success: 测量是否正常结束（YES）或被中断（NO）
 *       - error: 异常结束时的错误信息，正常结束时为nil
 */
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                 startHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))startHandler
                  dataHandler:(void(^_Nullable)(TSHRValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;

/**
 * @brief Stop the ongoing heart rate measurement
 * @chinese 停止正在进行的心率测量
 *
 * @param completion
 * [EN]: Completion block called when the measurement stops or fails to stop
 * [CN]: 当测量停止或无法停止时调用的完成回调块
 */
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Check if the device supports automatic heart rate monitoring
 * @chinese 检查设备是否支持自动心率监测
 *
 * @return
 * [EN]: YES if the device supports automatic heart rate monitoring, NO otherwise
 * [CN]: 如果设备支持自动心率监测返回YES，否则返回NO
 */
- (BOOL)isSupportAutomaticMonitoring;


/**
 * @brief Configure automatic heart rate monitoring
 * @chinese 配置自动心率监测
 *
 * @param configuration
 * [EN]: Configuration parameters for automatic heart rate monitoring
 * [CN]: 自动心率监测的配置参数
 *
 * @param completion
 * [EN]: Completion block called when the configuration is set or fails to set
 * [CN]: 当配置设置成功或失败时调用的完成回调块
 */
- (void)pushAutoMonitorConfigs:(TSAutoMonitorHRConfigs *_Nonnull)configuration
                        completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Get the current automatic heart rate monitoring configuration
 * @chinese 获取当前自动心率监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error
 * [CN]: 包含当前配置或错误的完成回调块
 */
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorHRConfigs *_Nullable configuration, NSError *_Nullable error))completion;

/**
 * @brief Synchronize raw heart rate data within a specified time range
 * @chinese 同步指定时间范围内的原始心率数据
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
 * [EN]: Completion block with synchronized raw heart rate measurement items or error
 * [CN]: 包含同步的原始心率测量条目或错误的完成回调块
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;


/**
 * @brief Synchronize raw heart rate data from a specified start time until now
 * @chinese 从指定开始时间同步至今的原始心率数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized raw heart rate measurement items or error
 * [CN]: 包含同步的原始心率测量条目或错误的完成回调块
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable hrItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily heart rate data within a specified time range
 * @chinese 同步指定时间范围内的每日心率数据
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
 * [EN]: Completion block with synchronized daily heart rate models or error.
 *       Each TSHRDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日心率模型数组或错误。
 *       每个 TSHRDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated heart rate data within the given time range.
 *       Time parameters are automatically normalized to day boundaries (00:00:00 to 23:59:59).
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法同步指定时间范围内的每日聚合心率数据。
 *       时间参数将自动规范化为日期边界（00:00:00 到 23:59:59）。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily heart rate data from a specified start time until now
 * @chinese 从指定开始时间同步至今的每日心率数据
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
 * [EN]: Completion block with synchronized daily heart rate models or error.
 *       Each TSHRDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日心率模型数组或错误。
 *       每个 TSHRDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated heart rate data from the start time to the current time.
 *       It is a convenience wrapper around syncDailyDataFromStartTime:endTime:completion: that
 *       automatically sets the end time to the current time.
 *       Start time is automatically normalized to 00:00:00 of the specified day.
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法从开始时间到当前时间同步每日聚合心率数据。
 *       它是syncDailyDataFromStartTime:endTime:completion:的便捷包装，
 *       自动将结束时间设置为当前时间。
 *       开始时间将自动规范化为指定日期的 00:00:00。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSHRDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

/**
 * @brief Check if the device supports resting heart rate monitoring
 * @chinese 检查设备是否支持静息心率监测
 *
 * @return
 * [EN]: YES if the device supports resting heart rate monitoring, NO otherwise
 * [CN]: 如果设备支持静息心率监测返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Resting heart rate is measured during periods of complete rest, typically during sleep.
 * It's an important indicator of cardiovascular health and fitness level.
 * This method checks if the connected device has the capability to measure and monitor resting heart rate.
 * [CN]: 静息心率是在完全休息期间测量的，通常在睡眠期间。
 * 它是心血管健康和健身水平的重要指标。
 * 此方法检查连接的设备是否具有测量和监测静息心率的能力。
 */
- (BOOL)isSupportRestingHeartRate;


/**
 * @brief Synchronize raw resting heart rate data within a specified time range
 * @chinese 同步指定时间范围内的原始静息心率数据
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
 * [EN]: Completion block with synchronized raw resting heart rate measurement items or error
 * [CN]: 包含同步的原始静息心率测量条目或错误的完成回调块
 *
 * @discussion
 * [EN]: Resting heart rate is measured during periods of complete rest, typically during sleep.
 * It's an important indicator of cardiovascular health and fitness level.
 * This method retrieves raw resting heart rate data within the specified time range.
 * [CN]: 静息心率是在完全休息期间测量的，通常在睡眠期间。
 * 它是心血管健康和健身水平的重要指标。
 * 此方法检索指定时间范围内的原始静息心率数据。
 */
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                         endTime:(NSTimeInterval)endTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize raw resting heart rate data from a specified start time until now
 * @chinese 从指定开始时间同步至今的原始静息心率数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized raw resting heart rate measurement items or error
 * [CN]: 包含同步的原始静息心率测量条目或错误的完成回调块
 *
 * @discussion
 * [EN]: Resting heart rate is measured during periods of complete rest, typically during sleep.
 * It's an important indicator of cardiovascular health and fitness level.
 * This method retrieves raw resting heart rate data from the specified start time until now.
 * [CN]: 静息心率是在完全休息期间测量的，通常在睡眠期间。
 * 它是心血管健康和健身水平的重要指标。
 * 此方法检索从指定开始时间到现在的原始静息心率数据。
 */
- (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime
                                      completion:(nonnull void (^)(NSArray<TSHRValueItem *> *_Nullable restingHRItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize today's resting heart rate data
 * @chinese 同步今天的静息心率数据
 *
 * @param completion
 * [EN]: Completion block with today's resting heart rate data or error
 * [CN]: 包含今天的静息心率数据或错误的完成回调块
 *
 * @discussion
 * [EN]: Resting heart rate is measured during periods of complete rest, typically during sleep.
 * It's an important indicator of cardiovascular health and fitness level.
 * This method retrieves the current day's resting heart rate data from the device.
 * The data includes all resting heart rate measurements recorded today.
 * [CN]: 静息心率是在完全休息期间测量的，通常在睡眠期间。
 * 它是心血管健康和健身水平的重要指标。
 * 此方法从设备获取当天的静息心率数据。
 * 数据包括今天记录的所有静息心率测量值。
 */
- (void)syncTodayRestingHeartRateDataWithCompletion:(nonnull void (^)(TSHRValueItem *_Nullable todayRestingHR, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
