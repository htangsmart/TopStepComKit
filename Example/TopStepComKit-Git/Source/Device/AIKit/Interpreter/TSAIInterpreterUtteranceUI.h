//
//  TSAIInterpreterUtteranceUI.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TopStepAIKit/TSAIDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UI-only model for one interpretation utterance
 * @chinese 同传一段 utterance 的 UI 模型
 *
 * @discussion
 * [EN]: Aggregates the three streaming callbacks (OriginalText / TranslatedText /
 *       AudioChunk) belonging to the same `utteranceIndex` into one renderable
 *       object. Text fields are cumulative (overwrite on update); audio bytes
 *       are appended so the report page can replay the synthesized voice.
 *       Timestamps of the two "final" moments feed the report's average
 *       latency (original final → translated final).
 * [CN]: 把同一 `utteranceIndex` 的三种流式回调（原文 / 译文 / 音频片段）
 *       聚合为一个可渲染对象。文本字段为累积值（更新时覆盖）；音频字节
 *       累加保存，供报告页回放合成语音。两次「定稿」的时间戳用于报告页
 *       的平均延迟（原文定稿 → 译文定稿）。
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
 * @brief Accumulated TTS audio bytes, kept for replay on the report page
 * @chinese 累积的 TTS 音频数据，供报告页回放
 */
@property (nonatomic, strong, readonly) NSMutableData *audioData;

/**
 * @brief Format of `audioData` (first chunk wins)
 * @chinese `audioData` 的格式（以首片为准）
 */
@property (nonatomic, assign) TSAIAudioFormat audioFormat;

/**
 * @brief Whether the final TTS audio chunk has been delivered
 * @chinese 最后一片 TTS 音频是否已下发
 */
@property (nonatomic, assign) BOOL isAudioFinal;

/**
 * @brief Translation went final but no TTS audio arrived in time (cloud has no voice for the target language)
 * @chinese 译文已定稿但迟迟没有 TTS 音频（云端对该目标语言无语音）
 */
@property (nonatomic, assign) BOOL isAudioUnavailable;

/**
 * @brief Local time when this utterance UI model was created
 * @chinese 该 UI 模型创建的本地时间
 */
@property (nonatomic, copy, nullable) NSDate *startTime;

/**
 * @brief Session-relative "mm:ss" when the utterance started
 * @chinese utterance 开始时相对会话的 "mm:ss"
 */
@property (nonatomic, copy, nullable) NSString *startOffsetText;

/**
 * @brief When the original text first became final
 * @chinese 原文首次定稿的时间
 */
@property (nonatomic, copy, nullable) NSDate *originalFinalDate;

/**
 * @brief When the translated text first became final
 * @chinese 译文首次定稿的时间
 */
@property (nonatomic, copy, nullable) NSDate *translatedFinalDate;

/**
 * @brief Original-final → translated-final latency in seconds; negative when unknown
 * @chinese 原文定稿到译文定稿的延迟（秒）；未知时为负数
 */
@property (nonatomic, assign, readonly) NSTimeInterval latency;

/**
 * @brief Whether both texts are final
 * @chinese 原文与译文是否都已定稿
 */
@property (nonatomic, assign, readonly) BOOL isComplete;

@end

NS_ASSUME_NONNULL_END
