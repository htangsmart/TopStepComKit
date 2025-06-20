//
//  TSRemindersModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMReminderModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSRemindersModel (SJ)

/**
 * @brief Convert TSRemindersModel to WMReminderModel
 * @chinese 将TSRemindersModel转换为WMReminderModel
 *
 * @param tsModel 
 * EN: TSRemindersModel object to be converted
 * CN: 需要转换的TSRemindersModel对象
 *
 * @return 
 * EN: Converted WMReminderModel object, nil if conversion fails
 * CN: 转换后的WMReminderModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts TSRemindersModel to WMReminderModel:
 *     - Converts time range (start and end time)
 *     - Maps interval to frequency
 *     - Sets up no-disturb settings
 *     - Preserves enabled status
 * CN: 该方法将TSRemindersModel转换为WMReminderModel：
 *     - 转换时间范围（开始和结束时间）
 *     - 将时间间隔映射为频率
 *     - 设置免打扰配置
 *     - 保持启用状态
 */
+ (nullable WMReminderModel *)wmModelWithTSRemindersModel:(nullable TSRemindersModel *)tsModel;

/**
 * @brief Convert WMReminderModel to TSRemindersModel
 * @chinese 将WMReminderModel转换为TSRemindersModel
 *
 * @param wmModel 
 * EN: WMReminderModel object to be converted
 * CN: 需要转换的WMReminderModel对象
 *
 * @return 
 * EN: Converted TSRemindersModel object, nil if conversion fails
 * CN: 转换后的TSRemindersModel对象，转换失败时返回nil
 *
 * @discussion
 * EN: This method converts WMReminderModel to TSRemindersModel:
 *     - Converts time range to start and end time
 *     - Maps frequency to interval
 *     - Sets up no-disturb settings
 *     - Preserves enabled status
 * CN: 该方法将WMReminderModel转换为TSRemindersModel：
 *     - 将时间范围转换为开始和结束时间
 *     - 将频率映射为时间间隔
 *     - 设置免打扰配置
 *     - 保持启用状态
 */
+ (nullable TSRemindersModel *)modelWithWMReminderModel:(nullable WMReminderModel *)wmModel;

@end

NS_ASSUME_NONNULL_END
