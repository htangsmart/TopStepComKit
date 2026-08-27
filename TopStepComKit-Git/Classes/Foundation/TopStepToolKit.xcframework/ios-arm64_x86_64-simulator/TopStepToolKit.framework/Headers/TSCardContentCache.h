//
//  TSCardContentCache.h
//  TopStepToolKit
//
//  Created by Codex on 2026/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local content cache for electronic cards.
 * @chinese 电子卡片内容本地缓存。
 */
@interface TSCardContentCache : NSObject

/**
 * @brief Gets all cached card contents in the specified user and device scope.
 * @chinese 获取指定用户和设备作用域内的全部卡片内容缓存。
 *
 * @param userId
 * [EN]: User identifier.
 * [CN]: 用户标识。
 * @param deviceIdentifier
 * [EN]: Device identifier, such as a MAC address.
 * [CN]: 设备标识，例如 MAC 地址。
 *
 * @return
 * [EN]: A dictionary whose keys are unified card type values and values are card contents.
 * [CN]: key 为统一卡片类型值、value 为卡片内容的字典。
 */
+ (NSDictionary<NSNumber *, NSString *> *)contentsForUserId:(NSString *)userId
                                           deviceIdentifier:(NSString *)deviceIdentifier;

/**
 * @brief Gets cached card hash values in the specified user and device scope.
 * @chinese 获取指定用户和设备作用域内的卡片哈希值缓存。
 *
 * @param userId User identifier. / 用户标识。
 * @param deviceIdentifier Device identifier. / 设备标识。
 * @return Hash values keyed by unified card type values. / 以统一卡片类型值为 key 的哈希值字典。
 */
+ (NSDictionary<NSNumber *, NSNumber *> *)hashValuesForUserId:(NSString *)userId
                                              deviceIdentifier:(NSString *)deviceIdentifier;

/**
 * @brief Caches content for a unified card type.
 * @chinese 缓存统一卡片类型对应的内容。
 *
 * @param content
 * [EN]: Card content to cache.
 * [CN]: 要缓存的卡片内容。
 * @param cardType
 * [EN]: Unified card type value.
 * [CN]: 统一卡片类型值。
 * @param userId
 * [EN]: User identifier.
 * [CN]: 用户标识。
 * @param deviceIdentifier
 * [EN]: Device identifier, such as a MAC address.
 * [CN]: 设备标识，例如 MAC 地址。
 */
+ (void)cacheContent:(NSString *)content
          forCardType:(NSInteger)cardType
               userId:(NSString *)userId
     deviceIdentifier:(NSString *)deviceIdentifier;

/**
 * @brief Caches card content and its hash value atomically.
 * @chinese 原子缓存卡片内容及其哈希值。
 *
 * @param content Card content. / 卡片内容。
 * @param hashValue Card content hash value. / 卡片内容哈希值。
 * @param cardType Unified card type value. / 统一卡片类型值。
 * @param userId User identifier. / 用户标识。
 * @param deviceIdentifier Device identifier. / 设备标识。
 */
+ (void)cacheContent:(NSString *)content
            hashValue:(int32_t)hashValue
          forCardType:(NSInteger)cardType
               userId:(NSString *)userId
     deviceIdentifier:(NSString *)deviceIdentifier;

@end

NS_ASSUME_NONNULL_END
