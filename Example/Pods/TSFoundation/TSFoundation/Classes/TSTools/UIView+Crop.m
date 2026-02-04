//
//  UIView+Crop.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/14.
//

#import "UIView+Crop.h"

@implementation UIView (Crop)

- (UIImage *)crop:(CGSize)cropSize corner:(CGFloat)corner scale:(CGFloat)scale{
    if (CGSizeEqualToSize(cropSize, CGSizeZero)) {
        cropSize = self.frame.size;
    }
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsBeginImageContextWithOptions(cropSize, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, cropSize.width, cropSize.height) cornerRadius:corner] addClip];
    [snapshotImage drawInRect:CGRectMake(0, 0, cropSize.width, cropSize.height)];
    UIImage * targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}


@end
