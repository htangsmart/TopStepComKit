//
//  TSElectrocardioInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSElectrocardioModel.h"
#import "TSHealthBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Electrocardiogram (ECG) measurement and monitoring interface
 * @chinese 心电图(ECG)测量和监测接口
 *
 * @discussion
 * [EN]: This interface provides methods for ECG measurement, automatic monitoring,
 * and historical data synchronization. ECG data is used to detect heart abnormalities,
 * arrhythmias, and assess overall cardiac health.
 * [CN]: 该接口提供心电图测量、自动监测和历史数据同步的方法。心电图数据用于检测心脏异常、
 * 心律不齐和评估整体心脏健康状况。
 */
@protocol TSElectrocardioInterface <TSHealthBaseInterface>


/**
 * @brief Check if the device supports manual ECG measurement
 * @chinese 检查设备是否支持手动心电图测量
 *
 * @return
 * [EN]: YES if the device supports manual ECG measurement, NO otherwise
 * [CN]: 如果设备支持手动心电图测量返回YES，否则返回NO
 */
- (BOOL)isSupportActivityMeasureByUser;


/**
 * @brief Start ECG measurement with specified parameters
 * @chinese 使用指定参数开始心电图测量
 *
 * @param measureParam
 * [EN]: Parameters for the measurement activity
 * [CN]: 测量活动的参数
 *
 * @param dataBlock
 * [EN]: Block to receive real-time ECG data
 * [CN]: 接收实时心电图数据的回调块
 *
 * @param completion
 * [EN]: Completion block called when the measurement starts or fails to start
 * [CN]: 当测量开始或无法开始时调用的完成回调块
 */
- (void)startMeasureWithParam:(TSActivityMeasureParam *_Nonnull)measureParam
                    dataBlock:(nonnull TSMeasureDataBlock)dataBlock
                   completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Stop the ongoing ECG measurement
 * @chinese 停止正在进行的心电图测量
 *
 * @param completion
 * [EN]: Completion block called when the measurement stops or fails to stop
 * [CN]: 当测量停止或无法停止时调用的完成回调块
 */
- (void)stopMeasureCompletion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Check if the device supports automatic ECG monitoring
 * @chinese 检查设备是否支持自动心电图监测
 *
 * @return
 * [EN]: YES if the device supports automatic ECG monitoring, NO otherwise
 * [CN]: 如果设备支持自动心电图监测返回YES，否则返回NO
 */
- (BOOL)isSupportAutomaticMonitoring;


/**
 * @brief Configure automatic ECG monitoring
 * @chinese 配置自动心电图监测
 *
 * @param configuration
 * [EN]: Configuration parameters for automatic ECG monitoring
 * [CN]: 自动心电图监测的配置参数
 *
 * @param completion
 * [EN]: Completion block called when the configuration is set or fails to set
 * [CN]: 当配置设置成功或失败时调用的完成回调块
 */
- (void)setAutoMonitorWithConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
                       completion:(nonnull TSCompletionBlock)completion;


/**
 * @brief Get the current automatic ECG monitoring configuration
 * @chinese 获取当前自动心电图监测配置
 *
 * @param completion
 * [EN]: Completion block with the current configuration or error
 * [CN]: 包含当前配置或错误的完成回调块
 */
- (void)getAutoMonitorConfigsCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;

/**
 * @brief Synchronize ECG history data within a specified time range
 * @chinese 同步指定时间范围内的心电图历史数据
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
 * [EN]: Completion block with synchronized ECG values or error
 * [CN]: 包含同步的心电图值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSElectrocardioModel *> *_Nullable egcValues, NSError *_Nullable error))completion;


/**
 * @brief Synchronize ECG history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的心电图历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized ECG values or error
 * [CN]: 包含同步的心电图值或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSElectrocardioModel *> *_Nullable egcValues, NSError *_Nullable error))completion;



@end

NS_ASSUME_NONNULL_END
