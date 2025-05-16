//
//  TSContactInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/12.
//

#import "TSKitBaseInterface.h"
#import "TSContactModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Contact management interface
 * @chinese 通讯录管理接口
 * 
 * @discussion 
 * EN: This interface defines all operations related to device contacts, including:
 *     1. Reading and writing contacts
 *     2. Reading and writing emergency contacts
 *     3. Monitoring contact changes
 * CN: 该接口定义了与设备通讯录相关的所有操作，包括：
 *     1. 通讯录联系人的读写
 *     2. 紧急联系人的读写
 *     3. 通讯录变化的监听
 */
@protocol TSContactInterface <TSKitBaseInterface>

/**
 * @brief Get maximum number of contacts supported by the device
 * @chinese 获取设备支持的最大联系人数量
 * 
 * @return 
 * [EN]: The maximum number of contacts that can be stored on the device
 * [CN]: 设备可以存储的最大联系人数量
 * 
 * @discussion 
 * [EN]: This method returns the maximum number of contacts that can be stored on the device.
 * This limit varies by device model and firmware version.
 * Use this value to prevent exceeding the device's contact storage capacity.
 * 
 * [CN]: 此方法返回设备可以存储的最大联系人数量。
 * 此限制因设备型号和固件版本而异。
 * 使用此值可以防止超出设备的联系人存储容量。
 */
- (NSInteger)supportMaxContacts;

/**
 * @brief Get all contacts
 * @chinese 获取所有联系人
 * 
 * @param completion 
 * EN: Callback when fetching completes
 *     - allContacts: Array of all contacts, nil if failed
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - allContacts: 所有联系人数组，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Retrieve all saved contacts from the device
 * CN: 从设备获取所有已保存的联系人信息
 */
- (void)getAllContactsWithCompletion:(nullable void (^)(NSArray<TSContactModel *> *_Nullable allContacts,
                                                      NSError *_Nullable error))completion;

/**
 * @brief Set all contacts
 * @chinese 设置所有联系人
 * 
 * @param allContacts 
 * EN: Array of contacts to set
 * CN: 要设置的联系人数组
 *
 * @param completion
 * EN: Callback when setting completes
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Synchronize the contact list to the device, overwriting all existing contacts
 * CN: 将联系人列表同步到设备，会覆盖设备上已有的所有联系人
 */
- (void)setAllContacts:(NSArray<TSContactModel *> *_Nullable)allContacts
            completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Get maximum number of emergency contacts supported by the device
 * @chinese 获取设备支持的最大紧急联系人数量
 * 
 * @return 
 * [EN]: The maximum number of emergency contacts that can be stored on the device
 * [CN]: 设备可以存储的最大紧急联系人数量
 * 
 * @discussion 
 * [EN]: This method returns the maximum number of emergency contacts that can be stored on the device.
 * This limit varies by device model and firmware version.
 * Use this value to prevent exceeding the device's emergency contact storage capacity.
 * 
 * [CN]: 此方法返回设备可以存储的最大紧急联系人数量。
 * 此限制因设备型号和固件版本而异。
 * 使用此值可以防止超出设备的紧急联系人存储容量。
 */
- (NSInteger)supportMaxEmergencyContacts;

/**
 * @brief Get emergency contact
 * @chinese 获取紧急联系人
 * 
 * @param completion 
 * EN: Callback when fetching completes
 *     - emergencyContact: Emergency contact, nil if failed
 *     - error: Error information if failed, nil if successful
 *     - isSosOn Whether to turn on the emergency contact switch
 * CN: 获取完成的回调
 *     - emergencyContact: 紧急联系人，获取失败时为nil
 *     - error: 获取失败时的错误信息，成功时为nil
 *     - isSosOn: 是否打开紧急联系人
 * @discussion 
 * EN: Retrieve the emergency contact information from the device
 * CN: 从设备获取已设置的紧急联系人信息
 */
- (void)getEmergencyContactWithCompletion:(nullable void (^)(NSArray<TSContactModel *> *_Nullable emergencyContact, BOOL isSosOn,
                                                           NSError *_Nullable error))completion;

/**
 * @brief Set emergency contact
 * @chinese 设置紧急联系人
 * 
 * @param emergencyContacts 
 * EN: Emergency contacts to set (multiple allowed)
 * CN: 要设置的紧急联系人（可多个）
 *
 * @param isSosOn
 * EN: Whether to turn on the emergency contact switch
 * CN: 是否打开紧急联系人

 * @param completion
 * EN: Callback when setting completes
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Synchronize the emergency contact information to the device
 * CN: 将紧急联系人信息同步到设备
 */
- (void)setEmergencyContacts:(NSArray<TSContactModel *> *_Nullable)emergencyContacts
                       sosOn:(BOOL)isSosOn
                completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Register contact change listener
 * @chinese 注册通讯录变化监听
 * 
 * @param completion 
 * EN: Callback when contacts change
 *     - allContacts: Updated array of all contacts
 *     - error: Error information if failed, nil if successful
 * CN: 通讯录变化时的回调
 *     - allContacts: 更新后的所有联系人数组
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This callback will be triggered when the device contacts change
 * CN: 当设备端通讯录发生变化时，此回调会被触发
 */
- (void)registerContactsDidChangedBlock:(nullable void (^)(NSArray<TSContactModel *> *allContacts,NSError *error))completion;

/**
 * @brief Register emergency contact change listener
 * @chinese 注册紧急联系人变化监听
 * 
 * @param completion 
 * EN: Callback when emergency contacts change
 *     - allContacts: Updated array of emergency contacts
 *     - error: Error information if failed, nil if successful
 * CN: 紧急联系人变化时的回调
 *     - allContacts: 更新后的紧急联系人数组
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This callback will be triggered when the device emergency contacts change.
 *     Note: Some devices may not support this feature, in which case an error will be returned.
 * CN: 当设备端紧急联系人发生变化时，此回调会被触发。
 *     注意：部分设备可能不支持此功能，此时会返回相应的错误信息。
 */
- (void)registerEmergencyContactsDidChangedBlock:(nullable void (^)(NSArray<TSContactModel *> *allContacts,NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
