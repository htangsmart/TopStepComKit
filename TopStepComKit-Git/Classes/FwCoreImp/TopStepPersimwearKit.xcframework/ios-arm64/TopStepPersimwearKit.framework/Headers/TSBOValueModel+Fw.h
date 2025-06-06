//
//  TSBOValueModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSBOValueModel (Fw)

/**
 * @brief Convert a single dictionary to TSBOValueModel object
 * @chinese 将单个字典转换为TSBOValueModel对象
 *
 * @param dict 
 * EN: Dictionary containing blood oxygen data with:
 * - ts: Timestamp in seconds
 * - d: Array containing single blood oxygen value
 * CN: 包含血氧数据的字典，包含：
 * - ts: 时间戳（秒）
 * - d: 包含单个血氧值的数组
 *
 * @return 
 * EN: Converted TSBOValueModel object, nil if conversion fails
 * CN: 转换后的TSBOValueModel对象，转换失败时返回nil
 */
+ (nullable TSBOValueModel *)boModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSBOValueModel objects
 * @chinese 将字典数组转换为TSBOValueModel对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing blood oxygen data
 * CN: 包含血氧数据的字典数组
 *
 * @return 
 * EN: Array of converted TSBOValueModel objects, nil if conversion fails
 * CN: 转换后的TSBOValueModel对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSBOValueModel *> *)boModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSBOValueModel *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

@end

NS_ASSUME_NONNULL_END
