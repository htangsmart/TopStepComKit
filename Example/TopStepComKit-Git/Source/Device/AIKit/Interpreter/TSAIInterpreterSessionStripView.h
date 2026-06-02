//
//  TSAIInterpreterSessionStripView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Session status strip with mic-meter, status text and taskId
 * @chinese 会话状态条：含 5 根麦克风电平柱、状态文字、taskId 标签
 *
 * @discussion
 * [EN]: White rounded card containing a 5-bar pulsing meter on the left,
 *       a session-state label in the center and a short taskId on the right.
 *       Use `setActive:` to switch between idle (gray, no animation) and
 *       running (green, staggered scale-pulse on each bar).
 * [CN]: 白色圆角卡片，左侧 5 根脉冲电平柱，中部会话状态文字，
 *       右侧 taskId 短码。`setActive:` 切换空闲（灰色无动画）
 *       与进行中（绿色错峰高度脉冲）。
 */
@interface TSAIInterpreterSessionStripView : UIView

/**
 * @brief Set the visible status text and color
 * @chinese 设置状态文字与颜色
 *
 * @param text  EN: status string · CN: 状态文字
 * @param color EN: text color    · CN: 文字颜色
 */
- (void)setStatusText:(nullable NSString *)text textColor:(nullable UIColor *)color;

/**
 * @brief Set the trailing taskId text (right-aligned, monospaced, dim)
 * @chinese 设置右侧 taskId 文字（右对齐、等宽、暗色）
 *
 * @param text EN: short id text · CN: taskId 短码
 */
- (void)setTaskIdText:(nullable NSString *)text;

/**
 * @brief Toggle meter animation; running = staggered green pulse, idle = gray static
 * @chinese 切换电平柱动画；进行中 = 错峰绿色脉冲，空闲 = 灰色静态
 *
 * @param active EN: YES while a session is running · CN: 会话进行中传 YES
 */
- (void)setActive:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
