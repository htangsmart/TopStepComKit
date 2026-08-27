//
//  TSAIBudsAssistantProvider+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import "TSAIBudsAssistantProvider.h"
#import "TSAIBudsChatAudioIngress+Internal.h"
#import "TSAIBudsSessionStore.h"

@import AIBudsAI;
@import AIBudsAIFoundation;
@import AIBudsFoundation;

NS_ASSUME_NONNULL_BEGIN

/** @brief Shared assistant state @chinese 助手共享状态 */
@interface TSAIBudsAssistantProvider ()

/** @brief Current summary task identifier @chinese 当前总结任务标识 */
@property (nonatomic, copy, nullable) NSString *currentSummaryTaskId;
/** @brief Current summary partial callback @chinese 当前总结中间结果回调 */
@property (nonatomic, copy, nullable) TSAISummaryPartialBlock currentSummaryPartialBlock;
/** @brief Current summary completion callback @chinese 当前总结完成回调 */
@property (nonatomic, copy, nullable) TSAISummaryCompletionBlock currentSummaryCompletionBlock;
/** @brief Current summary start time @chinese 当前总结开始时间 */
@property (nonatomic, copy, nullable) NSDate *currentSummaryStartTime;

/** @brief Current chat task identifier @chinese 当前对话任务标识 */
@property (nonatomic, copy, nullable) NSString *currentChatTaskId;
/** @brief Current device chat session event @chinese 当前设备对话会话事件 */
@property (nonatomic, assign) NSInteger currentSessionEvent;
/** @brief Current chat content callback @chinese 当前对话内容回调 */
@property (nonatomic, copy, nullable) TSAIChatContentBlock currentChatContentBlock;
/** @brief Current chat event callback @chinese 当前对话事件回调 */
@property (nonatomic, copy, nullable) TSAIChatEventBlock currentChatEventBlock;
/** @brief Current chat completion callback @chinese 当前对话完成回调 */
@property (nonatomic, copy, nullable) TSAIChatCompletionBlock currentChatCompletionBlock;
/** @brief Current public chat configuration @chinese 当前公开对话配置 */
@property (nonatomic, strong, nullable) TSAIChatConfig *currentChatConfig;
/** @brief Current chat start time @chinese 当前对话开始时间 */
@property (nonatomic, copy, nullable) NSDate *currentChatStartTime;
/** @brief Last chat runtime error @chinese 最近一次对话运行错误 */
@property (nonatomic, strong, nullable) NSError *currentChatLastError;
/** @brief Pending chat end reason @chinese 待写入报告的对话结束原因 */
@property (nonatomic, assign) TSAIChatEndReason currentChatPendingEndReason;
/** @brief Whether the caller requested chat stop @chinese 调用方是否请求停止对话 */
@property (nonatomic, assign) BOOL currentChatStopRequested;
/** @brief Mapping from question identifier to round index @chinese 问题标识到轮次序号的映射 */
@property (nonatomic, strong, nullable)
    NSMutableDictionary<NSString *, NSNumber *> *currentChatQuestionIdToRound;
/** @brief Next unassigned chat round index @chinese 下一个未分配的对话轮次序号 */
@property (nonatomic, assign) NSInteger currentChatNextRoundIndex;
/** @brief Chat lifecycle serialization queue @chinese 对话生命周期串行队列 */
@property (nonatomic, strong) dispatch_queue_t chatQueue;
/** @brief Bounded pre-session PCM ingress @chinese 有界会话前 PCM 入口 */
@property (nonatomic, strong) TSAIBudsChatAudioIngress *chatAudioIngress;
/** @brief Generation bound to the active chat task @chinese 当前对话任务绑定的代际 */
@property (nonatomic, assign) NSUInteger currentChatGeneration;

/** @brief Context-owned session store @chinese Context 持有的会话存储 */
@property (nonatomic, strong) TSAIBudsSessionStore *sessionStore;
/** @brief Device-side chat event callback @chinese 设备侧对话事件回调 */
@property (nonatomic, copy, nullable) void(^deviceEventBlock)(TSAIChatDeviceEvent event);
/** @brief Chat state callback @chinese 对话状态回调 */
@property (nonatomic, copy, nullable) TSAIChatStateBlock chatStateBlock;

/** @brief Execute synchronously on the chat queue @chinese 在对话串行队列同步执行 */
- (void)tsai_executeSynchronouslyOnChatQueue:(dispatch_block_t)block;
/** @brief Dispatch asynchronously to the chat queue @chinese 异步派发到对话串行队列 */
- (void)tsai_dispatchAsyncOnChatQueue:(dispatch_block_t)block;
/** @brief Whether the caller is on the chat queue @chinese 当前是否在对话串行队列 */
- (BOOL)tsai_isExecutingOnChatQueue;
/** @brief Stop AIBuds after ingress has flushed @chinese ingress 冲刷完成后停止 AIBuds */
- (void)tsai_stopVendorChatForGeneration:(NSUInteger)generation
                          taskIdentifier:(NSString *)taskIdentifier;

@end

/** @brief Summary implementation contract @chinese 总结实现契约 */
@interface TSAIBudsAssistantProvider (Summary)

/**
 * @brief Execute streaming text summarization
 * @chinese 执行流式文本总结
 * @param text EN: Source text. CN: 源文本。
 * @param onPartialResult EN: Partial callback. CN: 中间结果回调。
 * @param completion EN: Completion callback. CN: 完成回调。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)tsai_summarizeText:(NSString *)text
                 onPartialResult:(nullable TSAISummaryPartialBlock)onPartialResult
                      completion:(nullable TSAISummaryCompletionBlock)completion;

/**
 * @brief Cancel the active summary task
 * @chinese 取消当前总结任务
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 */
- (void)tsai_cancelSummarizeWithTaskId:(NSString *)taskId;

/**
 * @brief Handle a summary stream callback
 * @chinese 处理总结流式回调
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param isFinal EN: Whether this is final. CN: 是否为最终结果。
 * @param transcript EN: Cumulative text. CN: 累积文本。
 * @param error EN: Provider error. CN: Provider 错误。
 */
- (void)tsai_handleSummaryStreamResultForTaskId:(NSString *)taskId
                                        isFinal:(BOOL)isFinal
                                     transcript:(nullable NSString *)transcript
                                          error:(nullable NSError *)error;

/**
 * @brief Clear the active summary state
 * @chinese 清理当前总结状态
 */
- (void)tsai_resetCurrentSummaryTask;

/**
 * @brief Deliver a summary partial result
 * @chinese 下发总结中间结果
 * @param partialBlock EN: Partial callback. CN: 中间结果回调。
 * @param partial EN: Partial result. CN: 中间结果。
 */
- (void)tsai_callSummaryPartial:(nullable TSAISummaryPartialBlock)partialBlock
                        partial:(TSAISummaryPartialResult *)partial;

/**
 * @brief Deliver summary completion
 * @chinese 下发总结完成结果
 * @param completion EN: Completion callback. CN: 完成回调。
 * @param result EN: Final result. CN: 最终结果。
 * @param error EN: Completion error. CN: 完成错误。
 */
- (void)tsai_callSummaryCompletion:(nullable TSAISummaryCompletionBlock)completion
                            result:(nullable TSAISummaryResult *)result
                             error:(nullable NSError *)error;

@end

/** @brief Chat implementation contract @chinese 对话实现契约 */
@interface TSAIBudsAssistantProvider (Chat)

/**
 * @brief Execute chat session start
 * @chinese 执行对话会话启动
 * @param config EN: Chat configuration. CN: 对话配置。
 * @param onContent EN: Content callback. CN: 内容回调。
 * @param onEvent EN: Event callback. CN: 事件回调。
 * @param completion EN: Completion callback. CN: 完成回调。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)tsai_startChatWithConfig:(TSAIChatConfig *)config
                             onContent:(nullable TSAIChatContentBlock)onContent
                               onEvent:(nullable TSAIChatEventBlock)onEvent
                            completion:(nullable TSAIChatCompletionBlock)completion;

/**
 * @brief Stop the active chat session
 * @chinese 停止当前对话会话
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 */
- (void)tsai_stopChatWithTaskId:(NSString *)taskId;

/** @brief Cancel active chat state during shutdown @chinese 在关闭时取消当前对话状态 */
- (void)tsai_cancelActiveChatTask;

/**
 * @brief Handle an AIBuds chat session event
 * @chinese 处理 AIBuds 对话会话事件
 * @param eventNumber EN: Wrapped event value. CN: 包装后的事件值。
 */
- (void)tsai_receiveAIChatSessionEventNumber:(NSNumber *)eventNumber;

/**
 * @brief Append incremental device chat audio
 * @chinese 追加设备侧增量对话音频
 * @param opusData EN: Opus data. CN: Opus 数据。
 * @param pcmData EN: PCM data. CN: PCM 数据。
 */
- (void)tsai_appendDeviceChatOpusData:(nullable NSData *)opusData
                              pcmData:(nullable NSData *)pcmData;

/**
 * @brief Handle successful chat startup
 * @chinese 处理对话启动成功
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param generation EN: Input generation. CN: 输入代际。
 * @param session EN: AIBuds chat session. CN: AIBuds 对话会话。
 */
- (void)tsai_handleChatStartSuccessForTaskId:(NSString *)taskId
                                  generation:(NSUInteger)generation
                                     session:(id<AIBudsAIChatSessionConvertible>)session;

/**
 * @brief Handle failed chat startup
 * @chinese 处理对话启动失败
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param generation EN: Input generation. CN: 输入代际。
 * @param error EN: Startup error. CN: 启动错误。
 */
- (void)tsai_handleChatStartFailureForTaskId:(NSString *)taskId
                                  generation:(NSUInteger)generation
                                       error:(NSError *)error;

/**
 * @brief Handle chat startup timeout
 * @chinese 处理对话启动超时
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param generation EN: Input generation. CN: 输入代际。
 */
- (void)tsai_handleChatStartupTimeoutForTaskId:(NSString *)taskId
                                    generation:(NSUInteger)generation;

/**
 * @brief Fail and reset the active chat immediately
 * @chinese 立即失败并重置当前对话
 * @param error EN: Terminal error. CN: 终止错误。
 * @param endReason EN: Terminal reason. CN: 终止原因。
 */
- (void)tsai_failCurrentChatImmediatelyWithError:(NSError *)error
                                       endReason:(TSAIChatEndReason)endReason;

/**
 * @brief Handle chat text data
 * @chinese 处理对话文本数据
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param data EN: AIBuds chat data. CN: AIBuds 对话数据。
 */
- (void)tsai_handleChatDataForTaskId:(NSString *)taskId
                                data:(AIBudsAIChatDataModel *)data;

/**
 * @brief Handle chat intent data
 * @chinese 处理对话意图数据
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param intent EN: AIBuds intent data. CN: AIBuds 意图数据。
 */
- (void)tsai_handleChatIntentForTaskId:(NSString *)taskId
                                intent:(AIBudsAIChatIntentModel *)intent;

/**
 * @brief Handle chat voice data
 * @chinese 处理对话语音数据
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param voiceData EN: AIBuds voice data. CN: AIBuds 语音数据。
 */
- (void)tsai_handleChatVoiceDataForTaskId:(NSString *)taskId
                                voiceData:(AIBudsAIChatVoiceDataModel *)voiceData;

/**
 * @brief Handle a chat event
 * @chinese 处理对话事件
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param event EN: AIBuds event data. CN: AIBuds 事件数据。
 */
- (void)tsai_handleChatEventForTaskId:(NSString *)taskId
                                event:(AIBudsAIChatEventModel *)event;

/**
 * @brief Cache a chat runtime error
 * @chinese 缓存对话运行错误
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param error EN: Runtime error. CN: 运行错误。
 */
- (void)tsai_handleChatErrorForTaskId:(NSString *)taskId
                                error:(NSError *)error;

/**
 * @brief Handle chat completion
 * @chinese 处理对话结束
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param report EN: AIBuds report. CN: AIBuds 报告。
 */
- (void)tsai_handleChatFinishForTaskId:(NSString *)taskId
                                 report:(AIBudsAIChatSessionReportModel *)report;

/** @brief Clear active chat state @chinese 清理当前对话状态 */
- (void)tsai_resetCurrentChatSession;

/**
 * @brief Deliver chat content
 * @chinese 下发对话内容
 * @param content EN: Chat content. CN: 对话内容。
 */
- (void)tsai_emitChatContent:(TSAIChatContent *)content;

/**
 * @brief Deliver a chat event
 * @chinese 下发对话事件
 * @param eventType EN: Normalized event type. CN: 标准化事件类型。
 */
- (void)tsai_emitChatEvent:(TSAIChatEventType)eventType;

/**
 * @brief Deliver chat completion
 * @chinese 下发对话完成结果
 * @param completion EN: Completion callback. CN: 完成回调。
 * @param report EN: Chat report. CN: 对话报告。
 * @param error EN: Completion error. CN: 完成错误。
 */
- (void)tsai_callChatCompletion:(nullable TSAIChatCompletionBlock)completion
                         report:(nullable TSAIChatReport *)report
                          error:(nullable NSError *)error;

/**
 * @brief Deliver chat state
 * @chinese 下发对话状态
 * @param state EN: Chat state. CN: 对话状态。
 */
- (void)tsai_notifyChatState:(TSAIChatState)state;

@end

/** @brief Mapping implementation contract @chinese 映射实现契约 */
@interface TSAIBudsAssistantProvider (Mapping)

/**
 * @brief Build an AIBuds chat configuration
 * @chinese 构建 AIBuds 对话配置
 * @param config EN: Public chat configuration. CN: 公开对话配置。
 * @return EN: AIBuds chat configuration. CN: AIBuds 对话配置。
 */
- (AIBudsAIChatSessionConfig *)tsai_buildAIBudsConfigFromChatConfig:(TSAIChatConfig *)config;

/**
 * @brief Resolve the active AIBuds audio channel
 * @chinese 解析当前 AIBuds 音频通道
 * @return EN: AIBuds audio channel. CN: AIBuds 音频通道。
 */
- (AIBudsAIChatAudioChannel)tsai_currentAudioChannel;

/**
 * @brief Build a normalized chat report
 * @chinese 构建标准化对话报告
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param aibudsReport EN: AIBuds report. CN: AIBuds 报告。
 * @return EN: Normalized chat report. CN: 标准化对话报告。
 */
- (TSAIChatReport *)tsai_buildChatReportWithTaskId:(NSString *)taskId
                                      aibudsReport:(nullable AIBudsAIChatSessionReportModel *)aibudsReport;

/**
 * @brief Resolve the normalized chat end reason
 * @chinese 解析标准化对话结束原因
 * @return EN: Chat end reason. CN: 对话结束原因。
 */
- (TSAIChatEndReason)tsai_resolveChatEndReason;

/**
 * @brief Resolve the round index for a question
 * @chinese 解析问题对应的轮次序号
 * @param questionId EN: Question identifier. CN: 问题标识。
 * @return EN: Round index. CN: 轮次序号。
 */
- (NSInteger)tsai_roundIndexForQuestionId:(NSString *)questionId;

/**
 * @brief Map an AIBuds event type
 * @chinese 映射 AIBuds 事件类型
 * @param aibudsEvent EN: AIBuds event type. CN: AIBuds 事件类型。
 * @return EN: Normalized event type. CN: 标准化事件类型。
 */
- (TSAIChatEventType)tsai_mapAIBudsEventType:(AIBudsAIChatEventType)aibudsEvent;

/**
 * @brief Map an AIBuds intent type
 * @chinese 映射 AIBuds 意图类型
 * @param aibudsIntent EN: AIBuds intent type. CN: AIBuds 意图类型。
 * @return EN: Normalized intent type. CN: 标准化意图类型。
 */
- (TSAIChatIntentType)tsai_mapAIBudsIntentType:(AIBudsAIIntentType)aibudsIntent;

@end

/** @brief Device input implementation contract @chinese 设备输入实现契约 */
@interface TSAIBudsAssistantProvider (DeviceInput)

/**
 * @brief Map and route a normalized device chat event
 * @chinese 映射并路由标准化设备对话事件
 * @param event EN: Normalized device event. CN: 标准化设备事件。
 * @param audioChannel EN: Device audio channel. CN: 设备音频通道。
 */
- (void)tsai_handleDeviceChatSessionEvent:(TSAIChatDeviceEvent)event
                             audioChannel:(TSAIDeviceBridgeChatAudioChannel)audioChannel;

/**
 * @brief Route incremental device chat audio
 * @chinese 路由设备侧增量对话音频
 * @param opusData EN: Opus data. CN: Opus 数据。
 * @param pcmData EN: PCM data. CN: PCM 数据。
 */
- (void)tsai_handleDeviceChatAudioWithOpusData:(nullable NSData *)opusData
                                       pcmData:(nullable NSData *)pcmData;

@end

NS_ASSUME_NONNULL_END
