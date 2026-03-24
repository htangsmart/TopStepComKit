//
//  TSRemindersInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/21.
//

#import "TSKitBaseInterface.h"
#import "TSRemindersModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSRemindersInterface <TSKitBaseInterface>

/**
 * @brief Get the maximum number of custome reminders supported by the device
 * @chinese 获取设备支持的最大自定义提醒数量
 *
 * @return
 * [EN]: The maximum number of custome reminders that can be set on the device
 * [CN]: 设备上可以设置的最大自定义提醒数量
 *
 * @discussion
 * [EN]: Different device models may support different maximum numbers of custome reminders.
 * [CN]: 不同的设备型号可能支持不同的最大自定义提醒数量。
 */
- (NSInteger)supportMaxCustomeReminders;

/**
 * @brief Create a custom reminder template (Recommended)
 * @chinese 创建自定义提醒模板（推荐使用）
 *
 * @param completion
 * [EN]: Completion callback, returns a ready-to-use custom reminder model with error information.
 * [中文]: 完成回调，返回一个可用的自定义提醒模型和错误信息。
 *
 * @discussion
 * [EN]: This is the RECOMMENDED way to create custom reminders.
 *       The method automatically:
 *       - Assigns a valid unique ID for the custom reminder
 *       - Sets appropriate default values
 *       - Ensures compatibility across different device platforms
 *
 *       After receiving the reminder model, you can:
 *       1. Modify its properties (name, time, repeat days, etc.)
 *       2. Call updateReminder to save it to the device
 *
 * [中文]: 这是创建自定义提醒的推荐方式。
 *       此方法会自动：
 *       - 为自定义提醒分配一个有效的唯一ID
 *       - 设置合适的默认值
 *       - 确保在不同设备平台的兼容性
 *
 *       收到提醒模型后，您可以：
 *       1. 修改其属性（名称、时间、重复日期等）
 *       2. 调用updateReminder将其保存到设备
 *
 * @note
 * [EN]: Always use this method to create custom reminders instead of manually assigning IDs.
 * [中文]: 始终使用此方法创建自定义提醒，而不是手动分配ID。
 */
- (void)createCustomReminderTemplateWithCompletion:(void (^)(TSRemindersModel * _Nullable reminder, NSError * _Nullable error))completion;

/**
 * @brief Get all reminder settings
 * @chinese 获取所有提醒设置
 *
 * @param completion
 * [EN]: Completion callback returns an array of reminder objects.
 * [中文]: 完成回调返回提醒对象数组。
 *
 * @discussion
 * [EN]: Operation to get all reminder settings, returning an array of reminder objects.
 * [中文]: 获取所有提醒设置的操作，返回提醒对象数组。
 */
- (void)getAllRemindersWithCompletion:(void (^)(NSArray<TSRemindersModel *> *reminders ,NSError * _Nullable error))completion;

/**
 * @brief Set reminder settings
 * @chinese 设置提醒设置
 *
 * @param reminders
 * [EN]: An array of reminder objects.
 * [中文]: 提醒对象数组。
 *
 * @param completion
 * [EN]: Completion callback, returns success status.
 * [中文]: 完成回调，返回是否成功。
 *
 * @discussion
 * [EN]: Operation to set reminders, returning success status.
 * [中文]: 设置提醒的操作，返回是否成功。
 */
- (void)setReminders:(NSArray<TSRemindersModel *> *)reminders completion:(TSCompletionBlock)completion;

/**
 * @brief Update reminder by ID
 * @chinese 根据提醒ID更新提醒
 *
 * @param reminder
 * [EN]: Reminder model containing the updated information.
 * [中文]: 包含更新信息的提醒模型。
 *
 * @param completion
 * [EN]: Completion callback, returns success status and error information.
 * [中文]: 完成回调，返回是否成功和错误信息。
 *
 * @discussion
 * [EN]: Upsert behavior: If a reminder with the specified reminderId exists it will be updated;
 *       if it does not exist it will be added automatically (subject to device limits).
 * [中文]: 具备"插入或更新"语义：当指定 reminderId 的提醒存在时将被更新；
 *       当不存在时将自动新增（受设备数量上限约束）。
 *
 * @note
 * [EN]:  1. The reminder model must have a valid reminderId
 *        2. All properties in the model will be updated to the device
 *        3. Built-in reminders can be updated but not deleted
 *        4. Custom reminders can be fully updated
 *        5. If not found, a new reminder will be created (upsert)
 * [中文]: 1. 提醒模型必须具有有效的 reminderId
 *        2. 模型中的所有属性都将更新到设备
 *        3. 内置提醒可以更新但不能删除
 *        4. 自定义提醒可以完全更新
 *        5. 若未找到同 ID 提醒，则会自动新增（upsert）
 */
- (void)updateReminder:(TSRemindersModel *)reminder completion:(TSCompletionBlock)completion;

/**
 * @brief Delete reminder by ID
 * @chinese 根据提醒ID删除提醒
 *
 * @param reminderId
 * [EN]: Unique identifier of the reminder to delete.
 * [中文]: 要删除的提醒的唯一标识符。
 *
 * @param completion
 * [EN]: Completion callback, returns success status and error information.
 * [中文]: 完成回调，返回是否成功和错误信息。
 *
 * @discussion
 * [EN]: This method deletes a specific reminder from the device based on its unique identifier.
 *       The reminder will be permanently removed from the device's reminder list.
 *       If the reminder ID does not exist, the operation will fail with an appropriate error.
 * [中文]: 此方法根据唯一标识符从设备中删除特定的提醒。
 *       提醒将从设备的提醒列表中永久删除。
 *       如果提醒ID不存在，操作将失败并返回相应的错误。
 *
 * @note
 * [EN]: 1. Built-in reminders cannot be deleted, only disabled
 *       2. Only custom reminders can be permanently deleted
 * [中文]: 1. 内置提醒无法删除，只能禁用
 *       2. 只有自定义提醒可以永久删除
 */
- (void)deleteReminderWithId:(NSString *)reminderId completion:(TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
