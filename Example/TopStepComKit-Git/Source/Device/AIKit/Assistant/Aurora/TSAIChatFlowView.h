//
//  TSAIChatFlowView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIChatOrbView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Flow-mode stage: 240 orb container with ripples / equalizer, status text and current-round text (spec §4.1–4.2).
 *        When the round text does not fit, the orb shrinks to 0.6 and the text area becomes scrollable.
 * @chinese 畅聊主区：240 光球容器（涟漪 / 均衡器）、状态文案与当前轮文字（规范 §4.1–4.2）。
 *          当前轮文字放不下时光球缩到 0.6 让位，文字区改为可滚动（上下边缘渐隐）
 */
@interface TSAIChatFlowView : UIView

/** @brief Orb state @chinese 光球状态 */
@property (nonatomic, assign) TSAIChatOrbState orbState;

/** @brief Status title (22 / 800) @chinese 状态标题 */
@property (nonatomic, copy, nullable) NSString *statusTitle;

/** @brief Status subtitle (13 ink2) @chinese 状态副标 */
@property (nonatomic, copy, nullable) NSString *statusSubtitle;

/** @brief Current question text @chinese 当前轮问题 */
@property (nonatomic, copy, nullable) NSString *questionText;

/** @brief Current answer text @chinese 当前轮回答 */
@property (nonatomic, copy, nullable) NSString *answerText;

/** @brief Show a trailing cursor on the answer (speaking) @chinese 回答尾部显示光标（播放中） */
@property (nonatomic, assign) BOOL answerCursorVisible;

/** @brief Called when the big orb is tapped @chinese 点击大光球回调 */
@property (nonatomic, copy, nullable) void (^onOrbTap)(void);

/**
 * @brief Restart looping animations
 * @chinese 重启循环动画
 */
- (void)restartAnimations;

@end

NS_ASSUME_NONNULL_END
