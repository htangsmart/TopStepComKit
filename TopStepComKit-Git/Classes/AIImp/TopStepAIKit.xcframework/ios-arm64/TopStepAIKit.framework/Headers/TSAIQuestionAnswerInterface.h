//
//  TSAIQuestionAnswerInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import "TSAIQuestionAnswerConfig.h"
#import "TSAIQuestionAnswerDefines.h"
#import "TSAIContractDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Single-question AI answering interface
 * @chinese 单次 AI 问答接口
 *
 * @discussion
 * [EN]: Defines a provider-neutral text-in / text-out task. It is independent
 *       of AI Assistant summary and voice-chat sessions.
 * [CN]: 定义厂商无关的文本输入 / 文本输出任务，独立于 AI Assistant 的
 *       总结能力和语音对话会话。
 */
@protocol TSAIQuestionAnswerInterface <NSObject>

/**
 * @brief Configure and arm one device-voice question-answer session
 * @chinese 配置并等待一次设备语音问答会话
 * @param config EN: Business and audio-route configuration. CN: 业务与音频路由配置。
 * @param completion EN: Main-thread configuration result. CN: 主线程配置结果回调。
 * @return EN: Stable session identifier used by stop. CN: 用于停止的稳定会话标识。
 */
- (NSString *)startDeviceQuestionAnswerWithConfig:(TSAIQuestionAnswerConfig *)config
                                        completion:(TSAICompletionBlock _Nullable)completion;

/**
 * @brief Stop a configured device-voice question-answer session
 * @chinese 停止已配置的设备语音问答会话
 * @param taskId EN: Identifier returned by start. CN: start 返回的会话标识。
 */
- (void)stopDeviceQuestionAnswerWithTaskId:(NSString *)taskId;

/**
 * @brief Ask one text question and receive a streaming answer
 * @chinese 提交一个文本问题并接收流式答案
 *
 * @param question
 * EN: Non-empty question text
 * CN: 非空的问题文本
 *
 * @param config
 * EN: Provider-neutral question-answer configuration
 * CN: Provider 无关的问答配置
 *
 * @param onStartAnswering
 * EN: Optional main-thread callback invoked when answering starts
 * CN: 可选的主线程回调，服务开始回答时调用
 *
 * @param onPartialResult
 * EN: Optional main-thread callback for cumulative answer updates
 * CN: 可选的主线程回调，返回累积答案更新
 *
 * @param completion
 * EN: Main-thread callback invoked exactly once on success, failure or
 *     logical cancellation
 * CN: 成功、失败或逻辑取消时在主线程且仅调用一次的终态回调
 *
 * @return
 * EN: Stable client-side task identifier
 * CN: 稳定的客户端任务标识
 */
- (NSString *)askQuestion:(NSString *)question
                   config:(TSAIQuestionAnswerConfig *)config
         onStartAnswering:(TSAIQuestionAnswerStartBlock _Nullable)onStartAnswering
          onPartialResult:(TSAIQuestionAnswerPartialBlock _Nullable)onPartialResult
               completion:(TSAIQuestionAnswerCompletionBlock _Nullable)completion;

/**
 * @brief Logically cancel a question-answer task
 * @chinese 逻辑取消一个 AI 问答任务
 *
 * @param taskId
 * EN: Client task identifier returned by `askQuestion`
 * CN: `askQuestion` 返回的客户端任务标识
 *
 * @discussion
 * [EN]: The current AIBuds service has no physical cancellation API. Local
 *       cancellation completes once with an error and drops later callbacks.
 * [CN]: 当前 AIBuds 服务没有物理取消接口。本地取消会以错误终态回调一次，
 *       并丢弃后续回调。
 */
- (void)cancelQuestionAnswerWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
