//
//  TSSleepDetailItem+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/12/10.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSleepDetailItem (Fw)

/**
 * @brief Convert TSSleepDetailItem array to dictionary array for database insertion
 * @chinese 将TSSleepDetailItem数组转换为数据库插入用的字典数组
 *
 * @param sleepItems
 * EN: Array of TSSleepDetailItem objects to be converted
 * CN: 需要转换的TSSleepDetailItem对象数组
 *
 * @return
 * EN: Array of dictionaries with fields matching TSSleepTable structure
 * CN: 字典数组，字段与TSSleepTable结构保持一致
 */
+ (NSArray<NSDictionary *> *)dictionaryArrayFromSleepItems:(NSArray<TSSleepDetailItem *> *)sleepItems;

@end

NS_ASSUME_NONNULL_END
