//
//  TSBPValueItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSBPValueItem (Fw)

/**
 * @brief Convert a single dictionary to TSBPValueItem object
 * @chinese 将单个字典转换为TSBPValueItem对象
 *
 * @param dict 
 * EN: Dictionary containing blood pressure data with:
 * - ts: Timestamp in seconds
 * - sbp: Array containing systolic blood pressure value
 * - dbp: Array containing diastolic blood pressure value
 * CN: 包含血压数据的字典，包含：
 * - ts: 时间戳（秒）
 * - sbp: 包含收缩压值的数组
 * - dbp: 包含舒张压值的数组
 *
 * @return 
 * EN: Converted TSBPValueItem object, nil if conversion fails
 * CN: 转换后的TSBPValueItem对象，转换失败时返回nil
 */
+ (nullable TSBPValueItem *)bpModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSBPValueItem objects
 * @chinese 将字典数组转换为TSBPValueItem对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing blood pressure data
 * CN: 包含血压数据的字典数组
 *
 * @return 
 * EN: Array of converted TSBPValueItem objects, nil if conversion fails
 * CN: 转换后的TSBPValueItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSBPValueItem *> *)bpModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSBPValueItem *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

/**
 * @brief Convert TSBPValueItem array to dictionary array for database insertion
 * @chinese 将TSBPValueItem数组转换为数据库插入用的字典数组
 *
 * @param bpItems
 * EN: Array of TSBPValueItem objects to be converted
 * CN: 需要转换的TSBPValueItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSBloodPressureTable structure
 * CN: 字典数组，字段与TSBloodPressureTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromBPItems:(NSArray<TSBPValueItem *> *)bpItems;

@end

NS_ASSUME_NONNULL_END
