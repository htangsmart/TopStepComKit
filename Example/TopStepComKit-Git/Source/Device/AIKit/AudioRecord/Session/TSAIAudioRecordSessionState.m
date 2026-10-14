//
//  TSAIAudioRecordSessionState.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIAudioRecordSessionState.h"

@interface TSAIAudioRecordSessionState ()

// 当前会话阶段
@property (nonatomic, assign, readwrite) TSAIAudioRecordSessionPhase phase;
// 当前会话代次
@property (nonatomic, assign, readwrite) NSUInteger generation;
// 当前会话发起来源
@property (nonatomic, assign, readwrite) TSAIAudioRecordSessionSource source;
// 当前录音场景
@property (nonatomic, assign, readwrite) TSAIAudioRecordScene scene;
// 当前会话开始时间
@property (nonatomic, strong, nullable, readwrite) NSDate *startDate;
// 停止收音的时间
@property (nonatomic, strong, nullable, readwrite) NSDate *endDate;
// 当前音频流停止原因
@property (nonatomic, assign, readwrite) TSAudioRecordStopReason stopReason;
// 当前设备中断原因
@property (nonatomic, assign, readwrite) TSAIAudioRecordInterruptReason interruptReason;
// 音频流是否已经结束
@property (nonatomic, assign, readwrite) BOOL hasAudioStreamFinished;
// 语义会话是否已经结束
@property (nonatomic, assign, readwrite) BOOL hasSessionFinished;
// 是否已经回报设备启动成功
@property (nonatomic, assign) BOOL hasReportedStart;
// 是否已经回报设备停止
@property (nonatomic, assign) BOOL hasReportedStop;
// 已结束的暂停累计秒数
@property (nonatomic, assign) NSTimeInterval completedPausedDuration;
// 当前暂停开始时间，未暂停时为 nil
@property (nonatomic, strong, nullable) NSDate *pauseStartDate;

@end

@implementation TSAIAudioRecordSessionState

#pragma mark - 生命周期

/**
 * 初始化空闲状态
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _phase = TSAIAudioRecordSessionPhaseIdle;
        _scene = TSAIAudioRecordSceneUnknown;
        _stopReason = TSAudioRecordStopReasonUnknown;
        _interruptReason = TSAIAudioRecordInterruptReasonUnknown;
    }
    return self;
}

#pragma mark - 公开方法

/**
 * 在终态上创建新一代会话
 */
- (NSUInteger)beginWithSource:(TSAIAudioRecordSessionSource)source
                        scene:(TSAIAudioRecordScene)scene {
    if ([self isActive]) {
        return 0;
    }
    self.generation += 1;
    self.phase = TSAIAudioRecordSessionPhaseStarting;
    self.source = source;
    self.scene = scene;
    self.startDate = [NSDate date];
    self.endDate = nil;
    self.stopReason = TSAudioRecordStopReasonUnknown;
    self.interruptReason = TSAIAudioRecordInterruptReasonUnknown;
    self.hasAudioStreamFinished = NO;
    self.hasSessionFinished = NO;
    self.hasReportedStart = NO;
    self.hasReportedStop = NO;
    self.completedPausedDuration = 0;
    self.pauseStartDate = nil;
    return self.generation;
}

/**
 * 录音中切换为已暂停并记录暂停起点
 */
- (BOOL)markPausedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.phase != TSAIAudioRecordSessionPhaseRecording) {
        return NO;
    }
    self.phase = TSAIAudioRecordSessionPhasePaused;
    self.pauseStartDate = [NSDate date];
    return YES;
}

/**
 * 已暂停切换回录音中并累计暂停时长
 */
- (BOOL)markResumedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.phase != TSAIAudioRecordSessionPhasePaused) {
        return NO;
    }
    [self settlePause];
    self.phase = TSAIAudioRecordSessionPhaseRecording;
    return YES;
}

/**
 * 返回累计暂停秒数，含进行中的暂停
 */
- (NSTimeInterval)pausedDuration {
    NSTimeInterval current = self.pauseStartDate
        ? [[NSDate date] timeIntervalSinceDate:self.pauseStartDate]
        : 0;
    return self.completedPausedDuration + MAX(0, current);
}

/**
 * 返回不含暂停的实际录音秒数
 */
- (NSTimeInterval)activeDuration {
    if (self.startDate == nil) {
        return 0;
    }
    NSDate *referenceDate = self.endDate ?: [NSDate date];
    return MAX(0, [referenceDate timeIntervalSinceDate:self.startDate] - [self pausedDuration]);
}

/**
 * 将启动中切换为录音中
 */
- (BOOL)markStartedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.phase != TSAIAudioRecordSessionPhaseStarting) {
        return NO;
    }
    // 启动成功才开始计时，与草稿的 startDate 保持同一起点
    self.startDate = [NSDate date];
    self.phase = TSAIAudioRecordSessionPhaseRecording;
    return YES;
}

/**
 * 标记停止请求并保持幂等
 */
- (BOOL)markStopRequestedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation]) {
        return NO;
    }
    if (self.phase == TSAIAudioRecordSessionPhaseStopping ||
        self.phase == TSAIAudioRecordSessionPhaseFinalizing) {
        return NO;
    }
    if (self.phase != TSAIAudioRecordSessionPhaseStarting &&
        self.phase != TSAIAudioRecordSessionPhaseRecording &&
        self.phase != TSAIAudioRecordSessionPhasePaused) {
        return NO;
    }
    [self settlePause];
    [self markEndDateIfNeeded];
    self.phase = TSAIAudioRecordSessionPhaseStopping;
    return YES;
}

/**
 * 切换为最终结果整理阶段
 */
- (BOOL)markFinalizingForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    [self settlePause];
    [self markEndDateIfNeeded];
    self.phase = TSAIAudioRecordSessionPhaseFinalizing;
    return YES;
}

/**
 * 记录设备中断原因
 */
- (BOOL)markInterruptedWithReason:(TSAIAudioRecordInterruptReason)reason
                       generation:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    [self settlePause];
    [self markEndDateIfNeeded];
    self.interruptReason = reason;
    self.stopReason = TSAudioRecordStopReasonInterrupted;
    self.phase = TSAIAudioRecordSessionPhaseInterrupted;
    return YES;
}

/**
 * 标记底层音频流已经结束
 */
- (BOOL)markAudioStreamFinishedWithReason:(TSAudioRecordStopReason)reason
                                generation:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    self.hasAudioStreamFinished = YES;
    self.stopReason = reason;
    [self settlePause];
    [self markEndDateIfNeeded];
    return YES;
}

/**
 * 标记语义 Finish 已到达
 */
- (BOOL)markSessionFinishedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    [self settlePause];
    [self markEndDateIfNeeded];
    self.hasSessionFinished = YES;
    self.phase = TSAIAudioRecordSessionPhaseFinalizing;
    return YES;
}

/**
 * 标记会话已保存完成
 */
- (BOOL)markCompletedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    self.phase = TSAIAudioRecordSessionPhaseCompleted;
    return YES;
}

/**
 * 标记当前会话失败
 */
- (BOOL)markFailedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
    self.phase = TSAIAudioRecordSessionPhaseFailed;
    return YES;
}

/** 将终态会话恢复为准备状态 */
- (BOOL)resetToIdle {
    if ([self isActive]) {
        return NO;
    }
    self.phase = TSAIAudioRecordSessionPhaseIdle;
    self.source = TSAIAudioRecordSessionSourceApp;
    self.scene = TSAIAudioRecordSceneUnknown;
    self.startDate = nil;
    self.endDate = nil;
    self.stopReason = TSAudioRecordStopReasonUnknown;
    self.interruptReason = TSAIAudioRecordInterruptReasonUnknown;
    self.hasAudioStreamFinished = NO;
    self.hasSessionFinished = NO;
    self.hasReportedStart = NO;
    self.hasReportedStop = NO;
    self.completedPausedDuration = 0;
    self.pauseStartDate = nil;
    return YES;
}

/**
 * 单次消费设备启动成功回报
 */
- (BOOL)consumeStartReportForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.source != TSAIAudioRecordSessionSourceDevice ||
        self.hasReportedStart) {
        return NO;
    }
    self.hasReportedStart = YES;
    return YES;
}

/**
 * 单次消费设备停止回报
 */
- (BOOL)consumeStopReportForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.source != TSAIAudioRecordSessionSourceDevice ||
        self.hasReportedStop) {
        return NO;
    }
    self.hasReportedStop = YES;
    return YES;
}

/**
 * 返回当前是否处于非终态
 */
- (BOOL)isActive {
    return self.phase == TSAIAudioRecordSessionPhaseStarting ||
           self.phase == TSAIAudioRecordSessionPhaseRecording ||
           self.phase == TSAIAudioRecordSessionPhasePaused ||
           self.phase == TSAIAudioRecordSessionPhaseStopping ||
           self.phase == TSAIAudioRecordSessionPhaseInterrupted ||
           self.phase == TSAIAudioRecordSessionPhaseFinalizing;
}

/**
 * 复制状态快照
 */
- (id)copyWithZone:(NSZone *)zone {
    TSAIAudioRecordSessionState *copy = [[[self class] allocWithZone:zone] init];
    copy.phase = self.phase;
    copy.generation = self.generation;
    copy.source = self.source;
    copy.scene = self.scene;
    copy.startDate = self.startDate;
    copy.endDate = self.endDate;
    copy.stopReason = self.stopReason;
    copy.interruptReason = self.interruptReason;
    copy.hasAudioStreamFinished = self.hasAudioStreamFinished;
    copy.hasSessionFinished = self.hasSessionFinished;
    copy.hasReportedStart = self.hasReportedStart;
    copy.hasReportedStop = self.hasReportedStop;
    copy.completedPausedDuration = self.completedPausedDuration;
    copy.pauseStartDate = self.pauseStartDate;
    return copy;
}

#pragma mark - 私有方法

/**
 * 首次离开录音/暂停时记录停止收音时间
 */
- (void)markEndDateIfNeeded {
    if (self.endDate == nil) {
        self.endDate = [NSDate date];
    }
}

/**
 * 结束进行中的暂停并计入累计
 */
- (void)settlePause {
    if (self.pauseStartDate == nil) {
        return;
    }
    self.completedPausedDuration += MAX(0, [[NSDate date] timeIntervalSinceDate:self.pauseStartDate]);
    self.pauseStartDate = nil;
}

/**
 * 检查回调是否属于当前代次
 */
- (BOOL)matchesGeneration:(NSUInteger)generation {
    return generation > 0 && generation == self.generation;
}

@end
