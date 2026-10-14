//
//  TSAIChatEndCard.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Flow-mode end card: round count and duration (spec §4.4)
 * @chinese 畅聊结束卡：轮数与时长（规范 §4.4）
 */
@interface TSAIChatEndCard : UIView

/** @brief Fixed height @chinese 固定高度 */
+ (CGFloat)preferredHeight;

/**
 * @brief Fill and pop in
 * @chinese 填充内容并弹性入场
 * @param roundCount EN: Rounds. CN: 轮数。
 * @param duration EN: Session duration in seconds. CN: 会话时长（秒）。
 */
- (void)showWithRoundCount:(NSInteger)roundCount duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
