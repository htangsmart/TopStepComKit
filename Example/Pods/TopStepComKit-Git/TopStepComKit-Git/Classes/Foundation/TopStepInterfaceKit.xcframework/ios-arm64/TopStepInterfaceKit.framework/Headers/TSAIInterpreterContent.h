//
//  TSAIInterpreterContent.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Simultaneous-interpretation content kind
 * @chinese 同声传译内容类型
 *
 * @discussion
 * [EN]: Discriminator for the polymorphic `TSAIInterpreterContent` payload.
 *       Different kinds populate different fields — see field-level
 *       documentation on `TSAIInterpreterContent`.
 *
 *       Original text and translated text are intentionally delivered as
 *       two separate content callbacks (rather than one merged payload)
 *       because they stream independently — the ASR pipeline produces the
 *       original while the MT pipeline produces the translation, and UIs
 *       commonly render them in two separate panes.
 *
 * [CN]: `TSAIInterpreterContent` 多态载荷的类型判别字段。
 *       不同类型激活不同字段，详见 `TSAIInterpreterContent` 各字段说明。
 *
 *       原文与译文有意拆为两个独立的内容回调（而非合并为一个载荷），
 *       因为二者是各自独立的流——ASR 管线产出原文，MT 管线产出译文，
 *       UI 也常将其分两栏展示。
 */
typedef NS_ENUM(NSInteger, TSAIInterpreterContentType) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIInterpreterContentTypeUnknown        = -1,
    /// ASR 出的原文文本（累积） (Original text from ASR, cumulative)
    TSAIInterpreterContentTypeOriginalText   = 1,
    /// MT 出的译文文本（累积） (Translated text from MT, cumulative)
    TSAIInterpreterContentTypeTranslatedText = 2,
    /// 译文 TTS 合成的音频片段（增量) (Translation TTS audio segment, delta)
    TSAIInterpreterContentTypeAudioChunk     = 3,
};

/**
 * @brief Streaming content payload during an interpretation session
 * @chinese 同声传译会话中的流式内容载荷
 *
 * @discussion
 * [EN]: Unified payload delivered through the `onContent` callback. Callers
 *       dispatch by `contentType` and read only the fields relevant to
 *       that type:
 *
 *       | contentType     | utteranceIndex | language | text | isTextFinal | audioChunk | audioFormat | isAudioFinal |
 *       |-----------------|:--------------:|:--------:|:----:|:-----------:|:----------:|:-----------:|:------------:|
 *       | OriginalText    |       ●        |  ● (源)  |  ●   |      ●      |     —      |      —      |      —       |
 *       | TranslatedText  |       ●        | ● (目标) |  ●   |      ●      |     —      |      —      |      —       |
 *       | AudioChunk      |       ●        | ● (目标) |  —   |      —      |     ●      |      ●      |      ●       |
 *
 *       Important: `text` is **cumulative** (assign directly to UI), while
 *       `audioChunk` is a **delta** (append to playback buffer). Mixing the
 *       two semantics will cause repeated playback or wrong rendering.
 *
 *       `utteranceIndex` groups the OriginalText / TranslatedText /
 *       AudioChunk that belong to the same spoken sentence — UIs can use
 *       it to merge the three streams into the same bubble.
 *
 * [CN]: `onContent` 回调下发的统一载荷。调用方按 `contentType` 分发，
 *       只读取该类型对应的字段：
 *
 *       | contentType     | utteranceIndex | language | text | isTextFinal | audioChunk | audioFormat | isAudioFinal |
 *       |-----------------|:--------------:|:--------:|:----:|:-----------:|:----------:|:-----------:|:------------:|
 *       | OriginalText    |       ●        |  ● (源)  |  ●   |      ●      |     —      |      —      |      —       |
 *       | TranslatedText  |       ●        | ● (目标) |  ●   |      ●      |     —      |      —      |      —       |
 *       | AudioChunk      |       ●        | ● (目标) |  —   |      —      |     ●      |      ●      |      ●       |
 *
 *       注意：`text` 为**累积**值（可直接赋值给 UI），
 *       `audioChunk` 为**增量**片段（应追加到播放缓冲）。
 *       两者语义混用会导致重复播放或显示错误。
 *
 *       `utteranceIndex` 用于把同一句话对应的 OriginalText / TranslatedText /
 *       AudioChunk 归并到同一气泡。
 */
@interface TSAIInterpreterContent : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by startInterpretation...)
 * @chinese 任务唯一标识（与 startInterpretation... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Discriminator for the payload type
 * @chinese 载荷类型判别字段
 */
@property (nonatomic, assign) TSAIInterpreterContentType contentType;

/**
 * @brief 0-based utterance ordinal within the session
 * @chinese 会话内 utterance 序号（从 0 开始）
 *
 * @discussion
 * [EN]: All callbacks belonging to the same utterance (the original text,
 *       its translation and any audio chunks) share the same value.
 *       Increments when VAD detects a new utterance.
 * [CN]: 属于同一段 utterance 的所有回调（原文、译文、音频片段）共享同一值，
 *       VAD 检测到新一段语音时递增。
 */
@property (nonatomic, assign) NSInteger utteranceIndex;

/**
 * @brief Language carried by this payload
 * @chinese 本载荷对应的语言
 *
 * @discussion
 * [EN]: For `OriginalText`, the source language of the speaker. For
 *       `TranslatedText` and `AudioChunk`, the target language of the
 *       translation. Useful when the source language was auto-detected
 *       and the caller wants the resolved concrete value without
 *       consulting config. Never `TSAILanguageAuto` here — by the time
 *       content is emitted, the language has been resolved to a concrete
 *       value (or `TSAILanguageUnknown` if resolution failed on the very
 *       first partials of an `Auto` session).
 * [CN]: `OriginalText` 时为说话人源语言；
 *       `TranslatedText` 与 `AudioChunk` 时为译文目标语言。
 *       便于在源语言被自动检测时，调用方无需查 config 即可直接拿到解析后的具体语言。
 *       本字段不会为 `TSAILanguageAuto`——载荷下发时语言已被解析为具体值
 *       （`Auto` 会话最初几次 partial 解析失败时可能为
 *       `TSAILanguageUnknown`）。
 */
@property (nonatomic, assign) TSAILanguage language;

#pragma mark - Text fields (contentType = OriginalText | TranslatedText)

/**
 * @brief Cumulative recognized / translated text up to the current moment
 * @chinese 截至当前时刻的累积文本
 *
 * @discussion
 * [EN]: Full cumulative text for this utterance. For `OriginalText`, may
 *       be revised before stabilizing (ASR streaming behavior). For
 *       `TranslatedText`, the MT engine may also rewrite earlier words
 *       as more context arrives — do not assume append-only. Callers can
 *       `label.text = content.text` directly without manual concatenation.
 * [CN]: 本段 utterance 截至当前时刻的累积文本。
 *       `OriginalText` 在稳定前可能被修订（ASR 流式行为）；
 *       `TranslatedText` 中 MT 引擎也可能在拿到更多上下文时回改已下发字词，
 *       请勿假设为追加式。
 *       调用方可直接 `label.text = content.text`，无需手动拼接。
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 * @brief Whether the text has stabilized
 * @chinese 文本是否已稳定
 *
 * @discussion
 * [EN]: For `OriginalText`, `YES` means ASR will not revise this
 *       utterance's text further. For `TranslatedText`, `YES` means MT
 *       has finished translating this utterance. Persist / commit work
 *       should typically wait for `YES`.
 * [CN]: `OriginalText` 时 `YES` 表示 ASR 不再修订本段文本；
 *       `TranslatedText` 时 `YES` 表示 MT 已完成本段翻译。
 *       持久化 / 提交类操作通常应等到 `YES` 后再执行。
 */
@property (nonatomic, assign) BOOL isTextFinal;

#pragma mark - AudioChunk fields (contentType = AudioChunk)

/**
 * @brief Translation TTS audio delta segment (append to playback buffer)
 * @chinese 译文 TTS 音频增量片段（应追加到播放缓冲）
 *
 * @discussion
 * [EN]: Newly synthesized audio bytes since the previous AudioChunk
 *       callback within the same utterance. Default format is 16 kHz /
 *       16-bit / mono PCM little-endian; check `audioFormat` for the
 *       actual format.
 * [CN]: 自本段 utterance 上一次 AudioChunk 回调以来新合成的音频字节。
 *       默认格式为 16 kHz / 16-bit / 单声道 PCM 小端；
 *       具体格式以 `audioFormat` 为准。
 */
@property (nonatomic, copy, nullable) NSData *audioChunk;

/**
 * @brief Audio format of `audioChunk`
 * @chinese `audioChunk` 的音频格式
 */
@property (nonatomic, assign) TSAIAudioFormat audioFormat;

/**
 * @brief Whether this is the final audio chunk of the current utterance
 * @chinese 是否为本段 utterance 最后一个音频片段
 *
 * @discussion
 * [EN]: `YES` means no further AudioChunk callbacks will arrive for this
 *       utterance; the next AudioChunk (if any) belongs to a new utterance.
 * [CN]: `YES` 表示本段 utterance 不会再有 AudioChunk 回调，
 *       后续 AudioChunk（若有）归属新一段 utterance。
 */
@property (nonatomic, assign) BOOL isAudioFinal;

@end

NS_ASSUME_NONNULL_END
