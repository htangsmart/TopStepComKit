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
 * @brief Get the maximum number of reminders supported by the device
 * @chinese 获取设备支持的最大提醒数量
 * 
 * @return 
 * [EN]: The maximum number of reminders that can be set on the device
 * [CN]: 设备上可以设置的最大提醒数量
 * 
 * @discussion 
 * [EN]: Different device models may support different maximum numbers of reminders.
 * [CN]: 不同的设备型号可能支持不同的最大提醒数量。
 */
- (NSInteger)supportMaxReminders;

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

@end

NS_ASSUME_NONNULL_END
