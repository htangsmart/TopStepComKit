//
//  TSAIInterpreterUtterance.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One finalized utterance in an interpretation session
 * @chinese 同声传译会话中的一段已稳定 utterance
 *
 * @discussion
 * [EN]: A self-contained record of one VAD-segmented utterance after both
 *       ASR and MT have stabilized. Used as the element type of
 *       `TSAIInterpreterReport.utterances`, which is the canonical
 *       session-history archive — Apps that need a "translation log" UI
 *       should persist this list directly instead of re-aggregating the
 *       streaming `onContent` callbacks themselves.
 *
 *       Each utterance carries its own source / target language so a
 *       persisted record remains self-describing even if the App
 *       (mistakenly) reuses one storage table across different language
 *       pairs. The languages are always concrete values — never `Auto`,
 *       even for sessions whose config used `sourceLanguage = Auto`.
 *
 * [CN]: 一段经 VAD 切分、ASR / MT 均已稳定后的自包含 utterance 记录。
 *       作为 `TSAIInterpreterReport.utterances` 的元素，
 *       是会话历史档案的权威载体——
 *       需要"翻译记录"UI 的 App 应直接持久化该数组，
 *       而不必自行再消费一次 `onContent` 流。
 *
 *       每段 utterance 都自带源 / 目标语言，
 *       即使 App（不慎）把不同语言对的记录混入同一张表，
 *       单条记录依然是自描述的。
 *       此处语言均为具体值——即使会话 config 中
 *       `sourceLanguage = Auto`，最终落到 utterance 上时也已解析。
 */
@interface TSAIInterpreterUtterance : NSObject

/**
 * @brief 0-based ordinal within the session
 * @chinese 会话内序号（从 0 开始）
 *
 * @discussion
 * [EN]: Matches the `utteranceIndex` carried by the streaming `onContent`
 *       callbacks of the same utterance.
 * [CN]: 与本段 utterance 流式 `onContent` 回调中的 `utteranceIndex` 一致。
 */
@property (nonatomic, assign) NSInteger index;

/**
 * @brief When the speaker started this utterance (VAD speech-start)
 * @chinese 本段 utterance 开始时间（VAD 检测到说话起点）
 */
@property (nonatomic, copy) NSDate *startTime;

/**
 * @brief Final stabilized original text (from ASR)
 * @chinese 已稳定的最终原文（来自 ASR）
 *
 * @discussion
 * [EN]: Equivalent to the last `OriginalText` content payload of this
 *       utterance with `isTextFinal == YES`.
 * [CN]: 等同于本段 utterance 最后一次 `isTextFinal == YES` 的
 *       `OriginalText` 载荷文本。
 */
@property (nonatomic, copy) NSString *originalText;

/**
 * @brief Final stabilized translated text (from MT)
 * @chinese 已稳定的最终译文（来自 MT）
 *
 * @discussion
 * [EN]: Equivalent to the last `TranslatedText` content payload of this
 *       utterance with `isTextFinal == YES`. May be empty if the MT
 *       pipeline failed for this utterance while ASR succeeded.
 * [CN]: 等同于本段 utterance 最后一次 `isTextFinal == YES` 的
 *       `TranslatedText` 载荷文本。
 *       若 ASR 成功但 MT 失败，可能为空串。
 */
@property (nonatomic, copy) NSString *translatedText;

/**
 * @brief Source language of this utterance (always concrete)
 * @chinese 本段 utterance 的源语言（始终为具体语言）
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language of this utterance (always concrete)
 * @chinese 本段 utterance 的目标语言（始终为具体语言）
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

@end

NS_ASSUME_NONNULL_END
