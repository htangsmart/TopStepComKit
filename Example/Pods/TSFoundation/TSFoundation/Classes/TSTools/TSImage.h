
//
//  TSImage.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSImage : NSObject

/*
 * @brief 压缩图片
 *
 * @param sourceImage 原图
 * @param maxImageSize 压缩后尺寸
 * @param maxSize 压缩有大小
 */
+ (UIImage *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGSize)maxImageSize maxSizeWithKB:(CGFloat) maxSize;

/*
 * @brief 根据scale压缩图
 *
 * @param oriImage 原图
 * @param imageSize 压缩后尺寸
 * @param scale 压缩比例
 */
+ (UIImage*)reSizeImageWithOriImage:(UIImage*)oriImage toImageSize:(CGSize)imageSize scale:(CGFloat)scale;

/*
 * @brief 把方形图片转换成圆形图片
 *
 * @param oriImage 原图
 */
+ (UIImage *)drawRectImageToEllipes:(UIImage *)oriImage;

/*
 * @brief 根据颜色生成图片
 *
 * @param color 颜色
 * @param size 尺寸
 */
+ (nullable UIImage *)imageWithColor:(nonnull UIColor *)color size:(CGSize)size ;


+ (nullable UIImage *)circleImageWithColor:(nonnull UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
