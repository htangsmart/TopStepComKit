//
//  TSAIAudioRecordConfig.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/27.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"
#import "TSAudioRecordDefines.h"
#import "TSAIAudioRecordTranscriptionState.h"

@class TSAIAudioRouteConfiguration;

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
 * @brief Input route used by this recording session
 * @chinese 本次 AI 录音会话使用的输入路由
 *
 * @discussion
 * [EN]: The output channel must be None. Nil requests automatic input resolution.
 * [CN]: 输出通道必须为 None；为 nil 时请求自动解析输入通道。
 */
@property (nonatomic, copy, nullable) TSAIAudioRouteConfiguration *audioRouteConfiguration;

/**
 * @brief Party that supplies PCM audio for an App-initiated recording
 * @chinese App 发起录音时的音频提供方
 *
 * @discussion
 * [EN]: Defaults to Device. When set to App, the SDK does not open any
 *       microphone and does not resolve `audioRouteConfiguration`; the host App
 *       owns AVAudioSession, microphone permission and capture, and must push
 *       16 kHz mono Int16LE PCM with `appendAIAudioRecordingPCMData:error:`.
 *       If the connected device supports App-initiated AI recording, the device
 *       is still asked to enter its recording state; otherwise the recording runs
 *       on the App side only. When a start consumes a pending device request,
 *       the device request decides the audio source and this value is ignored.
 * [CN]: 默认 Device。设为 App 时，SDK 不打开任何麦克风，也不解析
 *       `audioRouteConfiguration`；AVAudioSession、麦克风权限与采集均由宿主
 *       App 负责，App 需通过 `appendAIAudioRecordingPCMData:error:` 推送
 *       16 kHz 单声道 Int16LE PCM。若已连接设备支持 App 发起 AI 录音，
 *       仍会通知设备进入录音状态；否则仅在 App 侧录音。消费设备发起的
 *       待处理请求时，音频提供方由设备请求决定，本属性被忽略。
 */
@property (nonatomic, assign) TSAIAudioRecordInputSource inputSource;

/**
 * @brief Exact device request expected by this start, or nil for the legacy App entry
 * @chinese 本次启动必须接受的设备请求标识；nil 保留原有 App 入口。标识过期或不匹配时失败，不改为 App 主动启动。
 */
@property (nonatomic, copy, nullable) NSString *expectedDeviceRequestIdentifier;

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
 *       offline recording capture locally without automatically uploading history.
 * [CN]: 默认 NO。为 NO 时，网络不可用会快速失败；为 YES 时，支持离线录音的
 *       服务独立进行本地收音，不自动上传历史录音。
 */
@property (nonatomic, assign) BOOL allowRecordingWhileOffline;

/** @brief Optional cloud recovery; defaults to Disabled
 * @chinese 可选云端恢复策略，默认 Disabled；仅独立本地录音路径使用
 */
@property (nonatomic, assign) TSAIAudioRecordTranscriptionRecoveryPolicy transcriptionRecoveryPolicy;

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
 * @brief Whether real-time transcripts are forwarded to the device screen
 * @chinese 是否把实时转写文本下发到设备屏幕显示
 *
 * @discussion
 * [EN]: Defaults to NO. When YES and the connected device declares transcript
 *       display support, the SDK forwards every transcript sentence to the device
 *       in order with acknowledgement tracking. Intended for sessions whose
 *       microphone is the charging case, so the case screen can show the text.
 * [CN]: 默认 NO。为 YES 且设备声明支持转写显示时，SDK 按顺序把每句转写文本
 *       下发到设备并跟踪应答。用于充电仓拾音的会话，让仓屏显示转写内容。
 */
@property (nonatomic, assign) BOOL deliversTranscriptToDevice;

/**
 * @brief Create a config with sensible defaults
 * @chinese 创建默认配置
 *
 * @return
 * EN: A new config instance with route = Opus/None/UseAutomaticRoute,
 *     inputSource = Device, scene = OnSite, language = Unknown, allowRecordingWhileOffline = NO,
 *     enableSpeakerDiarization = NO, deliversTranscriptToDevice = NO
 * CN: 新配置对象，路由 = Opus/None/UseAutomaticRoute，inputSource = Device，scene = OnSite，
 *     language = Unknown，allowRecordingWhileOffline = NO，
 *     enableSpeakerDiarization = NO，deliversTranscriptToDevice = NO
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
