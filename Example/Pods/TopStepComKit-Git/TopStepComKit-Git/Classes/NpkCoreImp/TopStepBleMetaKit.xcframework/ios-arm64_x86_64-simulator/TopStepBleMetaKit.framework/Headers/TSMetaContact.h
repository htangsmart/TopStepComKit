//
//  TSMetaContact.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaContact : TSBusinessBase

/**
 * @brief Get all normal contacts
 * @chinese 获取所有普通联系人
 *
 * @param completion 
 * EN: Completion callback with contact list and error information
 * CN: 完成回调，包含联系人列表与错误信息
 *
 * @discussion
 * [EN]: Retrieves the full list of regular contacts stored on the device.
 * [CN]: 获取设备上存储的普通联系人完整列表。
 */
+ (void)getAllNormalContacts:(void(^)(TSMetaContactList * _Nullable list, NSError * _Nullable error))completion;

/**
 * @brief Set normal contacts
 * @chinese 设置普通联系人列表
 *
 * @param list 
 * EN: Contact list to be written to the device
 * CN: 要写入设备的联系人列表
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态与错误信息
 *
 * @discussion
 * [EN]: Overwrites the device's regular contacts with the provided list.
 * [CN]: 使用传入列表覆盖设备上的普通联系人。
 */
+ (void)setNormalContacts:(TSMetaContactList *)list completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get emergency contacts
 * @chinese 获取紧急联系人列表
 *
 * @param completion 
 * EN: Completion callback with emergency contact list and error information
 * CN: 完成回调，包含紧急联系人列表与错误信息
 *
 * @discussion
 * [EN]: Retrieves the emergency contact configuration from the device.
 * [CN]: 获取设备上的紧急联系人配置。
 */
+ (void)getEmergencyContacts:(void(^)(TSMetaContactEmergencyList * _Nullable list, NSError * _Nullable error))completion;

/**
 * @brief Set emergency contacts
 * @chinese 设置紧急联系人列表
 *
 * @param list 
 * EN: Emergency contact configuration to be written to the device
 * CN: 要写入设备的紧急联系人配置
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态与错误信息
 *
 * @discussion
 * [EN]: Updates the device's emergency contact settings, including enable state and contacts.
 * [CN]: 更新设备的紧急联系人设置，包括启用状态与联系人列表。
 */
+ (void)setEmergencyContacts:(TSMetaContactEmergencyList *)list completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Register normal contacts change notification
 * @chinese 注册联系人变化监听
 *
 * @param completion 
 * EN: Completion callback with latest contact list and error when contacts change
 * CN: 完成回调，当联系人变化时返回最新联系人列表与错误信息
 *
 * @discussion
 * [EN]: Registers a notification to receive contact change events from the device.
 *       The completion block will be called whenever regular contacts change.
 * [CN]: 注册通知以接收来自设备的联系人变更事件。
 *       当普通联系人发生变化时，完成回调将被调用。
 */
+ (void)registerNormalContactsChanged:(void(^)(TSMetaContactList * _Nullable list, NSError * _Nullable error))completion;

/**
 * @brief Register emergency contacts change notification
 * @chinese 注册紧急联系人变化监听
 *
 * @param completion 
 * EN: Completion callback with latest emergency contact list and error when changes happen
 * CN: 完成回调，当紧急联系人变化时返回最新的紧急联系人列表与错误信息
 *
 * @discussion
 * [EN]: Registers a notification to receive emergency contact change events from the device.
 *       The completion block will be called whenever emergency contacts change.
 * [CN]: 注册通知以接收来自设备的紧急联系人变更事件。
 *       当紧急联系人发生变化时，完成回调将被调用。
 */
+ (void)registerEmergencyContactsChanged:(void(^)(TSMetaContactEmergencyList * _Nullable list, NSError * _Nullable error))completion;

/**
 * @brief Register device SOS request notification
 * @chinese 注册设备SOS请求监听
 *
 * @param completion 
 * EN: Completion callback when device triggers an SOS request
 *     - error: Error if registration or handling fails, nil otherwise
 * CN: 完成回调，当设备触发SOS请求时回调
 *     - error: 注册或处理失败时的错误，成功为nil
 *
 * @discussion
 * [EN]: Registers a notification to receive device SOS request events.
 *       The completion block will be called whenever the device requests SOS.
 * [CN]: 注册通知以接收设备的SOS请求事件。
 *       当设备发起SOS请求时，完成回调将被调用。
 */
 + (void)registerSOSRequest:(void(^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
