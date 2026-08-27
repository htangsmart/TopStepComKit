//
//  TSAISpeechProvider.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSAIContractDefines.h"
#import "TSAISpeechDefines.h"
#import "TSAITTSConfig.h"
#import "TSAITTSResult.h"
#import "TSAITTSStreamChunk.h"
#import "TSAIASRFileConfig.h"
#import "TSAIASRPCMConfig.h"
#import "TSAIASRDeviceMicConfig.h"
#import "TSAIASRPartialResult.h"
#import "TSAIASRResult.h"
#import "TSAIASRDeviceMicResult.h"

NS_ASSUME_NONNULL_BEGIN

/** @brief Streaming TTS audio chunk callback @chinese 流式 TTS 音频分片回调 */
typedef void (^TSAITTSStreamChunkBlock)(TSAITTSStreamChunk *chunk);

/** @brief Streaming TTS terminal callback @chinese 流式 TTS 终态回调 */
typedef void (^TSAITTSStreamCompletionBlock)(NSString *taskId,
                                             NSError * _Nullable error);

/**
 * @brief AI Speech provider protocol
 * @chinese AI 语音接口协议
 *
 * @discussion
 * [EN]: Defines AI speech-related capabilities, including:
 * - Text To Speech (TTS)
 * - One-shot speech recognition from a fixed-format PCM buffer
 * - Streaming Speech Recognition (ASR), from a local file or the device microphone
 *
 * [CN]: 定义 AI 语音相关能力，包括：
 * - 文本转语音（TTS）
 * - 固定格式 PCM 数据的一次性语音识别
 * - 流式语音识别（ASR），支持本地文件与设备麦克风两种输入源
 */
@protocol TSAISpeechProvider <NSObject>

/**
 * @brief Whether AI speech services are supported
 * @chinese 是否支持 AI 语音服务
 *
 * @return
 * EN: YES when AI speech services are supported
 * CN: 支持 AI 语音服务时返回 YES
 */
- (BOOL)isSpeechSupported;

/**
 * @brief Whether device-microphone speech recognition is supported
 * @chinese 是否支持设备麦克风语音识别
 *
 * @return
 * EN: YES when device-microphone speech recognition is supported
 * CN: 支持设备麦克风语音识别时返回 YES
 */
- (BOOL)isDeviceMicSpeechSupported;

/**
 * @brief Whether offline speech recognition is supported
 * @chinese 是否支持离线语音识别
 *
 * @return
 * EN: YES when offline speech recognition is supported
 * CN: 支持离线语音识别时返回 YES
 */
- (BOOL)isOfflineSpeechSupported;

/**
 * @brief Whether one-shot PCM speech recognition is supported
 * @chinese 是否支持一次性 PCM 语音识别
 * @return EN: YES when supported. CN: 支持时返回 YES。
 */
@optional
- (BOOL)isPCMRecognitionSupported;

@required

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

#pragma mark - Streaming Text To Speech

@optional

/**
 * @brief Whether streaming synthesis is supported for a TTS configuration
 * @chinese 指定 TTS 配置是否支持流式合成
 * @param config EN: TTS configuration. CN: TTS 配置。
 * @return EN: YES when streaming synthesis can be started. CN: 可启动流式合成时返回 YES。
 */
- (BOOL)isStreamingSynthesisSupportedForConfig:(TSAITTSConfig *)config;

/**
 * @brief Synthesize speech and emit ordered audio chunks
 * @chinese 合成语音并按顺序输出音频分片
 * @param text EN: Source text; must not be empty. CN: 待合成文本，不可为空。
 * @param config EN: TTS configuration. CN: TTS 配置。
 * @param onAudioChunk EN: Ordered non-empty audio chunks. CN: 按顺序输出的非空音频分片。
 * @param completion EN: Terminal callback invoked exactly once. CN: 仅调用一次的终态回调。
 * @return EN: Stable client task identifier. CN: 稳定的客户端任务标识。
 * @discussion EN: `completion` is the end marker and is dispatched after all chunk callbacks.
 *             CN: `completion` 是流结束标记，并在全部分片回调之后下发。
 */
- (NSString *)synthesizeSpeechStreamWithText:(NSString *)text
                                      config:(TSAITTSConfig *)config
                                onAudioChunk:(nullable TSAITTSStreamChunkBlock)onAudioChunk
                                  completion:(nullable TSAITTSStreamCompletionBlock)completion;

@required

#pragma mark - One-shot ASR (PCM)

/**
 * @brief Recognize a complete 16 kHz mono Int16LE PCM buffer
 * @chinese 识别一段完整的 16 kHz 单声道 Int16LE PCM 数据
 * @param pcmData EN: PCM data. CN: PCM 数据。
 * @param config EN: Recognition configuration. CN: 识别配置。
 * @param onPartialResult EN: Optional partial callback. CN: 可选中间结果回调。
 * @param completion EN: Completion invoked exactly once. CN: 仅调用一次的完成回调。
 * @return EN: Stable client task identifier. CN: 稳定的客户端任务标识。
 */
@optional
- (NSString *)recognizeSpeechWithPCMData:(NSData *)pcmData
                                  config:(TSAIASRPCMConfig *)config
                         onPartialResult:(nullable TSAIASRPartialBlock)onPartialResult
                              completion:(nullable TSAIASRCompletionBlock)completion;

@required

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
 * EN: TaskId returned by a PCM, file, or device-microphone ASR method
 * CN: PCM、文件或设备麦克风 ASR 方法返回的 taskId
 *
 * @discussion
 * [EN]: Routes to the right task by taskId, so a single cancel API covers
 *       PCM, file and device-microphone ASR. If the task has already
 *       completed or the taskId is unknown, the call is a no-op. The
 *       completion handler of a cancelled task is invoked with a non-nil
 *       error indicating cancellation; for device-mic ASR the underlying
 *       device microphone stream is also closed.
 *
 *       Difference from `stopDeviceMicRecognitionWithTaskId:` —
 *       `cancel` *discards* the in-flight result, while `stop` flushes the
 *       buffered audio and delivers a final result via the completion block.
 *
 * [CN]: 通过 taskId 路由到对应任务，PCM、文件与设备麦克风 ASR 共用同一个取消接口。
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

/**
 * @brief Register listener for device-microphone recognition state changes
 * @chinese 注册设备麦克风识别状态变化监听
 *
 * @param stateBlock
 * EN: Callback invoked when state changes; pass nil to unregister
 * CN: 状态变化时触发的回调；传 nil 可取消监听
 */
- (void)registerDeviceMicRecognitionStateDidChanged:(TSAIDeviceMicRecognitionStateBlock _Nullable)stateBlock;

/**
 * @brief Reject a device-initiated microphone recognition request
 * @chinese 拒绝设备侧发起的麦克风识别请求
 *
 * @param completion
 * EN: Completion block called after the rejection command is handled
 * CN: 拒绝命令处理完成后的回调
 *
 * @discussion
 * [EN]: Used when the device has requested recording but the app cannot
 *       continue, such as permission denied or a conflicting local state.
 * [CN]: 用于设备已请求录音但 App 无法继续的场景，如无权限或本地状态冲突。
 */
- (void)rejectDeviceMicRecognitionWithCompletion:(TSAICompletionBlock _Nullable)completion;

/**
 * @brief Query whether offline speech recognition is supported
 * @chinese 查询是否支持离线语音识别
 *
 * @param completion
 * EN: Completion block carrying support result
 * CN: 携带支持结果的完成回调
 */
- (void)queryOfflineSpeechSupportedWithCompletion:(TSAISpeechBoolResultBlock _Nullable)completion;

/**
 * @brief Set speech recognition mode
 * @chinese 设置语音识别模式
 *
 * @param mode
 * EN: Speech recognition mode
 * CN: 语音识别模式
 *
 * @param completion
 * EN: Completion block called when setting finishes
 * CN: 设置完成时调用的回调
 */
- (void)setSpeechRecognitionMode:(TSAISpeechRecognitionMode)mode
                      completion:(TSAICompletionBlock _Nullable)completion;

/**
 * @brief Set offline speech recognition mode
 * @chinese 设置离线语音识别模式
 *
 * @param mode
 * EN: Offline speech recognition mode
 * CN: 离线语音识别模式
 *
 * @param completion
 * EN: Completion block called when setting finishes
 * CN: 设置完成时调用的回调
 */
- (void)setOfflineSpeechMode:(TSAISpeechRecognitionMode)mode
                  completion:(TSAICompletionBlock _Nullable)completion;

/**
 * @brief Cancel every task owned by this capability Provider
 * @chinese 取消当前能力 Provider 持有的全部任务
 */
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
