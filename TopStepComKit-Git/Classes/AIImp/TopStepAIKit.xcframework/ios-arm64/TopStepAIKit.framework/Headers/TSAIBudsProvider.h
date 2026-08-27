//
//  TSAIBudsProvider.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/29.
//

#import <Foundation/Foundation.h>
#import "TSAIProvider.h"
#import "TSAITranslateProvider.h"
#import "TSAISpeechProvider.h"
#import "TSAIAssistantProvider.h"
#import "TSAIInterpreterProvider.h"
#import "TSAIAudioRecordProvider.h"
#import "TSAIImageGenerationProvider.h"
#import "TSAIQuestionAnswerProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds-backed AI provider
 * @chinese 基于 AIBuds 的 AI Provider
 */
@interface TSAIBudsProvider : NSObject <TSAIProvider>

/**
 * @brief Stable identifier of the AIBuds provider
 * @chinese AIBuds Provider 的稳定标识
 */
@property (nonatomic, copy, readonly) NSString *providerIdentifier;

/**
 * @brief Current AIBuds authorization state
 * @chinese AIBuds 当前鉴权状态
 */
@property (atomic, assign, readonly) TSAIAuthorizationState authorizationState;

/**
 * @brief Return the translation capability provider
 * @chinese 返回翻译能力 Provider
 * @return EN: Translation provider. CN: 翻译能力 Provider。
 */
- (id<TSAITranslateProvider>)translateProvider;

/**
 * @brief Return the speech capability provider
 * @chinese 返回语音能力 Provider
 * @return EN: Speech provider. CN: 语音能力 Provider。
 */
- (id<TSAISpeechProvider>)speechProvider;

/**
 * @brief Return the assistant capability provider
 * @chinese 返回助手能力 Provider
 * @return EN: Assistant provider. CN: 助手能力 Provider。
 */
- (id<TSAIAssistantProvider>)assistantProvider;

/**
 * @brief Return the question-answer capability provider
 * @chinese 返回问答能力 Provider
 * @return EN: Question-answer provider. CN: 问答能力 Provider。
 */
- (id<TSAIQuestionAnswerProvider>)questionAnswerProvider;

/**
 * @brief Return the interpretation capability provider
 * @chinese 返回同传能力 Provider
 * @return EN: Interpretation provider. CN: 同传能力 Provider。
 */
- (id<TSAIInterpreterProvider>)interpreterProvider;

/**
 * @brief Return the audio recording capability provider
 * @chinese 返回录音能力 Provider
 * @return EN: Audio recording provider. CN: 录音能力 Provider。
 */
- (id<TSAIAudioRecordProvider>)audioRecordProvider;

/**
 * @brief Return the image generation capability provider
 * @chinese 返回图片生成能力 Provider
 * @return EN: Image generation provider. CN: 图片生成能力 Provider。
 */
- (id<TSAIImageGenerationProvider>)imageGenerationProvider;

@end

NS_ASSUME_NONNULL_END
