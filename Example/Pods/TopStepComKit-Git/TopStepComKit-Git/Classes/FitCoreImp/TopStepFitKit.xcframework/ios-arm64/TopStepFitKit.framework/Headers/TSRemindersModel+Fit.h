//
//  TSRemindersModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSRemindersModel (Fit)

/**
 * @brief Convert FitCloudPersonalizedReminderObject to TSRemindersModel
 * @chinese 将FitCloudPersonalizedReminderObject转换为TSRemindersModel
 *
 * @param fitReminder 
 * [EN]: FitCloud personalized reminder object to convert.
 * [CN]: 需要转换的FitCloud个性化提醒对象。
 *
 * @return 
 * [EN]: Converted TSRemindersModel object.
 * [CN]: 转换后的TSRemindersModel对象。
 */
+ (TSRemindersModel *)reminderModelWithFitReminder:(FitCloudPersonalizedReminderObject *)fitReminder;

/**
 * @brief Convert array of FitCloudPersonalizedReminderObject to array of TSRemindersModel
 * @chinese 将FitCloudPersonalizedReminderObject数组转换为TSRemindersModel数组
 *
 * @param fitReminders 
 * [EN]: Array of FitCloud personalized reminder objects to convert.
 * [CN]: 需要转换的FitCloud个性化提醒对象数组。
 *
 * @return 
 * [EN]: Array of converted TSRemindersModel objects.
 * [CN]: 转换后的TSRemindersModel对象数组。
 */
+ (NSArray<TSRemindersModel *> *)reminderModelsWithFitReminders:(NSArray<FitCloudPersonalizedReminderObject *> *)fitReminders;

/**
 * @brief Convert TSRemindersModel to FitCloudPersonalizedReminderObject
 * @chinese 将TSRemindersModel转换为FitCloudPersonalizedReminderObject
 *
 * @param reminderModel 
 * [EN]: TSRemindersModel object to convert.
 * [CN]: 需要转换的TSRemindersModel对象。
 *
 * @return 
 * [EN]: Converted FitCloudPersonalizedReminderObject.
 * [CN]: 转换后的FitCloudPersonalizedReminderObject。
 */
+ (FitCloudPersonalizedReminderObject *)fitReminderWithModel:(TSRemindersModel *)reminderModel;

/**
 * @brief Convert array of TSRemindersModel to array of FitCloudPersonalizedReminderObject
 * @chinese 将TSRemindersModel数组转换为FitCloudPersonalizedReminderObject数组
 *
 * @param reminderModels 
 * [EN]: Array of TSRemindersModel objects to convert.
 * [CN]: 需要转换的TSRemindersModel对象数组。
 *
 * @return 
 * [EN]: Array of converted FitCloudPersonalizedReminderObject objects.
 * [CN]: 转换后的FitCloudPersonalizedReminderObject对象数组。
 */
+ (NSArray<FitCloudPersonalizedReminderObject *> *)fitRemindersWithModels:(NSArray<TSRemindersModel *> *)reminderModels;

/**
 * @brief Convert FitCloudLSRObject  to TSRemindersModel
 * @chinese 将久坐提醒和勿扰设置转换为TSRemindersModel
 *
 * @param lsrObject 
 * [EN]: Long sitting reminder object to convert.
 * [CN]: 需要转换的久坐提醒对象。
 *
 * @return 
 * [EN]: Converted TSRemindersModel object with long sitting reminder
 * [CN]: 转换后的包含久坐提醒和勿扰设置的TSRemindersModel对象。
 */
+ (TSRemindersModel *)reminderModelWithLSRObject:(FitCloudLSRObject *)lsrObject;

/**
 * @brief Convert FitCloudDRObject to TSRemindersModel
 * @chinese 将喝水提醒转换为TSRemindersModel
 *
 * @param drObject 
 * [EN]: Drink reminder object to convert.
 * [CN]: 需要转换的喝水提醒对象。
 *
 * @return 
 * [EN]: Converted TSRemindersModel object with drink reminder
 * [CN]: 转换后的包含喝水提醒的TSRemindersModel对象。
 */
+ (TSRemindersModel *)reminderModelWithDRObject:(FitCloudDRObject *)drObject;

/**
 * @brief Convert TSRemindersModel to FitCloudLSRObject
 * @chinese 将TSRemindersModel转换为久坐提醒对象
 *
 * @param remindModel 
 * [EN]: TSRemindersModel object to convert to long sitting reminder.
 * [CN]: 需要转换为久坐提醒的TSRemindersModel对象。
 *
 * @return 
 * [EN]: Converted FitCloudLSRObject for long sitting reminder settings.
 * [CN]: 转换后的久坐提醒设置对象。
 */
+ (FitCloudLSRObject *)fitLSRRemindWithModel:(TSRemindersModel *)remindModel;

/**
 * @brief Convert TSRemindersModel to FitCloudDRObject
 * @chinese 将TSRemindersModel转换为喝水提醒对象
 *
 * @param remindModel 
 * [EN]: TSRemindersModel object to convert to drink reminder.
 * [CN]: 需要转换为喝水提醒的TSRemindersModel对象。
 *
 * @return 
 * [EN]: Converted FitCloudDRObject for drink reminder settings.
 * [CN]: 转换后的喝水提醒设置对象。
 */
+ (FitCloudDRObject *)fitDRRemindWithModel:(TSRemindersModel *)remindModel;


@end

NS_ASSUME_NONNULL_END
