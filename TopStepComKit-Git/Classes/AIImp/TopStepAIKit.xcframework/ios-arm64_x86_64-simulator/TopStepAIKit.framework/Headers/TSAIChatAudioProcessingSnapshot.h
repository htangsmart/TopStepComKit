//
//  TSAIChatAudioProcessingSnapshot.h
//  TopStepAIKit
//
//  Created by Codex on 2026/10/28.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime state of chat audio processing
 * @chinese 对话音频处理的运行状态
 */
typedef NS_ENUM(NSInteger, TSAIChatAudioProcessingState) {
    /**
     * @brief Ready while no rendered audio currently needs echo processing
     * @chinese 已就绪，当前没有需要回声处理的播放音频
     */
    TSAIChatAudioProcessingStateReadyIdle = 0,
    /**
     * @brief Echo control is adapting; near-end speech remains eligible for interruption
     * @chinese 回声控制正在适应，近端人声仍可参与语音打断准入
     */
    TSAIChatAudioProcessingStateConverging = 1,
    /**
     * @brief Rendering with a healthy echo-control path
     * @chinese 正在播放，回声控制链路健康
     */
    TSAIChatAudioProcessingStateRenderingHealthy = 2,
    /**
     * @brief The reference required by active playback is missing or unusable
     * @chinese 播放所需的参考音频缺失或不可用
     */
    TSAIChatAudioProcessingStateReferenceLost = 3,
    /**
     * @brief Audio processing has stopped for this session
     * @chinese 本会话的音频处理已停止
     */
    TSAIChatAudioProcessingStateStopped = 4,
    /**
     * @brief Explicit half-duplex protection; voice input is suppressed during playback
     * @chinese 明确采用半双工保护，播放期间抑制语音输入
     */
    TSAIChatAudioProcessingStateHalfDuplex = 5,
};

/**
 * @brief Immutable snapshot of the effective chat audio processing state
 * @chinese 实际对话音频处理状态的不可变快照
 *
 * @discussion
 * [EN]: Describes effective behavior rather than the requested configuration.
 *       Physical full-duplex routing alone does not guarantee voice interruption.
 * [CN]: 描述实际行为而非请求配置；路由可同时收放音不代表可靠的语音打断。
 */
@interface TSAIChatAudioProcessingSnapshot : NSObject <NSCopying>

/**
 * @brief Effective echo-cancellation source
 * @chinese 实际使用的回声消除来源
 *
 * @discussion
 * [EN]: HostSoftware is reported only for an active host-side processing path.
 * [CN]: 仅在主机软件处理链路实际启用时报告 HostSoftware。
 *
 * @note
 * [EN]: Read-only; None means no echo canceller is active.
 * [CN]: 只读；None 表示未启用回声消除器。
 */
@property (nonatomic, assign, readonly) TSAIAudioEchoCancellationMode echoCancellationMode;

/**
 * @brief Current audio processing state
 * @chinese 当前音频处理状态
 *
 * @discussion
 * [EN]: Normal idle periods without TTS are distinct from reference failure.
 * [CN]: 无 TTS 的正常空闲阶段与参考音频故障分开表示。
 *
 * @note
 * [EN]: Read-only; a later state is delivered as a new snapshot.
 * [CN]: 只读；后续状态通过新的快照下发。
 */
@property (nonatomic, assign, readonly) TSAIChatAudioProcessingState state;

/**
 * @brief Whether voice interruption is currently allowed in this session
 * @chinese 本会话当前是否允许通过说话打断播放
 *
 * @discussion
 * [EN]: Combines caller intent and effective processing availability. When NO,
 *       speech during playback is not accepted as a new question.
 * [CN]: 综合调用方意图和实际处理能力；为 NO 时，播放期间不将说话采纳为新问题。
 *
 * @note
 * [EN]: Read-only; consult each state change rather than the requested flag.
 * [CN]: 只读；应以最新状态为准，不能仅依据请求开关。
 */
@property (nonatomic, assign, readonly) BOOL allowsUserInterrupt;

/**
 * @brief Optional diagnostic reason for reduced audio processing capability
 * @chinese 音频处理能力降级的可选诊断原因
 *
 * @discussion
 * [EN]: Explains reduced behavior without changing the selected audio route.
 * [CN]: 说明能力降低的原因，不表示输入或输出路由发生变化。
 *
 * @note
 * [EN]: Nil when no fallback reason applies; copied during construction.
 * [CN]: 没有降级原因时为 nil；构造时复制。
 */
@property (nonatomic, copy, readonly, nullable) NSString *fallbackReason;

/**
 * @brief Create an immutable snapshot of effective processing behavior
 * @chinese 创建实际处理行为的不可变快照
 *
 * @param echoCancellationMode
 * EN: Effective echo-cancellation source.
 * CN: 实际回声消除来源。
 *
 * @param state
 * EN: Current processing state.
 * CN: 当前处理状态。
 *
 * @param allowsUserInterrupt
 * EN: Whether voice interruption is currently allowed.
 * CN: 当前是否允许语音打断。
 *
 * @param fallbackReason
 * EN: Optional diagnostic reason for reduced capability.
 * CN: 能力降低时的可选诊断原因。
 *
 * @return
 * EN: A new immutable snapshot.
 * CN: 新的不可变快照。
 */
+ (instancetype)snapshotWithEchoCancellationMode:(TSAIAudioEchoCancellationMode)echoCancellationMode
                                          state:(TSAIChatAudioProcessingState)state
                            allowsUserInterrupt:(BOOL)allowsUserInterrupt
                                 fallbackReason:(nullable NSString *)fallbackReason;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
