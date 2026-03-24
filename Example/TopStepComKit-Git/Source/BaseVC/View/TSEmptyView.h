//
//  TSEmptyView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified empty-state view
 * @chinese 统一空状态视图
 *
 * @discussion
 * [EN]: Displays a vertically centered icon, title, and optional subtitle.
 *       Colors adapt automatically to light/dark mode.
 * [CN]: 垂直居中展示图标、主标题和可选副标题，颜色自动适配深色模式。
 */
@interface TSEmptyView : UIView

/**
 * @brief Create an empty-state view with icon, title, and subtitle.
 * @chinese 使用图标、主标题和副标题创建空状态视图。
 *
 * @param iconName SF Symbol 名称（如 @"tray"）
 * @param title    主标题文本
 * @param subtitle 副标题文本，传 nil 则不显示
 * @return 新建的 TSEmptyView 实例
 */
+ (instancetype)viewWithIcon:(NSString *)iconName
                       title:(NSString *)title
                    subtitle:(nullable NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
