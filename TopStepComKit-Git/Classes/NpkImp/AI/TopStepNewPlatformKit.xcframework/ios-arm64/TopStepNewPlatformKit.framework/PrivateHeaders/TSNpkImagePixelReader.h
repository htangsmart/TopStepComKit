//
//  TSNpkImagePixelReader.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Converts a UIImage to RGBA bytes at an exact pixel size
 * @chinese 把 UIImage 按指定像素尺寸转换为 RGBA 字节
 *
 * @discussion
 * [EN]: Works in pixels, never in points, so @2x/@3x images are handled correctly. The image is scaled to the
 *       requested pixel size when it differs. Output is RGBA8888, alpha-premultiplied, row 0 at the top.
 * [CN]: 全程按像素而不是 point 计算，2 倍图、3 倍图也能得到正确尺寸。图片像素尺寸与目标不同时会缩放到目标尺寸。
 *       输出为 RGBA8888、预乘 alpha、首行为图片顶部。
 */
@interface TSNpkImagePixelReader : NSObject

/**
 * @brief Pixel size of an image (size multiplied by scale)
 * @chinese 图片的像素尺寸（size 乘以 scale）
 */
+ (CGSize)pixelSizeOfImage:(UIImage *)image;

/**
 * @brief Read premultiplied RGBA bytes at the given pixel size
 * @chinese 按给定像素尺寸读取预乘 RGBA 字节
 *
 * @param image EN: Source image. CN: 源图片。
 * @param pixelSize EN: Target size in pixels, both sides positive. CN: 目标像素尺寸，宽高均需大于 0。
 * @param error EN: Failure reason. CN: 失败原因。
 * @return EN: width*height*4 bytes, or nil on failure. CN: 宽*高*4 字节数据，失败返回 nil。
 */
+ (nullable NSData *)premultipliedRGBADataFromImage:(UIImage *)image
                                          pixelSize:(CGSize)pixelSize
                                              error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
