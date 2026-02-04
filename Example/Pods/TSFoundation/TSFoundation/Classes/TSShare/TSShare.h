//
//  TSShare.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSShare : NSObject

+(void)shareView:(UIView *)shareView onVC:(UIViewController *)superVC;

+(void)shareView:(UIView *)shareView onVC:(UIViewController *)superVC complete:(void(^)(BOOL completed))complete;

+(void)shareImage:(UIImage *)shareImage onVC:(UIViewController *)superVC;

+(void)shareImage:(UIImage *)shareImage onVC:(UIViewController *)superVC complete:(void(^)(BOOL completed))complete;


@end

NS_ASSUME_NONNULL_END
