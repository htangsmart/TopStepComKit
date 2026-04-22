//
//  TSDoNotDisturbModel+Fw.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDoNotDisturbModel (Fw)

/**
 * @brief Convert TSLunchBreakDNDModel to NSDictionary
 * @chinese 将TSLunchBreakDNDModel转换为NSDictionary
 * 
 * @return 
 * EN: NSDictionary containing DND settings
 * CN: 包含免打扰设置的NSDictionary
 * 
 * @discussion
 * EN: Converts the model to a dictionary with the following structure:
 *     {
 *         isEnabledAllDay: true,  // All day DND enabled
 *         isEnabledPeriod: true,  // Period DND enabled
 *         periodStart: 600,       // Start time in minutes
 *         periodEnd: 900         // End time in minutes
 *     }
 * CN: 将模型转换为具有以下结构的字典：
 *     {
 *         isEnabledAllDay: true,  // 全天免打扰是否启用
 *         isEnabledPeriod: true,  // 时段免打扰是否启用
 *         periodStart: 600,       // 开始时间（分钟）
 *         periodEnd: 900         // 结束时间（分钟）
 *     }
 */
- (NSDictionary *)toDictionary;

/**
 * @brief Convert NSDictionary to TSLunchBreakDNDModel
 * @chinese 将NSDictionary转换为TSLunchBreakDNDModel
 * 
 * @param dictionary 
 * EN: NSDictionary containing DND settings
 * CN: 包含免打扰设置的NSDictionary
 * 
 * @return 
 * EN: Converted TSLunchBreakDNDModel object
 * CN: 转换后的TSLunchBreakDNDModel对象
 * 
 * @discussion
 * EN: Converts a dictionary with the following structure to model:
 *     {
 *         isEnabledAllDay: true,  // All day DND enabled
 *         isEnabledPeriod: true,  // Period DND enabled
 *         periodStart: 600,       // Start time in minutes
 *         periodEnd: 900         // End time in minutes
 *     }
 * CN: 将具有以下结构的字典转换为模型：
 *     {
 *         isEnabledAllDay: true,  // 全天免打扰是否启用
 *         isEnabledPeriod: true,  // 时段免打扰是否启用
 *         periodStart: 600,       // 开始时间（分钟）
 *         periodEnd: 900         // 结束时间（分钟）
 *     }
 */
+ (TSDoNotDisturbModel *)modelWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
