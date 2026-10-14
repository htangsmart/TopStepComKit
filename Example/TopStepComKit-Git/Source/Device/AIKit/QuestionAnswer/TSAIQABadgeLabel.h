//
//  TSAIQABadgeLabel.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Visual style of a status badge
 * @chinese 状态徽标的视觉样式
 */
typedef NS_ENUM(NSInteger, TSAIQABadgeStyle) {
    /// 灰色 · 空闲 / 已取消
    TSAIQABadgeStyleIdle = 0,
    /// 主色 · 进行中（带呼吸点）
    TSAIQABadgeStyleLive,
    /// 绿色 · 已完成
    TSAIQABadgeStyleSuccess,
    /// 红色 · 失败
    TSAIQABadgeStyleDanger,
    /// 琥珀 · 警告
    TSAIQABadgeStyleWarning,
};

/**
 * @brief Compact pill badge with a leading dot, used by round cards and status bars
 * @chinese 带前置圆点的胶囊状态徽标，用于轮次卡片与状态栏
 */
@interface TSAIQABadgeLabel : UIView

/**
 * @brief Badge text
 * @chinese 徽标文字
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 * @brief Badge style
 * @chinese 徽标样式
 */
@property (nonatomic, assign) TSAIQABadgeStyle style;

/**
 * @brief Apply text and style in one call
 * @chinese 一次性设置文字与样式
 *
 * @param text
 * EN: Badge text
 * CN: 徽标文字
 *
 * @param style
 * EN: Badge style
 * CN: 徽标样式
 */
- (void)applyText:(nullable NSString *)text style:(TSAIQABadgeStyle)style;

@end

NS_ASSUME_NONNULL_END
