//
//  TSAIImageGenerationStyle.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vendor-neutral image generation style
 * @chinese 厂商无关的图片生成风格
 */
@interface TSAIImageGenerationStyle : NSObject <NSCopying>

/** @brief Display name @chinese 展示名称 */
@property (nonatomic, copy, readonly) NSString *name;

/** @brief Stable style identifier passed to generation @chinese 传给生图任务的稳定风格标识 */
@property (nonatomic, copy, readonly) NSString *styleIdentifier;

/** @brief Optional style icon URL @chinese 可选的风格图标地址 */
@property (nonatomic, copy, readonly, nullable) NSURL *iconURL;

/**
 * @brief Create an image generation style
 * @chinese 创建图片生成风格
 *
 * @param name EN: Display name. CN: 展示名称。
 * @param styleIdentifier EN: Stable style identifier. CN: 稳定风格标识。
 * @param iconURL EN: Optional icon URL. CN: 可选图标地址。
 * @return EN: An immutable style. CN: 不可变风格对象。
 */
- (instancetype)initWithName:(NSString *)name
             styleIdentifier:(NSString *)styleIdentifier
                     iconURL:(nullable NSURL *)iconURL NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
