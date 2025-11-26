//
//  TSContactModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSContactModel (Npk)

/**
 * @brief Convert TSContactModel to TSMetaContactItem
 * @chinese 将 TSContactModel 转为 TSMetaContactItem
 */
+ (nullable TSMetaContactItem *)tsMetaItemWithModel:(nullable TSContactModel *)model;

/**
 * @brief Convert TSMetaContactItem to TSContactModel
 * @chinese 将 TSMetaContactItem 转为 TSContactModel
 */
+ (nullable TSContactModel *)modelWithTSMetaItem:(nullable TSMetaContactItem *)item;

/**
 * @brief Convert array of TSContactModel to TSMetaContactList
 * @chinese 将 TSContactModel 数组转为 TSMetaContactList
 */
+ (nullable TSMetaContactList *)tsMetaListWithModels:(nullable NSArray<TSContactModel *> *)models;

/**
 * @brief Convert TSMetaContactList to array of TSContactModel
 * @chinese 将 TSMetaContactList 转为 TSContactModel 数组
 */
+ (NSArray<TSContactModel *> *)modelsWithTSMetaList:(nullable TSMetaContactList *)list;

/**
 * @brief Build TSMetaContactEmergencyList from TSContactModel array and enable flag
 * @chinese 由 TSContactModel 数组与启用标志构建 TSMetaContactEmergencyList
 */
+ (nullable TSMetaContactEmergencyList *)tsMetaEmergencyListWithModels:(nullable NSArray<TSContactModel *> *)models
                                                                enable:(BOOL)enable;

/**
 * @brief Convert TSMetaContactEmergencyList to array of TSContactModel
 * @chinese 将 TSMetaContactEmergencyList 转为 TSContactModel 数组
 */
+ (NSArray<TSContactModel *> *)modelsWithTSMetaEmergencyList:(nullable TSMetaContactEmergencyList *)list;

/**
 * @brief Check if emergency contacts array has errors
 * @chinese 检查紧急联系人数组是否有错误
 *
 * @param emergencyContacts
 * [EN]: Array of emergency contact models to validate.
 *       Each contact will be checked for validation errors.
 * [CN]: 要验证的紧急联系人模型数组。
 *       将检查每个联系人的验证错误。
 *
 * @return
 * [EN]: Returns NSError object if any contact has validation errors, nil if all are valid.
 *       Returns nil if the array is nil or empty.
 * [CN]: 如果任何联系人存在验证错误则返回 NSError 对象，所有联系人都有效则返回 nil。
 *       如果数组为 nil 或为空则返回 nil。
 *
 * @discussion
 * [EN]: This method validates an array of emergency contacts by checking each individual contact.
 *       The validation stops at the first error found to improve performance.
 *       Each contact is validated using the doesModelHasError method.
 * [CN]: 此方法通过检查每个单独的联系人来验证紧急联系人数组。
 *       验证在发现第一个错误时停止，以提高性能。
 *       每个联系人使用 doesModelHasError 方法进行验证。
 */
+ (NSError *_Nullable)doesEmergencyContactsHasError:(nullable NSArray<TSContactModel *> *)emergencyContacts;

/**
 * @brief Check if contacts array has errors
 * @chinese 检查联系人数组是否有错误
 *
 * @param contacts
 * [EN]: Array of contact models to validate.
 *       Each contact will be checked for validation errors.
 * [CN]: 要验证的联系人模型数组。
 *       将检查每个联系人的验证错误。
 *
 * @return
 * [EN]: Returns NSError object if any contact has validation errors, nil if all are valid.
 *       Returns nil if the array is nil or empty.
 * [CN]: 如果任何联系人存在验证错误则返回 NSError 对象，所有联系人都有效则返回 nil。
 *       如果数组为 nil 或为空则返回 nil。
 *
 * @discussion
 * [EN]: This method validates an array of contacts by checking each individual contact.
 *       The validation stops at the first error found to improve performance.
 *       Each contact is validated using the doesModelHasError method.
 *       This is useful for batch validation before setting multiple contacts.
 * [CN]: 此方法通过检查每个单独的联系人来验证联系人数组。
 *       验证在发现第一个错误时停止，以提高性能。
 *       每个联系人使用 doesModelHasError 方法进行验证。
 *       此方法在设置多个联系人之前进行批量验证时很有用。
 */
+ (NSError *_Nullable)doesContactsHasError:(nullable NSArray<TSContactModel *> *)contacts;

/**
 * @brief Process contacts array to fix validation errors
 * @chinese 处理联系人数组以修复验证错误
 *
 * @param contacts
 * [EN]: Array of contact models to process.
 *       Each contact will be checked and adjusted if needed.
 * [CN]: 要处理的联系人模型数组。
 *       将检查并调整每个联系人（如有需要）。
 *
 * @return
 * [EN]: Array of processed contact models with adjusted fields.
 *       Returns empty array if input is nil or empty.
 * [CN]: 处理后的联系人模型数组，字段已调整。
 *       如果输入为nil或空则返回空数组。
 *
 * @discussion
 * [EN]: This method automatically adjusts contacts that exceed byte length limits:
 *       1. If name exceeds 31 bytes, it will be truncated to fit within 31 bytes
 *       2. If phoneNum exceeds 31 bytes, it will be truncated to fit within 31 bytes
 *       The truncation preserves UTF-8 character boundaries to avoid corruption.
 *       This method modifies the contact objects in place and returns the same array.
 * [CN]: 此方法自动调整超出字节长度限制的联系人：
 *       1. 如果姓名超过31字节，将被截取以适应31字节内
 *       2. 如果电话号码超过31字节，将被截取以适应31字节内
 *       截取操作会保留UTF-8字符边界以避免损坏。
 *       此方法直接修改联系人对象并返回同一数组。
 */
+ (NSArray<TSContactModel *> *)processContacts:(nullable NSArray<TSContactModel *> *)contacts;

@end

NS_ASSUME_NONNULL_END
