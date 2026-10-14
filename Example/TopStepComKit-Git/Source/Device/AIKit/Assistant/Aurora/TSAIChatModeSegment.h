//
//  TSAIChatModeSegment.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Page mode of the AI chat screen
 * @chinese AI 对话页的页面模式
 */
typedef NS_ENUM(NSInteger, TSAIChatPageMode) {
    /// AI 对话：按住说一句、回一句（SingleRound）
    TSAIChatPageModeChat = 0,
    /// AI 畅聊：进入即监听、自由多轮（Continuous）
    TSAIChatPageModeFlow = 1,
};

/**
 * @brief Two-way segmented control with a gradient thumb (spec §2.3)
 * @chinese 带渐变滑块的双段分段控件（规范 §2.3）
 */
@interface TSAIChatModeSegment : UIControl

/** @brief Selected mode @chinese 当前选中模式 */
@property (nonatomic, assign) TSAIChatPageMode selectedMode;

/** @brief Locked while a session is busy; taps call `onLockedTap` @chinese 会话进行中锁定；点击触发 `onLockedTap` */
@property (nonatomic, assign) BOOL locked;

/** @brief Called when the user picks a mode @chinese 用户选择模式后回调 */
@property (nonatomic, copy, nullable) void (^onSelect)(TSAIChatPageMode mode);

/** @brief Called when a locked segment is tapped @chinese 锁定态被点击时回调 */
@property (nonatomic, copy, nullable) void (^onLockedTap)(void);

/**
 * @brief Called when the user taps the other mode while locked
 * @chinese 锁定态下用户点击了另一模式时回调（带目标模式）
 * @discussion EN: Set to let the page end the current session first and switch afterwards;
 *             the thumb does not move until `setSelectedMode:animated:` is called.
 *             CN: 设置后由页面先结束当前会话再切换；在调用 `setSelectedMode:animated:` 之前滑块不动。
 *             优先于 `onLockedTap`。
 */
@property (nonatomic, copy, nullable) void (^onLockedSelect)(TSAIChatPageMode mode);

/** @brief Fixed height 40 @chinese 固定高度 40 */
+ (CGFloat)preferredHeight;

/**
 * @brief Change selection
 * @chinese 切换选中项
 * @param mode EN: Mode to select. CN: 要选中的模式。
 * @param animated EN: Animate the thumb (.35s spring). CN: 是否以 .35s 弹性过渡。
 */
- (void)setSelectedMode:(TSAIChatPageMode)mode animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
