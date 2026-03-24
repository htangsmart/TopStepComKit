//
//  TSLoadingHUD.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Lightweight loading HUD with blurred background
 * @chinese 轻量加载提示框（毛玻璃背景）
 *
 * @discussion
 * [EN]: Shows a blurred overlay with an activity indicator and optional message.
 *       Only one HUD is shown per view at a time. Call hideIn: to dismiss.
 * [CN]: 在指定视图上显示毛玻璃遮罩 + 活动指示器 + 可选文字。
 *       同一视图同时只显示一个 HUD，调用 hideIn: 关闭。
 */
@interface TSLoadingHUD : UIView

/**
 * @brief Show loading HUD in the given view.
 * @chinese 在指定视图中显示加载 HUD。
 *
 * @param view    要显示 HUD 的父视图
 * @param message 可选提示文字，nil 表示仅显示活动指示器
 */
+ (void)showIn:(UIView *)view message:(nullable NSString *)message;

/**
 * @brief Hide loading HUD from the given view.
 * @chinese 从指定视图中移除加载 HUD。
 *
 * @param view 要移除 HUD 的父视图
 */
+ (void)hideIn:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
