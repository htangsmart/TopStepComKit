//
//  TSAIChatRoundCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIChatIntent;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A self-sizing card showing one Q/A round of an AI chat session
 * @chinese 展示 AI 对话一轮 Q/A 的自适应高度卡片
 *
 * @discussion
 * [EN]: Renders the user question bubble (Q), AI answer bubble (A) and zero or
 *       more recognized intent chips. Designed to be added directly to a
 *       `UIStackView` so layout is purely intrinsic-content driven, avoiding
 *       index-based table reload churn during streaming updates.
 * [CN]: 渲染一轮的用户问句（Q 气泡）、AI 回答（A 气泡）以及零到多个识别到的
 *       意图 chip。直接放入 `UIStackView` 即可自适应高度，避免流式刷新时
 *       UITableView 重排带来的抖动。
 */
@interface TSAIChatRoundCell : UIView

/**
 * @brief 0-based round index displayed as `Round N` tag
 * @chinese 轮次序号，以 `Round N` 形式显示
 */
@property (nonatomic, assign) NSInteger roundIndex;

/**
 * @brief Set Q (user question) text; pass nil/empty to hide bubble
 * @chinese 设置 Q（用户问句）文本，传 nil/空字符串则隐藏气泡
 *
 * @param text
 * EN: Cumulative ASR text
 * CN: 累积 ASR 文本
 *
 * @param isFinal
 * EN: Whether ASR has stabilized; affects streaming caret display
 * CN: ASR 是否已稳定；影响流式光标的显示
 */
- (void)setQuestionText:(nullable NSString *)text isFinal:(BOOL)isFinal;

/**
 * @brief Set A (AI answer) text; pass nil/empty to hide bubble
 * @chinese 设置 A（AI 回答）文本，传 nil/空字符串则隐藏气泡
 *
 * @param text
 * EN: Cumulative LLM reply
 * CN: 累积 LLM 回复
 *
 * @param isFinal
 * EN: Whether the reply has finished; affects streaming caret display
 * CN: 回复是否已结束；影响流式光标的显示
 */
- (void)setAnswerText:(nullable NSString *)text isFinal:(BOOL)isFinal;

/**
 * @brief Append a recognized intent chip below the answer bubble
 * @chinese 在回答气泡下方追加一个意图 chip
 *
 * @param intent
 * EN: Recognized intent payload
 * CN: 识别到的意图载荷
 */
- (void)appendIntent:(TSAIChatIntent *)intent;

@end

NS_ASSUME_NONNULL_END
