//
//  TSAIInterpreterUtteranceUI.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UI-only model for one interpretation utterance
 * @chinese 同传一段 utterance 的 UI 模型
 *
 * @discussion
 * [EN]: Aggregates the three streaming callbacks (OriginalText / TranslatedText /
 *       AudioChunk) belonging to the same `utteranceIndex` into one renderable
 *       object. Text fields are cumulative (overwrite on update), `audioBytes` is
 *       a counter accumulating AudioChunk deltas. The same object is rendered
 *       twice: once in the source panel (original text) and once in the target
 *       panel (translated text + audio status).
 * [CN]: 把同一 `utteranceIndex` 的三种流式回调（原文 / 译文 / 音频片段）
 *       聚合为一个可渲染对象。文本字段为累积值（更新时覆盖），
 *       `audioBytes` 为累加 AudioChunk 增量的计数器。同一对象会被渲染两次：
 *       源面板显示原文，目标面板显示译文与音频状态。
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
 * @brief Local time when this utterance UI model was created
 * @chinese 该 UI 模型创建的本地时间
 */
@property (nonatomic, copy, nullable) NSDate *startTime;

@end

NS_ASSUME_NONNULL_END
