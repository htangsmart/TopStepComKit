//
//  TSDataSyncInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//
//  文件说明:
//  数据同步管理协议，定义了设备健康数据同步的方法，包括心率、血氧、血压、压力、睡眠、体温、心电图、运动和日常活动等数据

#import "TSKitBaseInterface.h"
//
#import "TSAllDataModel.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Data types for synchronization
 * @chinese 数据同步类型
 *
 * @discussion
 * [EN]: Defines the types of health data that can be synchronized from the device.
 *       These types can be combined using bitwise OR operations for batch synchronization.
 *       Each type represents a specific category of health metrics collected by the device.
 *
 * [CN]: 定义可以从设备同步的健康数据类型。
 *       这些类型可以使用按位或操作组合进行批量同步。
 *       每种类型代表设备收集的特定健康指标类别。
 */
typedef NS_OPTIONS(NSInteger, TSDataType) {
    /// 心率数据 (Heart rate data)
    TSDataTypeHeartRate     = 1 << 0,
    /// 血氧数据 (Blood oxygen data)
    TSDataTypeBloodOxygen   = 1 << 1,
    /// 血压数据 (Blood pressure data)
    TSDataTypeBloodPressure = 1 << 2,
    /// 压力水平数据 (Stress level data)
    TSDataTypeStress        = 1 << 3,
    /// 睡眠监测数据 (Sleep monitoring data)
    TSDataTypeSleep         = 1 << 4,
    /// 体温数据 (Temperature data)
    TSDataTypeTemperature   = 1 << 5,
    /// 心电图数据 (ECG data)
    TSDataTypeECG           = 1 << 6,
    /// 运动活动数据 (Sports activity data)
    TSDataTypeSport         = 1 << 7,
    /// 日常活动数据 (Daily activity data)
    TSDataTypeDailyActivity      = 1 << 8,
    /// 所有数据类型的组合 (All data types combined)
    TSDataTypeAll           = (TSDataTypeHeartRate |
                               TSDataTypeBloodOxygen |
                               TSDataTypeBloodPressure |
                               TSDataTypeStress |
                               TSDataTypeSleep |
                               TSDataTypeTemperature |
                               TSDataTypeECG |
                               TSDataTypeSport |
                               TSDataTypeDailyActivity)
};

/**
 * @brief Data synchronization interface
 * @chinese 数据同步接口
 *
 * @discussion
 * [EN]: This protocol defines methods for synchronizing health data from the device.
 *       It provides a comprehensive API for retrieving various health metrics within
 *       specified time ranges. The interface supports:
 *       - Batch synchronization of multiple data types
 *       - Flexible time range specification
 *       - Automatic error handling and reporting
 *
 * [CN]: 该协议定义了从设备同步健康数据的方法。
 *       它提供了一个全面的API，用于在指定时间范围内检索各种健康指标。该接口支持：
 *       - 多种数据类型的批量同步
 *       - 灵活的时间范围指定
 *       - 自动错误处理和报告
 */
@protocol TSDataSyncInterface <TSKitBaseInterface>

/**
 * @brief Fetch health data from device for specified time range
 * @chinese 从设备获取指定时间范围内的健康数据
 *
 * @param dataTypes 
 * [EN]: Types of data to fetch, can be combined using bitwise OR.
 *       Example: TSDataTypeHeartRate | TSDataTypeBloodOxygen
 * [CN]: 要获取的数据类型，可以使用按位或组合多个类型。
 *       示例：TSDataTypeHeartRate | TSDataTypeBloodOxygen
 *
 * @param startTime 
 * [EN]: Start time in timestamp format (seconds since 1970).
 *       Must be earlier than endTime.
 * [CN]: 开始时间，时间戳格式（1970年以来的秒数）。
 *       必须早于结束时间。
 *
 * @param endTime 
 * [EN]: End time in timestamp format (seconds since 1970).
 *       Must be later than startTime and not in the future.
 * [CN]: 结束时间，时间戳格式（1970年以来的秒数）。
 *       必须晚于开始时间且不能在将来。
 *
 * @param completion 
 * [EN]: Completion handler that provides a TSAllDataModel containing all requested data.
 *       Each data type will be populated if available, with any errors stored in corresponding error properties.
 * [CN]: 完成回调，提供包含所有请求数据的TSAllDataModel。
 *       如果可用，将填充每种数据类型，任何错误都存储在相应的错误属性中。
 *
 * @discussion
 * [EN]: This method fetches specified types of health data from the device within the given time range.
 *       Important notes:
 *       1. Multiple data types can be requested simultaneously
 *       2. Data is returned in ascending time order
 *       3. For each data type, either data will be populated or an error will be provided
 *       4. The completion handler is called on the main thread
 *       5. Time range should be reasonable (typically not more than 30 days) to avoid timeout
 *
 * [CN]: 此方法从设备获取指定时间范围内的指定类型健康数据。
 *       重要说明：
 *       1. 可以同时请求多个数据类型
 *       2. 数据按时间升序返回
 *       3. 对于每种数据类型，要么填充数据，要么提供错误
 *       4. 完成回调在主线程中调用
 *       5. 时间范围应合理（通常不超过30天），以避免超时
 */
- (void)syncDataWithTypes:(TSDataType)dataTypes
                startTime:(NSTimeInterval)startTime
                  endTime:(NSTimeInterval)endTime
               completion:(void (^)(TSAllDataModel* _Nonnull allDataModel))completion;

/**
 * @brief Fetch health data from device from start time to current time
 * @chinese 从设备获取从指定开始时间到当前时间的健康数据
 *
 * @param dataTypes 
 * [EN]: Types of data to fetch, can be combined using bitwise OR.
 *       Example: TSDataTypeHeartRate | TSDataTypeBloodOxygen
 * [CN]: 要获取的数据类型，可以使用按位或组合多个类型。
 *       示例：TSDataTypeHeartRate | TSDataTypeBloodOxygen
 *
 * @param startTime 
 * [EN]: Start time in timestamp format (seconds since 1970).
 *       Data will be fetched from this time to the current time.
 * [CN]: 开始时间，时间戳格式（1970年以来的秒数）。
 *       将获取从此时间到当前时间的数据。
 *
 * @param completion 
 * [EN]: Completion handler that provides a TSAllDataModel containing all requested data.
 *       Each data type will be populated if available, with any errors stored in corresponding error properties.
 * [CN]: 完成回调，提供包含所有请求数据的TSAllDataModel。
 *       如果可用，将填充每种数据类型，任何错误都存储在相应的错误属性中。
 *
 * @discussion
 * [EN]: This method fetches specified types of health data from the start time to the current time.
 *       It is a convenience wrapper around syncDataWithTypes:startTime:endTime:completion: that
 *       automatically sets the end time to the current time.
 *       
 *       Important notes:
 *       1. Multiple data types can be requested simultaneously
 *       2. Data is returned in ascending time order
 *       3. For each data type, either data will be populated or an error will be provided
 *       4. The completion handler is called on the main thread
 *       5. Time range should be reasonable (typically not more than 30 days) to avoid timeout
 *
 * [CN]: 此方法从开始时间到当前时间获取指定类型的健康数据。
 *       它是syncDataWithTypes:startTime:endTime:completion:的便捷包装，
 *       自动将结束时间设置为当前时间。
 *       
 *       重要说明：
 *       1. 可以同时请求多个数据类型
 *       2. 数据按时间升序返回
 *       3. 对于每种数据类型，要么填充数据，要么提供错误
 *       4. 完成回调在主线程中调用
 *       5. 时间范围应合理（通常不超过30天），以避免超时
 */
- (void)syncDataWithTypes:(TSDataType)dataTypes
                startTime:(NSTimeInterval)startTime
               completion:(nonnull void (^)(TSAllDataModel * _Nonnull allDataModel))completion;

@end

NS_ASSUME_NONNULL_END
