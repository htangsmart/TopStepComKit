//
//  TSRemindersModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/1.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSRemindersModel (Npk)

/**
 * @brief Convert TSRemindersModel to TSMetaRemindItem
 * @chinese 将 TSRemindersModel 转为 TSMetaRemindItem
 */
+ (nullable TSMetaRemindItem *)tsMetaItemWithModel:(nullable TSRemindersModel *)model;

/**
 * @brief Convert array of TSRemindersModel to TSMetaRemindList
 * @chinese 将 TSRemindersModel 数组转为 TSMetaRemindList
 */
+ (nullable TSMetaRemindList *)tsMetaListWithModels:(nullable NSArray<TSRemindersModel *> *)models;

/**
 * @brief Convert TSMetaRemindItem to TSRemindersModel
 * @chinese 将 TSMetaRemindItem 转为 TSRemindersModel
 */
+ (nullable TSRemindersModel *)modelWithTSMetaItem:(nullable TSMetaRemindItem *)item;

/**
 * @brief Convert TSMetaRemindList to array of TSRemindersModel
 * @chinese 将 TSMetaRemindList 转为 TSRemindersModel 数组
 */
+ (NSArray<TSRemindersModel *> *)modelsWithTSMetaList:(nullable TSMetaRemindList *)list;

/**
 * @brief Create a custom reminder template with specified ID
 * @chinese 使用指定ID创建自定义提醒模板
 *
 * @param reminderId 
 * [EN]: The reminder ID to assign (must be >= 32)
 * [CN]: 要分配的提醒ID（必须 >= 32）
 *
 * @return
 * [EN]: A new reminder model with default values
 * [CN]: 带有默认值的新提醒模型
 */
+ (TSRemindersModel *)reminderTemplateWithId:(NSInteger)reminderId;

/**
 * @brief Find next available reminder ID from existing reminders
 * @chinese 从现有提醒中查找下一个可用的提醒ID
 *
 * @param reminders
 * [EN]: Array of existing reminders
 * [CN]: 现有提醒数组
 *
 * @return
 * [EN]: Next available reminder ID (>= 32), or -1 if no ID available
 * [CN]: 下一个可用的提醒ID（>= 32），如果没有可用ID则返回 -1
 *
 * @discussion
 * [EN]: This method scans existing reminders and finds the first available ID
 *       starting from 32. Returns -1 if all IDs are exhausted (theoretically impossible).
 * [CN]: 此方法扫描现有提醒并从32开始查找第一个可用ID。
 *       如果所有ID都已用完则返回-1（理论上不可能）。
 */
+ (NSInteger)nextAvailableReminderIdFromReminders:(NSArray<TSRemindersModel *> *)reminders;

@end

NS_ASSUME_NONNULL_END
