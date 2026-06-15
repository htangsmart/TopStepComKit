//
//  TSAISpeechInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSKitBaseInterface.h"
#import "TSAITTSConfig.h"
#import "TSAITTSResult.h"
#import "TSAIASRFileConfig.h"
#import "TSAIASRDeviceMicConfig.h"
#import "TSAIASRPartialResult.h"
#import "TSAIASRResult.h"
#import "TSAIASRDeviceMicResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TTS synthesis completion block
 * @chinese 文本转语音合成完成回调
 *
 * @param result
 * EN: Synthesis result; nil on failure
 * CN: 合成结果，失败时为 nil
 *
 * @param error
 * EN: Error info; nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAITTSCompletionBlock)(TSAITTSResult * _Nullable result,
                                      NSError * _Nullable error);

/**
 * @brief Streaming ASR partial-result block
 * @chinese 流式语音识别中间结果回调
 *
 * @param partial
 * EN: Cumulative partial result emitted during recognition
 * CN: 识别过程中下发的累积中间结果
 *
 * @discussion
 * [EN]: Invoked zero or more times before completion. `partial.text` is the
 *       full cumulative transcription so far, not the newly added fragment.
 * [CN]: 在 completion 回调之前可能被调用零次或多次。
 *       `partial.text` 为截至当前时刻的累积识别文本，并非新增片段。
 */
typedef void(^TSAIASRPartialBlock)(TSAIASRPartialResult *partial);

/**
 * @brief Streaming ASR completion block (file ASR)
 * @chinese 流式语音识别完成回调（文件 ASR）
 *
 * @param result
 * EN: Final recognition result; nil on failure or cancellation
 * CN: 最终识别结果，失败或取消时为 nil
 *
 * @param error
 * EN: Error info; nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAIASRCompletionBlock)(TSAIASRResult * _Nullable result,
                                      NSError * _Nullable error);

/**
 * @brief Streaming ASR completion block (device-microphone ASR)
 * @chinese 流式语音识别完成回调（设备麦克风 ASR）
 *
 * @param result
 * EN: Final device-microphone session result; nil on failure or cancellation
 * CN: 设备麦克风会话的最终结果，失败或取消时为 nil
 *
 * @param error
 * EN: Error info; nil on success
 * CN: 错误信息，成功时为 nil
 *
 * @discussion
 * [EN]: Distinct from `TSAIASRCompletionBlock` because device-mic sessions
 *       carry session-level attributes (start / end time, interruption,
 *       on-device offline routing, scene, recorded audio file) that don't
 *       apply to file ASR. See `TSAIASRDeviceMicResult`.
 * [CN]: 与 `TSAIASRCompletionBlock` 分开，是因为设备麦克风会话带有
 *       文件 ASR 不具备的会话级信息（起止时间、中断状态、端侧离线路由、
 *       场景、录音落盘文件）。详见 `TSAIASRDeviceMicResult`。
 */
typedef void(^TSAIASRDeviceMicCompletionBlock)(TSAIASRDeviceMicResult * _Nullable result,
                                               NSError * _Nullable error);

/**
 * @brief AI Speech interface protocol
 * @chinese AI 语音接口协议
 *
 * @discussion
 * [EN]: Defines AI speech-related capabilities, including:
 * - Text To Speech (TTS)
 * - Streaming Speech Recognition (ASR), from a local file or the device microphone
 *
 * [CN]: 定义 AI 语音相关能力，包括：
 * - 文本转语音（TTS）
 * - 流式语音识别（ASR），支持本地文件与设备麦克风两种输入源
 */
@protocol TSAISpeechInterface <TSKitBaseInterface>

#pragma mark - Text To Speech

/**
 * @brief Synthesize speech from text (one-shot)
 * @chinese 文本转语音（一次性返回完整音频）
 *
 * @param text
 * EN: Source text to synthesize; must not be empty
 * CN: 待合成文本，不可为空
 *
 * @param config
 * EN: TTS configuration (speaker, etc.)
 * CN: TTS 配置（发音人等）
 *
 * @param completion
 * EN: Completion handler, invoked once when synthesis finishes or fails
 * CN: 完成回调，合成完成或失败时调用一次
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and future cancellation.
 *     The same taskId is also carried back in the result for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及后续取消能力。
 *     同一 taskId 会回填在 result 中，便于关联请求与响应。
 *
 * @discussion
 * [EN]: The taskId returned synchronously is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server task ID.
 *       This guarantees the caller obtains a stable identifier the moment the
 *       request is issued, decoupled from the concrete AI provider implementation.
 * [CN]: 同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关。
 *       这保证调用方在发起请求的瞬间即可拿到稳定标识，与具体提供方实现解耦。
 */
- (NSString *)synthesizeSpeechWithText:(NSString *)text
                                config:(TSAITTSConfig *)config
                            completion:(TSAITTSCompletionBlock _Nullable)completion;

/**
 * @brief Cancel a running TTS synthesis task
 * @chinese 取消一个进行中的 TTS 合成任务
 *
 * @param taskId
 * EN: TaskId returned by `synthesizeSpeechWithText:config:completion:`
 * CN: `synthesizeSpeechWithText:config:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: If the task has already completed or the taskId is unknown, the call
 *       is a no-op. The completion handler of a cancelled task is invoked
 *       with a non-nil error indicating cancellation.
 * [CN]: 若任务已完成或 taskId 未知，调用无副作用。
 *       被取消任务的 completion 回调会以非 nil 的取消错误调用。
 */
- (void)cancelSynthesisWithTaskId:(NSString *)taskId;

#pragma mark - Streaming ASR (File)

/**
 * @brief Recognize speech from a local audio file in a streaming manner
 * @chinese 以流式方式对本地音频文件进行语音识别
 *
 * @param audioFileURL
 * EN: Local file URL of the audio to recognize; must not be nil
 * CN: 待识别音频的本地文件 URL，不可为 nil
 *
 * @param config
 * EN: ASR configuration (language, audio format, etc.)
 * CN: 流式识别配置（语言、音频格式等）
 *
 * @param onPartialResult
 * EN: Partial-result callback, invoked zero or more times with cumulative text
 *     during recognition. May be nil if the caller only cares about the final
 *     result.
 * CN: 中间结果回调，识别过程中可能被多次调用，返回累积识别文本。
 *     若调用方只关心最终结果可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when recognition finishes,
 *     fails or is cancelled.
 * CN: 完成回调，识别完成、失败或取消时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and cancellation via
 *     `cancelRecognitionWithTaskId:`. The same taskId is echoed in every
 *     partial and the final result for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及通过 `cancelRecognitionWithTaskId:`
 *     取消任务。同一 taskId 会回填在每次 partial 与最终 result 中，便于关联。
 *
 * @discussion
 * [EN]: The taskId returned synchronously is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server
 *       task ID. The caller obtains a stable identifier the moment the
 *       request is issued, decoupled from the concrete AI provider.
 * [CN]: 同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关。
 *       调用方在发起请求的瞬间即可拿到稳定标识，与具体提供方实现解耦。
 */
- (NSString *)recognizeSpeechWithFileURL:(NSURL *)audioFileURL
                                  config:(TSAIASRFileConfig *)config
                         onPartialResult:(TSAIASRPartialBlock _Nullable)onPartialResult
                              completion:(TSAIASRCompletionBlock _Nullable)completion;

/**
 * @brief Cancel a running streaming ASR task
 * @chinese 取消一个进行中的流式语音识别任务
 *
 * @param taskId
 * EN: TaskId returned by either `recognizeSpeechWithFileURL:...` or
 *     `recognizeSpeechWithDeviceMicConfig:...`
 * CN: `recognizeSpeechWithFileURL:...` 或
 *     `recognizeSpeechWithDeviceMicConfig:...` 返回的 taskId
 *
 * @discussion
 * [EN]: Routes to the right task by taskId, so a single cancel API covers
 *       both file ASR and device-microphone ASR. If the task has already
 *       completed or the taskId is unknown, the call is a no-op. The
 *       completion handler of a cancelled task is invoked with a non-nil
 *       error indicating cancellation; for device-mic ASR the underlying
 *       device microphone stream is also closed.
 *
 *       Difference from `stopDeviceMicRecognitionWithTaskId:` —
 *       `cancel` *discards* the in-flight result, while `stop` flushes the
 *       buffered audio and delivers a final result via the completion block.
 *
 * [CN]: 通过 taskId 路由到对应任务，文件 ASR 与设备麦克风 ASR 共用同一个取消接口。
 *       若任务已完成或 taskId 未知，调用无副作用。
 *       被取消任务的 completion 回调会以非 nil 的取消错误调用；
 *       设备麦克风 ASR 场景还会同时关闭底层设备麦克风音频流。
 *
 *       与 `stopDeviceMicRecognitionWithTaskId:` 的区别：
 *       `cancel` 表示丢弃当前结果；`stop` 会冲刷已缓冲音频并通过 completion 回调
 *       下发最终识别结果。
 */
- (void)cancelRecognitionWithTaskId:(NSString *)taskId;

#pragma mark - Streaming ASR (Device Microphone)

/**
 * @brief Recognize speech captured live from the device microphone
 * @chinese 对设备麦克风采集的音频进行流式语音识别
 *
 * @param config
 * EN: Device-mic ASR configuration (language, offline fallback, scene)
 * CN: 设备麦克风识别配置（语言、离线降级开关、场景）
 *
 * @param onPartialResult
 * EN: Partial-result callback, invoked zero or more times with cumulative
 *     text during recognition. May be nil if the caller only cares about
 *     the final result.
 * CN: 中间结果回调，识别过程中可能被多次调用，返回累积识别文本。
 *     若调用方只关心最终结果可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when recognition stops,
 *     fails or is cancelled.
 * CN: 完成回调，识别结束、失败或取消时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing, `stop` and
 *     `cancel`. The same taskId is echoed in every partial and the final
 *     result for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪、`stop` 与 `cancel`。
 *     同一 taskId 会回填在每次 partial 与最终 result 中，便于关联。
 *
 * @discussion
 * [EN]: This is the "AI recording" capability — the SDK internally performs
 *       three steps the caller does not have to handle:
 *         1) Activate the AI capability on the connected device.
 *         2) Open the device microphone audio stream.
 *         3) Bridge the audio frames into the recognition pipeline and
 *            deliver partial / final results through the callbacks.
 *
 *       Unlike file ASR, the input is open-ended; callers must end the
 *       session explicitly via either `stopDeviceMicRecognitionWithTaskId:`
 *       (flush and deliver a final result) or `cancelRecognitionWithTaskId:`
 *       (discard).
 *
 *       The synchronously returned taskId is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server
 *       task ID, so the caller obtains a stable identifier the moment the
 *       request is issued.
 *
 * [CN]: 该方法即"AI 录音"能力 —— SDK 内部完成调用方无需感知的三步：
 *         1) 激活已连接设备的 AI 能力；
 *         2) 打开设备麦克风音频流；
 *         3) 将音频帧桥接到识别管道，并通过回调下发中间 / 最终结果。
 *
 *       与文件 ASR 不同，该输入源没有自然结束点；调用方必须显式结束会话，
 *       通过 `stopDeviceMicRecognitionWithTaskId:`（冲刷并下发最终结果）
 *       或 `cancelRecognitionWithTaskId:`（丢弃）。
 *
 *       同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关，
 *       调用方在发起请求的瞬间即可拿到稳定标识。
 */
- (NSString *)recognizeSpeechWithDeviceMicConfig:(TSAIASRDeviceMicConfig *)config
                                 onPartialResult:(TSAIASRPartialBlock _Nullable)onPartialResult
                                      completion:(TSAIASRDeviceMicCompletionBlock _Nullable)completion;

/**
 * @brief Stop a running device-microphone ASR task and deliver the final result
 * @chinese 主动结束设备麦克风 ASR 任务并下发最终识别结果
 *
 * @param taskId
 * EN: TaskId returned by
 *     `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`
 * CN: `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:`
 *     返回的 taskId
 *
 * @discussion
 * [EN]: Closes the device microphone audio stream, flushes any buffered
 *       audio through the recognition pipeline, and invokes the original
 *       `completion` block with the final result.
 *
 *       If the task has already completed or the taskId is unknown, the
 *       call is a no-op. Use `cancelRecognitionWithTaskId:` instead when
 *       you want to discard the result.
 *
 * [CN]: 关闭设备麦克风音频流，将已缓冲音频送入识别管道完成最终识别，
 *       并通过原 `completion` 回调下发最终结果。
 *
 *       若任务已完成或 taskId 未知，调用无副作用。
 *       若希望丢弃当前结果，请改用 `cancelRecognitionWithTaskId:`。
 */
- (void)stopDeviceMicRecognitionWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
