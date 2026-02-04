//
//  UIView+Crop.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Crop)

- (UIImage *)crop:(CGSize)cropSize corner:(CGFloat)corner scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
