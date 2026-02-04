//
//  TSImage.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/9.
//

#import "TSImage.h"

@implementation TSImage


+ (UIImage *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGSize)maxImageSize maxSizeWithKB:(CGFloat) maxSize{
    if (maxSize <= 0.0) maxSize = 1024.0;
    if (maxImageSize.width <= 0.0 || maxImageSize.height<=0.0f) maxImageSize = CGSizeMake(1024.0, 1024.0);
    UIGraphicsBeginImageContext(maxImageSize);
    [sourceImage drawInRect:CGRectMake(0,0,maxImageSize.width,maxImageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    CGFloat sizeOriginKB = imageData.length / 1024.0;
    CGFloat resizeRate = 0.9;
    while (sizeOriginKB > maxSize && resizeRate > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage,resizeRate);
        sizeOriginKB = imageData.length / 1024.0;
        resizeRate -= 0.1;
    }
    UIImage *targetImage = [UIImage imageWithData: imageData];
    return targetImage;
}

+ (UIImage*)reSizeImageWithOriImage:(UIImage*)oriImage toImageSize:(CGSize)imageSize scale:(CGFloat)scale
{
        
    if(oriImage == nil)     { return nil; }
    if(CGSizeEqualToSize(imageSize, CGSizeZero))   {return nil;}
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    [oriImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    oriImage = nil;
    UIImage * targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}



+ (UIImage *)drawRectImageToEllipes:(UIImage *)oriImage{
        
    CGSize imageSize = CGSizeMake(oriImage.size.width, oriImage.size.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, imageSize.width,imageSize.width));
    CGContextClip(context);
    [oriImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}




+ (nullable UIImage *)imageWithColor:(nonnull UIColor *)color size:(CGSize)size{

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (nullable UIImage *)circleImageWithColor:(nonnull UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
