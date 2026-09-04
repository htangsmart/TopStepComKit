//
//  TSAIUseCaseParameters.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAudioRecordDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable typed parameters for one AI use case
 * @chinese 单个 AI 用例的不可变强类型参数
 *
 * @discussion
 * [EN]: The kind property determines which value property is meaningful.
 * [CN]: kind 属性决定哪个值属性具有业务含义。
 */
@interface TSAIUseCaseParameters : NSObject <NSCopying>

/** @brief Parameter discriminator @chinese 参数类型判别值 */
@property (nonatomic, assign, readonly) TSAIUseCaseParameterKind kind;

/** @brief Recording scene when kind is AudioRecording @chinese kind 为 AudioRecording 时的录音场景 */
@property (nonatomic, assign, readonly) TSAIAudioRecordScene recordingScene;

/** @brief Translation mode when kind is VoiceTranslation @chinese kind 为 VoiceTranslation 时的翻译模式 */
@property (nonatomic, assign, readonly) TSAIVoiceTranslationMode voiceTranslationMode;

/**
 * @brief Create parameters for an audio-recording use case
 * @chinese 创建 AI 录音用例参数
 *
 * @param scene
 * EN: Recording scene to preserve in the start request
 * CN: 需要在启动请求中保留的录音场景
 *
 * @return
 * EN: Immutable audio-recording parameters
 * CN: 不可变 AI 录音参数
 */
+ (instancetype)audioRecordingParametersWithScene:(TSAIAudioRecordScene)scene;

/**
 * @brief Create parameters for a voice-translation use case
 * @chinese 创建语音翻译用例参数
 *
 * @param mode
 * EN: Translation mode to preserve in the start request
 * CN: 需要在启动请求中保留的翻译模式
 *
 * @return
 * EN: Immutable voice-translation parameters
 * CN: 不可变语音翻译参数
 */
+ (instancetype)voiceTranslationParametersWithMode:(TSAIVoiceTranslationMode)mode;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
