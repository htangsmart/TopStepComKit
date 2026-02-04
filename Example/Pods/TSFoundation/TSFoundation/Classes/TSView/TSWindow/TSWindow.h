//
//  TSWindow.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWindow : NSObject

/**
 获取当前显示的顶层视图控制器
 
 @return 当前显示的顶层视图控制器，如果获取失败返回 nil
 @discussion 该方法会递归查找当前显示的最顶层控制器，包括处理导航控制器、标签控制器、分屏控制器等各种情况
 */
+ (UIViewController *)windowTopVC ;

/**
 获取指定视图所在的视图控制器
 
 @param view 需要查找的视图
 @return 该视图所在的视图控制器，如果未找到返回 nil
 @discussion 该方法通过响应链向上查找，直到找到视图所属的视图控制器
 */
+ (UIViewController *)viewSuperVC:(UIView *)view ;



@end

NS_ASSUME_NONNULL_END
