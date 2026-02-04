//
//  TSScreenCapture.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSScreenCapture : NSObject

+ (UIImage *)screenshotForView:(UIView *)view frame:(CGRect)cutFrame ;


@end

NS_ASSUME_NONNULL_END
