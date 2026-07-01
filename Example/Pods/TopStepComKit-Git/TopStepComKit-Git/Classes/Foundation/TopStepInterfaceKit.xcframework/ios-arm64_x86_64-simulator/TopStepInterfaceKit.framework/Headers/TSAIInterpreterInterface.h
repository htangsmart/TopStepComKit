//
//  TSAIInterpreterInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import "TSKitBaseInterface.h"
#import "TSAIInterpreterConfig.h"
#import "TSAIInterpreterContent.h"
#import "TSAIInterpreterEvent.h"
#import "TSAIInterpreterReport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Interpretation streaming-content block
 * @chinese 同声传译流式内容回调
 *
 * @param content
 * EN: Polymorphic content payload — dispatch on `content.contentType`
 * CN: 多态内容载荷，按 `content.contentType` 分发
 *
 * @discussion
 * [EN]: High-frequency callback covering original text, translated text and
 *       translation TTS audio chunks. See `TSAIInterpreterContent` for the
 *       per-type field activation table.
 * [CN]: 高频回调，覆盖原文、译文、译文 TTS 音频片段。
 *       各类型激活的字段见 `TSAIInterpreterContent` 字段表。
 */
typedef void(^TSAIInterpreterContentBlock)(TSAIInterpreterContent *content);

/**
 * @brief Interpretation session-level event block
 * @chinese 同声传译会话级事件回调
 *
 * @param event
 * EN: Session-level state-transition event
 * CN: 会话级状态变更事件
 *
 * @discussion
 * [EN]: Low-frequency callback for UX state (mic animation, translation
 *       playback indicator, auto-detected language, ...). See
 *       `TSAIInterpreterEventType` for the event vocabulary.
 * [CN]: 低频回调，用于 UI 状态（话筒动画、译文播放指示、自动检测语言等）。
 *       事件枚举见 `TSAIInterpreterEventType`。
 */
typedef void(^TSAIInterpreterEventBlock)(TSAIInterpreterEvent *event);

/**
 * @brief Interpretation session completion block
 * @chinese 同声传译会话完成回调
 *
 * @param report
 * EN: Final session report; nil only when `error` indicates session failed
 *     to start
 * CN: 会话最终报告；仅当 `error` 表示会话未能启动时为 nil
 *
 * @param error
 * EN: Error info; nil on normal end (stop)
 * CN: 错误信息；正常结束（stop）时为 nil
 */
typedef void(^TSAIInterpreterCompletionBlock)(TSAIInterpreterReport * _Nullable report,
                                              NSError * _Nullable error);

/**
 * @brief AI Interpreter interface protocol
 * @chinese AI 同声传译接口协议
 *
 * @discussion
 * [EN]: Defines one-way simultaneous-interpretation capability — a
 *       long-running end-to-end voice pipeline driven by device-microphone
 *       audio, in which each detected utterance is streamed back as
 *       original text plus a streaming translation (and optional TTS audio
 *       of the translation). The protocol layer only exposes a single
 *       speaker direction: their `sourceLanguage` is translated into
 *       `targetLanguage`. Bidirectional / face-to-face conversation can
 *       be built on top by stop-then-restarting with a swapped config.
 *
 *       Shape parallels `TSAIAssistantInterface` chat:
 *       `start` returns a client-side UUID taskId synchronously, which
 *       routes the matching `stop` (flush + final report). Unlike chat,
 *       interpretation does not expose a separate `cancel` — see
 *       `stopInterpretationWithTaskId:` for the rationale.
 *
 * [CN]: 定义单向同声传译能力——由设备麦克风音频驱动的端到端长会话管线，
 *       对每段 VAD 切出的 utterance 流式回传原文及流式译文
 *       （及可选的译文 TTS 音频）。
 *       协议层只暴露单方向：说话人的 `sourceLanguage` 翻译为
 *       `targetLanguage`。双向 / 面对面对话需求可在上层通过
 *       "stop 后用对调的 config 重启"自行实现。
 *
 *       形态与 `TSAIAssistantInterface` 对话能力一致：
 *       `start` 同步返回客户端生成的 UUID taskId，
 *       用于路由对应的 `stop`（冲刷 + 下发最终报告）。
 *       与对话不同，同传不暴露独立的 `cancel`——理由见
 *       `stopInterpretationWithTaskId:`。
 */
@protocol TSAIInterpreterInterface <TSKitBaseInterface>

#pragma mark - Session Lifecycle

/**
 * @brief Start a simultaneous-interpretation session
 * @chinese 启动一次同声传译会话
 *
 * @param config
 * EN: Session configuration (mode, languages, speakers, VAD thresholds, ...)
 * CN: 会话配置（模式、语言、发音人、VAD 阈值等）
 *
 * @param onContent
 * EN: High-frequency content callback — original text, translated text,
 *     translation TTS audio chunks. May be nil if the caller relies solely
 *     on events and the final report.
 * CN: 高频内容回调——原文、译文、译文 TTS 音频片段。
 *     若调用方仅依赖事件与最终报告，可传 nil。
 *
 * @param onEvent
 * EN: Low-frequency session-level event callback (VAD start / end,
 *     translation playback start / end, auto-detected language, network
 *     error, ...). May be nil.
 * CN: 低频会话级事件回调（VAD 开始 / 结束、译文播放开始 / 结束、
 *     自动检测语言、网络异常等）。可传 nil。
 *
 * @param completion
 * EN: Completion handler, invoked exactly once when the session ends
 *     (user stop or error).
 * CN: 完成回调，会话结束（用户 stop 或出错）时调用一次。
 *
 * @return
 * EN: Client-side task identifier, used for log tracing and routing
 *     `stopInterpretationWithTaskId:`. The same taskId is echoed in
 *     every content / event payload and the final report for correlation.
 * CN: 客户端生成的任务标识，用于日志追踪及路由
 *     `stopInterpretationWithTaskId:`。
 *     同一 taskId 会回填在每个 content / event 载荷与最终报告中，便于关联。
 *
 * @discussion
 * [EN]: An interpretation session is an end-to-end voice pipeline that the
 *       SDK runs internally:
 *         1) Activate AI capability on the connected device.
 *         2) Open the device microphone audio stream.
 *         3) Pipe audio into ASR -> MT -> (optionally) TTS, segmented by
 *            VAD into multiple utterances within a single session.
 *         4) Stream original / translated text / audio through `onContent`,
 *            and session-level state through `onEvent`.
 *
 *       The language of the source speaker can be specified explicitly via
 *       `config.sourceLanguage`, or left nil for auto-detection — in which
 *       case the resolved language is delivered once via the
 *       `TSAIInterpreterEventTypeLanguageDetected` event.
 *
 *       Languages cannot be changed mid-session. To switch languages,
 *       `stop` the current session and start a new one with the new config.
 *
 *       Unlike single-shot text APIs, the session has no natural endpoint;
 *       it ends only when the caller invokes
 *       `stopInterpretationWithTaskId:` or when an unrecoverable runtime
 *       error occurs.
 *
 *       The synchronously returned taskId is generated on the client side
 *       (typically a UUID), independent of any underlying AI SDK / server
 *       task ID, so the caller obtains a stable identifier the moment the
 *       request is issued.
 *
 * [CN]: 一次同声传译会话即一条端到端语音管线，由 SDK 内部完成调用方无需感知的几步：
 *         1) 激活已连接设备的 AI 能力；
 *         2) 打开设备麦克风音频流；
 *         3) 将音频送入 ASR -> MT ->（可选）TTS，
 *            由 VAD 在单次会话内自动断句产生多段 utterance；
 *         4) 通过 `onContent` 流式下发原文 / 译文 / 音频，
 *            通过 `onEvent` 下发会话级状态。
 *
 *       源说话人语言可通过 `config.sourceLanguage` 显式指定，
 *       也可置 nil 走自动检测——此时解析出的具体语言通过
 *       `TSAIInterpreterEventTypeLanguageDetected` 事件下发一次。
 *
 *       会话中途不支持切换语言。如需切换，请 `stop` 当前会话后用新 config 重启。
 *
 *       与单次文本接口不同，会话没有自然结束点；
 *       仅在调用方调用 `stopInterpretationWithTaskId:`
 *       或发生不可恢复运行时错误时结束。
 *
 *       同步返回的 taskId 由 SDK 客户端生成（通常为 UUID），
 *       与底层 AI SDK 或服务端的任务 ID 无关，
 *       调用方在发起请求的瞬间即可拿到稳定标识。
 */
- (NSString *)startInterpretationWithConfig:(TSAIInterpreterConfig *)config
                                  onContent:(TSAIInterpreterContentBlock _Nullable)onContent
                                    onEvent:(TSAIInterpreterEventBlock _Nullable)onEvent
                                 completion:(TSAIInterpreterCompletionBlock _Nullable)completion;

/**
 * @brief Stop a running interpretation session and deliver the final report
 * @chinese 结束进行中的同声传译会话并下发最终报告
 *
 * @param taskId
 * EN: TaskId returned by
 *     `startInterpretationWithConfig:onContent:onEvent:completion:`
 * CN: `startInterpretationWithConfig:onContent:onEvent:completion:` 返回的 taskId
 *
 * @discussion
 * [EN]: Closes the device microphone audio stream, flushes any buffered
 *       audio through the recognition / translation pipeline, and invokes
 *       the original `completion` block with `endReason = UserStop`.
 *
 *       If the session has already ended or the taskId is unknown, the
 *       call is a no-op.
 *
 *       Interpretation only exposes `stop` (not a separate `cancel`) on
 *       purpose: a user ending a translation session always wants the
 *       final in-flight utterance to be delivered, not discarded — there
 *       is no useful "throw away the half-translated sentence" path the
 *       way there is for an AI chat round. The graceful-flush behavior is
 *       therefore the only behavior.
 *
 * [CN]: 关闭设备麦克风音频流，将已缓冲音频送入识别 / 翻译管道完成最后处理，
 *       并通过原 `completion` 回调下发 `endReason = UserStop` 的报告。
 *
 *       若会话已结束或 taskId 未知，调用无副作用。
 *
 *       同传只对外暴露 `stop`，不提供单独的 `cancel`：
 *       用户结束翻译会话时总希望进行中的最后一段 utterance 被正常下发，
 *       而非丢弃——不存在 AI 对话那种"扔掉这一轮"的合理场景。
 *       因此唯一的结束行为就是"冲刷下发"。
 */
- (void)stopInterpretationWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
