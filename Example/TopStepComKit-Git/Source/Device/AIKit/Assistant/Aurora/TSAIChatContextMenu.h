//
//  TSAIChatContextMenu.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Context menu action
 * @chinese 长按菜单动作
 */
typedef NS_ENUM(NSInteger, TSAIChatContextMenuAction) {
    /// 播放
    TSAIChatContextMenuActionPlay = 0,
    /// 复制
    TSAIChatContextMenuActionCopy,
    /// 删除
    TSAIChatContextMenuActionDelete,
};

/**
 * @brief Custom long-press menu: 播放 / 复制 / 删除 (spec §3.2)
 * @chinese 自定义长按菜单：播放 / 复制 / 删除（规范 §3.2）
 */
@interface TSAIChatContextMenu : UIView

/**
 * @brief Present above a bubble, aligned to its side; tapping outside dismisses
 * @chinese 在气泡上方 58pt 展示，与气泡同侧对齐；点击空白收起
 * @param bubble EN: Anchor bubble. CN: 锚点气泡。
 * @param hostView EN: View to add the menu to. CN: 承载菜单的视图。
 * @param alignRight EN: Align to the right edge (user bubble). CN: 是否右对齐（用户气泡）。
 * @param handler EN: Called with the chosen action. CN: 选择动作后回调。
 */
+ (instancetype)showAboveBubble:(UIView *)bubble
                         inView:(UIView *)hostView
                     alignRight:(BOOL)alignRight
                        handler:(void (^)(TSAIChatContextMenuAction action))handler;

/** @brief Dismiss @chinese 收起 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
