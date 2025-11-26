//
//  TSDataSyncConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/9/7.
//

#import "TSKitBaseModel.h"
#import "TSDataSyncDefines.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Data synchronization configuration model
 * @chinese 数据同步配置模型
 *
 * @discussion
 * [EN]: This model encapsulates all parameters needed for data synchronization,
 *       providing a unified and extensible way to configure sync operations.
 *       It supports multiple data types, different granularities, and flexible time ranges.
 *
 * [CN]: 该模型封装了数据同步所需的所有参数，提供统一且可扩展的同步操作配置方式。
 *       支持多种数据类型、不同颗粒度和灵活的时间范围。
 */
@interface TSDataSyncConfig : TSKitBaseModel

/**
 * @brief Data types to synchronize
 * @chinese 要同步的数据类型
 *
 * @discussion
 * [EN]: Specifies which types of health data to synchronize.
 *       Can be combined using bitwise OR operations for batch synchronization.
 *       Example: TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen
 *
 * [CN]: 指定要同步的健康数据类型。
 *       可以使用按位或操作组合进行批量同步。
 *       示例：TSDataSyncOptionHeartRate | TSDataSyncOptionBloodOxygen
 */
@property (nonatomic, assign) TSDataSyncOption options;

/**
 * @brief Data granularity for synchronization
 * @chinese 数据同步颗粒度
 *
 * @discussion
 * [EN]: Specifies the level of data aggregation.
 *       - TSDataGranularityRaw: Individual measurements
 *       - TSDataGranularityDay: Daily aggregated data
 *
 * [CN]: 指定数据聚合的级别。
 *       - TSDataGranularityRaw: 单个测量值
 *       - TSDataGranularityDay: 按天聚合的数据
 */
@property (nonatomic, assign) TSDataGranularity granularity;

/**
 * @brief Start time for synchronization
 * @chinese 同步开始时间
 *
 * @discussion
 * [EN]: Start time for data synchronization in timestamp format (seconds since 1970).
 *       If not specified (0), the SDK will automatically get the last sync time from the database.
 *       If no last sync time is found, it defaults to 0.
 *       Must be earlier than endTime if endTime is specified.
 *
 * [CN]: 数据同步的开始时间，时间戳格式（1970年以来的秒数）。
 *       如果未指定（0），SDK会自动从数据库获取上次的更新时间。
 *       如果没有找到上次更新时间，则默认为0。
 *       如果指定了endTime，必须早于结束时间。
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 * @brief End time for synchronization
 * @chinese 同步结束时间
 *
 * @discussion
 * [EN]: End time for data synchronization in timestamp format (seconds since 1970).
 *       If not specified (0), it defaults to current time.
 *       Must be later than startTime and not in the future.
 *
 * [CN]: 数据同步的结束时间，时间戳格式（1970年以来的秒数）。
 *       如果未指定（0），默认为当前时间。
 *       必须晚于开始时间且不能在将来。
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 * @brief Whether to include user-initiated measurements
 * @chinese 是否包含主动测量数据
 *
 * @discussion
 * [EN]: When set to YES, both user-initiated and automatic measurements will be included.
 *       When set to NO, only automatic/passive monitoring data will be included.
 *       Note: Automatic measurements are typically more frequent and comprehensive.
 *
 * [CN]: 当设置为YES时，包含用户主动测量和自动监测数据。
 *       当设置为NO时，仅包含自动/被动监测数据。
 *       注意：自动测量通常更频繁且更全面。
 */
@property (nonatomic, assign) BOOL includeUserInitiated;

#pragma mark - Initialization

/**
 * @brief Initialize with default values
 * @chinese 使用默认值初始化
 *
 * @discussion
 * [EN]: Creates a configuration with default values:
 *       - options: TSDataSyncOptionAll
 *       - granularity: TSDataGranularityDay
 *       - startTime: 0
 *       - endTime: 0 (sync to current time)
 *       - includeUserInitiated: YES
 *
 * [CN]: 使用默认值创建配置：
 *       - options: TSDataSyncOptionAll
 *       - granularity: TSDataGranularityDay
 *       - startTime: 0
 *       - endTime: 0（同步到当前时间）
 *       - includeUserInitiated: YES
 */
- (instancetype)init;

/**
 * @brief Initialize with specific data types and granularity
 * @chinese 使用指定的数据类型和颗粒度初始化
 */
- (instancetype)initWithOptions:(TSDataSyncOption)options
                     granularity:(TSDataGranularity)granularity;

/**
 * @brief Initialize with specific data types, granularity and time range
 * @chinese 使用指定的数据类型、颗粒度和时间范围初始化
 */
- (instancetype)initWithOptions:(TSDataSyncOption)options
                     granularity:(TSDataGranularity)granularity
                       startTime:(NSTimeInterval)startTime
                         endTime:(NSTimeInterval)endTime;

#pragma mark - Convenience Methods

/**
 * @brief Create a configuration for raw data synchronization
 * @chinese 创建原始数据同步配置
 */
+ (instancetype)configForRawDataWithOptions:(TSDataSyncOption)options
                                  startTime:(NSTimeInterval)startTime
                                    endTime:(NSTimeInterval)endTime;

/**
 * @brief Create a configuration for daily data synchronization
 * @chinese 创建每日数据同步配置
 */
+ (instancetype)configForDailyDataWithOptions:(TSDataSyncOption)options
                                    startTime:(NSTimeInterval)startTime
                                      endTime:(NSTimeInterval)endTime;

/**
 * @brief Create a configuration for data synchronization from start time to current time
 * @chinese 创建从开始时间到当前时间的数据同步配置
 */
+ (instancetype)configWithOptions:(TSDataSyncOption)options
                        granularity:(TSDataGranularity)granularity
                          startTime:(NSTimeInterval)startTime;

@end

NS_ASSUME_NONNULL_END
