//
//  TSAIDeviceQuestionAnswerOutputSink.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/13.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"
#import "TSAITTSResult.h"
#import "TSAITTSStreamChunk.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief App-side output sink for device-initiated question-answer playback
 * @chinese 设备发起问答的 App 侧播放输出协议
 *
 * @discussion
 * [EN]: AIKit owns ASR, answer generation, and TTS. The App owns the audio
 *       route and plays the complete audio payload through this sink.
 * [CN]: AIKit 负责 ASR、答案生成与 TTS；App 负责音频路由，并通过本协议
 *       播放完整音频数据。
 */
@protocol TSAIDeviceQuestionAnswerOutputSink <NSObject>

/**
 * @brief Play one complete question-answer TTS result
 * @chinese 播放一份完整的问答 TTS 结果
 * @param result EN: Complete synthesized audio result. CN: 完整的合成音频结果。
 * @param taskId EN: Playback task identifier. CN: 播放任务标识。
 * @param completion EN: Called exactly once when playback finishes or fails.
 *                       CN: 播放完成或失败时仅调用一次。
 * @discussion EN: AIKit invokes this method on the main thread. The sink may
 *                 complete on any queue.
 *             CN: AIKit 在主线程调用本方法；输出对象可在任意队列完成回调。
 */
- (void)playQuestionAnswerTTSResult:(TSAITTSResult *)result
                             taskId:(NSString *)taskId
                         completion:(nullable TSAICompletionBlock)completion
    NS_SWIFT_NAME(playQuestionAnswerTTSResult(_:taskId:completion:));

/**
 * @brief Stop and release a question-answer playback task
 * @chinese 停止并释放一项问答播放任务
 * @param taskId EN: Playback task identifier. CN: 播放任务标识。
 * @discussion EN: AIKit invokes this method on the main thread.
 *             CN: AIKit 在主线程调用本方法。
 */
- (void)stopQuestionAnswerPlaybackWithTaskId:(NSString *)taskId
    NS_SWIFT_NAME(stopQuestionAnswerPlayback(taskId:));

@end

/**
 * @brief App-side streaming output sink for device question-answer TTS
 * @chinese 设备问答 TTS 的 App 侧流式播放输出协议
 * @discussion EN: This optional extension preserves the complete-audio sink as fallback.
 *             CN: 本可选扩展保留完整音频输出协议作为回退路径。
 */
@protocol TSAIDeviceQuestionAnswerStreamingOutputSink <TSAIDeviceQuestionAnswerOutputSink>

/**
 * @brief Append one ordered streaming TTS audio chunk
 * @chinese 追加一个有序的流式 TTS 音频分片
 * @param chunk EN: Immutable audio chunk. CN: 不可变音频分片。
 * @param taskId EN: Playback task identifier. CN: 播放任务标识。
 * @discussion EN: AIKit invokes this method on the main thread in sequence order.
 *             CN: AIKit 在主线程按分片序号依次调用本方法。
 */
- (void)appendQuestionAnswerTTSStreamChunk:(TSAITTSStreamChunk *)chunk
                                    taskId:(NSString *)taskId
    NS_SWIFT_NAME(appendQuestionAnswerTTSStreamChunk(_:taskId:));

/**
 * @brief Finish input and complete after all queued audio is played
 * @chinese 结束输入，并在全部已排队音频播放完毕后完成
 * @param taskId EN: Playback task identifier. CN: 播放任务标识。
 * @param completion EN: Called exactly once after drain or failure. CN: 排空或失败后仅调用一次。
 * @discussion EN: AIKit invokes this method on the main thread; the sink may complete on any queue.
 *             CN: AIKit 在主线程调用本方法；输出对象可在任意队列完成回调。
 */
- (void)finishQuestionAnswerTTSStreamWithTaskId:(NSString *)taskId
                                      completion:(nullable TSAICompletionBlock)completion
    NS_SWIFT_NAME(finishQuestionAnswerTTSStream(taskId:completion:));

@end

NS_ASSUME_NONNULL_END
