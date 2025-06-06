//
//  TSStressValueModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSStressValueModel (Fw)

/**
 * @brief Convert a single dictionary to TSStressValueModel object
 * @chinese 将单个字典转换为TSStressValueModel对象
 *
 * @param dict 
 * EN: Dictionary containing stress data with:
 * - ts: Timestamp in seconds
 * - d: Array containing single stress value
 * CN: 包含压力数据的字典，包含：
 * - ts: 时间戳（秒）
 * - d: 包含单个压力值的数组
 *
 * @return 
 * EN: Converted TSStressValueModel object, nil if conversion fails
 * CN: 转换后的TSStressValueModel对象，转换失败时返回nil
 */
+ (nullable TSStressValueModel *)stressModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSStressValueModel objects
 * @chinese 将字典数组转换为TSStressValueModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing stress data
 * CN: 包含压力数据的字典数组
 *
 * @return 
 * EN: Array of converted TSStressValueModel objects, nil if conversion fails
 * CN: 转换后的TSStressValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSStressValueModel *> *)stressModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSStressValueModel *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

@end

NS_ASSUME_NONNULL_END
