//
//  TSAIChatConfig.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversation mode of a chat session
 * @chinese 会话模式
 */
typedef NS_ENUM(NSInteger, TSAIChatConversationMode) {
    /// 多轮：VAD 自动断句，持续问答直到 stop / 超时（AI 畅聊）
    /// (Continuous: VAD-segmented multi-round until stop / timeout)
    TSAIChatConversationModeContinuous  = 0,
    /// 单轮：一问一答，回复播放结束后会话自动结束（AI 对话）
    /// (Single round: one Q&A, session auto-ends after reply playback)
    TSAIChatConversationModeSingleRound = 1,
};

/**
 * @brief Owner of synthesized chat voice output
 * @chinese 对话合成语音输出的负责方
 */
typedef NS_ENUM(NSInteger, TSAIChatVoiceOutputMode) {
    /**
     * @brief Deliver PCM content for AIKit playback
     * @chinese 交付 PCM 内容，由 AIKit 播放
     */
    TSAIChatVoiceOutputModePCMStream = 0,
    /**
     * @brief Let a supporting Provider play synthesized voice internally
     * @chinese 由支持此模式的 Provider 在内部播放合成语音
     */
    TSAIChatVoiceOutputModeProviderPlayback = 1,
};

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
@interface TSAIChatConfig : NSObject <NSCopying>

/**
 * @brief Audio route used by this chat session
 * @chinese 本次 AI 对话会话使用的音频路由
 *
 * @discussion
 * [EN]: Nil requests automatic resolution. The selected route is copied and
 *       frozen when `startChatWithConfig:` is called.
 * [CN]: 为 nil 时请求自动选路；调用 `startChatWithConfig:` 时会复制并冻结实际路由。
 */
@property (nonatomic, copy, nullable) TSAIAudioRouteConfiguration *audioRouteConfiguration;

/**
 * @brief Exact device request expected by this start, or nil for the legacy App entry
 * @chinese 本次启动必须接受的设备请求标识；nil 保留原有 App 入口。标识过期或不匹配时失败，不改为 App 主动启动。
 */
@property (nonatomic, copy, nullable) NSString *expectedDeviceRequestIdentifier;

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
 * @brief Whether AI replies include synthesized voice
 * @chinese AI 回复是否包含合成语音
 *
 * @discussion
 * [EN]: In PCMStream mode, YES delivers PCM through `onContent` with
 *       `contentType = AudioChunk`. In ProviderPlayback mode, YES lets the
 *       Provider play voice and does not promise external audio chunks.
 *       NO requests text without audible synthesized voice; unsupported
 *       configurations fail explicitly.
 * [CN]: PCMStream 模式下，YES 通过 `onContent` 的 AudioChunk 交付 PCM。
 *       ProviderPlayback 模式下，YES 由 Provider 播放，不承诺外部音频分片。
 *       NO 请求无合成语音出声的文本回答；不支持的配置会明确失败。
 */
@property (nonatomic, assign) BOOL enableVoiceOutput;

/**
 * @brief Voice output ownership selected explicitly for this session
 * @chinese 本次会话显式选择的语音输出负责方
 *
 * @discussion
 * [EN]: PCMStream preserves the existing PCM content and AIKit playback
 *       contract. ProviderPlayback requires a Provider that supports internal
 *       playback; AIKit does not create an output driver or device PCM stream.
 * [CN]: PCMStream 保留现有 PCM 内容和 AIKit 播放契约。
 *       ProviderPlayback 要求 Provider 支持内部播放；AIKit 不创建输出驱动或设备 PCM 下行。
 *
 * @note
 * [EN]: Defaults to PCMStream. Unsupported output routes are rejected.
 * [CN]: 默认 PCMStream；不支持的输出路由会被拒绝。
 */
@property (nonatomic, assign) TSAIChatVoiceOutputMode voiceOutputMode;

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
 * @brief Conversation mode
 * @chinese 会话模式
 *
 * @discussion
 * [EN]: Continuous keeps the existing behaviour. SingleRound closes the input
 *       once (manually, by silence or by max duration), waits for the reply
 *       text and TTS to drain, then ends the session with
 *       endReason = RoundCompleted.
 * [CN]: Continuous 与现有行为一致。SingleRound 下输入只结束一次（手动 / 静默 /
 *       达到上限），SDK 等回复文本与 TTS 播完后以 endReason = RoundCompleted
 *       结束会话。
 *
 * @note
 * [EN]: Defaults to Continuous for backward compatibility.
 * [CN]: 默认 Continuous，兼容现有调用方。
 */
@property (nonatomic, assign) TSAIChatConversationMode conversationMode;

/**
 * @brief Whether silence ends the input in SingleRound mode
 * @chinese 单轮模式下静默是否结束输入
 *
 * @discussion
 * [EN]: YES: a pause longer than `silenceBeforeReplyInterval` ends the input
 *       (device-initiated single round, no button on the device).
 *       NO: only `finishChatInputWithTaskId:` / `sendChatText:taskId:` /
 *       `maximumInputDuration` end the input (App push-to-talk).
 *       Ignored in Continuous mode.
 *       Until the underlying AI SDK exposes an explicit end-of-utterance
 *       call, NO is honoured on a best-effort basis: a pause longer than
 *       `silenceBeforeReplyInterval` may still end the input early.
 * [CN]: YES：停顿超过 `silenceBeforeReplyInterval` 即结束输入（设备发起的单轮，
 *       设备上没有按钮）。NO：仅 `finishChatInputWithTaskId:` /
 *       `sendChatText:taskId:` / `maximumInputDuration` 能结束输入（App 按住说话）。
 *       Continuous 模式忽略。
 *       在底层 AI SDK 提供显式"本句结束"接口之前，NO 为尽力而为：
 *       停顿超过 `silenceBeforeReplyInterval` 仍可能提前结束输入。
 *
 * @note
 * [EN]: Defaults to YES.
 * [CN]: 默认 YES。
 */
@property (nonatomic, assign) BOOL endsInputOnSilence;

/**
 * @brief Maximum input duration (seconds) in SingleRound mode
 * @chinese 单轮模式下单次输入的最长时长（秒）
 *
 * @discussion
 * [EN]: Counted from SessionStarted. Reaching it finishes the input as if
 *       `finishChatInputWithTaskId:` were called and emits
 *       `TSAIChatEventTypeInputFinished`. 0 means no limit.
 *       Ignored in Continuous mode.
 * [CN]: 从 SessionStarted 开始计时，到达后等价于调用 `finishChatInputWithTaskId:`
 *       并下发 `TSAIChatEventTypeInputFinished`。0 表示不限制。Continuous 模式忽略。
 *
 * @note
 * [EN]: Defaults to 60 seconds.
 * [CN]: 默认 60 秒。
 */
@property (nonatomic, assign) NSTimeInterval maximumInputDuration;

/**
 * @brief Idle duration (seconds) to keep the underlying cloud session alive
 *        after a single round completes
 * @chinese 单轮结束后底层云端会话保活的空闲时长（秒）
 *
 * @discussion
 * [EN]: Only applies to SingleRound sessions started by the App (no
 *       `expectedDeviceRequestIdentifier`). After a round ends with
 *       `RoundCompleted`, the SDK keeps the vendor connection warm for this
 *       duration instead of tearing it down. The next `startChatWithConfig:`
 *       with an equivalent config (same language / agent / speaker / prompt /
 *       voice output / interrupt / silence interval and resulting vendor audio
 *       channel) adopts the warm connection: `SessionStarted` and
 *       `ServiceReady` are emitted at once, with no re-authentication or
 *       reconnection, and the conversation context is continued server-side.
 *       When the duration elapses with no new round, the connection is closed
 *       silently; the next round reconnects transparently. Each round is still
 *       its own task with its own `completion(endReason = RoundCompleted)`.
 *       0 disables reuse (the session is closed as soon as a round completes).
 *       Values above 600 are clamped to 600. Ignored in Continuous mode and for
 *       device-initiated rounds.
 * [CN]: 仅对 App 发起（未设置 `expectedDeviceRequestIdentifier`）的 SingleRound
 *       会话生效。一轮以 `RoundCompleted` 结束后，SDK 在该时长内保留厂商云端连接
 *       而不是立即关闭；下一次 `startChatWithConfig:` 若配置等价（语言 / 角色 /
 *       发音人 / prompt / 语音输出 / 打断 / 静默阈值及解析出的厂商音频通道一致），
 *       直接复用该连接：立即发出 `SessionStarted` 与 `ServiceReady`，无需重新鉴权
 *       与建连，服务端保留跨轮上下文。空闲超时后静默关闭连接，下一轮透明重建。
 *       每一轮仍是独立 task，各自以 `completion(endReason = RoundCompleted)` 结束。
 *       0 表示不复用（一轮结束即关闭会话）。大于 600 时按 600 处理。
 *       Continuous 模式与设备发起的轮次忽略该字段。
 *
 * @note
 * [EN]: Defaults to 90 seconds. While the connection is kept warm, the
 *       vendor's own no-input timeout is extended accordingly; the SDK
 *       enforces `autoEndSessionTimeout` for the in-round "no input" case
 *       itself.
 * [CN]: 默认 90 秒。保活期间厂商自身的无输入超时会被相应放宽，轮内「无输入」
 *       超时由 SDK 按 `autoEndSessionTimeout` 自行保证。
 */
@property (nonatomic, assign) NSTimeInterval roundIdleTimeout;

/**
 * @brief How long to wait for the App to act on a client-action intent
 * @chinese 等待 App 处理「需客户端补充信息」意图的时长
 *
 * @discussion
 * [EN]: When the cloud returns an intent with `requiresClientAction = YES`
 *       (e.g. LocationQuery) it will not answer the round by itself. The SDK
 *       suspends its regular idle timers for that round and waits this long
 *       for the App to call `replayPendingIntentRoundWithText:taskId:`; the
 *       timer restarts after a replay. On expiry `IntentActionTimedOut` is
 *       emitted; SingleRound ends with `TSAIErrorCodeIntentActionRequired`,
 *       Continuous gives up the round only.
 * [CN]: 云端返回 `requiresClientAction = YES` 的意图（如 LocationQuery）时不会自行回答。
 *       SDK 对该轮暂停常规空闲计时，等待 App 调用
 *       `replayPendingIntentRoundWithText:taskId:`，重发后重新计时。超时发出
 *       `IntentActionTimedOut`；单轮以 `TSAIErrorCodeIntentActionRequired` 结束，
 *       畅聊仅放弃本轮。
 *
 * @note
 * [EN]: Defaults to 20 seconds. Should cover a system permission prompt plus
 *       a location fix. <= 0 disables the guard (not recommended).
 * [CN]: 默认 20 秒，需覆盖系统权限弹窗加一次定位。<= 0 关闭保护（不建议）。
 */
@property (nonatomic, assign) NSTimeInterval intentActionTimeout;

/**
 * @brief Whether an App-initiated chat always opens the device-side AI chat
 * @chinese App 发起时是否始终打开设备端 AI 对话
 *
 * @discussion
 * [EN]: NO (default): the device is coordinated only when the resolved route
 *       goes through device Opus (case capture or case playback); otherwise the
 *       chat is App-only and the device never enters its AI chat scene.
 *       YES: when the device is connected and supports App-initiated AI chat,
 *       the session is always coordinated with the device (FitCloud
 *       `startAIChatSession`), whatever capture / playback was chosen. The
 *       device then always uploads Opus; when the capture channel is not
 *       device Opus that audio is discarded by the SDK. Bluetooth headset (SCO)
 *       capture is not coordinated and stays App-only. Ignored for device-
 *       initiated rounds.
 * [CN]: NO（默认）：仅当解析后的路由经过设备 Opus（耳机仓拾音或耳机仓播放）时才做设备协同，
 *       否则为纯 App 对话，设备不进入 AI 对话场景。
 *       YES：设备在线且支持 App 发起 AI 对话时，无论拾音 / 播放选哪一路都与设备协同
 *       （FitCloud `startAIChatSession`）。此时设备固定上传 Opus，拾音不是设备 Opus 时
 *       该音频由 SDK 丢弃。蓝牙耳机（SCO）拾音不做设备协同，仍为纯 App 对话。
 *       设备发起的轮次忽略该字段。
 */
@property (nonatomic, assign) BOOL opensDeviceChatSession;

/**
 * @brief Cloud usage (billing) plan of this session
 * @chinese 本次会话使用的云端计费套餐
 *
 * @discussion
 * [EN]: Lite only supports normal voice conversation. Pro gives access to
 *       all features (voice conversation, AI image recognition, ...) and is
 *       billed against a separate quota; set it explicitly when needed. Fixed when the session starts; a warm
 *       SingleRound session is only reused by a config with the same plan.
 *       See `TSAIUsagePlan`; currently honoured by the StarBurst vendor only.
 * [CN]: Lite 仅支持普通语音对话；Pro 可使用全部能力（普通语音对话、AI 识图等），
 *       扣减另一组额度，需要时显式指定。会话启动时生效，单轮保活会话只会被套餐相同的配置复用。
 *       见 `TSAIUsagePlan`，目前仅火山（StarBurst）厂商生效。
 *
 * @note
 * [EN]: Defaults to `TSAIUsagePlanLite`.
 * [CN]: 默认 `TSAIUsagePlanLite`。
 */
@property (nonatomic, assign) TSAIUsagePlan usagePlan;

/**
 * @brief Create a config with sensible defaults
 * @chinese 创建带合理默认值的配置
 *
 * @return
 * EN: A new config instance with: `enableVoiceOutput = YES`, `voiceOutputMode = PCMStream`,
 *     `allowUserInterrupt = YES`, `silenceBeforeReplyInterval = 0.8`,
 *     `autoEndSessionTimeout = 15.0`, `conversationMode = Continuous`,
 *     `endsInputOnSilence = YES`, `maximumInputDuration = 60`,
 *     `roundIdleTimeout = 90`, `intentActionTimeout = 20`, `usagePlan = Lite`.
 *     All identifier fields are nil.
 * CN: 新建配置对象，默认 `enableVoiceOutput = YES`、`voiceOutputMode = PCMStream`、
 *     `allowUserInterrupt = YES`、`silenceBeforeReplyInterval = 0.8`、
 *     `autoEndSessionTimeout = 15.0`、`conversationMode = Continuous`、
 *     `endsInputOnSilence = YES`、`maximumInputDuration = 60`、
 *     `roundIdleTimeout = 90`、`intentActionTimeout = 20`、`usagePlan = Lite`，
 *     所有标识类字段为 nil。
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
