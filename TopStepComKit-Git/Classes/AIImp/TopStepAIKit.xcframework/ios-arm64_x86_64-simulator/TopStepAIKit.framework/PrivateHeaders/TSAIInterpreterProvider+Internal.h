//
//  TSAIInterpreterProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIInterpreterProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional explicit interpretation with Provider-owned capture and playback
 * @chinese 显式由 Provider 管理采集与播放的同传内部能力
 */
@protocol TSAINativeInterpreterProvider <TSAIInterpreterProvider>

/**
 * @brief Validate native configuration without acquiring audio or starting work
 * @chinese 不占用音频、不启动业务地校验原生配置
 * @param config
 * EN: Requested or resolved configuration.
 * CN: 调用方请求或解析后的配置。
 * @return
 * EN: Nil when supported, otherwise an explicit error.
 * CN: 支持时为 nil，否则返回明确错误。
 */
- (nullable NSError *)validateProviderManagedInterpretationConfig:(TSAIInterpreterConfig *)config;

/**
 * @brief Pause a matching task without releasing its logical ownership
 * @chinese 暂停匹配任务并保留逻辑所有权
 * @param taskId
 * EN: Exact task identifier.
 * CN: 精确任务标识。
 * @param completion
 * EN: Main-thread result for accepting the pause operation.
 * CN: 主线程返回暂停操作是否被接受。
 */
- (void)pauseInterpretationWithTaskId:(NSString *)taskId completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Resume a matching paused task
 * @chinese 恢复匹配的暂停任务
 * @param taskId
 * EN: Exact task identifier.
 * CN: 精确任务标识。
 * @param completion
 * EN: Main-thread vendor resume result.
 * CN: 主线程返回厂商恢复结果。
 */
- (void)resumeInterpretationWithTaskId:(NSString *)taskId completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Internal provider capability for one-shot device voice translation
 * @chinese 设备整段语音翻译使用的内部 Provider 能力
 */
@protocol TSAIDeviceInterpreterProvider <TSAIInterpreterProvider>

/**
 * @brief Interpret one complete device PCM buffer
 * @chinese 翻译一段完整的设备 PCM 数据
 * @param pcmData EN: Complete 16 kHz mono Int16LE PCM. CN: 完整的 16 kHz 单声道 Int16LE PCM。
 * @param config EN: Voice-translation configuration. CN: 语音翻译配置。
 * @param onContent EN: Streaming content callback. CN: 流式内容回调。
 * @param completion EN: Exactly-once whole-session completion; implementations
 *                    must close every vendor stage within a bounded time.
 *                    CN: 整轮会话精确一次完成回调；实现必须为每个底层阶段
 *                    提供有界收口。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)interpretDeviceVoicePCMData:(NSData *)pcmData
                                    config:(TSAIInterpreterConfig *)config
                                 onContent:(nullable TSAIInterpreterContentBlock)onContent
                                completion:(nullable TSAIInterpreterCompletionBlock)completion;

/**
 * @brief Request cancellation of one owned device task
 * @chinese 请求取消指定设备任务
 * @param taskId EN: Owned task identifier. CN: 已持有的任务标识。
 * @param completion EN: Called only after the owned vendor operation can no
 *                    longer affect the shared runtime. A parent-task timeout
 *                    does not satisfy this release callback. CN: 仅当对应底层
 *                    任务已无法影响共享运行时后回调；父任务超时不等同于
 *                    资源释放完成。
 */
- (void)cancelDeviceInterpretationWithTaskId:(NSString *)taskId
                                  completion:(nullable TSAICompletionBlock)completion;

@end

/**
 * @brief Internal ingress for an App interpretation session using device PCM
 * @chinese 使用设备 PCM 的 App 同传会话内部输入能力
 */
@protocol TSAIExternalPCMInterpreterProvider <TSAIInterpreterProvider>

/**
 * @brief Append ordered external PCM to one exact App session
 * @chinese 向精确的 App 同传会话追加有序外部 PCM
 * @param pcmData EN: 16 kHz mono Int16LE PCM. CN: 16 kHz 单声道 Int16LE PCM。
 * @param taskIdentifier EN: Interpreter task that owns the input. CN: 持有该输入的同传任务。
 * @param isFinal EN: Whether device input has ended. CN: 设备输入是否结束。
 */
- (void)appendExternalPCMData:(nullable NSData *)pcmData
               taskIdentifier:(NSString *)taskIdentifier
                      isFinal:(BOOL)isFinal;

@optional

/**
 * @brief Start an App interpretation session with an explicit input owner
 * @chinese 以明确的输入持有方启动 App 同传会话
 * @discussion EN: With usesExternalPCMInput = YES the provider must not open the
 *             microphone or the audio session; input arrives through
 *             appendExternalPCMData:taskIdentifier:isFinal:.
 *             CN: usesExternalPCMInput 为 YES 时 Provider 不得自行打开麦克风或改写音频会话，
 *             输入只经 appendExternalPCMData:taskIdentifier:isFinal: 送入
 *             （例如 AIKit 自行通过 HFP 采集的蓝牙耳机麦克风）。
 * @param config EN: Interpreter configuration. CN: 同传配置。
 * @param usesExternalPCMInput EN: Whether input is supplied externally. CN: 是否由外部提供输入 PCM。
 * @param onContent EN: Streaming content callback. CN: 流式内容回调。
 * @param onEvent EN: Event callback. CN: 事件回调。
 * @param completion EN: Exactly-once completion. CN: 精确一次完成回调。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)startInterpretationWithConfig:(TSAIInterpreterConfig *)config
                       usesExternalPCMInput:(BOOL)usesExternalPCMInput
                                  onContent:(nullable TSAIInterpreterContentBlock)onContent
                                    onEvent:(nullable TSAIInterpreterEventBlock)onEvent
                                 completion:(nullable TSAIInterpreterCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
