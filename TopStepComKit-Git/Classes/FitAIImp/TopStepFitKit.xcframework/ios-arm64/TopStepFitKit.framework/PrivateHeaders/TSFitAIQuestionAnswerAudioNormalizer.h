//
//  TSFitAIQuestionAnswerAudioNormalizer.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TSFitAIQuestionAnswerAudioNormalizer;

/**
 * @brief Delegate for normalized AI question-answer audio
 * @chinese AI 问答音频归一化代理
 */
@protocol TSFitAIQuestionAnswerAudioNormalizerDelegate <NSObject>

/**
 * @brief Receive one normalized audio packet for the current question
 * @chinese 接收当前问题的一包归一化音频
 * @param normalizer EN: Audio normalizer. CN: 音频归一化器。
 * @param opusData EN: Incremental Opus data, or nil. CN: 增量 Opus 数据，可为空。
 * @param pcmData EN: Incremental PCM data, or nil. CN: 增量 PCM 数据，可为空。
 */
- (void)fitAIQuestionAnswerAudioNormalizer:
            (TSFitAIQuestionAnswerAudioNormalizer *)normalizer
                   didProduceOpusData:(nullable NSData *)opusData
                              pcmData:(nullable NSData *)pcmData;

@end

/**
 * @brief Normalize one AI question's incremental and aggregate audio callbacks
 * @chinese 归一化单次 AI 问答的增量与全量音频回调
 *
 * @discussion
 * [EN]: The final aggregate packet is used only to deliver a missing PCM tail.
 *       It never replays audio already delivered by incremental callbacks.
 * [CN]: 结束回调中的全量数据仅用于补齐缺失的 PCM 尾部，不会重放已经通过
 *       增量回调投递的音频。
 */
@interface TSFitAIQuestionAnswerAudioNormalizer : NSObject

/** @brief Normalized audio delegate @chinese 归一化音频代理 */
@property (nonatomic, weak, nullable)
    id<TSFitAIQuestionAnswerAudioNormalizerDelegate> delegate;

/**
 * @brief Begin one question voice input
 * @chinese 开始一次问题语音输入
 * @return EN: YES when a new input was accepted. CN: 接受新输入时返回 YES。
 */
- (BOOL)handleQuestionAnswerVoiceBegin;

/**
 * @brief Handle one incremental question audio packet
 * @chinese 处理一包问题增量音频
 * @param opusData EN: Incremental Opus data. CN: 增量 Opus 数据。
 * @param pcmData EN: Incremental decoded PCM data. CN: 增量解码 PCM 数据。
 */
- (void)handleQuestionAnswerDeltaOpusData:(nullable NSData *)opusData
                                  pcmData:(nullable NSData *)pcmData;

/**
 * @brief Finish one question voice input with its aggregate audio
 * @chinese 使用全量音频结束一次问题语音输入
 * @param opusData EN: Complete Opus data. CN: 完整 Opus 数据。
 * @param pcmData EN: Complete decoded PCM data. CN: 完整解码 PCM 数据。
 * @return EN: YES when the active input was finalized. CN: 当前输入完成时返回 YES。
 */
- (BOOL)handleQuestionAnswerVoiceStopWithOpusData:(nullable NSData *)opusData
                                          pcmData:(nullable NSData *)pcmData;

/** @brief Reset the current question state @chinese 重置当前问题状态 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
