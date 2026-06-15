//
//  TSAIChatContent.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"
#import "TSAIChatIntent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI chat content kind
 * @chinese AI 对话内容类型
 *
 * @discussion
 * [EN]: Discriminator for the polymorphic `TSAIChatContent` payload. Different
 *       kinds populate different fields — see field-level documentation on
 *       `TSAIChatContent`.
 * [CN]: `TSAIChatContent` 多态载荷的类型判别字段。
 *       不同类型激活不同字段，详见 `TSAIChatContent` 各字段说明。
 */
typedef NS_ENUM(NSInteger, TSAIChatContentType) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIChatContentTypeUnknown    = -1,
    /// ASR 出的用户问题文本（累积） (User question text from ASR, cumulative)
    TSAIChatContentTypeQuestion   = 1,
    /// LLM 出的 AI 回答文本（累积） (AI answer text from LLM, cumulative)
    TSAIChatContentTypeAnswer     = 2,
    /// TTS 合成的音频片段（增量） (TTS audio segment, delta)
    TSAIChatContentTypeAudioChunk = 3,
    /// 识别到的指令型意图 (Recognized command-style intent)
    TSAIChatContentTypeIntent     = 4,
};

/**
 * @brief Streaming content payload during an AI chat session
 * @chinese AI 对话会话中的流式内容载荷
 *
 * @discussion
 * [EN]: Unified payload delivered through the `onContent` callback. Callers
 *       dispatch by `contentType` and read only the fields relevant to that
 *       type:
 *
 *       | contentType   | text | isTextFinal | audioChunk | isAudioFinal | intent |
 *       |---------------|:----:|:-----------:|:----------:|:------------:|:------:|
 *       | Question      |  ●   |      ●      |     —      |      —       |   —    |
 *       | Answer        |  ●   |      ●      |     —      |      —       |   —    |
 *       | AudioChunk    |  —   |      —      |     ●      |      ●       |   —    |
 *       | Intent        |  —   |      —      |     —      |      —       |   ●    |
 *
 *       Important: `text` is **cumulative** (assign directly to UI), while
 *       `audioChunk` is a **delta** (append to playback buffer). Mixing the
 *       two semantics will cause repeated playback or wrong rendering.
 *
 *       `roundIndex` lets callers commit per-round work (persist Q&A pairs,
 *       newline in transcript, etc.). One session contains one or more rounds
 *       segmented by VAD.
 *
 * [CN]: `onContent` 回调下发的统一载荷。调用方按 `contentType` 分发，
 *       只读取该类型对应的字段：
 *
 *       | contentType   | text | isTextFinal | audioChunk | isAudioFinal | intent |
 *       |---------------|:----:|:-----------:|:----------:|:------------:|:------:|
 *       | Question      |  ●   |      ●      |     —      |      —       |   —    |
 *       | Answer        |  ●   |      ●      |     —      |      —       |   —    |
 *       | AudioChunk    |  —   |      —      |     ●      |      ●       |   —    |
 *       | Intent        |  —   |      —      |     —      |      —       |   ●    |
 *
 *       注意：`text` 为**累积**值（可直接赋值给 UI），
 *       `audioChunk` 为**增量**片段（应追加到播放缓冲）。
 *       两者语义混用会导致重复播放或显示错误。
 *
 *       `roundIndex` 用于按轮次提交工作（持久化问答对、文本换行等）。
 *       一次会话包含一轮或多轮，由 VAD 自动断句。
 */
@interface TSAIChatContent : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by startChat...)
 * @chinese 任务唯一标识（与 startChat... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Discriminator for the payload type
 * @chinese 载荷类型判别字段
 */
@property (nonatomic, assign) TSAIChatContentType contentType;

/**
 * @brief 0-based round ordinal within the session
 * @chinese 会话内问答轮次序号（从 0 开始）
 *
 * @discussion
 * [EN]: All callbacks belonging to the same Q&A round share the same value.
 *       Increments when VAD detects a new user utterance.
 * [CN]: 同一问答轮的所有回调共享同一值，VAD 检测到新一句用户话语时递增。
 */
@property (nonatomic, assign) NSInteger roundIndex;

#pragma mark - Question / Answer fields (contentType = Question | Answer)

/**
 * @brief Cumulative recognized / generated text up to the current moment
 * @chinese 截至当前时刻的累积文本
 *
 * @discussion
 * [EN]: Full cumulative text. For `Question`, may be revised before
 *       stabilizing (ASR streaming behavior). For `Answer`, append-only
 *       (LLM streaming behavior). Callers can `label.text = content.text`
 *       directly without manual concatenation.
 * [CN]: 完整累积文本。`Question` 在稳定前可能被修订（ASR 流式行为）；
 *       `Answer` 为追加式（LLM 流式行为）。
 *       调用方可直接 `label.text = content.text`，无需手动拼接。
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 * @brief Whether the text has stabilized
 * @chinese 文本是否已稳定
 *
 * @discussion
 * [EN]: For `Question`, `YES` means ASR will not revise this round's text
 *       further. For `Answer`, `YES` means LLM has finished this round's
 *       reply. Persist / commit work should typically wait for `YES`.
 * [CN]: `Question` 时 `YES` 表示 ASR 不再修订本轮文本；
 *       `Answer` 时 `YES` 表示 LLM 已完成本轮回复。
 *       持久化 / 提交类操作通常应等到 `YES` 后再执行。
 */
@property (nonatomic, assign) BOOL isTextFinal;

#pragma mark - AudioChunk fields (contentType = AudioChunk)

/**
 * @brief TTS audio delta segment (append to playback buffer)
 * @chinese TTS 音频增量片段（应追加到播放缓冲）
 *
 * @discussion
 * [EN]: Newly synthesized audio bytes since the previous AudioChunk callback
 *       in the same round. Default format is 16 kHz / 16-bit / mono PCM
 *       little-endian; check `audioFormat` for the actual format.
 * [CN]: 自本轮上一次 AudioChunk 回调以来新合成的音频字节。
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
 * @brief Whether this is the final audio chunk of the current round
 * @chinese 是否为本轮最后一个音频片段
 *
 * @discussion
 * [EN]: `YES` means no further AudioChunk callbacks will arrive for this
 *       round; the next AudioChunk (if any) belongs to a new round.
 * [CN]: `YES` 表示本轮不会再有 AudioChunk 回调，
 *       后续 AudioChunk（若有）归属新一轮。
 */
@property (nonatomic, assign) BOOL isAudioFinal;

#pragma mark - Intent fields (contentType = Intent)

/**
 * @brief Recognized command-style intent
 * @chinese 识别到的指令型意图
 */
@property (nonatomic, strong, nullable) TSAIChatIntent *intent;

@end

NS_ASSUME_NONNULL_END
