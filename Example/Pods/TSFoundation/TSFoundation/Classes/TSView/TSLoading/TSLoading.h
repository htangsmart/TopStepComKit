//
//  TSLoading.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/29.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
//#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSLoading : NSObject

+ (void)showImageLoadingOnSuperView:(UIView *)superView ;

+ (void)showImageLoadingOnSuperView:(UIView *)superView  text:(nonnull NSString *)loadingText afterDelay:(CGFloat)delay ;

+ (void)dismissImageLoadingOnSuperView:(UIView *)superView;

+ (void)dismissImageLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay;

+ (void)dismissImageLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay complete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
