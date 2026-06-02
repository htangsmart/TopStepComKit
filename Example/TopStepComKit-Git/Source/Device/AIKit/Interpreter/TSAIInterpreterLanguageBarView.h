//
//  TSAIInterpreterLanguageBarView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Language selection bar with two stacked-label pills and a swap button
 * @chinese 语言条：白底圆角卡片，含源 / 目标语言两个堆叠胶囊和蓝色互换圆按钮
 *
 * @discussion
 * [EN]: Each pill renders three lines: a small uppercase LABEL ("SOURCE" /
 *       "TARGET"), a large value (language name) and an optional orange
 *       "auto" / "detect" tag for the source pill when auto-detect is on.
 *       The center swap button rotates source / target; it is disabled when
 *       a session is running or source is set to Auto.
 * [CN]: 每个胶囊三行结构：小号大写 LABEL（"SOURCE" / "TARGET"）、
 *       大号语言名、源胶囊在 Auto 模式下额外显示橙色 auto / detect 小标。
 *       中间圆形蓝色互换按钮，在会话进行中或源为 Auto 时禁用。
 */
@interface TSAIInterpreterLanguageBarView : UIView

/**
 * @brief Tap callback on source language pill
 * @chinese 点击源语言胶囊回调
 */
@property (nonatomic, copy, nullable) void (^onSourceTap)(void);

/**
 * @brief Tap callback on target language pill
 * @chinese 点击目标语言胶囊回调
 */
@property (nonatomic, copy, nullable) void (^onTargetTap)(void);

/**
 * @brief Tap callback on swap button
 * @chinese 点击互换按钮回调
 */
@property (nonatomic, copy, nullable) void (^onSwapTap)(void);

/**
 * @brief Update displayed source language
 * @chinese 更新源语言展示
 *
 * @param valueText
 * EN: Main value text (language name, e.g. "English" or "Auto")
 * CN: 主显示文本（语言名，如 "English" / "Auto"）
 *
 * @param autoTag
 * EN: Trailing orange tag (e.g. "auto" / "detect"); pass nil to hide
 * CN: 尾部橙色小标（如 "auto" / "detect"），传 nil 隐藏
 */
- (void)setSourceValueText:(NSString *)valueText autoTag:(nullable NSString *)autoTag;

/**
 * @brief Update displayed target language
 * @chinese 更新目标语言展示
 *
 * @param valueText
 * EN: Main value text (language name)
 * CN: 主显示文本（语言名）
 */
- (void)setTargetValueText:(NSString *)valueText;

/**
 * @brief Update enabled state of pills and swap button
 * @chinese 更新胶囊与互换按钮的可点状态
 *
 * @param pillsEnabled
 * EN: NO disables both pills (typically while a session is running)
 * CN: 传 NO 时两个胶囊不可点（通常会话进行中）
 *
 * @param swapEnabled
 * EN: NO disables the swap button (e.g. source is Auto or session running)
 * CN: 传 NO 时互换按钮不可点（如源为 Auto 或会话进行中）
 */
- (void)setPillsEnabled:(BOOL)pillsEnabled swapEnabled:(BOOL)swapEnabled;

@end

NS_ASSUME_NONNULL_END
