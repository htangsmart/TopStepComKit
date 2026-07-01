//
//  TSAIAssistantInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSKitBaseInterface.h"
#import "TSAISummaryPartialResult.h"
#import "TSAISummaryResult.h"
#import "TSAIChatConfig.h"
#import "TSAIChatContent.h"
#import "TSAIChatEvent.h"
#import "TSAIChatReport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming summary partial-result block
 * @chinese 流式总结中间结果回调
 *
 * @param partial
 * EN: Cumulative partial result emitted during summarization
 * CN: 总结过程中下发的累积中间结果
 *
 * @discussion
 * [EN]: Invoked zero or more times before completion. `partial.text` is the
 *       full cumulative summary so far. Streaming LLM output is append-only —
 *       previously emitted text will not be revised — so callers can render
 *       this directly to UI (e.g. `label.text = partial.text`).
 * [CN]: 在 completion 回调之前可能被调用零次或多次。
 *       `partial.text` 为截至当前时刻的累积总结文本。
 *       LLM 流式输出为追加式，已下发的文本不会被修订，
 *       调用方可直接赋值给 UI（如 `label.text = partial.text`）。
 */
typedef void(^TSAISummaryPartialBlock)(TSAISummaryPartialResult *partial);

/**
 * @brief Streaming summary completion block
 * @chinese 流式总结完成回调
 *
 * @param result
 * EN: Final summary result; nil on failure or cancellation
 * CN: 最终总结结果，失败或取消时为 nil
 *
 * @param error
 * EN: Error info; nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAISummaryCompletionBlock)(TSAISummaryResult * _Nullable result,
                                          NSError * _Nullable error);

/**
 * @brief AI chat streaming-content block
 * @chinese AI 对话流式内容回调
 *
 * @param content
 * EN: Polymorphic content payload — dispatch on `content.contentType`
 * CN: 多态内容载荷，按 `content.contentType` 分发
 *
 * @discussion
 * [EN]: High-frequency callback covering question / answer text, TTS audio
 *       chunks and command-style intents. See `TSAIChatContent` for the
 *       per-type field activation table.
 * [CN]: 高频回调，覆盖问题 / 回答文本、TTS 音频片段、指令型意图。
 *       各类型激活的字段见 `TSAIChatContent` 字段表。
 */
typedef void(^TSAIChatContentBlock)(TSAIChatContent *content);

/**
 * @brief AI chat session-level event block
 * @chinese AI 对话会话级事件回调
 *
 * @param event
 * EN: Session-level state-transition event
 * CN: 会话级状态变更事件
 *
 * @discussion
 * [EN]: Low-frequency callback for UX state (mic animation, AI playback
 *       indicator, ...). See `TSAIChatEventType` for the event vocabulary.
 * [CN]: 低频回调，用于 UI 状态（话筒动画、AI 播放指示等）。
 *       事件枚举见 `TSAIChatEventType`。
 */
typedef void(^TSAIChatEventBlock)(TSAIChatEvent *event);

/**
 * @brief AI chat session completion block
 * @chinese AI 对话会话完成回调
 *
 * @param report
 * EN: Final session report; nil only when `error` indicates session failed
 *     to start
 * CN: 会话最终报告；仅当 `error` 表示会话未能启动时为 nil
 *
 * @param error
 * EN: Error info; nil on normal end (stop / timeout)
 * CN: 错误信息；正常结束（stop / 超时）时为 nil
 */
typedef void(^TSAIChatCompletionBlock)(TSAIChatReport * _Nullable report,
                                       NSError * _Nullable error);

/**
 * @brief Device-side AI chat event
 * @chinese 设备端 AI 对话事件
 *
 * @discussion
 * [EN]: Events emitted by the connected device regarding the AI chat
 *       session lifecycle. Delivered via `registerOnAIChatDeviceEvent:`.
 *       The protocol layer abstracts away transport-level distinctions
 *       (e.g. SCO vs Opus on the underlying SDK) — start requests over
 *       different audio channels collapse into a single `RequestStart`.
 * [CN]: 已连接设备就 AI 对话会话生命周期发出的事件，
 *       通过 `registerOnAIChatDeviceEvent:` 下发。
 *       协议层屏蔽底层传输差异（如底层 SDK 的 SCO / Opus 通道），
 *       不同音频通道的启动请求统一归并为 `RequestStart`。
 */
typedef NS_ENUM(NSInteger, TSAIChatDeviceEvent) {
    /**
     * @brief Device requests the app to start an AI chat session
     * @chinese 设备请求 App 启动 AI 对话
     */
    TSAIChatDeviceEventRequestStart   = 0,
    /**
     * @brief Device requests the app to end the current AI chat session
     * @chinese 设备请求 App 结束当前 AI 对话
     */
    TSAIChatDeviceEventRequestEnd     = 1,
    /**
     * @brief Current AI chat session was interrupted by the device (e.g. state conflict)
     * @chinese 当前 AI 对话被设备中断（如状态冲突）
     */
    TSAIChatDeviceEventInterrupted    = 2,
};

/**
 * @brief AI Assistant interface protocol
 * @chinese AI 助手接口协议
 *
 * @discussion
 * [EN]: Defines AI assistant capabilities. Two distinct shapes coexist:
 *
 *       1. Text-in / text-out LLM tasks — single-shot streaming returning
 *          a final result. Example: text summarization, cancellable via
 *          `cancelSummarizeWithTaskId:`.
 *       2. Voice chat session — long-running end-to-end voice conversation
 *          driven by device-microphone audio, with multiple Q&A rounds
 *          segmented by VAD. Example: AI chat. The session ends through
 *          `stopChatWithTaskId:` (graceful flush) or auto-timeout — there is
 *          no separate forced-cancel entry.
 *
 * [CN]: 定义 AI 助手能力，包含两种形态：
 *
 *       1. 文本进 / 文本出的 LLM 任务 —— 单次流式返回最终结果。
 *          例：文本总结，通过 `cancelSummarizeWithTaskId:` 取消。
 *       2. 语音对话会话 —— 由设备麦克风音频驱动的端到端长会话，
 *          会话内由 VAD 自动断句产生多轮问答。例：AI 对话。
 *          会话结束方式为 `stopChatWithTaskId:`（优雅冲刷）或自动超时，
 *          不提供单独的强制取消入口。
 */
@protocol TSAIAssistantInterface <TSKitBaseInterface>

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
 *         - `RequestStart`: navigate to the chat UI and call
 *           `startChatWithConfig:onContent:onEvent:completion:`.
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
 *         - `RequestStart`：跳转到对话页面并调用
 *           `startChatWithConfig:onContent:onEvent:completion:` 启动会话；
 *         - `RequestEnd`：调用 `stopChatWithTaskId:` 并关闭对话页面；
 *         - `Interrupted`：向用户提示错误并关闭对话页面。
 *
 *       此回调下发的是来自设备的请求 / 事件信号；
 *       会话本身仍仅通过 `startChat` / `stopChat` 入口启动与结束，
 *       收到事件并不代表 SDK 侧的会话状态已发生切换。
 */
- (void)registerOnAIChatDeviceEvent:(void(^_Nullable)(TSAIChatDeviceEvent event))deviceEventBlock;


@end

NS_ASSUME_NONNULL_END
