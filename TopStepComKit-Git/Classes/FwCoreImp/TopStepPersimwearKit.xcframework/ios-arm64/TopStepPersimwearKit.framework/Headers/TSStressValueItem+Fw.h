//
//  TSStressValueItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSStressValueItem (Fw)

/**
 * @brief Convert a single dictionary to TSStressValueItem object
 * @chinese 将单个字典转换为TSStressValueItem对象
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
 * EN: Converted TSStressValueItem object, nil if conversion fails
 * CN: 转换后的TSStressValueItem对象，转换失败时返回nil
 */
+ (nullable TSStressValueItem *)stressModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSStressValueItem objects
 * @chinese 将字典数组转换为TSStressValueItem对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing stress data
 * CN: 包含压力数据的字典数组
 *
 * @return 
 * EN: Array of converted TSStressValueItem objects, nil if conversion fails
 * CN: 转换后的TSStressValueItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSStressValueItem *> *)stressModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSStressValueItem *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

/**
 * @brief Convert TSStressValueItem array to dictionary array for database insertion
 * @chinese 将TSStressValueItem数组转换为数据库插入用的字典数组
 *
 * @param stressItems
 * EN: Array of TSStressValueItem objects to be converted
 * CN: 需要转换的TSStressValueItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSHealthStressTable structure
 * CN: 字典数组，字段与TSHealthStressTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromStressItems:(NSArray<TSStressValueItem *> *)stressItems;

@end

NS_ASSUME_NONNULL_END
