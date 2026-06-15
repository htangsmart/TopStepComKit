//
//  TSAIChatConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI chat session configuration
 * @chinese AI 语音对话会话配置
 *
 * @discussion
 * [EN]: Configuration for a single AI chat session started via
 *       `startChatWithConfig:onContent:onEvent:completion:`. A chat session is
 *       an end-to-end voice conversation: device microphone audio is fed into
 *       the pipeline, recognized text is sent to the LLM, and the LLM reply
 *       is streamed back as text plus optional TTS audio. Multiple Q&A rounds
 *       can happen within a single session, segmented by VAD.
 * [CN]: 单次 AI 对话会话的配置，通过
 *       `startChatWithConfig:onContent:onEvent:completion:` 启动。
 *       一次会话即一次端到端语音对话：设备麦克风音频灌入识别管道，
 *       识别文本送至 LLM，LLM 回复以文本（及可选的 TTS 音频）流式回传。
 *       一次会话内可由 VAD 自动断句产生多轮问答。
 */
@interface TSAIChatConfig : NSObject

/**
 * @brief Speech-input language hint (BCP-47)
 * @chinese 语音输入语言提示（BCP-47）
 *
 * @discussion
 * [EN]: BCP-47 language tag such as `"zh-CN"`, `"en-US"`. When nil, the SDK
 *       falls back to the device-UI language. Using a string instead of an
 *       enum lets the AI provider add new languages without bumping the SDK.
 * [CN]: BCP-47 语言标签，如 `"zh-CN"`、`"en-US"`。
 *       为 nil 时由 SDK 回退到设备 UI 语言。
 *       使用字符串而非枚举，便于 AI 提供方新增语种时无需升级 SDK。
 */
@property (nonatomic, copy, nullable) NSString *languageHint;

/**
 * @brief Initial prompt injected into the conversation
 * @chinese 注入对话的初始 prompt
 *
 * @discussion
 * [EN]: Optional context for the AI agent, typically a user-profile snippet
 *       (e.g. "User's location is Beijing. User's name is John."). Sent once
 *       at session start; not echoed back via `onContent`.
 * [CN]: 给 AI 角色的可选上下文，通常是一段用户画像
 *       （例如 "User's location is Beijing. User's name is John."）。
 *       在会话开始时一次性下发，不会通过 `onContent` 回传。
 */
@property (nonatomic, copy, nullable) NSString *initialPrompt;

/**
 * @brief Agent identifier
 * @chinese AI 角色标识
 *
 * @discussion
 * [EN]: String ID identifying the AI agent / persona. The value space is
 *       defined by the backend AI provider (e.g. `"ZNT002"`). Using a string
 *       avoids leaking vendor-specific enums into the protocol layer.
 * [CN]: 标识 AI 角色 / 人设的字符串 ID，取值由后端 AI 提供方定义（如 `"ZNT002"`）。
 *       使用字符串可避免把厂商专属枚举泄漏到协议层。
 */
@property (nonatomic, copy, nullable) NSString *agentId;

/**
 * @brief TTS speaker (voice) identifier
 * @chinese TTS 发音人标识
 *
 * @discussion
 * [EN]: String ID identifying the TTS voice (e.g. `"xiaogang"`). Only takes
 *       effect when `enableVoiceOutput` is `YES`. Value space defined by the
 *       backend AI provider.
 * [CN]: 标识 TTS 发音人的字符串 ID（如 `"xiaogang"`），
 *       仅当 `enableVoiceOutput` 为 `YES` 时生效。取值由后端 AI 提供方定义。
 */
@property (nonatomic, copy, nullable) NSString *speakerId;

/**
 * @brief Whether the session emits TTS audio for AI replies
 * @chinese 是否产出 AI 回复的 TTS 音频流
 *
 * @discussion
 * [EN]: When `YES`, AI replies are also synthesized as PCM and delivered via
 *       `onContent` with `contentType = AudioChunk`. When `NO`, only text is
 *       streamed (saves bandwidth / battery in text-only UIs).
 * [CN]: 为 `YES` 时，AI 回复同时合成为 PCM 音频并通过 `onContent`
 *       以 `contentType = AudioChunk` 下发；为 `NO` 时仅下发文本
 *       （在纯文本 UI 中可省流量与功耗）。
 */
@property (nonatomic, assign) BOOL enableVoiceOutput;

/**
 * @brief Whether the user is allowed to interrupt AI playback by speaking
 * @chinese 是否允许用户通过说话打断 AI 回复播放
 *
 * @discussion
 * [EN]: When `YES`, detecting user speech during AI playback stops the
 *       current TTS and starts a new question round. Recommended `YES` for
 *       natural conversation UX.
 * [CN]: 为 `YES` 时，AI 播放期间检测到用户说话会立即停止当前 TTS
 *       并开启新一轮提问。建议为 `YES`，体验更自然。
 */
@property (nonatomic, assign) BOOL allowUserInterrupt;

/**
 * @brief Silence (in seconds) required after the user stops speaking before
 *        the AI starts to respond
 * @chinese 用户停止说话后，AI 开始回复前需要的静默时长（秒）
 *
 * @discussion
 * [EN]: Acts as a VAD pause threshold for end-of-turn detection. Lower values
 *       feel snappier but risk cutting off the user mid-sentence. Typical
 *       range: 0.5 ~ 1.5s. Defaults to 0.8s when created via `defaultConfig`.
 * [CN]: 作为 VAD 判断"用户说完了"的停顿阈值。
 *       值越小响应越快，但可能在用户说完前被切断。典型取值 0.5 ~ 1.5 秒。
 *       通过 `defaultConfig` 创建时默认 0.8 秒。
 */
@property (nonatomic, assign) NSTimeInterval silenceBeforeReplyInterval;

/**
 * @brief Auto-end session timeout (in seconds) without any new input
 * @chinese 无新输入时自动结束会话的超时时长（秒）
 *
 * @discussion
 * [EN]: When neither user speech nor AI playback occurs for this duration,
 *       the session ends automatically and `completion` is invoked with
 *       `endReason = Timeout`. Defaults to 15s when created via `defaultConfig`.
 * [CN]: 在该时长内既无用户说话也无 AI 播放时，会话自动结束并通过 `completion`
 *       回调，`endReason = Timeout`。通过 `defaultConfig` 创建时默认 15 秒。
 */
@property (nonatomic, assign) NSTimeInterval autoEndSessionTimeout;

/**
 * @brief Create a config with sensible defaults
 * @chinese 创建带合理默认值的配置
 *
 * @return
 * EN: A new config instance with: `enableVoiceOutput = YES`,
 *     `allowUserInterrupt = YES`, `silenceBeforeReplyInterval = 0.8`,
 *     `autoEndSessionTimeout = 15.0`. All identifier fields are nil.
 * CN: 新建配置对象，默认 `enableVoiceOutput = YES`、
 *     `allowUserInterrupt = YES`、`silenceBeforeReplyInterval = 0.8`、
 *     `autoEndSessionTimeout = 15.0`，所有标识类字段为 nil。
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
