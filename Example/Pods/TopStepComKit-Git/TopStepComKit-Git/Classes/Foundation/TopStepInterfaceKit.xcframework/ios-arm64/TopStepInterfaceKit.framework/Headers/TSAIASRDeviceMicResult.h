//
//  TSAIASRDeviceMicResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Final result of a device-microphone ASR session
 * @chinese 设备麦克风语音识别会话的最终结果
 *
 * @discussion
 * [EN]: Returned by the completion block of
 *       `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`
 *       once the session ends — either via
 *       `stopDeviceMicRecognitionWithTaskId:` (normal stop) or via an
 *       interruption / error.
 *
 *       Distinct from `TSAIASRResult` (used for file ASR) because a
 *       device-mic session has additional attributes that do not apply to
 *       a closed audio file: wall-clock session boundaries, interruption
 *       state, online/offline routing, scene hint and an optional recorded
 *       audio file produced on the device side.
 *
 * [CN]: 由
 *       `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`
 *       的 completion 回调下发，会话结束时返回 ——
 *       结束方式可能是 `stopDeviceMicRecognitionWithTaskId:`（正常停止）
 *       或被中断 / 出错。
 *
 *       与 `TSAIASRResult`（文件 ASR 使用）拆开，是因为设备麦克风会话
 *       拥有文件 ASR 不具备的属性：墙钟起止时间、中断状态、在线/离线路由、
 *       场景信息以及设备端可能落盘的录音文件。
 */
@interface TSAIASRDeviceMicResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the recognize API)
 * @chinese 任务唯一标识（与识别接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Final cumulative recognized text
 * @chinese 最终累积识别文本
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Session duration in seconds
 * @chinese 会话时长（秒）
 *
 * @discussion
 * [EN]: Convenience field equal to `sessionEndTime - sessionStartTime`.
 * [CN]: 便利字段，等于 `sessionEndTime - sessionStartTime`。
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * @brief Wall-clock time when the session started
 * @chinese 会话开始时刻（墙钟时间）
 */
@property (nonatomic, copy) NSDate *sessionStartTime;

/**
 * @brief Wall-clock time when the session ended
 * @chinese 会话结束时刻（墙钟时间）
 */
@property (nonatomic, copy) NSDate *sessionEndTime;

/**
 * @brief Audio scene used for this session (echoed from the request config)
 * @chinese 本次会话所采用的场景（回填自请求配置）
 *
 * @discussion
 * [EN]: See `TSAIASRScene` in TSAIDefines.h.
 * [CN]: 见 TSAIDefines.h 中的 `TSAIASRScene`。
 */
@property (nonatomic, assign) TSAIASRScene scene;

/**
 * @brief Whether this session was actually recognized by the on-device offline engine
 * @chinese 本次会话是否实际使用了端侧离线引擎
 *
 * @discussion
 * [EN]: `YES` only when the SDK fell back to the on-device engine because
 *       the online service was unreachable AND
 *       `config.offlineFallbackEnabled` was `YES`. Always `NO` otherwise
 *       (online recognition or fallback disabled).
 * [CN]: 仅当在线服务不可达且 `config.offlineFallbackEnabled` 为 `YES`，
 *       SDK 实际降级到端侧离线引擎时为 `YES`；
 *       其它情况（在线识别 / 未开启降级）均为 `NO`。
 */
@property (nonatomic, assign) BOOL isOfflineRecognition;

/**
 * @brief Whether the session was stopped by a system interruption
 * @chinese 会话是否被系统中断终止
 *
 * @discussion
 * [EN]: `YES` if the session was terminated by an external interruption
 *       such as an incoming phone call. The completion block is still
 *       invoked with whatever result was recognized up to the interruption
 *       point; an accompanying error may also be present.
 * [CN]: 若会话被来电等外部事件中断，此字段为 `YES`。
 *       中断时 completion 仍会以"截至中断时刻已识别"的结果回调，
 *       同时可能伴随错误信息。
 */
@property (nonatomic, assign) BOOL isStoppedByInterruption;

/**
 * @brief Local file URL of the audio recorded during the session, if any
 * @chinese 本次会话录制的本地音频文件 URL（如有）
 *
 * @discussion
 * [EN]: Some underlying SDKs persist the captured audio to the app's
 *       sandbox during recognition; this property points at that file.
 *       `nil` when the SDK does not produce a local recording.
 *
 *       This is the **playback-ready** file (e.g. WAV / MP3 / Opus),
 *       suitable for `AVAudioPlayer`, sharing or uploading. Raw on-device
 *       encodings (e.g. proprietary PCM frames produced by the earbuds
 *       chip) are intentionally NOT exposed here — they are an
 *       implementation detail of the underlying SDK.
 *
 * [CN]: 部分底层 SDK 会在识别过程中将设备麦克风音频落盘到 App 沙盒，
 *       此属性指向该文件。底层未落盘时为 `nil`。
 *
 *       此处提供的是 **可直接使用** 的音频文件（如 WAV / MP3 / Opus），
 *       适用于 `AVAudioPlayer` 播放、分享、上传等场景。
 *       设备端的原始编码（如耳机芯片输出的私有 PCM 帧）不在此暴露 ——
 *       它属于底层 SDK 的实现细节。
 */
@property (nonatomic, copy, nullable) NSURL *recordedAudioFileURL;

/**
 * @brief Audio format of `recordedAudioFileURL`
 * @chinese `recordedAudioFileURL` 对应的音频格式
 *
 * @discussion
 * [EN]: Meaningful only when `recordedAudioFileURL` is non-nil; otherwise
 *       set to `TSAIAudioFormatNone`.
 * [CN]: 仅当 `recordedAudioFileURL` 非 nil 时有意义，
 *       否则置为 `TSAIAudioFormatNone`。
 */
@property (nonatomic, assign) TSAIAudioFormat recordedAudioFormat;

@end

NS_ASSUME_NONNULL_END
