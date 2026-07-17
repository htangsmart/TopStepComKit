//
//  TSHRValueItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSHRValueItem (Fw)

/**
 * @brief Convert a single dictionary to TSHRValueItem object
 * @chinese 将单个字典转换为TSHRValueItem对象
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
 * EN: Converted TSHRValueItem object, nil if conversion fails
 * CN: 转换后的TSHRValueItem对象，转换失败时返回nil
 */
+ (nullable TSHRValueItem *)hrModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSHRValueItem objects
 * @chinese 将字典数组转换为TSHRValueItem对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing heart rate data
 * CN: 包含心率数据的字典数组
 *
 * @return 
 * EN: Array of converted TSHRValueItem objects, nil if conversion fails
 * CN: 转换后的TSHRValueItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSHRValueItem *> *)hrModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;

/**
 * @brief Convert sport heart rate data array to array of TSHRValueItem objects
 * @chinese 将运动心率数据数组转换为TSHRValueItem对象数组
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
 * EN: Array of converted TSHRValueItem objects, nil if conversion fails
 * CN: 转换后的TSHRValueItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSHRValueItem *> *)hrModelsWithSportDictArray:(nullable NSArray<NSDictionary *> *)sportDictArray;


+ (nullable TSHRValueItem *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

/**
 * @brief Convert TSHRValueItem array to dictionary array for database insertion
 * @chinese 将TSHRValueItem数组转换为数据库插入用的字典数组
 *
 * @param hrItems
 * EN: Array of TSHRValueItem objects to be converted
 * CN: 需要转换的TSHRValueItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSHeartRateTable structure
 * CN: 字典数组，字段与TSHeartRateTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromHRItems:(NSArray<TSHRValueItem *> *)hrItems;

@end

NS_ASSUME_NONNULL_END
