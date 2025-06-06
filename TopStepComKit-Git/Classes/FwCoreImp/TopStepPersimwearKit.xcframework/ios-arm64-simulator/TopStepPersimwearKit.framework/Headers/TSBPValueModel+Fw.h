//
//  TSBPValueModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSBPValueModel (Fw)

/**
 * @brief Convert a single dictionary to TSBPValueModel object
 * @chinese 将单个字典转换为TSBPValueModel对象
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
 * EN: Converted TSBPValueModel object, nil if conversion fails
 * CN: 转换后的TSBPValueModel对象，转换失败时返回nil
 */
+ (nullable TSBPValueModel *)bpModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSBPValueModel objects
 * @chinese 将字典数组转换为TSBPValueModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing blood pressure data
 * CN: 包含血压数据的字典数组
 *
 * @return 
 * EN: Array of converted TSBPValueModel objects, nil if conversion fails
 * CN: 转换后的TSBPValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSBPValueModel *> *)bpModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSBPValueModel *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

@end

NS_ASSUME_NONNULL_END
