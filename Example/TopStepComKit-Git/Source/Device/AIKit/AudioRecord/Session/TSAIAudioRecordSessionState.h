//
//  TSAIAudioRecordSessionState.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TopStepAIKit/TSAudioRecordDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI audio-recording session phase used by the Demo coordinator
 * @chinese Demo 会话协调器使用的 AI 录音阶段
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordSessionPhase) {
    TSAIAudioRecordSessionPhaseIdle = 0,
    TSAIAudioRecordSessionPhaseStarting,
    TSAIAudioRecordSessionPhaseRecording,
    TSAIAudioRecordSessionPhaseStopping,
    TSAIAudioRecordSessionPhaseInterrupted,
    TSAIAudioRecordSessionPhaseFinalizing,
    TSAIAudioRecordSessionPhaseCompleted,
    TSAIAudioRecordSessionPhaseFailed,
};

/**
 * @brief Source that initiated an AI audio-recording session
 * @chinese AI 录音会话的发起来源
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordSessionSource) {
    TSAIAudioRecordSessionSourceApp = 0,
    TSAIAudioRecordSessionSourceDevice,
};

/**
 * @brief Pure state model for one AI audio-recording session
 * @chinese 单次 AI 录音会话的纯状态模型
 */
@interface TSAIAudioRecordSessionState : NSObject <NSCopying>

/** @brief Current phase @chinese 当前阶段 */
@property (nonatomic, assign, readonly) TSAIAudioRecordSessionPhase phase;

/** @brief Monotonic session generation @chinese 单调递增的会话代次 */
@property (nonatomic, assign, readonly) NSUInteger generation;

/** @brief Session initiation source @chinese 会话发起来源 */
@property (nonatomic, assign, readonly) TSAIAudioRecordSessionSource source;

/** @brief Recording scene @chinese 录音场景 */
@property (nonatomic, assign, readonly) TSAIAudioRecordScene scene;

/** @brief Session start date @chinese 会话开始时间 */
@property (nonatomic, strong, nullable, readonly) NSDate *startDate;

/** @brief Audio-stream stop reason @chinese 音频流停止原因 */
@property (nonatomic, assign, readonly) TSAudioRecordStopReason stopReason;

/** @brief Device interruption reason @chinese 设备中断原因 */
@property (nonatomic, assign, readonly) TSAIAudioRecordInterruptReason interruptReason;

/** @brief Whether the audio stream ended @chinese 音频流是否已结束 */
@property (nonatomic, assign, readonly) BOOL hasAudioStreamFinished;

/** @brief Whether the semantic Finish arrived @chinese 语义 Finish 是否已到达 */
@property (nonatomic, assign, readonly) BOOL hasSessionFinished;

/**
 * @brief Begin a new session when the current state is terminal
 * @chinese 当前状态为终态时开始新会话
 * @param source EN: Initiation source. CN: 发起来源。
 * @param scene EN: Recording scene. CN: 录音场景。
 * @return EN: New generation, or 0 when busy. CN: 新代次；忙碌时返回 0。
 */
- (NSUInteger)beginWithSource:(TSAIAudioRecordSessionSource)source
                        scene:(TSAIAudioRecordScene)scene;

/// @brief Marks the specified generation as started.
/// @chinese 将指定代次标记为启动成功。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markStartedForGeneration:(NSUInteger)generation;

/// @brief Marks a stop request for the specified generation.
/// @chinese 标记指定代次的停止请求。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markStopRequestedForGeneration:(NSUInteger)generation;

/// @brief Marks the specified generation as waiting for final results.
/// @chinese 将指定代次标记为等待最终结果。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markFinalizingForGeneration:(NSUInteger)generation;

/// @brief Marks the specified generation as interrupted.
/// @chinese 将指定代次标记为已中断。
/// @param reason Device interruption reason. / 设备中断原因。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markInterruptedWithReason:(TSAIAudioRecordInterruptReason)reason
                       generation:(NSUInteger)generation;

/// @brief Marks the underlying audio stream as finished.
/// @chinese 标记底层音频流已结束。
/// @param reason Audio stream stop reason. / 音频流停止原因。
/// @param generation Session generation. / 会话代次。
/// @return YES when the signal belongs to the active generation. / 信号属于当前代次时返回 YES。
- (BOOL)markAudioStreamFinishedWithReason:(TSAudioRecordStopReason)reason
                                generation:(NSUInteger)generation;

/// @brief Marks the semantic Finish result as received.
/// @chinese 标记已收到语义 Finish 结果。
/// @param generation Session generation. / 会话代次。
/// @return YES when the signal belongs to the active generation. / 信号属于当前代次时返回 YES。
- (BOOL)markSessionFinishedForGeneration:(NSUInteger)generation;

/// @brief Marks persistence as completed.
/// @chinese 标记持久化已完成。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markCompletedForGeneration:(NSUInteger)generation;

/// @brief Marks a terminal session failure.
/// @chinese 标记会话终态失败。
/// @param generation Session generation. / 会话代次。
/// @return YES when the transition is accepted. / 状态迁移被接受时返回 YES。
- (BOOL)markFailedForGeneration:(NSUInteger)generation;

/// @brief Resets a terminal session to the ready state.
/// @chinese 将终态会话重置为准备状态。
/// @return YES when the reset is accepted. / 状态重置被接受时返回 YES。
- (BOOL)resetToIdle;

/// @brief Consumes the device start report once per generation.
/// @chinese 每个代次仅消费一次设备启动回报。
/// @param generation Session generation. / 会话代次。
/// @return YES only for the first eligible consumption. / 仅首次符合条件的消费返回 YES。
- (BOOL)consumeStartReportForGeneration:(NSUInteger)generation;

/// @brief Consumes the device stop report once per generation.
/// @chinese 每个代次仅消费一次设备停止回报。
/// @param generation Session generation. / 会话代次。
/// @return YES only for the first eligible consumption. / 仅首次符合条件的消费返回 YES。
- (BOOL)consumeStopReportForGeneration:(NSUInteger)generation;

/// @brief Returns whether the current phase is active.
/// @chinese 返回当前阶段是否为活动态。
/// @return YES for a nonterminal session. / 会话尚未进入终态时返回 YES。
- (BOOL)isActive;

@end

NS_ASSUME_NONNULL_END
