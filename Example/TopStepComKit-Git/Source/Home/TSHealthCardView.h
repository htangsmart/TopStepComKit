//
//  TSHealthCardView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Square health data card view
 * @chinese 方形健康数据卡片视图
 *
 * @discussion
 * [EN]: Displays a health metric with icon, title, and current value.
 *       Supports a disabled (grayed out) state for unsupported features.
 * [CN]: 显示带有图标、标题和当前数值的健康指标卡片。
 *       支持不可用的灰色禁用状态（用于不支持的功能）。
 */
@interface TSHealthCardView : UIView

/**
 * @brief Whether the card is enabled (tappable)
 * @chinese 卡片是否可用（可点击）
 *
 * @discussion
 * [EN]: When NO, the card is displayed in a grayed-out state.
 * [CN]: 为 NO 时，卡片显示为灰色。
 */
@property (nonatomic, assign) BOOL enabled;

/**
 * @brief Disable reason type
 * @chinese 禁用原因类型
 *
 * @discussion
 * [EN]: Used to determine the toast message when tapping a disabled card.
 * [CN]: 用于判断点击禁用卡片时显示的提示信息。
 */
@property (nonatomic, assign) NSInteger disableReason; // 0: 设备未连接, 1: 设备不支持

/**
 * @brief SF Symbol icon name
 * @chinese SF Symbol 图标名称
 */
@property (nonatomic, copy) NSString *iconName;

/**
 * @brief Icon background tint color (used when enabled)
 * @chinese 图标背景着色（仅在可用时使用）
 */
@property (nonatomic, strong) UIColor *iconColor;

/**
 * @brief Card title (metric name)
 * @chinese 卡片标题（指标名称）
 */
@property (nonatomic, copy) NSString *titleText;

/**
 * @brief Current metric value string, e.g. "72 bpm" or "--"
 * @chinese 当前指标数值字符串，例如 "72 bpm" 或 "--"
 */
@property (nonatomic, copy) NSString *valueText;

/**
 * @brief Tap callback block
 * @chinese 点击回调
 */
@property (nonatomic, copy, nullable) void (^onTap)(void);

/**
 * @brief Create card with icon, color, title and initial value
 * @chinese 使用图标、颜色、标题和初始数值创建卡片
 *
 * @param iconName
 * EN: SF Symbol name
 * CN: SF Symbol 图标名称
 *
 * @param iconColor
 * EN: Icon tint color
 * CN: 图标着色颜色
 *
 * @param title
 * EN: Card title text
 * CN: 卡片标题文字
 *
 * @param value
 * EN: Initial value string (use "--" when unknown)
 * CN: 初始数值字符串（未知时传 "--"）
 */
+ (instancetype)cardWithIconName:(NSString *)iconName
                       iconColor:(UIColor *)iconColor
                           title:(NSString *)title
                           value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
