//
//  TSAIAssistantProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAssistantDefines.h"

@class TSAIChatConfig;
@class TSAIChatAudioProcessor;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Joins the exact provider task and any vendor teardown it initiated
 * @chinese 等待精确 Provider 任务及其发起的厂商拆除完成
 */
@protocol TSAIChatTerminationProviding <NSObject>
/**
 * @brief Wait for termination or a safely parked connection
 * @chinese 等待任务终止或连接安全保活
 * @param taskId EN: Exact public task identifier. CN: 精确公开任务标识。
 * @param completion EN: Cleanup result; timeout never clears ownership.
 * CN: 清理结果；超时不得清空占用状态。
 */
- (void)waitForChatTerminationWithTaskId:(NSString *)taskId
                            completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
@optional
/**
 * @brief Update actual host output activity for no-input timing
 * @chinese 更新宿主实际输出活动状态，用于无输入计时
 * @param active EN: Output is queued or playing. CN: 输出已排队或正在播放。
 * @param taskId EN: Exact public task identifier. CN: 精确公开任务标识。
 */
- (void)setChatHostPlaybackActive:(BOOL)active taskId:(NSString *)taskId;
@end

/**
 * @brief Optional external-PCM input implemented by a chat Provider
 * @chinese Chat Provider 可选实现的外部 PCM 输入
 */
@protocol TSAIExternalPCMChatProvider <NSObject>

/**
 * @brief Append 16 kHz mono Int16LE PCM to the active chat
 * @chinese 向活动对话追加 16 kHz 单声道 Int16LE PCM
 */
- (void)appendExternalPCMData:(NSData *)pcmData;

@optional

/**
 * @brief Append PCM of a given chat task without blocking the caller
 * @chinese 向指定对话任务追加 PCM，不阻塞调用线程
 *
 * @discussion
 * EN: Called on the audio thread. The data is handed to the chat queue asynchronously and dropped
 *     when taskId is no longer the active task (late data of an old session).
 * CN: 在音频线程调用。数据异步交给对话队列；taskId 已不是当前任务时（旧会话的迟到数据）直接丢弃。
 */
- (void)appendExternalPCMData:(NSData *)pcmData taskId:(NSString *)taskId;

/**
 * @brief The AIKit-captured microphone of the task produces data (InputReady)
 * @chinese 该任务由 AIKit 采集的麦克风已开始出数据（InputReady）
 *
 * @discussion
 * EN: Input timers (single-round input idle, maximum input duration, continuous idle) count from
 *     here for routes whose input AIKit captures. Routes without InputReady keep the old start point.
 * CN: 对 AIKit 采集输入的路由，输入计时（单轮输入空闲、最长输入、畅聊空闲）从这一刻起算；
 *     没有 InputReady 的路由保持原来的起点。
 */
- (void)tsai_inputDidBecomeReadyForTaskId:(NSString *)taskId;

/**
 * @brief Start a chat whose audio input is captured by AIKit
 * @chinese 启动由 AIKit 采集音频输入的对话
 *
 * @discussion
 * EN: With usesExternalPCMInput = YES the route input (e.g. earbuds SCO captured on the phone)
 *     arrives only through appendExternalPCMData:, and the Provider must neither open a
 *     microphone nor play voice itself; AIKit plays the PCM content. With NO it behaves like
 *     -startChatWithConfig:onContent:onEvent:completion:.
 * CN: usesExternalPCMInput 为 YES 时，路由输入（例如由手机采集的耳机 SCO）只经
 *     appendExternalPCMData: 送入，Provider 不得自行打开麦克风或播放语音，语音由 AIKit 按 PCM 内容播放；
 *     为 NO 时与 -startChatWithConfig:onContent:onEvent:completion: 相同。
 */
- (NSString *)startChatWithConfig:(TSAIChatConfig *)config
             usesExternalPCMInput:(BOOL)usesExternalPCMInput
                        onContent:(nullable TSAIChatContentBlock)onContent
                          onEvent:(nullable TSAIChatEventBlock)onEvent
                       completion:(nullable TSAIChatCompletionBlock)completion;

@end

/**
 * @brief Internal rollback hook for pending device-origin chat preparation
 * @chinese 设备发起 Chat pending 准备的内部回滚钩子
 */
@protocol TSAIDeviceChatPreparationManaging <NSObject>

/**
 * @brief Reset pending input without stopping an active chat task
 * @chinese 清理 pending 输入，但不得停止活动 Chat 任务
 */
- (void)resetPendingDeviceChatPreparation;

@end

/**
 * @brief Optional processing binding and timestamp-preserving device input
 * @chinese 可选的处理器绑定与保留时间戳的设备输入
 */
@protocol TSAIChatAudioProcessingProvider <NSObject>

/**
 * @brief Prepare the processor consumed by the next chat start
 * @chinese 准备由下一次对话启动消费的处理器
 *
 * @param processor
 * EN: Next session processor, or nil to clear the pending binding. Enqueued on the chat queue.
 * CN: 下一会话处理器；nil 清除待绑定对象。操作排入对话队列。
 */
- (void)prepareChatAudioProcessor:(nullable TSAIChatAudioProcessor *)processor;

/**
 * @brief Accept device audio with its earliest host arrival timestamp
 * @chinese 接收带最早主机到达时间的设备音频
 *
 * @param opusData
 * EN: Optional encoded device bytes.
 * CN: 可选的设备编码字节。
 *
 * @param pcmData
 * EN: Optional decoded 16 kHz mono Int16LE PCM.
 * CN: 可选的 16 kHz 单声道 Int16LE 解码 PCM。
 *
 * @param receivedAtNanoseconds
 * EN: Monotonic host arrival time, not a firmware capture timestamp.
 * CN: 主机单调到达时刻，不是固件采集时间戳。
 */
- (void)handleDeviceChatAudioWithOpusData:(nullable NSData *)opusData
                                pcmData:(nullable NSData *)pcmData
                  receivedAtNanoseconds:(uint64_t)receivedAtNanoseconds;

@end

NS_ASSUME_NONNULL_END
