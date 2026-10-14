//
//  TSAIAssistantInterface.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSAIContractDefines.h"
#import "TSAIAssistantDefines.h"
#import "TSAISummaryPartialResult.h"
#import "TSAISummaryResult.h"
#import "TSAIChatConfig.h"
#import "TSAIChatContent.h"
#import "TSAIChatEvent.h"
#import "TSAIChatReport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI Assistant interface protocol
 * @chinese AI 助手接口协议
 *
 * @discussion
 * [EN]: Defines AI assistant capabilities. Two shapes coexist:
 *
 *       1. Text summarization — a single-shot streaming task returning a
 *          final result and cancellable through its task identifier.
 *       2. Voice chat session — long-running end-to-end voice conversation
 *          driven by device-microphone audio, with multiple Q&A rounds
 *          segmented by VAD. Example: AI chat. The session ends through
 *          `stopChatWithTaskId:` (graceful flush) or auto-timeout — there is
 *          no separate forced-cancel entry.
 *
 * [CN]: 定义 AI 助手能力，包含两种形态：
 *
 *       1. 文本总结 —— 单次流式返回最终结果，可通过任务标识取消。
 *       2. 语音对话会话 —— 由设备麦克风音频驱动的端到端长会话，
 *          会话内由 VAD 自动断句产生多轮问答。例：AI 对话。
 *          会话结束方式为 `stopChatWithTaskId:`（优雅冲刷）或自动超时，
 *          不提供单独的强制取消入口。
 */
@protocol TSAIAssistantInterface <NSObject>

#pragma mark - AI Summary

/**
 * @brief Summarize the given text in a streaming manner
 * @chinese 以流式方式对给定文本进行总结
 *
 * @param text
 * EN: Source text to summarize; must not be empty. Exceeding the underlying
 *     model's context window results in an invalid-param error rather than
 *     implicit truncation.
 * CN: 待总结的文本，不可为空。超过底层模型上下文长度时会返回参数错误，
 *     不会做隐式截断。
 *
 * @param onPartialResult
 * EN: Partial-result callback, invoked zero or more times with cumulative
 *     summary text during generation. May be nil if the caller only cares
 *     about the final result.
 * CN: 中间结果回调，生成过程中可能被多次调用，返回累积总结文本。
 *     若调用方只关心最终结果可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when summarization finishes,
 *     fails or is cancelled.
 * CN: 完成回调，总结完成、失败或取消时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and cancellation
 *     via `cancelSummarizeWithTaskId:`. The same taskId is echoed in
 *     every partial and the final result for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及通过
 *     `cancelSummarizeWithTaskId:` 取消任务。
 *     同一 taskId 会回填在每次 partial 与最终 result 中，便于关联。
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
- (NSString *)summarizeText:(NSString *)text
            onPartialResult:(TSAISummaryPartialBlock _Nullable)onPartialResult
                 completion:(TSAISummaryCompletionBlock _Nullable)completion;

#pragma mark - Cancel Summary

/**
 * @brief Cancel a running text-summarization task
 * @chinese 取消一个进行中的文本总结任务
 *
 * @param taskId
 * EN: TaskId returned by `summarizeText:onPartialResult:completion:`
 * CN: `summarizeText:onPartialResult:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: If the task has already completed or the taskId does not match the
 *       currently running summary, the call is a no-op. The completion
 *       handler of a cancelled task is invoked with a non-nil error
 *       indicating cancellation.
 * [CN]: 若任务已完成或 taskId 与当前进行中的总结任务不匹配，调用无副作用。
 *       被取消任务的 completion 回调会以非 nil 的取消错误调用。
 */
- (void)cancelSummarizeWithTaskId:(NSString *)taskId;

#pragma mark - AI Chat (Voice Conversation Session)

/**
 * @brief Start an AI voice chat session
 * @chinese 启动一次 AI 语音对话会话
 *
 * @param config
 * EN: Session configuration (language, agent, speaker, VAD thresholds, ...)
 * CN: 会话配置（语言、角色、发音人、VAD 阈值等）
 *
 * @param onContent
 * EN: High-frequency content callback — question / answer text, TTS audio
 *     chunks, recognized intents. May be nil if the caller relies solely on
 *     events and the final report.
 * CN: 高频内容回调 —— 问题 / 回答文本、TTS 音频片段、识别到的意图。
 *     若调用方仅依赖事件与最终报告，可传 nil。
 *
 * @param onEvent
 * EN: Low-frequency session-level event callback (VAD start / end, AI
 *     playback start / end, network error, ...). May be nil.
 * CN: 低频会话级事件回调（VAD 开始 / 结束、AI 播放开始 / 结束、网络异常等）。
 *     可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when the session ends
 *     (user stop, auto-timeout, cancel or error).
 * CN: 完成回调，会话结束（用户 stop、自动超时、cancel 或出错）时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and routing
 *     `stopChatWithTaskId:`. The same taskId is echoed in every content /
 *     event payload and the final report for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及路由 `stopChatWithTaskId:`。
 *     同一 taskId 会回填在每个 content / event 载荷与最终报告中，便于关联。
 *
 * @discussion
 * [EN]: A chat session is an end-to-end voice conversation that the SDK runs
 *       internally:
 *         1) Activate AI capability on the connected device.
 *         2) Open the device microphone audio stream.
 *         3) Pipe audio into ASR -> LLM -> (optionally) TTS, segmented by
 *            VAD into multiple Q&A rounds within a single session.
 *         4) Stream question / answer / audio / intent through `onContent`,
 *            and session-level state through `onEvent`.
 *
 *       Unlike single-shot text APIs, the session has no natural endpoint;
 *       it ends when the caller invokes `stopChatWithTaskId:` (graceful
 *       flush) or when the auto-timeout in `config.autoEndSessionTimeout`
 *       elapses with no input.
 *
 *       The synchronously returned taskId is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server
 *       task ID, so the caller obtains a stable identifier the moment the
 *       request is issued.
 *
 * [CN]: 一次会话即一次端到端语音对话，由 SDK 内部完成调用方无需感知的几步：
 *         1) 激活已连接设备的 AI 能力；
 *         2) 打开设备麦克风音频流；
 *         3) 将音频送入 ASR -> LLM ->（可选）TTS，
 *            由 VAD 在单次会话内自动断句产生多轮问答；
 *         4) 通过 `onContent` 流式下发问题 / 回答 / 音频 / 意图，
 *            通过 `onEvent` 下发会话级状态。
 *
 *       与单次文本接口不同，会话没有自然结束点；
 *       结束触发为：调用方调用 `stopChatWithTaskId:`（优雅冲刷），
 *       或 `config.autoEndSessionTimeout` 时长内无输入触发自动结束。
 *
 *       同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关，
 *       调用方在发起请求的瞬间即可拿到稳定标识。
 */
- (NSString *)startChatWithConfig:(TSAIChatConfig *)config
                        onContent:(TSAIChatContentBlock _Nullable)onContent
                          onEvent:(TSAIChatEventBlock _Nullable)onEvent
                       completion:(TSAIChatCompletionBlock _Nullable)completion;

/**
 * @brief Stop a running chat session gracefully and deliver the final report
 * @chinese 优雅结束进行中的对话会话并下发最终报告
 *
 * @param taskId
 * EN: TaskId returned by
 *     `startChatWithConfig:onContent:onEvent:completion:`
 * CN: `startChatWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: Closes the device microphone audio stream, flushes any buffered
 *       audio through the recognition / generation pipeline, and invokes the
 *       original `completion` block with `endReason = UserStop`.
 *
 *       If the session has already ended or the taskId is unknown, the call
 *       is a no-op.
 *
 * [CN]: 关闭设备麦克风音频流，将已缓冲音频送入识别 / 生成管道完成最后处理，
 *       并通过原 `completion` 回调下发 `endReason = UserStop` 的报告。
 *
 *       若会话已结束或 taskId 未知，调用无副作用。
 */
- (void)stopChatWithTaskId:(NSString *)taskId;

#pragma mark - AI Chat (Input / Playback Control)

/**
 * @brief Finish the current user input and wait for the reply
 * @chinese 结束当前用户输入，等待回复
 *
 * @param taskId
 * EN: TaskId returned by `startChatWithConfig:onContent:onEvent:completion:`
 * CN: `startChatWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: Unlike `stopChatWithTaskId:` this does NOT end the session. The SDK
 *       stops forwarding audio, emits `TSAIChatEventTypeInputFinished`, then
 *       delivers Question (final) → Answer → AudioChunk → `RoundCompleted`.
 *       SingleRound: the session then ends with endReason = RoundCompleted.
 *       Continuous: forces end-of-turn for the current utterance, then returns
 *       to listening; no-op when the user is not speaking.
 *       No-op if the input has already been finished or the taskId is unknown.
 * [CN]: 与 `stopChatWithTaskId:` 不同，本方法不结束会话。SDK 停止转发音频，
 *       下发 `TSAIChatEventTypeInputFinished`，随后依次下发 Question（定稿）→
 *       Answer → AudioChunk → `RoundCompleted`。
 *       单轮：之后以 endReason = RoundCompleted 结束会话。
 *       多轮：强制结束当前这句，回到监听；用户未在说话时无副作用。
 *       输入已结束或 taskId 未知时无副作用。
 */
- (void)finishChatInputWithTaskId:(NSString *)taskId;

/**
 * @brief Submit a text question into the chat session
 * @chinese 向会话提交文本提问
 *
 * @param text
 * EN: Question text, must not be empty
 * CN: 提问文本，不可为空
 *
 * @param taskId
 * EN: TaskId returned by `startChatWithConfig:onContent:onEvent:completion:`
 * CN: `startChatWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @return
 * EN: YES if accepted. NO when text is empty, the taskId is unknown, the
 *     session has not started, or the input of a SingleRound session is
 *     already finished.
 * CN: 接受返回 YES；文本为空、taskId 未知、会话未启动或单轮输入已结束时返回 NO。
 *
 * @discussion
 * [EN]: The text is echoed back once through `onContent` as a Question with
 *       isTextFinal = YES, then Answer / AudioChunk follow as usual.
 *       SingleRound: submitting text implies `finishChatInputWithTaskId:`.
 *       Works with any input channel, including `TSAIAudioInputChannelNone`.
 * [CN]: 文本会以 Question（isTextFinal = YES）通过 `onContent` 回显一次，
 *       随后照常下发 Answer / AudioChunk。
 *       单轮：提交文本即视为 `finishChatInputWithTaskId:`。
 *       任意输入通道均可用，包括 `TSAIAudioInputChannelNone`。
 */
- (BOOL)sendChatText:(NSString *)text taskId:(NSString *)taskId;

/**
 * @brief Replay the round that is waiting for client-supplied context with supplementary text
 * @chinese 用补充后的文本重发"等待客户端补充信息"的那一轮
 *
 * @param text
 * EN: Replay text, e.g. "我现在的位置在深圳市南山区，今天天气怎么样？"
 * CN: 重发文本，例如"我现在的位置在深圳市南山区，今天天气怎么样？"
 *
 * @param taskId
 * EN: TaskId returned by `startChatWithConfig:onContent:onEvent:completion:`
 * CN: `startChatWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @return
 * EN: YES if accepted. NO when text is empty, the taskId is unknown, no
 *     intent with `requiresClientAction` is pending, or the vendor session
 *     cannot accept text.
 * CN: 接受返回 YES；文本为空、taskId 未知、当前没有 `requiresClientAction` 的待处理意图
 *     或厂商会话不支持文本时返回 NO。
 *
 * @discussion
 * [EN]: Use after receiving an intent with `requiresClientAction = YES`
 *       (e.g. `TSAIChatIntentTypeLocationQuery`) and obtaining the missing
 *       context. Unlike `sendChatText:taskId:` the text is NOT echoed as a
 *       Question, the cloud's Answer / AudioChunk for the replay are delivered
 *       under the original `roundIndex`, and it is accepted in SingleRound
 *       sessions even though the input is already finished. The
 *       `intentActionTimeout` restarts after a replay. Typically paired with
 *       `-[TSAIContext updateCurrentLocation:]`.
 * [CN]: 收到 `requiresClientAction = YES` 的意图（如 `TSAIChatIntentTypeLocationQuery`）
 *       并取得缺失信息后调用。与 `sendChatText:taskId:` 不同：文本不会作为 Question 回显，
 *       云端对重发的 Answer / AudioChunk 以原 `roundIndex` 下发，单轮会话在输入已结束后
 *       仍接受。重发后 `intentActionTimeout` 重新计时。通常与
 *       `-[TSAIContext updateCurrentLocation:]` 配合使用。
 */
- (BOOL)replayPendingIntentRoundWithText:(NSString *)text taskId:(NSString *)taskId;

/**
 * @brief Interrupt the AI reply playback
 * @chinese 中断 AI 回复播放
 *
 * @param taskId
 * EN: TaskId returned by `startChatWithConfig:onContent:onEvent:completion:`
 * CN: `startChatWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: Only effective while AI playback is in progress; emits
 *       `TSAIChatEventTypeAIPlaybackInterrupted`.
 *       Continuous: returns to listening (same as a speech interrupt).
 *       SingleRound: the round is treated as completed → `RoundCompleted`
 *       → session ends with endReason = RoundCompleted.
 *       No-op otherwise.
 * [CN]: 仅在 AI 播放中生效，下发 `TSAIChatEventTypeAIPlaybackInterrupted`。
 *       多轮：回到监听（与说话打断一致）。
 *       单轮：视为本轮完成 → `RoundCompleted` → 以 endReason = RoundCompleted 结束会话。
 *       其它情况无副作用。
 */
- (void)interruptChatPlaybackWithTaskId:(NSString *)taskId;

/**
 * @brief Register listener for device-side AI chat events
 * @chinese 注册设备端 AI 对话事件的监听
 *
 * @param deviceEventBlock
 * EN: Callback invoked when the connected device emits a chat lifecycle
 *     event — request to start, request to end, or session interruption.
 *     Pass nil to remove a previously registered listener.
 * CN: 当已连接设备发出 AI 对话生命周期事件（请求启动、请求结束、会话中断）时
 *     触发的回调。传 nil 可移除已注册的监听。
 *
 * @discussion
 * [EN]: Typical caller responses by event:
 *         - `RequestStart`: call
 *           `startChatWithConfig:onContent:onEvent:completion:` to prepare the
 *           local session, but do not navigate yet. Open the chat UI only when
 *           `onEvent` receives `TSAIChatEventTypeSessionStarted`, after device
 *           synchronization has succeeded.
 *         - `RequestEnd`: call `stopChatWithTaskId:` and dismiss the chat
 *           UI.
 *         - `Interrupted`: surface an error to the user and dismiss the
 *           chat UI.
 *
 *       This callback delivers request / event signals from the device.
 *       The session itself is started and ended exclusively through the
 *       `startChat` / `stopChat` entries — receiving an event does NOT
 *       imply a session-state change has already taken effect on the SDK
 *       side.
 *
 * [CN]: 调用方对各事件的典型响应：
 *         - `RequestStart`：调用
 *           `startChatWithConfig:onContent:onEvent:completion:` 准备本地会话，
 *           此时不要打开页面；仅当 `onEvent` 收到
 *           `TSAIChatEventTypeSessionStarted`（设备同步已成功）后再打开对话页面；
 *         - `RequestEnd`：调用 `stopChatWithTaskId:` 并关闭对话页面；
 *         - `Interrupted`：向用户提示错误并关闭对话页面。
 *
 *       此回调下发的是来自设备的请求 / 事件信号；
 *       会话本身仍仅通过 `startChat` / `stopChat` 入口启动与结束，
 *       收到事件并不代表 SDK 侧的会话状态已发生切换。
 */
- (void)registerOnAIChatDeviceEvent:(void(^_Nullable)(TSAIChatDeviceEvent event))deviceEventBlock;

/**
 * @brief Register listener for AI chat session state changes
 * @chinese 注册 AI 对话会话状态变化监听
 *
 * @param stateBlock
 * EN: Callback invoked when chat session state changes; pass nil to unregister
 * CN: 对话会话状态变化时触发的回调；传 nil 可取消监听
 *
 * @discussion
 * [EN]: This is an app-facing state stream compatible with Flutter's historical
 *       0 / 1 / 2 / 3 / 255 state vocabulary. Device request events remain
 *       available through `registerOnAIChatDeviceEvent:`.
 * [CN]: 这是面向 App 的状态流，兼容 Flutter 历史使用的
 *       0 / 1 / 2 / 3 / 255 状态语义。设备请求事件仍通过
 *       `registerOnAIChatDeviceEvent:` 下发。
 */
- (void)registerAIChatStateDidChanged:(TSAIChatStateBlock _Nullable)stateBlock;


@end

NS_ASSUME_NONNULL_END
