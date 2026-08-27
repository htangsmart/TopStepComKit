//
//  TSAIAudioRecordConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/27.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"
#import "TSAudioRecordDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI audio recording session configuration
 * @chinese AI 录音会话配置
 *
 * @discussion
 * [EN]: Configuration for starting an AI audio recording session. It mirrors
 *       the provider-side session config without exposing provider-specific
 *       types in InterfaceKit.
 * [CN]: 用于启动 AI 录音会话的配置。该模型对齐底层 AI 服务会话配置，
 *       但不在 InterfaceKit 暴露厂商专属类型。
 */
@interface TSAIAudioRecordConfig : NSObject <NSCopying>

/**
 * @brief Recording scene
 * @chinese 录音场景
 */
@property (nonatomic, assign) TSAIAudioRecordScene recordingScene;

/**
 * @brief Speech-input language
 * @chinese 语音输入语言
 *
 * @discussion
 * [EN]: Set to `TSAILanguageUnknown` to let the SDK use the current app language.
 *       Assigning `TSAILanguageAuto` is rejected because the recording service
 *       expects a concrete speech-input language when specified.
 * [CN]: 设为 `TSAILanguageUnknown` 时由 SDK 使用当前 App 语言。
 *       写入 `TSAILanguageAuto` 会被拒绝，因为录音服务在指定语言时需要具体的
 *       语音输入语言。
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Whether to allow starting while network is offline
 * @chinese 网络离线时是否允许启动
 *
 * @discussion
 * [EN]: Defaults to NO. When NO, the AI recording service should fail fast if
 *       internet access is unavailable. When YES, providers that support
 *       offline recording may start and sync later.
 * [CN]: 默认 NO。为 NO 时，网络不可用会快速失败；为 YES 时，支持离线录音的
 *       服务可先开始录音并稍后同步。
 */
@property (nonatomic, assign) BOOL allowRecordingWhileOffline;

/**
 * @brief Whether to enable speaker diarization
 * @chinese 是否启用说话人分离
 *
 * @discussion
 * [EN]: Defaults to NO. When enabled, supported providers may return speaker
 *       segments together with real-time transcript results.
 * [CN]: 默认 NO。启用后，支持该能力的 Provider 可随实时转写结果返回说话人片段。
 */
@property (nonatomic, assign) BOOL enableSpeakerDiarization;

/**
 * @brief Create a config with sensible defaults
 * @chinese 创建默认配置
 *
 * @return
 * EN: A new config instance with scene = OnSite, language = Unknown,
 *     allowRecordingWhileOffline = NO, enableSpeakerDiarization = NO
 * CN: 新配置对象，scene = OnSite，language = Unknown，
 *     allowRecordingWhileOffline = NO，enableSpeakerDiarization = NO
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
