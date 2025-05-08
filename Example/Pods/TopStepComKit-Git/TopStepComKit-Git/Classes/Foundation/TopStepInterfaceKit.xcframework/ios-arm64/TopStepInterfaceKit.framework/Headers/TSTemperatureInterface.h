//
//  TSTemperatureInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSHealthBaseInterface.h"
#import "TSTemperatureValueModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Temperature measurement and monitoring interface
 * @chinese 温度测量和监测接口
 *
 * @discussion
 * [EN]: This interface provides methods for temperature measurement, automatic monitoring,
 * and historical data synchronization.
 * [CN]: 该接口提供温度测量、自动监测和历史数据同步的方法。
 */
@protocol TSTemperatureInterface <TSHealthBaseInterface>


/**
 * @brief Check if the device supports manual temperature measurement
 * @chinese 检查设备是否支持手动温度测量
 *
 * @return
 * [EN]: YES if the device supports manual temperature measurement, NO otherwise
 * [CN]: 如果设备支持手动温度测量返回YES，否则返回NO
 */
- (BOOL)isSupportActivityMeasureByUser;


/**
 * @brief Start temperature measurement with specified parameters
 * @chinese 使用指定参数开始温度测量
 *
 * @param measureParam
 * [EN]: Parameters for the measurement activity
 * [CN]: 测量活动的参数
 *
 * @param dataBlock
 * [EN]: Block to receive real-time measurement data
 * [CN]: 接收实时测量数据的回调块
 *
 * @param completion
 * [EN]: Completion block called when the measurement starts or fails to start
 * [CN]: 当测量开始或无法开始时调用的完成回调块
 */
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                    dataBlock:(nonnull TSMeasureDataBlock)dataBlock
                   completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Stop the ongoing temperature measurement
 * @chinese 停止正在进行的温度测量
 *
 * @param completion
 * [EN]: Completion block called when the measurement stops or fails to stop
 * [CN]: 当测量停止或无法停止时调用的完成回调块
 */
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Check if the device supports automatic temperature monitoring
 * @chinese 检查设备是否支持自动温度监测
 *
 * @return
 * [EN]: YES if the device supports automatic temperature monitoring, NO otherwise
 * [CN]: 如果设备支持自动温度监测返回YES，否则返回NO
 */
- (BOOL)isSupportAutomaticMonitoring;


/**
 * @brief Configure automatic temperature monitoring
 * @chinese 配置自动温度监测
 *
 * @param configuration
 * [EN]: Configuration parameters for automatic monitoring
 * [CN]: 自动监测的配置参数
 *
 * @param completion
 * [EN]: Completion block called when the configuration is set or fails to set
 * [CN]: 当配置设置成功或失败时调用的完成回调块
 */
- (void)setAutoMonitorWithConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                       completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Get the current automatic temperature monitoring configuration
 * @chinese 获取当前自动温度监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error
 * [CN]: 包含当前配置或错误的完成回调块
 */
- (void)getAutoMonitorConfigsCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;


/**
 * @brief Synchronize temperature history data within a specified time range
 * @chinese 同步指定时间范围内的温度历史数据
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
 * [EN]: Completion block with synchronized temperature values or error
 * [CN]: 包含同步的温度值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSTemperatureValueModel *> *_Nullable temValues, NSError *_Nullable error))completion;

/**
 * @brief Synchronize temperature history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的温度历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized temperature values or error
 * [CN]: 包含同步的温度值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSTemperatureValueModel *> *_Nullable temValues, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
