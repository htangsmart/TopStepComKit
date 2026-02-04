
//
//  TSImageCompress.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSImageCompress : NSObject

+ (UIImage *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGSize)maxImageSize maxSizeWithKB:(CGFloat) maxSize;

+ (UIImage*)reSizeImageWithOriImage:(UIImage*)oriImage toImageSize:(CGSize)imageSize scale:(CGFloat)scale;


@end

NS_ASSUME_NONNULL_END
