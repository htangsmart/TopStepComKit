//
//  TSHealthData.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSKitBaseModel.h"
#import "TSDataSyncConfig.h"
#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSHealthData : TSKitBaseModel

/**
 * @brief Data type of the health values
 * @chinese 健康数据类型
 *
 * @discussion
 * [EN]: Indicates which kind of health data these values belong to, such as
 *       heart rate, SpO2, blood pressure, stress, sleep, temperature, ECG, etc.
 * [CN]: 表示这些健康数据所属的具体类型，例如心率、血氧、血压、压力、睡眠、体温、心电等。
 */
@property (nonatomic,assign) TSDataSyncOption option;

/**
 * @brief Health value list in ascending time order (daily aggregated)
 * @chinese 健康数据列表（按时间升序，按天聚合）
 *
 * @discussion
 * [EN]: Each element represents one day's aggregated data within the requested range.
 *       For example, querying the past 7 days of heart rate will return 7 elements,
 *       each describing one day's collection. When no data is available, this array is empty.
 * [CN]: 每个元素代表请求时间范围内的“某一天”的数据集合。
 *       例如查询过去 7 天的心率数据，将返回 7 个元素，每个元素代表一天的数据集合。
 *       当没有数据时，该数组为空。
 */
@property (nonatomic,strong) NSArray <TSHealthValueModel *>* healthValues;

/**
 * @brief Error describing why fetching this type failed
 * @chinese 获取该类型数据失败时的错误
 *
 * @discussion
 * [EN]: If fetching this data type failed, this property contains the error. When fetching
 *       succeeds (even if no data), this property is nil.
 * [CN]: 若该类型数据获取失败，将通过此属性返回错误；若获取成功（即使没有数据），该属性为 nil。
 */
@property (nonatomic,strong,nullable) NSError *fetchError;

#pragma mark - Creation Methods

/**
 * @brief Create TSHealthData object with specified parameters (instance method)
 * @chinese 使用指定参数创建TSHealthData对象（实例方法）
 */
- (instancetype)initWithOption:(TSDataSyncOption)option
                  healthValues:(NSArray<TSHealthValueModel *> *)healthValues
                    fetchError:(nullable NSError *)fetchError;

/**
 * @brief Create TSHealthData object with specified parameters (class method)
 * @chinese 使用指定参数创建TSHealthData对象（类方法）
 */
+ (instancetype)healthDataWithOption:(TSDataSyncOption)option
                        healthValues:(NSArray<TSHealthValueModel *> *)healthValues
                          fetchError:(nullable NSError *)fetchError;

/**
 * @brief Create TSHealthData object with data type and health values (class method)
 * @chinese 使用数据类型和健康数据创建TSHealthData对象（类方法）
 */
+ (instancetype)healthDataWithOption:(TSDataSyncOption)option
                        healthValues:(NSArray<TSHealthValueModel *> *)healthValues;

/**
 * @brief Create TSHealthData object with data type and error (class method)
 * @chinese 使用数据类型和错误创建TSHealthData对象（类方法）
 */
+ (instancetype)healthDataWithOption:(TSDataSyncOption)option
                          fetchError:(NSError *)fetchError;

#pragma mark - Find Methods

/**
 * @brief Find TSHealthData object with specified data type from array
 * @chinese 从数组中查找指定数据类型的TSHealthData对象
 *
 * @param option
 * [EN]: The data type to search for (e.g., TSDataSyncOptionHeartRate, TSDataSyncOptionBloodOxygen)
 * [CN]: 要查找的数据类型（例如：TSDataSyncOptionHeartRate、TSDataSyncOptionBloodOxygen）
 *
 * @param healthDataArray
 * [EN]: Array of TSHealthData objects to search in
 * [CN]: 要搜索的TSHealthData对象数组
 *
 * @return
 * [EN]: The TSHealthData object with matching option, or nil if not found
 * [CN]: 匹配指定option的TSHealthData对象，如果未找到则返回nil
 *
 * @discussion
 * [EN]: This method searches through the provided array to find a TSHealthData object
 *       whose option property matches the specified TSDataSyncOption. Returns the first
 *       matching object found, or nil if no match is found.
 * [CN]: 此方法在提供的数组中搜索option属性与指定TSDataSyncOption匹配的TSHealthData对象。
 *       返回找到的第一个匹配对象，如果未找到匹配项则返回nil。
 */
+ (nullable TSHealthData *)findHealthDataWithOption:(TSDataSyncOption)option
                                          fromArray:(NSArray<TSHealthData *> *)healthDataArray;

@end

NS_ASSUME_NONNULL_END
