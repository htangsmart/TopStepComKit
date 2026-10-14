//
//  TSAIQATextRoundCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIQATextRound;
@class TSAIQATextRoundCell;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Actions raised by a text round cell
 * @chinese 文字轮次卡片的交互回调
 */
@protocol TSAIQATextRoundCellDelegate <NSObject>

/**
 * @brief Copy button tapped
 * @chinese 点击了复制按钮
 *
 * @param cell
 * EN: Source cell
 * CN: 来源卡片
 *
 * @param round
 * EN: Round bound to the cell
 * CN: 卡片绑定的轮次
 */
- (void)textRoundCell:(TSAIQATextRoundCell *)cell didTapCopyForRound:(TSAIQATextRound *)round;

/**
 * @brief Retry button tapped
 * @chinese 点击了重新提问按钮
 *
 * @param cell
 * EN: Source cell
 * CN: 来源卡片
 *
 * @param round
 * EN: Round bound to the cell
 * CN: 卡片绑定的轮次
 */
- (void)textRoundCell:(TSAIQATextRoundCell *)cell didTapRetryForRound:(TSAIQATextRound *)round;

@end

/**
 * @brief Cell showing one question bubble and its streaming answer card
 * @chinese 展示一个问题气泡及其流式答案卡片的单元格
 *
 * @discussion
 * [EN]: The card header badge follows start → partial → completion; the latest
 *       `deltaText` is highlighted so streaming stays visible; the footer exposes
 *       taskId / questionId / duration for log correlation.
 * [CN]: 卡片头部徽标跟随 start → partial → completion 变化；最新 `deltaText` 高亮以体现流式；
 *       底部露出 taskId / questionId / 耗时便于对照日志。
 */
@interface TSAIQATextRoundCell : UITableViewCell

/**
 * @brief Reuse identifier
 * @chinese 复用标识
 */
@property (class, nonatomic, copy, readonly) NSString *cellReuseIdentifier;

/**
 * @brief Interaction delegate
 * @chinese 交互代理
 */
@property (nonatomic, weak, nullable) id<TSAIQATextRoundCellDelegate> delegate;

/**
 * @brief Bind a round and refresh every subview
 * @chinese 绑定轮次并刷新全部子视图
 *
 * @param round
 * EN: Round to display
 * CN: 要显示的轮次
 */
- (void)applyRound:(TSAIQATextRound *)round;

@end

NS_ASSUME_NONNULL_END
