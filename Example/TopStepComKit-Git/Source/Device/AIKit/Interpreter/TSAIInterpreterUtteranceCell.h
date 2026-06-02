//
//  TSAIInterpreterUtteranceCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UI-only model for one interpretation utterance row
 * @chinese 同传字幕表一行的 UI 模型
 *
 * @discussion
 * [EN]: Aggregates the three streaming callbacks (OriginalText / TranslatedText /
 *       AudioChunk) belonging to the same `utteranceIndex` into one renderable
 *       row. Text fields are cumulative (overwrite on update), `audioBytes` is
 *       a counter accumulating AudioChunk deltas.
 * [CN]: 把同一 `utteranceIndex` 的三种流式回调（原文 / 译文 / 音频片段）
 *       聚合为一行可渲染数据。文本字段为累积值（更新时覆盖），
 *       `audioBytes` 为累加 AudioChunk 增量的计数器。
 */
@interface TSAIInterpreterUtteranceUI : NSObject

/**
 * @brief 0-based utterance ordinal within the session
 * @chinese 会话内 utterance 序号（从 0 开始）
 */
@property (nonatomic, assign) NSInteger index;

/**
 * @brief Cumulative recognized original text (ASR)
 * @chinese 累积原文（ASR）
 */
@property (nonatomic, copy, nullable) NSString *originalText;

/**
 * @brief Whether the original text has stabilized
 * @chinese 原文是否已稳定
 */
@property (nonatomic, assign) BOOL isOriginalFinal;

/**
 * @brief Cumulative translated text (MT)
 * @chinese 累积译文（MT）
 */
@property (nonatomic, copy, nullable) NSString *translatedText;

/**
 * @brief Whether the translated text has stabilized
 * @chinese 译文是否已稳定
 */
@property (nonatomic, assign) BOOL isTranslatedFinal;

/**
 * @brief Accumulated TTS audio byte count
 * @chinese 已累积 TTS 音频字节数
 */
@property (nonatomic, assign) NSUInteger audioBytes;

/**
 * @brief Whether the final TTS audio chunk has been delivered
 * @chinese 最后一片 TTS 音频是否已下发
 */
@property (nonatomic, assign) BOOL isAudioFinal;

/**
 * @brief Local time when this utterance UI row was created
 * @chinese 该行 UI 创建的本地时间
 */
@property (nonatomic, copy, nullable) NSDate *startTime;

@end


/**
 * @brief Table cell rendering one utterance: original + translated + audio status
 * @chinese 同传字幕表单元格：渲染原文 / 译文 / 音频状态
 *
 * @discussion
 * [EN]: Self-sizing card with three label rows. Use the class method
 *       `heightForUtterance:showAudio:cellWidth:` to drive
 *       `tableView:heightForRowAtIndexPath:`.
 * [CN]: 自适应高度卡片，含三行标签。配合类方法
 *       `heightForUtterance:showAudio:cellWidth:` 计算行高。
 */
@interface TSAIInterpreterUtteranceCell : UITableViewCell

/**
 * @brief Bind a utterance UI model to this cell
 * @chinese 将 UI 模型绑定到 cell
 *
 * @param utterance
 * EN: UI model populated from streaming callbacks
 * CN: 由流式回调填充的 UI 模型
 *
 * @param showAudio
 * EN: Whether the audio status row should be visible (off when
 *     `enableVoiceOutput == NO`)
 * CN: 是否显示音频状态行（`enableVoiceOutput == NO` 时关闭）
 */
- (void)bindWithUtterance:(TSAIInterpreterUtteranceUI *)utterance
                 showAudio:(BOOL)showAudio;

/**
 * @brief Compute the row height for a given UI model and cell width
 * @chinese 根据 UI 模型与 cell 宽度计算行高
 *
 * @param utterance
 * EN: UI model
 * CN: UI 模型
 *
 * @param showAudio
 * EN: Whether to reserve space for the audio status row
 * CN: 是否预留音频状态行空间
 *
 * @param cellWidth
 * EN: Effective cell width (table view bounds width)
 * CN: 实际 cell 宽度（表格 bounds 宽度）
 *
 * @return
 * EN: Row height in points
 * CN: 行高（pt）
 */
+ (CGFloat)heightForUtterance:(TSAIInterpreterUtteranceUI *)utterance
                    showAudio:(BOOL)showAudio
                    cellWidth:(CGFloat)cellWidth;

@end

NS_ASSUME_NONNULL_END
