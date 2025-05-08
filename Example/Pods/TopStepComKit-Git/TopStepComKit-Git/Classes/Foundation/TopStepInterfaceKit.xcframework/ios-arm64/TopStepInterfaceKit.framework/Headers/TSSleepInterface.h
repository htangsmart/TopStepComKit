//
//  TSSleepInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSKitBaseInterface.h"
#import "TSSleepModel.h"
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
- (void)setAutoMonitorWithConfigs:(TSAutoMonitorConfigs *_Nonnull)configuration
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
- (void)getAutoMonitorConfigsCompletion:(nonnull void (^)(TSAutoMonitorConfigs *_Nullable configuration, NSError *_Nullable error))completion;


/**
 * @brief Synchronize sleep history data within a specified time range
 * @chinese 同步指定时间范围内的睡眠历史数据
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
 * [EN]: Completion block with synchronized sleep data or error
 * [CN]: 包含同步的睡眠数据或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                                 endTime:(NSTimeInterval)endTime
                              completion:(nonnull void (^)(NSArray<TSSleepModel *> *_Nullable sleepValues, NSError *_Nullable error))completion;

/**
 * @brief Synchronize sleep history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的睡眠历史数据
 *
 * @param startTime 
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion 
 * [EN]: Completion block with synchronized sleep data or error
 * [CN]: 包含同步的睡眠数据或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                              completion:(nonnull void (^)(NSArray<TSSleepModel *> *_Nullable sleepValues, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
