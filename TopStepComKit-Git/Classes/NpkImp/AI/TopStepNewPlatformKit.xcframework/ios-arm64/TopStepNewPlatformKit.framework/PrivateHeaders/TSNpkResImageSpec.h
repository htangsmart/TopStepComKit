//
//  TSNpkResImageSpec.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One entry of the res.bin image replacement plan
 * @chinese res.bin 图片替换计划中的一项
 *
 * @discussion
 * [EN]: Pure model. An entry either replaces/adds the image at tableIndex, or removes it.
 * [CN]: 纯数据模型。一项要么替换/新增 tableIndex 处的图片，要么移除它。
 */
@interface TSNpkResImageSpec : NSObject

/** @brief Index in the image table (0 is the preview) @chinese 图片索引表下标（0 固定为预览图） */
@property (nonatomic, assign, readonly) NSUInteger tableIndex;
/** @brief Image to write; nil when removing @chinese 要写入的图片；移除时为 nil */
@property (nonatomic, strong, readonly, nullable) UIImage *image;
/** @brief Target size in pixels @chinese 目标像素尺寸 */
@property (nonatomic, assign, readonly) CGSize pixelSize;
/** @brief Whether the image keeps an alpha channel @chinese 是否保留透明通道 */
@property (nonatomic, assign, readonly) BOOL hasAlpha;
/** @brief YES when this entry removes the image @chinese 为 YES 表示移除该图片 */
@property (nonatomic, assign, readonly) BOOL isRemoval;

/**
 * @brief Create an entry that replaces or adds an image
 * @chinese 创建"替换或新增图片"的计划项
 */
+ (instancetype)specWithTableIndex:(NSUInteger)tableIndex
                             image:(UIImage *)image
                         pixelSize:(CGSize)pixelSize
                          hasAlpha:(BOOL)hasAlpha;

/**
 * @brief Create an entry that removes an image
 * @chinese 创建"移除图片"的计划项
 */
+ (instancetype)removalSpecWithTableIndex:(NSUInteger)tableIndex;

@end

NS_ASSUME_NONNULL_END
