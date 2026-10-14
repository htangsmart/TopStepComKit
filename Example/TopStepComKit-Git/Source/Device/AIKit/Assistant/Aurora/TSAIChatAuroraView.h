//
//  TSAIChatAuroraView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIChatTheme.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Aurora background: three drifting soft-light blobs tinted by the conversation tone
 * @chinese 极光背景：三团随会话"气色"变色的漂移柔光
 *
 * @discussion
 * [EN]: Spec §2.1. Each blob is a 320pt radial gradient that drifts on an
 *       18 / 22 / 20s ease-in-out loop; tone changes fade colors over 1.2s.
 * [CN]: 规范 §2.1。每团柔光为 320pt 径向渐变，按 18 / 22 / 20s 往返漂移；
 *       气色变化时颜色 1.2s 渐变。
 */
@interface TSAIChatAuroraView : UIView

/** @brief Current tone @chinese 当前气色 */
@property (nonatomic, assign) TSAIChatTone tone;

/**
 * @brief Change tone with the 1.2s fade
 * @chinese 切换气色（1.2s 渐变）
 * @param tone EN: New tone. CN: 新气色。
 * @param animated EN: Whether to fade. CN: 是否渐变。
 */
- (void)setTone:(TSAIChatTone)tone animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
