//
//  TSAIBudsInterpreterStreamMapper+Private.h
//  TopStepAIKit
//
//  Created by Claude on 2026/9/23.
//

#import <Foundation/Foundation.h>
#import "TSAIInterpreterContent.h"
#import "TSAIInterpreterEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vendor-neutral snapshot of one AIBuds interpretation stream callback
 * @chinese 一次 AIBuds 同传流式回调的厂商无关快照
 *
 * @discussion
 * [EN]: Mirrors the fields of `AIBudsSimultaneousInterpretationDataModel`
 *       that matter for content mapping. The three sequence fields are
 *       independent: translation and TTS usually lag behind recognition,
 *       so they must never be replaced by the source sequence.
 * [CN]: 对齐 `AIBudsSimultaneousInterpretationDataModel` 中与内容映射相关的字段。
 *       三个序号彼此独立：译文与 TTS 通常滞后于识别，不能用原文序号替代。
 */
@interface TSAIBudsInterpreterStreamFrame : NSObject

/** @brief Vendor response sequence @chinese 厂商响应序号（仅用于日志，不作为句序号） */
@property (nonatomic, assign) NSInteger sequence;
/** @brief Cumulative source text @chinese 原文累计文本 */
@property (nonatomic, copy, nullable) NSString *sourceText;
/** @brief Whether the source text is definite @chinese 原文是否已定稿 */
@property (nonatomic, assign) BOOL isSourceTextDefinite;
/** @brief Utterance index of the source text @chinese 原文所属句序号 */
@property (nonatomic, strong, nullable) NSNumber *sourceTextSequence;
/** @brief Cumulative translated text @chinese 译文累计文本 */
@property (nonatomic, copy, nullable) NSString *targetText;
/** @brief Whether the translated text is definite @chinese 译文是否已定稿 */
@property (nonatomic, assign) BOOL isTargetTextDefinite;
/** @brief Utterance index of the translated text @chinese 译文所属句序号 */
@property (nonatomic, strong, nullable) NSNumber *targetTextSequence;
/** @brief Decoded TTS PCM delta @chinese 已解码的 TTS PCM 增量 */
@property (nonatomic, copy, nullable) NSData *audioData;
/** @brief Translation index the TTS audio belongs to @chinese TTS 音频对应的译文句序号 */
@property (nonatomic, strong, nullable) NSNumber *audioTargetTextSequence;

@end

/**
 * @brief Kind of a mapped stream output
 * @chinese 映射输出类型
 */
typedef NS_ENUM(NSInteger, TSAIBudsInterpreterStreamOutputKind) {
    /// 内容回调 (Content callback)
    TSAIBudsInterpreterStreamOutputKindContent = 0,
    /// 事件回调 (Event callback)
    TSAIBudsInterpreterStreamOutputKindEvent = 1,
};

/**
 * @brief One ordered output produced by the stream mapper
 * @chinese 流映射器产出的一条有序输出
 */
@interface TSAIBudsInterpreterStreamOutput : NSObject

/** @brief Output kind @chinese 输出类型 */
@property (nonatomic, assign, readonly) TSAIBudsInterpreterStreamOutputKind kind;
/** @brief Content payload when kind is Content @chinese kind 为 Content 时的内容载荷 */
@property (nonatomic, strong, readonly, nullable) TSAIInterpreterContent *content;
/** @brief Event type when kind is Event @chinese kind 为 Event 时的事件类型 */
@property (nonatomic, assign, readonly) TSAIInterpreterEventType eventType;
/** @brief Utterance index of the event @chinese 事件对应的句序号 */
@property (nonatomic, assign, readonly) NSInteger eventUtteranceIndex;

@end

/**
 * @brief Stateful mapper from AIBuds stream frames to interpreter contract callbacks
 * @chinese 将 AIBuds 流式回调映射为同传契约回调的有状态映射器
 *
 * @discussion
 * [EN]: One instance per interpretation session. Guarantees the contract of
 *       `TSAIInterpreterContent`: original text, translated text and audio of
 *       the same utterance share one `utteranceIndex`; text of an utterance is
 *       frozen once final; `isAudioFinal` marks the end of one utterance's audio.
 *       Not thread-safe; call it from the Provider lifecycle queue.
 * [CN]: 每个同传会话一个实例。保证 `TSAIInterpreterContent` 契约：
 *       同一句的原文、译文、音频共享同一 `utteranceIndex`；
 *       某句文本定稿后不再变化；`isAudioFinal` 标记单句音频结束。
 *       非线程安全，需在 Provider 生命周期队列调用。
 */
@interface TSAIBudsInterpreterStreamMapper : NSObject

/** @brief Finalized source sentences keyed by utterance index @chinese 按句序号记录的已定稿原文 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSString *> *finalSourceSentences;
/** @brief Finalized translated sentences keyed by utterance index @chinese 按句序号记录的已定稿译文 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSString *> *finalTargetSentences;

/**
 * @brief Create a mapper for one session
 * @chinese 为单个会话创建映射器
 * @param taskId EN: Session task identifier. CN: 会话任务标识。
 * @param sourceLanguage EN: Language written to original-text content. CN: 原文内容携带的语言。
 * @param targetLanguage EN: Language written to translation and audio content. CN: 译文与音频内容携带的语言。
 * @return EN: Mapper instance. CN: 映射器实例。
 */
- (instancetype)initWithTaskId:(NSString *)taskId
                sourceLanguage:(TSAILanguage)sourceLanguage
                targetLanguage:(TSAILanguage)targetLanguage NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Map one stream frame to ordered outputs
 * @chinese 将一次流式回调映射为有序输出
 * @param frame EN: Stream frame. CN: 流式回调快照。
 * @param isStreamFinal EN: Whether the vendor marked the whole stream as finished. CN: 厂商是否标记整条流结束。
 * @return EN: Outputs to emit in order. CN: 需按顺序下发的输出。
 */
- (NSArray<TSAIBudsInterpreterStreamOutput *> *)outputsForFrame:(TSAIBudsInterpreterStreamFrame *)frame
                                                  isStreamFinal:(BOOL)isStreamFinal;

/**
 * @brief Flush outputs owed at session end
 * @chinese 会话结束时补齐尚未下发的终态输出
 * @return EN: Outputs to emit in order, such as the pending audio final. CN: 需按顺序下发的输出，例如未结束句的音频终态。
 */
- (NSArray<TSAIBudsInterpreterStreamOutput *> *)finishOutputs;

@end

NS_ASSUME_NONNULL_END
