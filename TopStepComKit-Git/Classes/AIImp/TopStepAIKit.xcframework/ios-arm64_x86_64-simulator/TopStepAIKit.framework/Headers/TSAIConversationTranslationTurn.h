//
//  TSAIConversationTranslationTurn.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIConversationTranslationDefines.h"
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One utterance turn inside a conversation-translation session
 * @chinese 对话翻译会话中的一轮发言
 *
 * @discussion
 * [EN]: Immutable value delivered inside `TSAIConversationTranslationSnapshot`.
 *       Text fields grow while the turn streams and are authoritative once
 *       `isFinal` is YES.
 * [CN]: 随 `TSAIConversationTranslationSnapshot` 下发的不可变值对象。
 *       流式阶段文本会持续增长，`isFinal` 为 YES 后即为最终结果。
 */
@interface TSAIConversationTranslationTurn : NSObject <NSCopying>

/**
 * @brief Stable identifier of this turn
 * @chinese 本轮的稳定标识
 */
@property (nonatomic, copy, readonly) NSString *turnId;

/**
 * @brief Zero-based position inside the session
 * @chinese 在会话中的序号，从 0 开始
 */
@property (nonatomic, assign, readonly) NSInteger index;

/**
 * @brief Participant who spoke in this turn
 * @chinese 本轮的发言参与者
 */
@property (nonatomic, assign, readonly) TSAIConversationParticipant speaker;

/**
 * @brief Side that started this turn (App button or device key)
 * @chinese 发起本轮的一方（App 按钮或设备按键）
 */
@property (nonatomic, assign, readonly) TSAISessionInitiator initiator;

/**
 * @brief Language spoken in this turn
 * @chinese 本轮的源语言
 */
@property (nonatomic, assign, readonly) TSAILanguage sourceLanguage;

/**
 * @brief Language of the translation
 * @chinese 本轮的目标语言
 */
@property (nonatomic, assign, readonly) TSAILanguage targetLanguage;

/**
 * @brief Recognized original text
 * @chinese 识别出的原文
 */
@property (nonatomic, copy, readonly, nullable) NSString *originalText;

/**
 * @brief Translated text
 * @chinese 译文
 */
@property (nonatomic, copy, readonly, nullable) NSString *translatedText;

/**
 * @brief Whether recognition and translation of this turn have finished
 * @chinese 本轮识别与翻译是否已结束
 */
@property (nonatomic, assign, readonly) BOOL isFinal;

/**
 * @brief Synthesized translation audio archived for replay
 * @chinese 归档供重播的译文语音
 *
 * @note
 * [EN]: 16 kHz mono signed 16-bit little-endian PCM; nil when no TTS was produced.
 * [CN]: 16 kHz 单声道 16 位小端 PCM；未生成 TTS 时为 nil。
 */
@property (nonatomic, copy, readonly, nullable) NSData *translatedAudio;

/**
 * @brief Format of `translatedAudio`
 * @chinese `translatedAudio` 的格式
 */
@property (nonatomic, assign, readonly) TSAIAudioFormat translatedAudioFormat;

/**
 * @brief Create an immutable turn
 * @chinese 创建不可变轮次
 *
 * @param turnId EN: Stable identifier. CN: 稳定标识。
 * @param index EN: Position in the session. CN: 会话内序号。
 * @param speaker EN: Speaking participant. CN: 发言参与者。
 * @param initiator EN: Starting side. CN: 发起方。
 * @param sourceLanguage EN: Spoken language. CN: 源语言。
 * @param targetLanguage EN: Translation language. CN: 目标语言。
 * @param originalText EN: Recognized text. CN: 原文。
 * @param translatedText EN: Translated text. CN: 译文。
 * @param isFinal EN: Whether the turn is final. CN: 是否终态。
 * @param translatedAudio EN: Archived PCM. CN: 归档 PCM。
 * @param translatedAudioFormat EN: Audio format. CN: 音频格式。
 *
 * @return
 * EN: Immutable turn
 * CN: 不可变轮次
 */
+ (instancetype)turnWithId:(NSString *)turnId
                     index:(NSInteger)index
                   speaker:(TSAIConversationParticipant)speaker
                 initiator:(TSAISessionInitiator)initiator
            sourceLanguage:(TSAILanguage)sourceLanguage
            targetLanguage:(TSAILanguage)targetLanguage
              originalText:(nullable NSString *)originalText
            translatedText:(nullable NSString *)translatedText
                   isFinal:(BOOL)isFinal
           translatedAudio:(nullable NSData *)translatedAudio
     translatedAudioFormat:(TSAIAudioFormat)translatedAudioFormat;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
