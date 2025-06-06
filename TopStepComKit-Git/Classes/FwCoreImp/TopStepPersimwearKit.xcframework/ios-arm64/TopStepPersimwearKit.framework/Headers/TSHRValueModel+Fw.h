//
//  TSHRValueModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSHRValueModel (Fw)

/**
 * @brief Convert a single dictionary to TSHRValueModel object
 * @chinese 将单个字典转换为TSHRValueModel对象
 *
 * @param dict 
 * EN: Dictionary containing heart rate data with:
 * - ts: Timestamp in seconds
 * - d: Array containing single heart rate value
 * CN: 包含心率数据的字典，包含：
 * - ts: 时间戳（秒）
 * - d: 包含单个心率值的数组
 *
 * @return 
 * EN: Converted TSHRValueModel object, nil if conversion fails
 * CN: 转换后的TSHRValueModel对象，转换失败时返回nil
 */
+ (nullable TSHRValueModel *)hrModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSHRValueModel objects
 * @chinese 将字典数组转换为TSHRValueModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing heart rate data
 * CN: 包含心率数据的字典数组
 *
 * @return 
 * EN: Array of converted TSHRValueModel objects, nil if conversion fails
 * CN: 转换后的TSHRValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSHRValueModel *> *)hrModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

/**
 * @brief Convert sport heart rate data array to array of TSHRValueModel objects
 * @chinese 将运动心率数据数组转换为TSHRValueModel对象数组
 *
 * @param sportDictArray 
 * EN: Array of dictionaries containing sport heart rate data with:
 * - ts: Timestamp in seconds
 * - d: Dictionary containing sport data including:
 *   - hr: Heart rate value
 *   - ds: Start timestamp
 * CN: 包含运动心率数据的字典数组，包含：
 * - ts: 时间戳（秒）
 * - d: 包含运动数据的字典，包括：
 *   - hr: 心率值
 *   - ds: 开始时间戳
 *
 * @return 
 * EN: Array of converted TSHRValueModel objects, nil if conversion fails
 * CN: 转换后的TSHRValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSHRValueModel *> *)hrModelsWithSportDictArray:(nullable NSArray<NSDictionary *> *)sportDictArray;


+ (nullable TSHRValueModel *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

@end

NS_ASSUME_NONNULL_END
