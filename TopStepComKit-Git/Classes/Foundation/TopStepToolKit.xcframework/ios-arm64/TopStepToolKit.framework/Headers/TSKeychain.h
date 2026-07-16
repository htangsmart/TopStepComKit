//
//  TSKeychain.h
//  TopStepToolKit
//
//  Created by 磐石 on 2026/1/29.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kTSKeychainService;

typedef void(^TSKeychainSaveCompletion)(BOOL isSuccess, NSError * _Nullable error);
typedef void(^TSKeychainQueryCompletion)(NSString * _Nullable uuidString, NSError * _Nullable error);
typedef void(^TSKeychainQueryMapCompletion)(NSDictionary<NSString *, NSString *> * _Nullable macUuidMap, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface TSKeychain : NSObject

/**
 * @brief Query the MAC-UUID dictionary from Keychain
 * @chinese 查询Keychain中保存的MAC与UUID字典
 *
 * @param completion
 * EN: Callback with MAC->UUID dictionary if found
 * CN: 查询回调，返回MAC->UUID字典（若存在）
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)queryBleUuidMapCompletion:(TSKeychainQueryMapCompletion)completion;

/**
 * @brief Save the MAC-UUID dictionary into Keychain
 * @chinese 保存MAC与UUID字典到Keychain
 *
 * @param macUuidMap
 * EN: Dictionary with MAC as key and UUID as value
 * CN: 以MAC为key、UUID为value的字典
 *
 * @param completion
 * EN: Callback for save result
 * CN: 保存结果回调
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)saveBleUuidMap:(NSDictionary<NSString *, NSString *> *)macUuidMap
            completion:(TSKeychainSaveCompletion)completion;

/**
 * @brief Query BLE UUID by MAC address from the Keychain map
 * @chinese 通过MAC地址从Keychain字典中查询UUID
 *
 * @param mac
 * EN: Device MAC address used as the lookup key
 * CN: 设备MAC地址，用作查询主键
 *
 * @param completion
 * EN: Callback with UUID string if found
 * CN: 查询回调，返回UUID字符串（若存在）
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)queryBleUuidForMac:(NSString *)mac
                completion:(TSKeychainQueryCompletion)completion;

/**
 * @brief Save BLE UUID for a MAC address into the Keychain map
 * @chinese 将MAC与UUID保存到Keychain字典中
 *
 * @param mac
 * EN: Device MAC address used as the lookup key
 * CN: 设备MAC地址，用作查询主键
 *
 * @param uuidString
 * EN: BLE UUID string to be saved
 * CN: 需要保存的BLE UUID字符串
 *
 * @param completion
 * EN: Callback for save result
 * CN: 保存结果回调
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)saveBleUuid:(NSString *)uuidString
             forMac:(NSString *)mac
         completion:(TSKeychainSaveCompletion)completion;

/**
 * @brief Remove BLE UUID by MAC address from the Keychain map
 * @chinese 通过MAC地址从Keychain字典中删除UUID
 *
 * @param mac
 * EN: Device MAC address used as the lookup key
 * CN: 设备MAC地址，用作删除主键
 *
 * @param completion
 * EN: Callback for remove result
 * CN: 删除结果回调
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)removeBleUuidForMac:(NSString *)mac
                 completion:(TSKeychainSaveCompletion)completion;

/**
 * @brief Clear the whole MAC-UUID map in Keychain
 * @chinese 清空Keychain中保存的MAC与UUID字典
 *
 * @param completion
 * EN: Callback for clear result
 * CN: 清空结果回调
 *
 * @return
 * EN: None
 * CN: 无
 */
+ (void)clearBleUuidMapWithCompletion:(TSKeychainSaveCompletion)completion;

@end

NS_ASSUME_NONNULL_END
