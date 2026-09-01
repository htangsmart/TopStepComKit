//
//  TSDeviceBindingStore.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import <Foundation/Foundation.h>

#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persisted device binding record
 * @chinese 持久化设备绑定记录
 */
@interface TSDeviceBindingRecord : NSObject

/** @brief Record schema version @chinese 记录结构版本 */
@property (nonatomic, assign) NSUInteger schemaVersion;
/** @brief SDK type owning the binding @chinese 绑定所属 SDK 类型 */
@property (nonatomic, assign) TSSDKType sdkType;
/** @brief Bound device MAC address @chinese 绑定设备 MAC 地址 */
@property (nonatomic, copy) NSString *macAddress;
/** @brief Bound user identifier @chinese 绑定用户标识 */
@property (nonatomic, copy) NSString *userIdentifier;

@end

/**
 * @brief Example-owned device binding storage
 * @chinese Example 自有的设备绑定存储
 */
@interface TSDeviceBindingStore : NSObject

/**
 * @brief Return the current valid binding record
 * @chinese 返回当前有效绑定记录
 *
 * @return EN: Binding record or nil. CN: 绑定记录；不存在时返回 nil。
 */
- (nullable TSDeviceBindingRecord *)bindingRecord;

/**
 * @brief Save a valid binding record
 * @chinese 保存有效绑定记录
 *
 * @param record EN: Binding record. CN: 绑定记录。
 */
- (void)saveBindingRecord:(TSDeviceBindingRecord *)record;

/**
 * @brief Remove new and legacy binding fields
 * @chinese 删除新旧绑定字段
 */
- (void)clearBindingRecord;

@end

NS_ASSUME_NONNULL_END
