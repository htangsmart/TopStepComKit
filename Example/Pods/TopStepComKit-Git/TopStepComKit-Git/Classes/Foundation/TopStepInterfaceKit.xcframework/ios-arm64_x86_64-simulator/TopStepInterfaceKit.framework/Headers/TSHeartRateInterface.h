//
//  TSHeartRateInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSHealthBaseInterface.h"

#import "TSHRAutoMonitorConfigs.h"
#import "TSHRValueModel.h"

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
 * @param dataBlock
 * [EN]: Block to receive real-time heart rate data
 * [CN]: 接收实时心率数据的回调块
 *
 * @param completion
 * [EN]: Completion block called when the measurement starts or fails to start
 * [CN]: 当测量开始或无法开始时调用的完成回调块
 */
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                    dataBlock:(nonnull TSMeasureDataBlock)dataBlock
                   completion:(nonnull TSCompletionBlock)completion;


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
- (void)setAutoMonitorWithConfigs:(TSHRAutoMonitorConfigs *_Nonnull)configuration
                       completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Get the current automatic heart rate monitoring configuration
 * @chinese 获取当前自动心率监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error
 * [CN]: 包含当前配置或错误的完成回调块
 */
- (void)getAutoMonitorConfigsCompletion:(nonnull void (^)(TSHRAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;

/**
 * @brief Synchronize heart rate history data within a specified time range
 * @chinese 同步指定时间范围内的心率历史数据
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
 * [EN]: Completion block with synchronized heart rate values or error
 * [CN]: 包含同步的心率值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSHRValueModel *> *_Nullable hrValues, NSError *_Nullable error))completion;


/**
 * @brief Synchronize heart rate history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的心率历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized heart rate values or error
 * [CN]: 包含同步的心率值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSHRValueModel *> *_Nullable hrValues, NSError *_Nullable error))completion;


/**
 * @brief Synchronize  history resting heart rate data 
 * @chinese 同步历史静息心率数据

 * @param completion
 * [EN]: Completion block with synchronized resting heart rate values or error
 * [CN]: 包含同步的静息心率值或错误的完成回调块
 *
 * @discussion
 * [EN]: Resting heart rate is measured during periods of complete rest, typically during sleep.
 * It's an important indicator of cardiovascular health and fitness level.
 * [CN]: 静息心率是在完全休息期间测量的，通常在睡眠期间。
 * 它是心血管健康和健身水平的重要指标。
 */
- (void)syncHistoryRestingHeartRateCompletion:(nonnull void (^)(NSArray<TSHRValueModel *> *_Nullable restHRModes, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
