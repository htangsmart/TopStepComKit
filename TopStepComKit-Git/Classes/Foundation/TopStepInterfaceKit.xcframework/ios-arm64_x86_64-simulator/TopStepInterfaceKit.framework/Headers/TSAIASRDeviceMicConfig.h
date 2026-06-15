//
//  TSAIASRDeviceMicConfig.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming ASR request configuration for the device microphone
 * @chinese 设备麦克风流式语音识别请求配置
 *
 * @discussion
 * [EN]: Configuration for recognizing audio captured live from the connected
 *       device's microphone (e.g. earbuds / glasses / watch) via
 *       `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`.
 *
 *       The SDK internally activates the device's AI capability, opens the
 *       device microphone stream, and bridges the audio frames into the
 *       recognition pipeline. Callers do NOT need to manage device-side
 *       recording or audio-frame plumbing themselves.
 *
 * [CN]: 用于 `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`
 *       的设备麦克风（耳机 / 眼镜 / 手表）实时识别配置。
 *
 *       SDK 内部会激活设备 AI 能力、打开设备麦克风音频流，并把音频帧桥接到
 *       识别管道。调用方无需自行处理设备录音与音频帧分发。
 */
@interface TSAIASRDeviceMicConfig : NSObject

/**
 * @brief Recognition language
 * @chinese 识别语言
 *
 * @discussion
 * [EN]: See `TSAILanguage` in TSAIDefines.h. Must be a concrete language —
 *       `TSAILanguageAuto` is not allowed because the recognizer needs
 *       to know the language up front; passing it returns an
 *       invalid-parameter error from the underlying SDK.
 * [CN]: 见 TSAIDefines.h 中的 `TSAILanguage`。必须为具体语言——
 *       不允许传 `TSAILanguageAuto`，因为识别引擎必须事先知道语言；
 *       底层 SDK 会以参数错误返回。
 */
@property (nonatomic, assign) TSAILanguage language;

/**
 * @brief Desired audio format of the recorded file delivered via
 *        `TSAIASRDeviceMicResult.recordedAudioFileURL`
 * @chinese 录音落盘文件（最终通过 result.recordedAudioFileURL 返回）的目标格式
 *
 * @discussion
 * [EN]: The device microphone emits Opus-encoded audio at the hardware
 *       level; the SDK transcodes it to the requested format before
 *       producing the recorded file. Defaults to `TSAIAudioFormatMp3`.
 *       `TSAIAudioFormatNone` and `TSAIAudioFormatUnknown` are also
 *       treated as MP3.
 *
 *       Best-effort: when the backend cannot produce the requested format
 *       (e.g. lacks the corresponding encoder), it silently falls back to
 *       its default format. The actual produced format is reflected by
 *       `recordedAudioFormat` on `TSAIASRDeviceMicResult`, which is the
 *       source of truth.
 *
 *       Independent from the recognition pipeline; this only affects the
 *       file delivered to the caller, not what the recognizer consumes.
 *
 * [CN]: 设备麦克风在硬件层面输出 Opus 编码音频；
 *       SDK 会先转码到此处指定的目标格式，再产出最终落盘文件。
 *       默认为 `TSAIAudioFormatMp3`；
 *       `TSAIAudioFormatNone` 与 `TSAIAudioFormatUnknown` 同样按 MP3 处理。
 *
 *       此字段为尽力而为：若后端无法产出指定格式（如缺少对应编码器），
 *       会静默回退到默认格式。实际产出格式以
 *       `TSAIASRDeviceMicResult.recordedAudioFormat` 为准。
 *
 *       与识别管道无关；该字段仅影响交付给调用方的录音文件，
 *       不影响识别引擎的输入。
 */
@property (nonatomic, assign) TSAIAudioFormat outputAudioFormat;

/**
 * @brief Whether to fall back to on-device offline recognition when the
 *        online service is unavailable
 * @chinese 在线服务不可用时是否允许降级到端侧离线识别
 *
 * @discussion
 * [EN]: Defaults to `NO`. When `YES`, the SDK tries the online engine first
 *       and falls back to the on-device offline engine if the network or
 *       server is unreachable. Note that on-device offline ASR is typically
 *       limited (smaller vocabulary, lower accuracy); back-ends without an
 *       offline engine will surface a not-supported error instead of
 *       silently degrading.
 * [CN]: 默认 `NO`。设为 `YES` 时，SDK 优先走在线识别，
 *       网络或服务不可用时降级到端侧离线引擎。
 *       注意端侧离线识别能力通常受限（词表较小、准确率偏低）；
 *       不具备离线引擎的后端会显式报 not-support 错误，而不会静默降级。
 */
@property (nonatomic, assign) BOOL offlineFallbackEnabled;

/**
 * @brief Audio scene hint
 * @chinese 音频场景提示
 *
 * @discussion
 * [EN]: See `TSAIASRScene` in TSAIDefines.h. Helps the backend choose a
 *       tailored acoustic model. Defaults to `TSAIASRSceneUnknown`, in which
 *       case the backend uses its general-purpose model.
 * [CN]: 见 TSAIDefines.h 中的 `TSAIASRScene`。
 *       用于后端选择匹配的声学模型。默认为 `TSAIASRSceneUnknown`，
 *       此时后端使用通用模型。
 */
@property (nonatomic, assign) TSAIASRScene scene;

/**
 * @brief Create a config with the given language
 * @chinese 通过识别语言创建配置
 *
 * @param language
 * EN: Recognition language
 * CN: 识别语言
 *
 * @return
 * EN: A new config instance (outputAudioFormat = MP3,
 *     offlineFallbackEnabled = NO, scene = Unknown)
 * CN: 新创建的配置对象（outputAudioFormat = MP3，
 *     offlineFallbackEnabled = NO，scene = Unknown）
 */
+ (instancetype)configWithLanguage:(TSAILanguage)language;

@end

NS_ASSUME_NONNULL_END
