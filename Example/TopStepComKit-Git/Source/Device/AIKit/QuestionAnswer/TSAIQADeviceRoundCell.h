//
//  TSAIQADeviceRoundCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIQADeviceRound;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Cell showing one device-initiated round: question, answer and playback strip
 * @chinese 展示一轮设备发起问答的单元格：问题、回答与播放条
 *
 * @discussion
 * [EN]: The question and answer sections follow the text phases; the playback strip is a
 *       separate block because `TSAIDeviceQuestionAnswerEvent.phase` never waits for TTS.
 * [CN]: 问题与回答两段跟随文字阶段；播放条是独立区块，因为
 *       `TSAIDeviceQuestionAnswerEvent.phase` 不等待 TTS 播放。
 */
@interface TSAIQADeviceRoundCell : UITableViewCell

/**
 * @brief Reuse identifier
 * @chinese 复用标识
 */
@property (class, nonatomic, copy, readonly) NSString *cellReuseIdentifier;

/**
 * @brief Bind a round and refresh
 * @chinese 绑定轮次并刷新
 *
 * @param round
 * EN: Round to display
 * CN: 要显示的轮次
 *
 * @param playbackText
 * EN: Playback strip text; nil hides the strip
 * CN: 播放条文字；nil 隐藏播放条
 */
- (void)applyRound:(TSAIQADeviceRound *)round playbackText:(nullable NSString *)playbackText;

@end

NS_ASSUME_NONNULL_END
