//
//  UIViewController+TSToast.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Lightweight capsule toast helper
 * @chinese 轻量胶囊 Toast 辅助分类
 *
 * @discussion
 * [EN]: Presents a transient dark capsule message near the top of the controller's view and
 *       auto-dismisses after ~2 seconds. Provided as a shared category so multiple screens do not
 *       each re-implement their own toast.
 * [CN]: 在控制器视图顶部附近展示一个短暂的黑色胶囊消息，约 2 秒后自动消失。
 *       以共享分类形式提供，避免多个页面各自重复实现 Toast。
 */
@interface UIViewController (TSToast)

/**
 * @brief Show a transient toast message
 * @chinese 展示一条短暂的 Toast 消息
 *
 * @param message
 * EN: The text to display; ignored if empty
 * CN: 要展示的文本；为空时忽略
 */
- (void)ts_showToast:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
