//
//  TSAIImageGenerationConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vendor-neutral image generation configuration
 * @chinese 厂商无关的图片生成配置
 */
@interface TSAIImageGenerationConfig : NSObject <NSCopying>

/**
 * @brief Optional style identifier returned by style discovery
 * @chinese 风格查询返回的可选风格标识
 *
 * @discussion
 * [EN]: Nil or an empty value leaves the style unspecified; the active Provider determines the behavior.
 * [CN]: nil 或空值表示不指定风格，具体行为由当前 Provider 决定。
 */
@property (nonatomic, copy, nullable) NSString *styleIdentifier;

/** @brief Number of images requested @chinese 请求生成的图片数量 */
@property (nonatomic, assign) NSInteger imageCount;

/** @brief Requested image pixel size @chinese 请求的图片像素尺寸 */
@property (nonatomic, assign) CGSize imageSize;

/**
 * @brief Prompt language context
 * @chinese 提示词语言上下文
 *
 * @discussion
 * [EN]: Unknown uses the current App localization. Auto is invalid.
 * [CN]: Unknown 使用当前 App 本地化语言；Auto 为非法值。
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Create an image generation configuration
 * @chinese 创建图片生成配置
 *
 * @param styleIdentifier EN: Optional discovered style identifier. CN: 可选的已发现风格标识。
 * @param imageSize EN: Requested pixel size. CN: 请求的像素尺寸。
 * @return EN: A configuration requesting one image. CN: 默认请求一张图片的配置。
 */
+ (instancetype)configWithStyleIdentifier:(nullable NSString *)styleIdentifier
                                imageSize:(CGSize)imageSize;

@end

NS_ASSUME_NONNULL_END
