//
//  TSAIDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#ifndef TSAIDefines_h
#define TSAIDefines_h

#pragma mark - Audio Format

/**
 * @brief Shared AI audio format
 * @chinese AI 模块通用音频格式
 *
 * @discussion
 * [EN]: Single source of truth for audio format across all TSAIKit modules
 *       (Speech / Interpreter / Recording ...). Values intentionally align
 *       with `AIBudsAIAudioFormat` for cross-SDK interop.
 *
 *       Field semantics:
 *       - As a result field (e.g. TSAITTSResult.audioFormat): `None` means
 *         "no audio produced".
 *       - As a config field (e.g. TSAIASRFileConfig.audioFormat): `None`
 *         means "format not specified; let the SDK sniff the file header".
 *         Raw PCM must specify the format explicitly.
 *
 * [CN]: 所有 TSAIKit 模块（Speech / Interpreter / 录音 ...）共用的音频格式枚举。
 *       取值与 `AIBudsAIAudioFormat` 对齐，便于跨 SDK 互通。
 *
 *       字段语义：
 *       - 在结果字段中（如 TSAITTSResult.audioFormat）：`None` 表示无音频产出。
 *       - 在配置字段中（如 TSAIASRFileConfig.audioFormat）：`None` 表示未指定格式，
 *         由 SDK 通过文件头嗅探。裸 PCM 必须显式指定格式。
 */
typedef NS_ENUM(NSInteger, TSAIAudioFormat) {
    /// 未知格式 (Unknown audio format)
    TSAIAudioFormatUnknown = -1,
    /// 无格式 / 未指定（嗅探） (No format / unspecified, sniff)
    TSAIAudioFormatNone    = 0,
    /// PCM
    TSAIAudioFormatPcm     = 1,
    /// Opus
    TSAIAudioFormatOpus    = 2,
    /// MP3
    TSAIAudioFormatMp3     = 3,
    /// WAV
    TSAIAudioFormatWav     = 4,
};

#pragma mark - AI Language

/**
 * @brief Unified AI language enum (ASR / Translate / Interpreter)
 * @chinese AI 模块统一语言枚举（ASR / 翻译 / 同声传译）
 *
 * @discussion
 * [EN]: Single source of truth for "spoken / written human language" across
 *       all TSAIKit modules — streaming ASR, translation and simultaneous
 *       interpretation. Keeping one enum (instead of one per backend) avoids
 *       duplicate "ChineseSimplified = 1" definitions and the cost of
 *       converting between enums when an utterance is piped from ASR into
 *       MT in the interpreter pipeline.
 *
 *       Distinct from the device-UI language enum `TSLanguageType`, because
 *       the AI services support far fewer languages than the on-device UI.
 *
 *       `Auto` semantics — valid only as a *source / input* language to
 *       request backend auto-detection (translate `sourceLanguage`,
 *       interpreter `sourceLanguage`). It is NOT valid as:
 *       - an ASR `language` (the recognizer must know the target language up front);
 *       - a translate / interpreter `targetLanguage` (the target is the
 *         caller's intent and cannot be detected);
 *       - the secondary side language of a two-way interpreter session.
 *       Modules that disallow `Auto` reject it at the property setter
 *       (assert in Debug, drop in Release) or at the request-validation
 *       layer with an invalid-parameter error. See per-property docs for
 *       the exact contract.
 *
 *       Per-module supported subset: a module's backend may not implement
 *       every value. When an unsupported language is passed, the
 *       implementation surfaces a not-supported error rather than silently
 *       falling back to a default language.
 *
 * [CN]: 所有 TSAIKit 模块（流式 ASR / 翻译 / 同声传译）共用的"人类语言"枚举。
 *       使用单一枚举（而非每个后端各自定义）可以避免到处出现重复的
 *       "ChineseSimplified = 1"，也省去了同传管线把 ASR 输出语言塞进 MT
 *       时的枚举转换成本。
 *
 *       与设备 UI 语言枚举 `TSLanguageType` 区分开，因为 AI 服务支持的语种
 *       远少于设备 UI 端。
 *
 *       `Auto` 语义——仅在 *源 / 输入* 语言场景有效，用于请求后端自动检测
 *       （翻译的 `sourceLanguage`、同传的 `sourceLanguage`）。以下场景**不可**使用：
 *       - ASR `language`（识别引擎必须事先知道目标语言）；
 *       - 翻译 / 同传的 `targetLanguage`（目标语言是调用方意图，无从检测）；
 *       - 同传双向模式下的次方向语言。
 *       禁止使用 `Auto` 的模块，会在属性 setter 处拒绝写入
 *       （Debug 触发断言，Release 静默丢弃），或在请求校验层返回参数错误。
 *       具体契约见各属性文档。
 *
 *       各模块支持子集：某模块后端未必实现枚举中所有值；
 *       传入未支持的语言时，实现层会返回 not-support 错误，
 *       不会静默回退到默认语言。
 */
typedef NS_ENUM(NSInteger, TSAILanguage) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAILanguageUnknown            = -1,
    /// 自动检测（仅源语言场景可用） (Auto-detect; valid for source/input languages only)
    TSAILanguageAuto               = 0,
    /// 简体中文 (Simplified Chinese, zh-CN)
    TSAILanguageChineseSimplified  = 1,
    /// 繁体中文 (Traditional Chinese, zh-TW)
    TSAILanguageChineseTraditional = 2,
    /// 美式英语 (English US, en-US)
    TSAILanguageEnglishUS          = 3,
    /// 英式英语 (English UK, en-GB)
    TSAILanguageEnglishUK          = 4,
    /// 日语 (Japanese, ja-JP)
    TSAILanguageJapanese           = 5,
    /// 韩语 (Korean, ko-KR)
    TSAILanguageKorean             = 6,
    /// 法语 (French, fr-FR)
    TSAILanguageFrench             = 7,
    /// 德语 (German, de-DE)
    TSAILanguageGerman             = 8,
    /// 西班牙语 (Spanish, es-ES)
    TSAILanguageSpanish            = 9,
    /// 俄语 (Russian, ru-RU)
    TSAILanguageRussian            = 10,
};

#pragma mark - ASR Scene

/**
 * @brief AI ASR audio scene hint
 * @chinese AI 语音识别音频场景提示
 *
 * @discussion
 * [EN]: Hint for the ASR backend to pick a tailored acoustic model / noise
 *       suppression strategy. Applies to both file ASR (e.g. a recorded
 *       phone-call .wav) and device-microphone ASR.
 *
 *       - `OnSite`: live, possibly far-field capture with environment noise
 *         and multiple speakers (meetings, interviews, face-to-face).
 *       - `Call`: telephone / VoIP recordings with narrow- or wide-band
 *         channel distortion, typically a single speaker.
 *
 *       Backends that do not differentiate scenes will fall back to a
 *       general-purpose model.
 *
 * [CN]: 用于提示 ASR 后端选择匹配的声学模型 / 降噪策略。
 *       同时适用于文件 ASR（如通话录音 .wav）和设备麦克风 ASR。
 *
 *       - `OnSite`：现场拾音，可能为远场，存在环境噪声与多说话人
 *         （会议、采访、面对面交流）。
 *       - `Call`：电话 / VoIP 录音，存在窄带或宽带信道失真，通常为单说话人。
 *
 *       不区分场景的后端会回退到通用模型。
 */
typedef NS_ENUM(NSInteger, TSAIASRScene) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIASRSceneUnknown = -1,
    /// 现场录音（会议、采访、面对面）(On-site recording: meetings, interviews, face-to-face)
    TSAIASRSceneOnSite  = 1,
    /// 通话录音（电话、VoIP）(Call recording: telephone, VoIP)
    TSAIASRSceneCall    = 2,
};

#pragma mark - Translate Language

#pragma mark - AI Chat Intent

/**
 * @brief AI chat recognized intent type
 * @chinese AI 对话识别到的指令型意图类型
 *
 * @discussion
 * [EN]: Strongly-typed command intents extracted from the user's utterance
 *       during an AI chat session. Defined at the protocol layer (rather
 *       than passed as opaque vendor strings) because the underlying
 *       capability domain is bounded and stable — cameras / volume / music
 *       / call control / device control are common across glasses, watches
 *       and earbuds. Each concrete sub-SDK is responsible for mapping its
 *       vendor-specific intent strings into this enum.
 *
 *       Values are grouped with intentional gaps (10 / 20 / 30 / 40 / 50)
 *       so new entries can be inserted within a domain without renumbering.
 *
 *       When a vendor surfaces an intent that falls outside this enum, the
 *       sub-SDK should set `TSAIChatIntent.type = Unknown` and place the
 *       raw vendor string into `TSAIChatIntent.intentId` so the caller may
 *       still react to it if desired.
 *
 * [CN]: AI 对话过程中从用户话语抽取出的强类型指令意图。
 *       之所以在协议层定义（而非作为不透明的 vendor 字符串透传），
 *       是因为底层能力域有界且稳定 —— 拍照 / 音量 / 音乐 / 通话 / 设备控制
 *       在眼镜、手表、耳机间是共性能力。
 *       各子 SDK 负责把自身 vendor 的意图字符串映射到本枚举。
 *
 *       取值按能力域分组并预留扩展位（10 / 20 / 30 / 40 / 50），
 *       新增同域意图时无需重新编号。
 *
 *       当 vendor 抛出本枚举未覆盖的意图时，子 SDK 应将
 *       `TSAIChatIntent.type` 置为 `Unknown`，并把 vendor 原始字符串放入
 *       `TSAIChatIntent.intentId`，调用方可据此自行处理。
 */
typedef NS_ENUM(NSInteger, TSAIChatIntentType) {
    /// 未知 / 未识别到协议层定义的意图（详见 intentId） (Unknown; see intentId for vendor raw value)
    TSAIChatIntentTypeUnknown            = -1,
    /// 未识别到指令（纯闲聊） (No actionable intent, casual chat)
    TSAIChatIntentTypeNone               = 0,

    // Camera & Recording
    /// 拍照 (Take a photo)
    TSAIChatIntentTypePhotoCapture       = 1,
    /// 理解照片内容 (Understand photo content)
    TSAIChatIntentTypePhotoUnderstand    = 2,
    /// 开始录像 (Start recording video)
    TSAIChatIntentTypeVideoStart         = 3,
    /// 停止录像 (Stop recording video)
    TSAIChatIntentTypeVideoStop          = 4,
    /// 开始录音 (Start recording audio)
    TSAIChatIntentTypeAudioRecord        = 5,

    // Volume
    /// 调高音量 (Increase volume)
    TSAIChatIntentTypeVolumeUp           = 10,
    /// 调低音量 (Decrease volume)
    TSAIChatIntentTypeVolumeDown         = 11,
    /// 设置音量到指定值（具体值见 value / valueDictionary） (Set volume; level in value)
    TSAIChatIntentTypeVolumeSet          = 12,

    // Music
    /// 播放音乐 (Play music)
    TSAIChatIntentTypeMusicPlay          = 20,
    /// 停止播放 (Stop playback)
    TSAIChatIntentTypeMusicStop          = 21,
    /// 下一首 (Next track)
    TSAIChatIntentTypeMusicNext          = 22,
    /// 上一首 (Previous track)
    TSAIChatIntentTypeMusicPrev          = 23,

    // Call
    /// 接听来电 (Answer incoming call)
    TSAIChatIntentTypeCallAnswer         = 30,
    /// 拒接来电 (Decline incoming call)
    TSAIChatIntentTypeCallDecline        = 31,
    /// 通话录音 (Record current call)
    TSAIChatIntentTypeCallRecord         = 32,

    // Device
    /// 查询电量 (Query device battery)
    TSAIChatIntentTypeDeviceBatteryQuery = 40,
    /// 关机 (Power off device)
    TSAIChatIntentTypeDevicePowerOff     = 41,

    // Dialog / Agent
    /// 退出对话 (Exit current dialog)
    TSAIChatIntentTypeDialogExit         = 50,
    /// 切换 AI 角色 (Switch AI agent / role)
    TSAIChatIntentTypeAgentSwitch        = 51,
    /// 声音克隆 (Trigger voice clone flow)
    TSAIChatIntentTypeVoiceClone         = 52,
};

#endif /* TSAIDefines_h */
