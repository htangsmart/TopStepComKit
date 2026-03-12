//
//  TSStressInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSHealthBaseInterface.h"
#import "TSStressValueItem.h"
#import "TSAutoMonitorConfigs.h"
#import "TSStressDailyModel.h"



NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stress measurement and monitoring interface
 * @chinese 压力测量和监测接口
 *
 * @discussion
 * [EN]: This interface provides methods for stress level measurement, automatic monitoring,
 * and historical data synchronization.
 * [CN]: 该接口提供压力水平测量、自动监测和历史数据同步的方法。
 */
@protocol TSStressInterface <TSHealthBaseInterface>


/**
 * @brief Check if the device supports manual stress measurement
 * @chinese 检查设备是否支持手动压力测量
 *
 * @return
 * [EN]: YES if the device supports manual stress measurement, NO otherwise
 * [CN]: 如果设备支持手动压力测量返回YES，否则返回NO
 */
- (BOOL)isSupportActivityMeasureByUser;


/**
 * @brief Start stress measurement with specified parameters
 * @chinese 使用指定参数开始压力测量
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
 *       - data: Real-time stress measurement data, nil if error occurs
 *       - error: Error information if data reception fails, nil if successful
 * [CN]: 接收实时测量数据的回调块
 *       - data: 实时压力测量数据，发生错误时为nil
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
                  dataHandler:(void(^_Nullable)(TSStressValueItem * _Nullable data, NSError * _Nullable error))dataHandler
                   endHandler:(void(^_Nullable)(BOOL success, NSError * _Nullable error))endHandler;

/**
 * @brief Stop the ongoing stress measurement
 * @chinese 停止正在进行的压力测量
 *
 * @param completion
 * [EN]: Completion block called when the measurement stops or fails to stop
 * [CN]: 当测量停止或无法停止时调用的完成回调块
 */
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Check if the device supports automatic stress monitoring
 * @chinese 检查设备是否支持自动压力监测
 *
 * @return
 * [EN]: YES if the device supports automatic stress monitoring, NO otherwise
 * [CN]: 如果设备支持自动压力监测返回YES，否则返回NO
 */
- (BOOL)isSupportAutomaticMonitoring;


/**
 * @brief Configure automatic stress monitoring
 * @chinese 配置自动压力监测
 *
 * @param configuration
 * [EN]: Configuration parameters for automatic monitoring
 * [CN]: 自动监测的配置参数
 *
 * @param completion
 * [EN]: Completion block called when the configuration is set or fails to set
 * [CN]: 当配置设置成功或失败时调用的完成回调块
 */
- (void)pushAutoMonitorConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                    completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Get the current automatic stress monitoring configuration
 * @chinese 获取当前自动压力监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error
 * [CN]: 包含当前配置或错误的完成回调块
 */
- (void)fetchAutoMonitorConfigsWithCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;


/**
 * @brief Synchronize raw stress data within a specified time range
 * @chinese 同步指定时间范围内的原始压力数据
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
 * [EN]: Completion block with synchronized raw stress measurement items or error
 * [CN]: 包含同步的原始压力测量条目或错误的完成回调块
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize raw stress data from a specified start time until now
 * @chinese 从指定开始时间同步至今的原始压力数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp in seconds since 1970)
 * [CN]: 数据同步的开始时间（1970年以来的秒数时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized raw stress measurement items or error
 * [CN]: 包含同步的原始压力测量条目或错误的完成回调块
 */
- (void)syncRawDataFromStartTime:(NSTimeInterval)startTime
                      completion:(nonnull void (^)(NSArray<TSStressValueItem *> *_Nullable stressItems, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily stress data within a specified time range
 * @chinese 同步指定时间范围内的每日压力数据
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
 * [EN]: Completion block with synchronized daily stress models or error.
 *       Each TSStressDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日压力模型数组或错误。
 *       每个 TSStressDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated stress data within the given time range.
 *       Time parameters are automatically normalized to day boundaries (00:00:00 to 23:59:59).
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法同步指定时间范围内的每日聚合压力数据。
 *       时间参数将自动规范化为日期边界（00:00:00 到 23:59:59）。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

/**
 * @brief Synchronize daily stress data from a specified start time until now
 * @chinese 从指定开始时间同步至今的每日压力数据
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
 * [EN]: Completion block with synchronized daily stress models or error.
 *       Each TSStressDailyModel represents one day's aggregated data.
 * [CN]: 完成回调，返回同步的每日压力模型数组或错误。
 *       每个 TSStressDailyModel 代表一天的数据集合。
 *
 * @discussion
 * [EN]: This method synchronizes daily aggregated stress data from the start time to the current time.
 *       It is a convenience wrapper around syncDailyDataFromStartTime:endTime:completion: that
 *       automatically sets the end time to the current time.
 *       Start time is automatically normalized to 00:00:00 of the specified day.
 *       Data is returned in ascending time order, with each element representing one day.
 *       The completion handler is called on the main thread.
 * [CN]: 此方法从开始时间到当前时间同步每日聚合压力数据。
 *       它是syncDailyDataFromStartTime:endTime:completion:的便捷包装，
 *       自动将结束时间设置为当前时间。
 *       开始时间将自动规范化为指定日期的 00:00:00。
 *       数据按时间升序返回，每个元素代表一天。
 *       完成回调在主线程中调用。
 */
- (void)syncDailyDataFromStartTime:(NSTimeInterval)startTime
                        completion:(nonnull void (^)(NSArray<TSStressDailyModel *> *_Nullable dailyModels, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
