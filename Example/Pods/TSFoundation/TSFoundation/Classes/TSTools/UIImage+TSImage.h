//
//  UIImage+TSImage.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TSImage)
- (UIImage *)tsRotate;

/**
 *  颜色转图片
 */
+ (UIImage *)tsImageWithColor:(UIColor *)color;
/**
 *  视图转图片
 */
+ (UIImage *)tsImageWithView:(UIView *)view;
/**
 *  Layer转图片
 */
+ (UIImage *)tsImageWithLayer:(CALayer *)layer;


@end

NS_ASSUME_NONNULL_END
