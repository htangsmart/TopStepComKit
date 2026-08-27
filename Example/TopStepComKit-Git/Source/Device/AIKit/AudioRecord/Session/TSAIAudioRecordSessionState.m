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
    self.stopReason = TSAudioRecordStopReasonUnknown;
    self.interruptReason = TSAIAudioRecordInterruptReasonUnknown;
    self.hasAudioStreamFinished = NO;
    self.hasSessionFinished = NO;
    self.hasReportedStart = NO;
    self.hasReportedStop = NO;
    return self.generation;
}

/**
 * 将启动中切换为录音中
 */
- (BOOL)markStartedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] ||
        self.phase != TSAIAudioRecordSessionPhaseStarting) {
        return NO;
    }
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
        self.phase != TSAIAudioRecordSessionPhaseRecording) {
        return NO;
    }
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
    return YES;
}

/**
 * 标记语义 Finish 已到达
 */
- (BOOL)markSessionFinishedForGeneration:(NSUInteger)generation {
    if (![self matchesGeneration:generation] || ![self isActive]) {
        return NO;
    }
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
    self.stopReason = TSAudioRecordStopReasonUnknown;
    self.interruptReason = TSAIAudioRecordInterruptReasonUnknown;
    self.hasAudioStreamFinished = NO;
    self.hasSessionFinished = NO;
    self.hasReportedStart = NO;
    self.hasReportedStop = NO;
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
    copy.stopReason = self.stopReason;
    copy.interruptReason = self.interruptReason;
    copy.hasAudioStreamFinished = self.hasAudioStreamFinished;
    copy.hasSessionFinished = self.hasSessionFinished;
    copy.hasReportedStart = self.hasReportedStart;
    copy.hasReportedStop = self.hasReportedStop;
    return copy;
}

#pragma mark - 私有方法

/**
 * 检查回调是否属于当前代次
 */
- (BOOL)matchesGeneration:(NSUInteger)generation {
    return generation > 0 && generation == self.generation;
}

@end
