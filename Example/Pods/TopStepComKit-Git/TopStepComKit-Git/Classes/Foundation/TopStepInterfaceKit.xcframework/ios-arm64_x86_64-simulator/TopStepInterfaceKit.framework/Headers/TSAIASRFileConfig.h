//
//  TSAIASRFileConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming ASR request configuration for a local audio file
 * @chinese 文件流式语音识别请求配置
 *
 * @discussion
 * [EN]: Configuration for recognizing a local audio file via
 *       `recognizeSpeechWithFileURL:config:onPartialResult:completion:`.
 *       File-based ASR is always online — there is no offline fallback option.
 * [CN]: 用于 `recognizeSpeechWithFileURL:config:onPartialResult:completion:`
 *       的本地音频文件识别配置。
 *       文件 ASR 始终走在线识别，不提供离线降级选项。
 */
@interface TSAIASRFileConfig : NSObject

/**
 * @brief Recognition language
 * @chinese 识别语言
 *
 * @discussion
 * [EN]: See `TSAILanguage` in TSAIDefines.h. Must be a concrete language —
 *       `TSAILanguageAuto` is not allowed because the recognizer needs
 *       to know the language up front; passing it returns an
 *       invalid-parameter error from the underlying SDK.
 *       If a target language is not covered by the enum, contact the SDK
 *       team to extend it.
 * [CN]: 见 TSAIDefines.h 中的 `TSAILanguage`。必须为具体语言——
 *       不允许传 `TSAILanguageAuto`，因为识别引擎必须事先知道语言；
 *       底层 SDK 会以参数错误返回。
 *       若目标语言未被覆盖，请联系 SDK 团队扩展枚举。
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Audio format of the input file
 * @chinese 输入音频文件的格式
 *
 * @discussion
 * [EN]: Defaults to `TSAIAudioFormatNone` when created via the factory
 *       method, meaning the SDK will sniff the format from the file header
 *       (works for self-describing formats such as mp3 / wav / opus).
 *       Raw PCM input must specify the format explicitly.
 * [CN]: 通过工厂方法创建时默认为 `TSAIAudioFormatNone`，
 *       表示由 SDK 通过文件头嗅探格式（适用于 mp3 / wav / opus 等带头格式）。
 *       裸 PCM 输入必须显式指定格式。
 */
@property (nonatomic, assign) TSAIAudioFormat audioFormat;

/**
 * @brief Create a config with the given language
 * @chinese 通过识别语言创建配置
 *
 * @param language
 * EN: Recognition language
 * CN: 识别语言
 *
 * @return
 * EN: A new config instance (audioFormat defaults to None / sniff)
 * CN: 新创建的配置对象（audioFormat 默认为 None / 嗅探）
 */
+ (instancetype)configWithLanguage:(TSAILanguage)language;

@end

NS_ASSUME_NONNULL_END
