//
//  TSAIStreamTextView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Title + cumulative streaming text container
 * @chinese 标题 + 累积流式文本容器
 *
 * @discussion
 * [EN]: Designed for streaming LLM / ASR / Translate output where the partial
 *       result is the *full* cumulative text so far (append-only). Callers
 *       simply assign the latest cumulative string to `text` whenever a new
 *       partial arrives and the view will refresh and auto-scroll.
 * [CN]: 用于流式 LLM / ASR / 翻译场景，partial 结果是「截至当前的累积文本」
 *       （只增不改）。调用方在每次拿到 partial 时直接把累积文本赋给 `text`，
 *       视图会刷新并自动滚到底。
 */
@interface TSAIStreamTextView : UIView

/**
 * @brief Title shown above the text area
 * @chinese 显示在文本区上方的标题
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Latest cumulative text; assign the full string on each partial
 * @chinese 当前累积文本，每次 partial 直接把全量赋值即可
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 * @brief Text color of the content area; defaults to black
 * @chinese 文本区文字颜色，默认黑色
 *
 * @discussion
 * [EN]: Switch to a danger / warning color to surface error or cancellation
 *       messages in the same text area. Reset to nil (or default) to restore
 *       the normal streaming style.
 * [CN]: 失败 / 取消时可切换为红色 / 橙色，把错误信息直接在文本区呈现。
 *       置回 nil（或默认色）即恢复正常流式展示样式。
 */
@property (nonatomic, strong, null_resettable) UIColor *textColor;

/**
 * @brief Background color of the content area; defaults to white
 * @chinese 文本区背景颜色，默认白色
 *
 * @discussion
 * [EN]: Pair with `textColor` to highlight error / warning messages (e.g.
 *       red text on a tinted red background). Reset to nil to restore the
 *       default white background.
 * [CN]: 与 `textColor` 配合，可在文本区直接强化错误/警告提示（如红字 +
 *       淡红底）。置回 nil 即恢复默认白底。
 */
@property (nonatomic, strong, null_resettable) UIColor *contentBackgroundColor;

/**
 * @brief Optional accessory view docked at the trailing edge of the title row
 * @chinese 标题行右侧的可选附件视图
 *
 * @discussion
 * [EN]: Use to display per-section status badge, duration label, etc. The
 *       accessory view's intrinsic size is honored; title label auto-shrinks
 *       its trailing edge to leave room. Pass nil to remove.
 * [CN]: 用于展示分区级状态徽章、耗时等附件控件。会按 accessoryView 的
 *       intrinsic size 布局；标题 label 自动让出右侧空间。传 nil 表示移除。
 */
@property (nonatomic, strong, nullable) UIView *accessoryView;

/**
 * @brief Reset content; clears displayed text but keeps title
 * @chinese 重置内容，清空文本但保留标题
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
