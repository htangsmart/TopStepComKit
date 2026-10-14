//
//  TSAIChatHeroView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Empty state of chat mode: orb + greeting + suggestion chips (spec §3.1)
 * @chinese 对话模式空态：光球 + 问候 + 建议 chip（规范 §3.1）
 */
@interface TSAIChatHeroView : UIView

/** @brief Called with the suggestion text when a chip is tapped @chinese 点击建议 chip 时回调其文字 */
@property (nonatomic, copy, nullable) void (^onSuggestionTap)(NSString *text);

/**
 * @brief Replay the staggered pop-in of the chips
 * @chinese 重放 chip 的逐个弹性入场
 */
- (void)playEntrance;

/**
 * @brief Restart the orb's looping animations
 * @chinese 重启光球循环动画
 */
- (void)restartAnimations;

@end

NS_ASSUME_NONNULL_END
