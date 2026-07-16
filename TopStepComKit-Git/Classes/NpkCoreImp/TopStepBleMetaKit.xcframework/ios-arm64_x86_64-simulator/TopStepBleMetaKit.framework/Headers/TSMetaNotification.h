//
//  TSMetaNotification.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbConfigParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Get notification list completion callback
 * @chinese 获取通知列表完成回调
 * 
 * @discussion 
 * EN: Completion callback for getting notification list
 * CN: 获取通知列表的完成回调
 */
typedef void (^TSMetaNotificationListCompletion)(BOOL isSuccess, TSMetaNotificationModel * _Nullable notificationModel, NSError * _Nullable error);

@interface TSMetaNotification : TSBusinessBase

/**
 * @brief Get notification list
 * @chinese 获取消息通知列表
 * 
 * @param completion 
 * EN: Completion callback that returns the notification list
 * CN: 完成回调，返回通知列表
 * 
 * @discussion 
 * EN: Retrieves the current notification list from the peripheral device.
 *      The completion block will be called with the result and notification model.
 * CN: 从外设设备获取当前的通知列表。
 *      完成回调会返回结果和通知模型。
 */
+ (void)getNotificationList:(nullable TSMetaNotificationListCompletion)completion;

/**
 * @brief Set notification list
 * @chinese 设置消息通知列表
 * 
 * @param notificationModel 
 * EN: The notification model to set
 * CN: 要设置的通知模型
 * 
 * @param completion 
 * EN: Completion callback when operation is completed
 * CN: 操作完成的回调
 * 
 * @discussion 
 * EN: Sets the notification list on the peripheral device.
 *      The completion block will be called with the operation result.
 * CN: 在外设设备上设置通知列表。
 *      完成回调会返回操作结果。
 */
+ (void)setNotificationList:(TSMetaNotificationModel *)notificationModel completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Register notification change event
 * @chinese 注册消息提醒变化通知
 *
 * @param changed
 * EN: Callback invoked when device reports notification settings changed; returns current model and optional error.
 * CN: 当设备上报消息提醒配置变化时回调；返回当前模型及可选错误。
 *
 * @discussion
 * EN: Use this to subscribe to device "notification changed" events (e.g., key eDeviceNotificationChanged) and keep UI/data in sync.
 * CN: 用于订阅设备“消息提醒变化”事件（如键值 eDeviceNotificationChanged），以保持界面/数据同步。
 */
+ (void)registerNotificationDidChanged:(nullable TSMetaNotificationListCompletion)completion;

@end

NS_ASSUME_NONNULL_END
