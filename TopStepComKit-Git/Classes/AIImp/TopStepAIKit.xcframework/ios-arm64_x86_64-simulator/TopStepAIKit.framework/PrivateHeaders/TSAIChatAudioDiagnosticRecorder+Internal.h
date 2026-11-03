//
//  TSAIChatAudioDiagnosticRecorder+Internal.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/10/28.
//

#import <Foundation/Foundation.h>

#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bounded opt-in DEBUG recorder for three chat audio streams.
 * @chinese 有界且需主动启用的 DEBUG 三路对话音频记录器。
 *
 * @discussion
 * [EN]: Saves 16 kHz mono Int16LE PCM and numeric timing metadata.
 *       All file access is asynchronous; failures only disable diagnostics.
 * [CN]: 保存 16 kHz 单声道 Int16LE PCM 与数字时序元数据；文件操作异步执行，
 *       失败只停用诊断，不影响会话。保留最近三次记录，每次最多 180 秒、总文件 30 MiB。
 */
@interface TSAIChatAudioDiagnosticRecorder : NSObject

/**
 * @brief Create a recorder only when explicit DEBUG diagnostics are enabled.
 * @chinese 仅在显式启用 DEBUG 诊断时创建记录器。
 *
 * @param generation
 * EN: Owning processing generation.
 * CN: 所属音频处理代次。
 *
 * @return
 * EN: A recorder when DEBUG and TSAIChatAudioDiagnosticsEnabled is YES; otherwise nil.
 * CN: DEBUG 且 TSAIChatAudioDiagnosticsEnabled 为 YES 时返回记录器，否则 nil。
 */
+ (nullable instancetype)recorderIfEnabledForGeneration:(NSUInteger)generation;

/**
 * @brief Queue bounded audio and its supplied monotonic timing.
 * @chinese 有界入队音频及其单调时序。
 *
 * @param pcmData
 * EN: Complete 16 kHz mono Int16LE samples.
 * CN: 完整的 16 kHz 单声道 Int16LE 样本。
 *
 * @param stream
 * EN: Only capture, render or processed.
 * CN: 仅允许 capture、render 或 processed。
 *
 * @param hostTimeNanoseconds
 * EN: Supplied host time; capture is arrival-estimated, render is actual rendering time,
 *     processed is capture-derived estimated time.
 * CN: 调用方主机时刻；capture 为到达估计，render 为实际渲染，processed 为采集派生估计。
 *
 * @param sampleIndex
 * EN: Index of the first sample in this stream.
 * CN: 本分片在该音频流中的首样本索引。
 */
- (void)recordPCMData:(NSData *)pcmData
               stream:(NSString *)stream
  hostTimeNanoseconds:(uint64_t)hostTimeNanoseconds
          sampleIndex:(uint64_t)sampleIndex;

/**
 * @brief Stop admission and asynchronously finish already accepted records.
 * @chinese 停止接收并异步完成已接收记录。
 *
 * @discussion
 * [EN]: Thread-safe and idempotent.
 * [CN]: 线程安全且幂等。
 */
- (void)finish;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
