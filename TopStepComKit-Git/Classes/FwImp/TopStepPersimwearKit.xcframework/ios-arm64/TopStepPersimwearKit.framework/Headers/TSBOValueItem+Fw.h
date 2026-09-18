//
//  TSBOValueItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSBOValueItem (Fw)

/**
 * @brief Convert a single dictionary to TSBOValueItem object
 * @chinese 将单个字典转换为TSBOValueItem对象
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
 * EN: Converted TSBOValueItem object, nil if conversion fails
 * CN: 转换后的TSBOValueItem对象，转换失败时返回nil
 */
+ (nullable TSBOValueItem *)boModelWithFwDict:(nullable NSDictionary *)dict;

/**
 * @brief Convert array of dictionaries to array of TSBOValueItem objects
 * @chinese 将字典数组转换为TSBOValueItem对象数组
 *
 * @param dictArray 
 * EN: Array of dictionaries containing blood oxygen data
 * CN: 包含血氧数据的字典数组
 *
 * @return 
 * EN: Array of converted TSBOValueItem objects, nil if conversion fails
 * CN: 转换后的TSBOValueItem对象数组，转换失败时返回nil
 */
+ (nullable NSArray<TSBOValueItem *> *)boModelsWithFwDictArray:(nullable NSArray<NSDictionary *> *)dictArray;


+ (nullable TSBOValueItem *)measureModelWithFwDict:(nullable NSDictionary *)valueInfo ;

/**
 * @brief Convert TSBOValueItem array to dictionary array for database insertion
 * @chinese 将TSBOValueItem数组转换为数据库插入用的字典数组
 *
 * @param boItems
 * EN: Array of TSBOValueItem objects to be converted
 * CN: 需要转换的TSBOValueItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSOxySaturationTable structure
 * CN: 字典数组，字段与TSOxySaturationTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromBOItems:(NSArray<TSBOValueItem *> *)boItems;

@end

NS_ASSUME_NONNULL_END
