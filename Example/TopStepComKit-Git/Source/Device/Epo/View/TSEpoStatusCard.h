//
//  TSEpoStatusCard.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSEpoTimeInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO status card view
 * @chinese EPO 状态卡片视图
 *
 * @discussion
 * [EN]: Shows the device EPO validity (computed from validDate vs now), valid-until and last-update
 *       times. Exposes a refresh and a clear action via blocks. The host feeds a TSEpoTimeInfo (or nil
 *       for unknown) and the card renders itself.
 * [CN]: 展示设备 EPO 有效性(由 validDate 与当前时间计算)、有效期至与上次更新时间。通过 block 暴露
 *       刷新与清除动作。宿主传入 TSEpoTimeInfo(或 nil 表示未知)，卡片自行渲染。
 */
@interface TSEpoStatusCard : UIView

/**
 * @brief Callback when the refresh button is tapped
 * @chinese 点击刷新按钮时的回调
 */
@property (nonatomic, copy, nullable) void(^onRefresh)(void);

/**
 * @brief Callback when the clear button is tapped (after host confirms)
 * @chinese 点击清除按钮时的回调（由宿主负责二次确认）
 */
@property (nonatomic, copy, nullable) void(^onClear)(void);

/**
 * @brief The card height for the given width
 * @chinese 给定宽度下的卡片高度
 *
 * @param width
 * EN: The card width
 * CN: 卡片宽度
 *
 * @return
 * EN: The height the host should use
 * CN: 宿主应使用的高度
 */
+ (CGFloat)cardHeightForWidth:(CGFloat)width;

/**
 * @brief Render the card with EPO time info
 * @chinese 用 EPO 时间信息渲染卡片
 *
 * @param info
 * EN: The EPO time info; validity is computed from info.validDate. Pass nil for the unknown state.
 * CN: EPO 时间信息；有效性由 info.validDate 计算。传 nil 显示未知态。
 */
- (void)renderWithInfo:(nullable TSEpoTimeInfo *)info;

/**
 * @brief Reset the card to the unknown state
 * @chinese 将卡片重置为未知态
 */
- (void)renderUnknown;

@end

NS_ASSUME_NONNULL_END
