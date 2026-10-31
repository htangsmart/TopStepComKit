//
//  TSAIInterpreterReport.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"
#import "TSAIInterpreterUtterance.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Latest interpretation record without a vendor finalization signal
 * @chinese 厂商未提供定稿信号时的最新同传记录快照
 */
@interface TSAIInterpreterUtteranceSnapshot : NSObject <NSCopying>

/**
 * @brief Stable source-record identifier
 * @chinese 稳定的来源记录标识
 * @discussion [EN]: Used to replace updates of the same record. [CN]: 用于替换同一记录的后续更新。
 * @note [EN]: Does not represent a finalized sentence. [CN]: 不表示句子已定稿。
 */
@property (nonatomic, copy) NSString *sourceRecordIdentifier;

/**
 * @brief Stable zero-based ordinal within the current task
 * @chinese 当前任务内稳定的从零开始的序号
 * @discussion [EN]: Matches streaming utteranceIndex. [CN]: 与流式 utteranceIndex 一致。
 * @note [EN]: Assigned on first observation. [CN]: 首次观察到记录时分配。
 */
@property (nonatomic, assign) NSInteger index;

/**
 * @brief Latest original text
 * @chinese 最新原文
 * @discussion [EN]: May be revised by the vendor. [CN]: 厂商仍可能修改。
 * @note [EN]: Empty when not yet available. [CN]: 尚未返回时为空串。
 */
@property (nonatomic, copy) NSString *originalText;

/**
 * @brief Latest translated text
 * @chinese 最新译文
 * @discussion [EN]: May be revised by the vendor. [CN]: 厂商仍可能修改。
 * @note [EN]: Empty when not yet available. [CN]: 尚未返回时为空串。
 */
@property (nonatomic, copy) NSString *translatedText;

/**
 * @brief Source language selected for this task
 * @chinese 当前任务选择的源语言
 * @discussion [EN]: A concrete configured language. [CN]: 配置中的具体语言。
 * @note [EN]: Never fabricates automatic detection. [CN]: 不伪造自动识别结果。
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language selected for this task
 * @chinese 当前任务选择的目标语言
 * @discussion [EN]: A concrete configured language. [CN]: 配置中的具体语言。
 * @note [EN]: Not an inferred vendor language. [CN]: 不推断厂商未返回的语言。
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

/**
 * @brief Unmodified optional timestamp supplied by the vendor
 * @chinese 厂商提供的可选原始时间戳
 * @discussion [EN]: Preserves the source value without guessing units. [CN]: 保留来源值，不猜测单位。
 * @note [EN]: Nil when unavailable; not a VAD-start timestamp. [CN]: 缺失时为 nil；不是 VAD 起点时间。
 */
@property (nonatomic, copy, nullable) NSString *sourceTimestamp;

@end

/**
 * @brief Reason an interpretation session ended
 * @chinese 同声传译会话结束原因
 */
typedef NS_ENUM(NSInteger, TSAIInterpreterEndReason) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIInterpreterEndReasonUnknown     = -1,
    /// 调用方主动 stop (Caller invoked stop)
    TSAIInterpreterEndReasonUserStop    = 1,
    /// 系统中断（来电、AudioSession 抢占等） (System interruption: incoming call, audio session preemption, ...)
    TSAIInterpreterEndReasonInterrupted = 2,
    /// 运行时错误导致结束 (Ended due to runtime error)
    TSAIInterpreterEndReasonError       = 3,
};

/**
 * @brief AI interpreter session archive
 * @chinese AI 同声传译会话档案
 *
 * @discussion
 * [EN]: Delivered exactly once via the completion handler when the session
 *       ends. Unlike `TSAIChatReport` (which carries metadata only on the
 *       assumption the App has consumed the streaming content itself),
 *       this report is a **session archive** — it carries the full list
 *       of stabilized utterances so that Apps can persist a "translation
 *       history" record directly without re-aggregating the streaming
 *       `onContent` callbacks.
 *       Native services without final markers keep their latest records in
 *       `provisionalUtterances` instead, without promoting them to finalized utterances.
 *
 *       The shape is intentional for interpretation's typical product
 *       shape: a translation-log UI ("here's what you translated with
 *       this client last Tuesday") is the common case, not the exception.
 *
 *       Config-echo fields (languages, voice output / playback flags,
 *       speaker ID) are duplicated here on purpose so each persisted
 *       report is self-describing and survives independently of the
 *       original `TSAIInterpreterConfig` instance.
 *
 * [CN]: 会话结束时通过 completion 回调下发一次。
 *       与 `TSAIChatReport` 仅汇报元信息不同（对话场景假定 App 已自行消费流式内容），
 *       本 Report 是**会话档案**——直接携带已稳定的全部 utterance 列表，
 *       便于 App 直接持久化为"翻译记录"，
 *       而无需自己再消费一次 `onContent` 流并做归并。
 *       原生服务没有定稿标记时，将最新记录保存在 provisionalUtterances，
 *       不提升为已定稿 utterances。
 *
 *       这是为同传典型产品形态有意设计的：
 *       "翻译记录"列表 UI（"上周二跟这位客户都翻译了什么"）是常见需求，并非特例。
 *
 *       配置回显字段（语言、是否产出语音 / 是否自动播放、发音人 ID）
 *       在此处刻意冗余，保证每条持久化记录都是自描述的，
 *       不依赖原 `TSAIInterpreterConfig` 实例。
 */
@interface TSAIInterpreterReport : NSObject

#pragma mark - Identity

/**
 * @brief Task identifier (the same one returned synchronously by startInterpretation...)
 * @chinese 任务唯一标识（与 startInterpretation... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

#pragma mark - Config echo

/**
 * @brief Source language used in the session (always concrete)
 * @chinese 本次会话使用的源语言（始终为具体语言）
 *
 * @discussion
 * [EN]: Echoes `TSAIInterpreterConfig.sourceLanguage`, with one important
 *       resolution: if the config used `TSAILanguageAuto`, this field
 *       carries the language actually detected by the backend (same
 *       value delivered earlier via the `LanguageDetected` event).
 *       Never `Auto`.
 * [CN]: 回显 `TSAIInterpreterConfig.sourceLanguage`，并做一次解析：
 *       若 config 设为 `TSAILanguageAuto`，本字段携带后端实际检测到的语言
 *       （与 `LanguageDetected` 事件下发的值一致）。
 *       本字段不会为 `Auto`。
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language used in the session
 * @chinese 本次会话使用的目标语言
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

/**
 * @brief Whether the session produced TTS audio (echo of config)
 * @chinese 本次会话是否产出译文 TTS 音频（config 回显）
 */
@property (nonatomic, assign) BOOL enableVoiceOutput;

/**
 * @brief Whether the SDK auto-played translated audio on the device (echo of config)
 * @chinese 本次会话是否由 SDK 自动把译文音频送到设备播放（config 回显）
 */
@property (nonatomic, assign) BOOL autoPlayVoice;

/**
 * @brief TTS speaker (voice) identifier used in the session (echo of config)
 * @chinese 本次会话使用的 TTS 发音人标识（config 回显）
 *
 * @discussion
 * [EN]: nil when `enableVoiceOutput` was NO or when the caller did not
 *       specify a speaker (backend used its default).
 * [CN]: `enableVoiceOutput` 为 NO，或调用方未指定发音人（由后端使用默认值）时为 nil。
 */
@property (nonatomic, copy, nullable) NSString *speakerId;

#pragma mark - Session metadata

/**
 * @brief Session start time
 * @chinese 会话开始时间
 */
@property (nonatomic, copy) NSDate *startTime;

/**
 * @brief Session end time
 * @chinese 会话结束时间
 */
@property (nonatomic, copy) NSDate *endTime;

/**
 * @brief Session duration in seconds (endTime - startTime)
 * @chinese 会话总时长（秒，endTime - startTime）
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * @brief Reason the session ended
 * @chinese 会话结束原因
 */
@property (nonatomic, assign) TSAIInterpreterEndReason endReason;

/**
 * @brief Full path to the original audio file
 * @chinese 原始音频文件完整路径
 *
 * @discussion
 * [EN]: Nil when the provider did not persist the session audio.
 * [CN]: Provider 未保存本次会话音频时为 nil。
 */
@property (nonatomic, copy, nullable) NSString *rawAudioFilePath;

#pragma mark - Content archive

/**
 * @brief All finalized utterances in this session, in chronological order
 * @chinese 本次会话所有已稳定 utterance，按时间顺序
 *
 * @discussion
 * [EN]: Each element is a self-contained record (original text + translated
 *       text + per-utterance languages + start time). Empty when the
 *       session ended before any VAD utterance was produced (e.g. stopped
 *       immediately, or `endReason == Error` on session-start failure).
 *
 *       This list is the authoritative session history — the streaming
 *       `onContent` callbacks delivered the same content earlier, but the
 *       App is not required to aggregate them; persisting `utterances`
 *       directly is both correct and idiomatic.
 *
 * [CN]: 每个元素都是自包含记录（原文 + 译文 + 该句源 / 目标语言 + 起始时间）。
 *       若会话结束前未产出任何 VAD utterance（如立即 stop，或会话启动即失败的
 *       `endReason == Error`），该数组为空。
 *
 *       该列表为会话历史的权威载体——
 *       虽然流式 `onContent` 此前已分次下发同样内容，
 *       但 App 无需自行归并，直接持久化 `utterances` 即可，
 *       这是推荐做法。
 */
@property (nonatomic, copy) NSArray<TSAIInterpreterUtterance *> *utterances;

/**
 * @brief Latest records whose text finality cannot be established
 * @chinese 尚无法确认文本定稿的最新记录
 *
 * @discussion
 * [EN]: Separate from finalized utterances. Provider-managed services without
 *       final markers return their latest snapshots here; late vendor updates
 *       after completion are not promised to be included.
 * [CN]: 与已定稿 utterances 分开；没有定稿标记的原生服务在此返回最新快照，
 *       不承诺包含 completion 之后厂商迟到的更新。
 *
 * @note
 * [EN]: Defaults to an empty array. Persistence must preserve its provisional status.
 * [CN]: 默认为空数组；持久化时须保留未定稿状态。
 */
@property (nonatomic, copy) NSArray<TSAIInterpreterUtteranceSnapshot *> *provisionalUtterances;

@end

NS_ASSUME_NONNULL_END
