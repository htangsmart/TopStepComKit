//
//  TSAIInterpreterConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Simultaneous-interpretation session configuration
 * @chinese 同声传译会话配置
 *
 * @discussion
 * [EN]: Configuration for a single one-way interpretation session started
 *       via `startInterpretationWithConfig:onContent:onEvent:completion:`.
 *       A session is an end-to-end voice pipeline: device microphone audio
 *       is fed into ASR, recognized text into MT, and the translation is
 *       streamed back as text plus optional TTS audio. Multiple utterances
 *       can occur within a single session, segmented by VAD.
 *
 *       Only one direction is supported at the protocol layer:
 *       `sourceLanguage` (what the speaker says) is translated into
 *       `targetLanguage`. A bidirectional / face-to-face conversation
 *       mode is intentionally out of scope — the App can implement that
 *       on top by stop-then-restarting with a swapped config.
 *
 *       Language fields use `TSAILanguage` (defined in TSAIDefines.h),
 *       shared across the AI ASR / Translate / Interpreter modules. Use
 *       `TSAILanguageAuto` on `sourceLanguage` to request backend
 *       auto-detection of the speaker's language; `targetLanguage` must
 *       be a concrete language.
 *
 * [CN]: 单次单向同声传译会话的配置，通过
 *       `startInterpretationWithConfig:onContent:onEvent:completion:` 启动。
 *       一次会话即一条端到端语音管线：设备麦克风音频灌入 ASR，
 *       识别文本送至 MT，译文以文本（及可选的 TTS 音频）流式回传。
 *       一次会话内可由 VAD 自动断句产生多段 utterance。
 *
 *       协议层只支持单向：`sourceLanguage`（说话人发言语言）翻译为
 *       `targetLanguage`。双向 / 面对面对话模式刻意不纳入协议——
 *       App 可在上层通过"stop 后用对调的 config 重启"自行实现。
 *
 *       语言字段使用 `TSAILanguage`（定义见 TSAIDefines.h），
 *       与 AI 模块下的 ASR / 翻译 / 同传共用。
 *       `sourceLanguage` 可设为 `TSAILanguageAuto` 由后端自动检测说话人语言；
 *       `targetLanguage` 必须为具体语言。
 */
@interface TSAIInterpreterConfig : NSObject

/**
 * @brief Source language (what the speaker says)
 * @chinese 源语言（说话人发言语言）
 *
 * @discussion
 * [EN]: Set to `TSAILanguageAuto` to request backend auto-detection — the
 *       resolved concrete value is delivered once via the
 *       `TSAIInterpreterEventTypeLanguageDetected` event. May be
 *       `TSAILanguageUnknown` at construction time but must be set to a
 *       valid value (concrete or `Auto`) before calling start.
 * [CN]: 设为 `TSAILanguageAuto` 请求后端自动检测，解析后的具体语言通过
 *       `TSAIInterpreterEventTypeLanguageDetected` 事件下发一次。
 *       构造时可为 `TSAILanguageUnknown`，但调用 start 前必须设为有效值
 *       （具体语言或 `Auto`）。
 */
@property (nonatomic, assign) TSAILanguage sourceLanguage;

/**
 * @brief Target language (what utterances are translated into)
 * @chinese 目标语言（译文语言）
 *
 * @discussion
 * [EN]: Must be a concrete language. Assigning `TSAILanguageAuto` is
 *       rejected at the property level — it triggers an `NSAssert` in
 *       Debug builds and is silently dropped in Release builds (the
 *       previous value is kept). `TSAILanguageUnknown` is allowed at the
 *       property level (it is the default value of a freshly created
 *       config) but is rejected by the start call with an
 *       invalid-parameter error.
 * [CN]: 必须为具体语言。在属性层面拒绝写入 `TSAILanguageAuto`——
 *       Debug 下触发 `NSAssert`，Release 下静默丢弃（保持原值不变）。
 *       `TSAILanguageUnknown` 在属性层面允许（这是新建 config 的初始值），
 *       但 start 调用时会以参数错误返回。
 */
@property (nonatomic, assign) TSAILanguage targetLanguage;

/**
 * @brief Whether the session emits TTS audio for the translated text
 * @chinese 是否产出译文的 TTS 音频流
 *
 * @discussion
 * [EN]: When `YES`, translations are also synthesized as PCM and delivered
 *       via `onContent` with `contentType = AudioChunk`. When `NO`, only
 *       text is streamed (saves bandwidth / battery in text-only UIs such
 *       as live-caption overlays).
 *
 *       Independent from `autoPlayVoice` — this only controls whether
 *       audio is produced and surfaced to the App; whether it is also
 *       routed to the device speaker is controlled separately.
 *
 * [CN]: 为 `YES` 时，译文同时合成为 PCM 音频并通过 `onContent`
 *       以 `contentType = AudioChunk` 下发；为 `NO` 时仅下发文本
 *       （在纯字幕类 UI 中可省流量与功耗）。
 *
 *       与 `autoPlayVoice` 相互独立——本字段仅控制是否合成音频并交付给 App；
 *       是否同时由 SDK 自动送到设备扬声器播放，由 `autoPlayVoice` 单独控制。
 */
@property (nonatomic, assign) BOOL enableVoiceOutput;

/**
 * @brief Whether the SDK automatically plays the translated audio on the connected device
 * @chinese 是否由 SDK 自动把译文音频送到已连接设备播放
 *
 * @discussion
 * [EN]: When `YES`, the SDK pipes the synthesized translation audio to the
 *       connected device's speaker (earbuds / glasses / watch) automatically —
 *       the App does not need to play the AudioChunk stream itself.
 *       When `NO`, the SDK does not play any audio; the App is responsible
 *       for consuming the AudioChunk stream from `onContent` and playing
 *       it through whatever audio route it prefers (App speaker, external
 *       output, recording, ...).
 *
 *       Only takes effect when `enableVoiceOutput == YES` (no audio is
 *       produced at all otherwise). Typical setting: `YES` for normal
 *       earbud / glasses interpretation, `NO` for App-side custom playback
 *       (volume mixing, post-processing, captioning-only flows that still
 *       want the raw audio for waveform UI).
 *
 * [CN]: 为 `YES` 时，SDK 自动将合成的译文音频送到已连接设备
 *       （耳机 / 眼镜 / 手表）的扬声器播放，App 无需自行播放 AudioChunk 流。
 *       为 `NO` 时 SDK 不播放任何音频，App 须自行从 `onContent` 的
 *       AudioChunk 流取数据，按需播放（App 扬声器、外部输出、录制等）。
 *
 *       仅当 `enableVoiceOutput == YES` 时生效（否则根本不产出音频）。
 *       常见取值：耳机 / 眼镜常规同传场景置 `YES`；
 *       App 端自定义播放（音量混合、后处理、仅字幕但需要原始音频做波形 UI 等）
 *       场景置 `NO`。
 */
@property (nonatomic, assign) BOOL autoPlayVoice;

/**
 * @brief TTS speaker (voice) identifier for the translated text
 * @chinese 译文 TTS 发音人标识
 *
 * @discussion
 * [EN]: String ID identifying the TTS voice used to read translations into
 *       `targetLanguage` (e.g. `"xiaogang"`). Only takes effect when
 *       `enableVoiceOutput` is `YES`. Value space defined by the backend
 *       AI provider.
 * [CN]: 用于朗读 `targetLanguage` 译文的 TTS 发音人字符串 ID
 *       （如 `"xiaogang"`），仅当 `enableVoiceOutput` 为 `YES` 时生效。
 *       取值由后端 AI 提供方定义。
 */
@property (nonatomic, copy, nullable) NSString *speakerId;

/**
 * @brief Create a config with sensible defaults
 * @chinese 创建带合理默认值的配置
 *
 * @return
 * EN: A new config instance with: `enableVoiceOutput = YES`,
 *     `autoPlayVoice = YES`. Both language fields are
 *     `TSAILanguageUnknown` and `speakerId` is nil — caller must at
 *     least set `sourceLanguage` and `targetLanguage` before use.
 * CN: 新建配置对象，默认 `enableVoiceOutput = YES`、`autoPlayVoice = YES`。
 *     两个语言字段为 `TSAILanguageUnknown`，`speakerId` 为 nil；
 *     调用方至少需在使用前设置 `sourceLanguage` 与 `targetLanguage`。
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
