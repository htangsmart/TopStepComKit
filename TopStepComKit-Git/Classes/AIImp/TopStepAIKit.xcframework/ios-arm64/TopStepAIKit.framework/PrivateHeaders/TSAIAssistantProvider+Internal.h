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
 * @brief Explicit Provider-owned chat capture and playback integration
 * @chinese 显式由 Provider 管理对话采集与播放的内部接入契约
 *
 * @discussion
 * [EN]: The Provider reports playback and input readiness through existing chat
 *       events. AIKit preserves those events and does not create a capture or
 *       output driver for this mode. Device PCM is still delivered by task.
 * [CN]: Provider 通过现有 Chat 事件报告播放和输入就绪；AIKit 保留这些事件，
 *       不为此模式创建采集或输出驱动。设备 PCM 仍按任务交付。
 */
@protocol TSAINativePlaybackChatProvider <NSObject>

/**
 * @brief Validate native playback parameters without starting audio or a task
 * @chinese 无采播及任务副作用地校验原生播放参数
 * @param config
 * EN: Requested or resolved chat configuration.
 * CN: 调用方请求或解析后的对话配置。
 * @return
 * EN: Nil when supported, otherwise a descriptive error.
 * CN: 支持时为 nil，否则返回说明原因的错误。
 */
- (nullable NSError *)validateNativePlaybackChatConfig:(TSAIChatConfig *)config;

/**
 * @brief Stop the native playback owned by an exact chat task
 * @chinese 停止精确对话任务所属的原生播放
 * @param taskId
 * EN: Owning task identifier; stale identifiers must not affect a new task.
 * CN: 所属任务标识；旧标识不得影响新任务。
 */
- (void)stopNativePlaybackWithTaskId:(NSString *)taskId;

/**
 * @brief Whether the Provider reports no audio ownership or exposed capture/playback use
 * @chinese Provider 是否报告无音频所有权且无公开采集或播放占用
 * @return
 * EN: File-only operations do not hold audio ownership. YES requires no audio
 *     owner or exposed capture/playback flag; it does not prove physical drain.
 * CN: 纯文件业务不取得音频所有权；没有音频 owner 或公开采播标志时才返回 YES，
 *     不证明 AVAudioSession 已完成物理排空。
 */
- (BOOL)isNativePlaybackAudioSessionIdle;

@optional

/**
 * @brief Changes to the Provider's observable audio-idle state
 * @chinese Provider 可观察音频空闲状态变化
 * @discussion
 * EN: Delivered on the main thread. The Context merges it with Core leases.
 * CN: 在主线程交付，由 Context 与 Core 租约状态合并。
 * @note
 * EN: Does not promise physical vendor callback or audio-session draining.
 * CN: 不承诺厂商回调或音频会话已经物理排空。
 */
@property (nonatomic, copy, nullable) void (^nativePlaybackAudioSessionIdleDidChangeHandler)(BOOL idle);

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
 *     microphone. It must not play voice itself unless it also implements
 *     TSAINativePlaybackChatProvider and config.voiceOutputMode explicitly
 *     selects ProviderPlayback. Otherwise AIKit plays the PCM content.
 *     With NO it behaves like -startChatWithConfig:onContent:onEvent:completion:.
 * CN: usesExternalPCMInput 为 YES 时，路由输入（例如由手机采集的耳机 SCO）只经
 *     appendExternalPCMData: 送入，Provider 不得自行打开麦克风；仅在同时实现
 *     TSAINativePlaybackChatProvider 且显式选择 ProviderPlayback 时允许自播，
 *     其他情况仍由 AIKit 按 PCM 内容播放；
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
