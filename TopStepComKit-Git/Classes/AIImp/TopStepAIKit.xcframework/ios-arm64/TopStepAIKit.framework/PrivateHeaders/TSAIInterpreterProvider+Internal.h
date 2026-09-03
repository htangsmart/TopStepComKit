//
//  TSAIInterpreterProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIInterpreterProvider.h"

NS_ASSUME_NONNULL_BEGIN

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
 * @brief Append ordered external PCM to the active App session
 * @chinese 向活动 App 同传会话追加有序外部 PCM
 * @param pcmData EN: 16 kHz mono Int16LE PCM. CN: 16 kHz 单声道 Int16LE PCM。
 * @param isFinal EN: Whether device input has ended. CN: 设备输入是否结束。
 */
- (void)appendExternalPCMData:(nullable NSData *)pcmData isFinal:(BOOL)isFinal;

@end

NS_ASSUME_NONNULL_END
