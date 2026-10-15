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
/** @brief Current device-reported chat route @chinese 当前设备上报的对话路由 */
@property (nonatomic, assign) TSAIDeviceBridgeChatAudioChannel currentDeviceAudioChannel;
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

// ---- 单轮 / 输入控制状态（均在 chatQueue 上读写） ----
/// 当前厂商会话对象（sendText / 静音注入用）
@property (nonatomic, strong, nullable) id<AIBudsAIChatSessionConvertible> currentChatSession;
/// 本轮输入是否已结束
@property (nonatomic, assign) BOOL currentChatInputFinished;
/// 会话就绪前收到的结束输入请求，SessionStarted 后立即执行
@property (nonatomic, assign) BOOL currentChatInputFinishPending;
/// 是否停止向厂商转发真实音频
@property (nonatomic, assign) BOOL currentChatAudioGated;
/// 厂商 VAD 判定用户正在说话
@property (nonatomic, assign) BOOL currentChatUserSpeaking;
/// 本轮是否已有输入真正到达厂商（VAD 开始说话 / 文本提交）；为 NO 时厂商侧没有任何 dialog，
/// 输入结束后只需短暂等待即可按「没听到声音」收口，且收口时可直接转入保活而非 interrupt
@property (nonatomic, assign) BOOL currentChatVendorInputSubmitted;
/// 当前等待回复计时是否为「未检测到语音」的缩短版；VAD 迟到触发时需恢复为完整时长
@property (nonatomic, assign) BOOL currentChatReplyWaitShortened;
/** @brief Whether the vendor reported the cloud connection ready @chinese 厂商是否已回报云端连接就绪 */
@property (nonatomic, assign) BOOL currentChatServiceConnected;
/** @brief Text queued until the cloud connection is ready @chinese 等待云端连接就绪后补发的文本 */
@property (nonatomic, copy, nullable) NSString *currentChatPendingOutgoingText;
/** @brief PCM buffered until the cloud connection is ready @chinese 等待云端连接就绪前缓冲的出站 PCM */
@property (nonatomic, strong, nullable) NSMutableData *currentChatPendingOutboundPCM;
/** @brief Bytes dropped from the outbound buffer on overflow @chinese 出站缓冲超限丢弃的字节数 */
@property (nonatomic, assign) NSUInteger currentChatOutboundDroppedBytes;
/** @brief Silence injection deferred until connected @chinese 静音注入挂起等待连接就绪 */
@property (nonatomic, assign) BOOL currentChatSilenceInjectionPending;
/** @brief Watchdog for the cloud connection after a local start @chinese 本地启动后的云端连接看门狗 */
@property (nonatomic, strong, nullable) dispatch_source_t currentChatConnectWatchdogTimer;
/// 单轮是否已完成（RoundCompleted 已下发）
@property (nonatomic, assign) BOOL currentChatRoundCompleted;
/// 本轮回答文本是否已定稿
@property (nonatomic, assign) BOOL currentChatRoundAnswerFinal;
/// 本轮是否已收到 TTS 音频分片
@property (nonatomic, assign) BOOL currentChatRoundAudioStarted;
/// 本轮 TTS 音频分片是否已发完
@property (nonatomic, assign) BOOL currentChatRoundAudioFinal;
/// 厂商侧播放是否已开始
@property (nonatomic, assign) BOOL currentChatVendorPlaybackStarted;
/// 厂商侧播放是否已结束（含打断）
@property (nonatomic, assign) BOOL currentChatVendorPlaybackEnded;
/// 厂商是否自行播放回复（SCO / A2DP），否则由 AIKit 或设备播放 AudioChunk
@property (nonatomic, assign) BOOL currentChatVendorPlaysVoice;
/// 静音注入剩余帧数
@property (nonatomic, assign) NSUInteger currentChatSilenceFramesRemaining;
/// 单轮输入上限定时器
@property (nonatomic, strong, nullable) dispatch_source_t currentChatMaxInputTimer;
/// 静音注入定时器
@property (nonatomic, strong, nullable) dispatch_source_t currentChatSilenceTimer;
/// 回答定稿后等待音频终态的兜底定时器
@property (nonatomic, strong, nullable) dispatch_source_t currentChatRoundDrainTimer;
// ---- 会话复用（单轮保活）状态（均在 chatQueue 上读写） ----
/// 绑定到厂商回调的会话标识：新建会话时等于 currentChatTaskId，复用保活会话时沿用其首个 taskId
@property (nonatomic, copy, nullable) NSString *currentChatVendorTaskId;
/// 当前厂商会话实际使用的 AIBuds 配置（复用兼容性比较用）
@property (nonatomic, strong, nullable) AIBudsAIChatSessionConfig *currentChatVendorConfig;
/// 复用模式下由 AIKit 自行计时的「会话内无输入」超时定时器（单轮：轮内；畅聊：整个会话）
@property (nonatomic, strong, nullable) dispatch_source_t currentChatInputIdleTimer;
/// 畅聊无输入计时最近一次（重新）启动的系统时间，用于合并高频重置（音频分片每 20ms 一片）
@property (nonatomic, assign) NSTimeInterval currentChatContinuousIdleArmedUptime;
/// 本轮已安排转入保活（等待已派发的内容送达后再结束任务）
@property (nonatomic, assign) BOOL currentChatParkPending;
/// 单轮复用模式下输入结束 / 文本提交后等待云端首个识别或回答的定时器
@property (nonatomic, strong, nullable) dispatch_source_t currentChatReplyWaitTimer;
// ---- 需客户端补充信息的意图（如 LocationQuery）状态（均在 chatQueue 上读写） ----
/// 云端要求客户端补充信息后才会作答的待处理意图；非空期间停用常规空闲 / 等待回复计时
@property (nonatomic, strong, nullable) TSAIChatIntent *currentChatPendingClientIntent;
/// 待处理意图所属轮次
@property (nonatomic, assign) NSInteger currentChatPendingClientIntentRoundIndex;
/// 等待 App 处理意图（含重发后等待云端回答）的定时器
@property (nonatomic, strong, nullable) dispatch_source_t currentChatIntentActionTimer;
/// 重发后下一个新 questionId 应映射到的轮次；-1 表示没有待映射的重发
@property (nonatomic, assign) NSInteger currentChatReplayTargetRoundIndex;
/// 最近一次重发的文本，用于抑制云端对它的 Question 回显
@property (nonatomic, copy, nullable) NSString *currentChatReplayText;
/// 保活中的厂商会话（上一轮以 RoundCompleted 结束、尚未被下一轮复用或空闲回收）
@property (nonatomic, strong, nullable) id<AIBudsAIChatSessionConvertible> warmChatSession;
/// 保活会话绑定的厂商回调标识
@property (nonatomic, copy, nullable) NSString *warmChatVendorTaskId;
/// 保活会话启动时使用的 AIBuds 配置
@property (nonatomic, strong, nullable) AIBudsAIChatSessionConfig *warmChatVendorConfig;
/// 保活会话是否由厂商自行播放回复
@property (nonatomic, assign) BOOL warmChatVendorPlaysVoice;
/// 保活会话中已出现过的厂商 questionId（复用后用于丢弃旧轮次迟到数据）
@property (nonatomic, strong, nullable) NSMutableSet<NSString *> *warmChatSeenQuestionIds;
/// 保活空闲回收定时器
@property (nonatomic, strong, nullable) dispatch_source_t warmChatIdleTimer;
/// 保活会话进入保活态的时间（日志用）
@property (nonatomic, copy, nullable) NSDate *warmChatParkedTime;
/// 保活会话的云端连接是否已就绪；NO 表示转入保活时 ws 仍在握手（等待厂商 AiServiceConnected）
@property (nonatomic, assign) BOOL warmChatServiceConnected;
/// 保活会话连接就绪后应使用的空闲回收时长（握手期间不计空闲）
@property (nonatomic, assign) NSTimeInterval warmChatIdleTimeout;
/// 当前任务是否复用了保活会话（复用后、新一轮 questionId 出现前的厂商音频属于旧轮次，需丢弃）
@property (nonatomic, assign) BOOL currentChatAdoptedWarmSession;
/// 当前任务按「复用已打开的厂商 socket」启动：StarBurst 在 socket 已打开时 start 不会再回报
/// AiServiceConnected（30001），启动成功后由 AIKit 直接放开出站闸门，不等 30001、不挂连接看门狗
@property (nonatomic, assign) BOOL currentChatAssumesOpenVendorLink;
/// 最近一次在云端链路仍连通时调用 stopAIChat 的时刻（systemUptime，0 表示无记录）。
/// StarBurst 的 stop 不关闭 socket（厂商确认为设计行为），服务端约 60s 无消息才关闭；
/// 窗口内的下一次 start 会复用这条 socket。每次新建厂商会话时读取并清零（只用一次）
@property (nonatomic, assign) NSTimeInterval vendorLinkAliveStopUptime;
// ---- 厂商 stop → start 串行化状态（均在 chatQueue 上读写） ----
/// 已向厂商发出 stopAIChat、尚未收到其 finish 回调的厂商会话标识；非空时新会话的厂商启动必须等待
@property (nonatomic, copy, nullable) NSString *vendorStopAwaitingTaskId;
/// 等待上一厂商会话结束后再执行的厂商启动（绑定 currentChatTaskId）
@property (nonatomic, copy, nullable) dispatch_block_t pendingVendorChatStart;
/// 等待上一厂商会话结束的兜底计时：到点仍未收到 finish 也执行启动
@property (nonatomic, strong, nullable) dispatch_source_t pendingVendorChatStartTimer;
/// 当前任务向厂商发出 stopAIChat 后等待其 finish 的看门狗：到点仍未收到 finish 则本地收口当前任务
@property (nonatomic, strong, nullable) dispatch_source_t vendorStopFinishWatchdogTimer;
/** @brief Serial queue that invokes vendor stopAIChat off the chat queue @chinese 在 chatQueue 之外调用厂商 stopAIChat 的串行队列（厂商阻塞时不拖死 chatQueue 与看门狗） */
@property (nonatomic, strong) dispatch_queue_t vendorControlQueue;
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
/**
 * @brief Stop the vendor chat session and remember that its finish is pending
 * @chinese 停止厂商会话，并记录「等待其 finish 回调」
 * @param vendorTaskId EN: Vendor callback identifier being stopped; nil when unknown. CN: 被停止的厂商回调标识；未知时传 nil。
 * @param linkAlive EN: Whether the cloud link was connected and error-free when stopping; StarBurst keeps the socket open, so the next start reuses it. CN: 停止时云端链路是否连通且无错误；StarBurst 不关 socket，下一次 start 会复用它。
 */
- (void)tsai_stopVendorChatRememberingTaskId:(nullable NSString *)vendorTaskId
                                   linkAlive:(BOOL)linkAlive;
/** @brief Whether the current task's cloud link is connected and error-free @chinese 当前任务的云端链路是否连通且无错误 */
- (BOOL)tsai_currentChatVendorLinkAlive;
/**
 * @brief Read and clear the open-socket record before a new vendor start
 * @chinese 新建厂商会话前读取并清除「stop 后 socket 仍打开」记录
 * @param taskId EN: Public task identifier (log only). CN: 公开任务标识（仅日志）。
 * @return EN: YES when the last stop left a live socket within the reuse window. CN: 上一次停止留下的 socket 仍在复用窗口内返回 YES。
 */
- (BOOL)tsai_consumeOpenVendorLinkForTaskId:(NSString *)taskId;
/**
 * @brief Note that a vendor session has finished; runs a deferred vendor start when it was waiting on it
 * @chinese 记录厂商会话已结束；若有新会话在等待它结束，则执行被推迟的厂商启动
 * @param vendorTaskId EN: Vendor callback identifier that finished. CN: 已结束的厂商回调标识。
 */
- (void)tsai_vendorChatSessionDidFinishForTaskId:(nullable NSString *)vendorTaskId;
/** @brief Cancel a deferred vendor start (task reset / stop before start) @chinese 取消被推迟的厂商启动（任务重置 / 启动前停止） */
- (void)tsai_cancelPendingVendorChatStart;
/** @brief Run the deferred vendor start now @chinese 立即执行被推迟的厂商启动 */
- (void)tsai_runPendingVendorChatStartWithReason:(NSString *)reason;
/**
 * @brief Arm a watchdog for the vendor finish callback after stopping the current task's vendor session
 * @chinese 当前任务停止厂商会话后，为其 finish 回调加看门狗；到点未收到则本地收口当前任务
 * @param generation EN: Generation of the task being stopped. CN: 被停止任务的代际。
 * @param taskIdentifier EN: Public task identifier being stopped. CN: 被停止的公开任务标识。
 * @param vendorTaskId EN: Vendor callback identifier that was stopped. CN: 被停止的厂商回调标识。
 */
- (void)tsai_armVendorStopFinishWatchdogForGeneration:(NSUInteger)generation
                                        taskIdentifier:(NSString *)taskIdentifier
                                          vendorTaskId:(nullable NSString *)vendorTaskId;
/** @brief Cancel the vendor finish watchdog @chinese 取消厂商 finish 看门狗 */
- (void)tsai_cancelVendorStopFinishWatchdog;

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

/** @brief Finish current input and wait for reply @chinese 结束当前输入并等待回复 */
- (void)tsai_finishChatInputWithTaskId:(NSString *)taskId;

/** @brief Submit a text question @chinese 提交文本提问 */
- (BOOL)tsai_sendChatText:(NSString *)text taskId:(NSString *)taskId;

/** @brief Interrupt AI reply playback @chinese 中断 AI 回复播放 */
- (void)tsai_interruptChatPlaybackWithTaskId:(NSString *)taskId;

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
 * @brief Finish the current chat task locally when the vendor never reports finish
 * @chinese 厂商迟迟不回 finish 时，在本地收口当前对话任务（构建报告、重置并回调 completion）
 * @param reason EN: Log reason. CN: 日志原因。
 */
- (void)tsai_finishCurrentChatSessionLocallyWithReason:(NSString *)reason;

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
 * @brief Deliver a chat event carrying a round index and the related intent
 * @chinese 派发携带轮次序号与相关意图的对话事件
 * @param eventType EN: Event type. CN: 事件类型。
 * @param roundIndex EN: Round index, -1 for session-level. CN: 轮次序号，会话级为 -1。
 * @param intent EN: Related intent or nil. CN: 相关意图，可为 nil。
 */
- (void)tsai_emitChatEvent:(TSAIChatEventType)eventType
                roundIndex:(NSInteger)roundIndex
                    intent:(nullable TSAIChatIntent *)intent;

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
@interface TSAIBudsAssistantProvider (SingleRound)
/** @brief Whether the current chat runs in SingleRound mode @chinese 当前会话是否为单轮模式 */
- (BOOL)tsai_isSingleRoundChat;
/** @brief Whether AIKit feeds external PCM to the vendor @chinese 当前路由是否由 AIKit 推送外部 PCM */
- (BOOL)tsai_chatUsesExternalPCM;
/** @brief Session started hook @chinese 会话启动成功钩子 */
- (void)tsai_singleRoundDidStartSession:(id<AIBudsAIChatSessionConvertible>)session;
/** @brief Session reset hook @chinese 会话重置钩子 */
- (void)tsai_singleRoundResetState;
/** @brief Vendor event hook; NO means swallow @chinese 厂商事件钩子，返回 NO 表示吞掉 */
- (BOOL)tsai_singleRoundShouldForwardVendorEvent:(AIBudsAIChatEventType)eventType;
/** @brief Vendor text data hook; NO means drop @chinese 厂商文本数据钩子，返回 NO 表示丢弃 */
- (BOOL)tsai_singleRoundShouldForwardChatData:(AIBudsAIChatDataModel *)data
                                    roundIndex:(NSInteger)roundIndex;
/** @brief Vendor voice data hook @chinese 厂商音频数据钩子 */
- (void)tsai_singleRoundDidReceiveVoiceDataFinal:(BOOL)isFinal;
/** @brief Vendor error hook: aborts an unfinished single round at once @chinese 厂商报错钩子：单轮未完成时立即收口 */
- (void)tsai_singleRoundDidReceiveError:(NSError *)error;
/** @brief Forward outbound PCM, buffering while the cloud link is not ready @chinese 转发出站 PCM；云端未就绪时缓冲 */
- (void)tsai_forwardOutboundPCM:(NSData *)pcmData
                      toSession:(id<AIBudsAIChatSessionConvertible>)session;
/**
 * @brief Open the outbound gate: cancel the connect watchdog, flush buffered PCM / text, emit ServiceReady
 * @chinese 放开出站闸门：取消连接看门狗，冲刷缓冲的音频 / 文本并下发 ServiceReady
 * @param reason EN: Log reason. CN: 日志原因。
 */
- (void)tsai_openChatOutboundGateWithReason:(NSString *)reason;
/** @brief Vendor session finish hook @chinese 厂商会话结束钩子 */
- (void)tsai_singleRoundWillFinishSession;
@end

/** @brief Session reuse (warm single-round session) contract @chinese 会话复用（单轮保活）契约 */
@interface TSAIBudsAssistantProvider (SessionReuse)
/** @brief Whether this config may reuse / keep a warm vendor session @chinese 该配置是否允许复用 / 保活厂商会话 */
- (BOOL)tsai_chatSessionReuseEnabledForConfig:(nullable TSAIChatConfig *)config;
/** @brief Effective idle timeout after clamping @chinese 钳位后的保活空闲时长 */
- (NSTimeInterval)tsai_effectiveRoundIdleTimeoutForConfig:(nullable TSAIChatConfig *)config;
/** @brief Vendor no-input timeout to request for this config @chinese 本配置应下发给厂商的无输入超时 */
- (NSTimeInterval)tsai_vendorAutoEndDurationForConfig:(TSAIChatConfig *)config;
/**
 * @brief Adopt the warm vendor session for a new task when compatible
 * @chinese 配置兼容时让新任务复用保活中的厂商会话
 * @return EN: YES when adopted (start success is dispatched internally). CN: 已复用返回 YES（内部派发启动成功）。
 */
- (BOOL)tsai_adoptWarmChatSessionIfPossibleForTaskId:(NSString *)taskId
                                           generation:(NSUInteger)generation
                                         vendorConfig:(AIBudsAIChatSessionConfig *)vendorConfig;
/**
 * @brief Drop the warm vendor session
 * @chinese 丢弃保活中的厂商会话
 * @param reason EN: Log reason. CN: 日志原因。
 * @param stopVendor EN: Whether to stop the vendor session. CN: 是否停止厂商会话。
 */
- (void)tsai_discardWarmChatSessionWithReason:(NSString *)reason stopVendor:(BOOL)stopVendor;
/**
 * @brief Park the live vendor session and complete the public task
 * @chinese 将当前厂商会话转入保活并结束公开任务
 * @return EN: YES when parked. CN: 已转入保活返回 YES。
 */
- (BOOL)tsai_parkVendorChatSessionAfterRound;
/**
 * @brief Park a vendor session whose websocket is still connecting instead of stopping it
 * @chinese 把云端尚未连通（ws 仍在握手）的厂商会话转入保活并结束公开任务，而不是 stopAIChat
 * @discussion EN: Stopping a CONNECTING StarBurst socket leaves an orphan socket that silently
 *   opens later and blocks every subsequent start (no 30001 → 2003 after 8s). Keeping the
 *   session warm lets the next start adopt it once it connects.
 *   CN: 对握手中的 StarBurst socket 调用 stop 只发 interrupt、不取消连接，之后它自行连上成为
 *   僵尸 ws，后续每次 start 都不再建连（无 30001 → 8s 后 2003）。转入保活后下一次 start
 *   在其连通后直接复用。
 * @return EN: YES when parked. CN: 已转入保活返回 YES。
 */
- (BOOL)tsai_parkConnectingVendorChatSessionForTaskId:(NSString *)taskId
                                           generation:(NSUInteger)generation;
/** @brief Whether a vendor callback belongs to the warm session @chinese 厂商回调是否属于保活会话 */
- (BOOL)tsai_isWarmChatVendorTaskId:(nullable NSString *)vendorTaskId;
/** @brief Vendor finish while warm @chinese 保活期间厂商会话结束 */
- (void)tsai_handleWarmChatFinishWithReport:(nullable AIBudsAIChatSessionReportModel *)report;
/** @brief Vendor error while warm @chinese 保活期间厂商报错 */
- (void)tsai_handleWarmChatError:(NSError *)error;
/** @brief Vendor event while warm @chinese 保活期间厂商事件 */
- (void)tsai_handleWarmChatEvent:(AIBudsAIChatEventModel *)event;
/** @brief Arm the in-round no-input timer (reuse mode only) @chinese 启动轮内无输入计时（仅复用模式） */
- (void)tsai_armInputIdleTimerIfNeeded;
/** @brief Cancel the in-round no-input timer @chinese 取消轮内无输入计时 */
- (void)tsai_cancelInputIdleTimer;
/**
 * @brief (Re)arm the continuous-mode no-input timer (reuse mode only)
 * @chinese （重新）启动畅聊无输入计时（仅复用模式）
 * @discussion EN: Replaces the vendor autoEnd that reuse mode relaxes to >= 600s. Called on session start,
 *             VAD end, every chat/voice payload and text submission; VAD start cancels it.
 *             CN: 替代复用模式下被放宽到 ≥600s 的厂商 autoEnd。会话启动、VAD 结束、每片文本 / 音频、
 *             文本提交时重置；VAD 开始说话时取消。
 */
- (void)tsai_armContinuousIdleTimerIfNeeded;
/** @brief Arm the wait-for-reply timer after input ends (reuse mode only) @chinese 输入结束后启动等待回复计时（仅复用模式） */
- (void)tsai_armReplyWaitTimerIfNeeded;
/**
 * @brief Arm the wait-for-reply timer with an explicit timeout
 * @chinese 以指定时长启动等待回复计时
 * @param timeout EN: Seconds to wait. CN: 等待秒数。
 * @param shortened EN: YES when this is the short "no speech detected" wait. CN: 是否为「未检测到语音」的缩短等待。
 */
- (void)tsai_armReplyWaitTimerWithTimeout:(NSTimeInterval)timeout shortened:(BOOL)shortened;
/** @brief Cancel the wait-for-reply timer @chinese 取消等待回复计时 */
- (void)tsai_cancelReplyWaitTimer;
@end

/** @brief Client-action intent (e.g. LocationQuery) contract @chinese 需客户端补充信息的意图（如 LocationQuery）契约 */
@interface TSAIBudsAssistantProvider (Intent)
/**
 * @brief Start waiting for the App to act on a client-action intent
 * @chinese 开始等待 App 处理需客户端补充信息的意图
 * @param intent EN: The intent with requiresClientAction = YES. CN: requiresClientAction 为 YES 的意图。
 * @param roundIndex EN: Round the intent belongs to. CN: 意图所属轮次。
 */
- (void)tsai_beginPendingClientIntent:(TSAIChatIntent *)intent roundIndex:(NSInteger)roundIndex;
/**
 * @brief Clear the pending client-action intent and resume regular idle timers
 * @chinese 清除待处理意图并恢复常规空闲计时
 * @param reason EN: Log reason. CN: 日志原因。
 */
- (void)tsai_clearPendingClientIntentWithReason:(NSString *)reason;
/** @brief Whether a client-action intent is pending @chinese 是否有待处理的客户端动作意图 */
- (BOOL)tsai_hasPendingClientIntent;
/**
 * @brief Inspect incoming chat data for the pending round: clears the pending state on answer,
 *        tells the caller whether the Question echo of a replay should be suppressed
 * @chinese 用到达的对话数据更新待处理状态：收到回答即清除；返回是否应抑制重发文本的 Question 回显
 * @param data EN: Vendor chat data. CN: 厂商对话数据。
 * @param roundIndex EN: Resolved round index. CN: 解析后的轮次序号。
 * @return EN: YES when the Question part must not be forwarded. CN: Question 部分不应下发时返回 YES。
 */
- (BOOL)tsai_pendingIntentShouldSuppressQuestionForData:(AIBudsAIChatDataModel *)data
                                              roundIndex:(NSInteger)roundIndex;
/**
 * @brief Replay the pending round with supplementary text (public entry, any queue)
 * @chinese 用补充文本重发待处理的轮次（公开入口，任意队列）
 * @param text EN: Replay text. CN: 重发文本。
 * @param taskId EN: Public task identifier. CN: 公开任务标识。
 * @return EN: YES if accepted. CN: 接受返回 YES。
 */
- (BOOL)tsai_replayPendingIntentRoundWithText:(NSString *)text taskId:(NSString *)taskId;
/** @brief Reset intent state on session reset @chinese 会话重置时清理意图状态 */
- (void)tsai_intentResetState;
@end

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
