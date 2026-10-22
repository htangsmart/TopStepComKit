//
//  TSAIAssistantProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAssistantDefines.h"

@class TSAIChatConfig;

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
