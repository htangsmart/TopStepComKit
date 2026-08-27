//
//  TSAIChatDeviceSessionState.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatDeviceSessionState.h"

static const NSUInteger kTSAIChatDeviceSessionMaximumReportAttempts = 2;

@interface TSAIChatDeviceSessionReportRequest ()

// 会话代次
@property (nonatomic, assign, readwrite) NSUInteger generation;
// 回报次数
@property (nonatomic, assign, readwrite) NSUInteger attempt;
// 回报类型
@property (nonatomic, assign, readwrite) TSAIChatDeviceSessionReportKind kind;
// 会话结束来源
@property (nonatomic, assign, readwrite) TSAIChatDeviceSessionEndOrigin origin;

- (instancetype)initWithGeneration:(NSUInteger)generation
                            attempt:(NSUInteger)attempt
                               kind:(TSAIChatDeviceSessionReportKind)kind
                             origin:(TSAIChatDeviceSessionEndOrigin)origin;

@end

@implementation TSAIChatDeviceSessionReportRequest

/** 初始化设备会话回报请求 */
- (instancetype)initWithGeneration:(NSUInteger)generation
                            attempt:(NSUInteger)attempt
                               kind:(TSAIChatDeviceSessionReportKind)kind
                             origin:(TSAIChatDeviceSessionEndOrigin)origin {
    self = [super init];
    if (self) {
        _generation = generation;
        _attempt = attempt;
        _kind = kind;
        _origin = origin;
    }
    return self;
}

@end

@interface TSAIChatDeviceSessionState ()

// 状态访问锁
@property (nonatomic, strong) NSRecursiveLock *stateLock;
// 当前会话代次
@property (nonatomic, assign, readwrite) NSUInteger generation;
// 当前会话阶段
@property (nonatomic, assign, readwrite) TSAIChatDeviceSessionPhase phase;
// 当前结束来源
@property (nonatomic, assign, readwrite) TSAIChatDeviceSessionEndOrigin origin;
// 当前回报次数
@property (nonatomic, assign, readwrite) NSUInteger reportAttempts;
// 当前回报类型
@property (nonatomic, assign) TSAIChatDeviceSessionReportKind reportKind;

@end

@implementation TSAIChatDeviceSessionState

#pragma mark - 生命周期

/** 初始化会话状态 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _stateLock = [[NSRecursiveLock alloc] init];
        _phase = TSAIChatDeviceSessionPhaseIdle;
        _origin = TSAIChatDeviceSessionEndOriginNone;
    }
    return self;
}

#pragma mark - 公开方法

/** 返回当前会话代次 */
- (NSUInteger)generation {
    [self.stateLock lock];
    NSUInteger generation = _generation;
    [self.stateLock unlock];
    return generation;
}

/** 返回当前会话阶段 */
- (TSAIChatDeviceSessionPhase)phase {
    [self.stateLock lock];
    TSAIChatDeviceSessionPhase phase = _phase;
    [self.stateLock unlock];
    return phase;
}

/** 返回当前结束来源 */
- (TSAIChatDeviceSessionEndOrigin)origin {
    [self.stateLock lock];
    TSAIChatDeviceSessionEndOrigin origin = _origin;
    [self.stateLock unlock];
    return origin;
}

/** 返回当前回报次数 */
- (NSUInteger)reportAttempts {
    [self.stateLock lock];
    NSUInteger reportAttempts = _reportAttempts;
    [self.stateLock unlock];
    return reportAttempts;
}

/** 开始新的设备启动请求 */
- (BOOL)beginDeviceStartWithGeneration:(NSUInteger *)generation {
    [self.stateLock lock];
    BOOL canBegin = self.phase == TSAIChatDeviceSessionPhaseIdle ||
        self.phase == TSAIChatDeviceSessionPhaseTerminated ||
        self.phase == TSAIChatDeviceSessionPhaseClosedByDevice ||
        self.phase == TSAIChatDeviceSessionPhaseReportFailed;
    if (!canBegin) {
        [self.stateLock unlock];
        return NO;
    }
    self.generation += 1;
    self.phase = TSAIChatDeviceSessionPhaseStartRequested;
    self.origin = TSAIChatDeviceSessionEndOriginNone;
    self.reportAttempts = 0;
    if (generation) {
        *generation = self.generation;
    }
    [self.stateLock unlock];
    return YES;
}

/** 标记云端 AI 会话已启动 */
- (BOOL)markAIStartedForGeneration:(NSUInteger)generation {
    [self.stateLock lock];
    BOOL canStart = self.generation == generation &&
        self.phase == TSAIChatDeviceSessionPhaseStartRequested;
    if (canStart) {
        self.phase = TSAIChatDeviceSessionPhaseActive;
    }
    [self.stateLock unlock];
    return canStart;
}

/** 检查任务是否仍属于当前启动流程 */
- (BOOL)canAcceptTaskForGeneration:(NSUInteger)generation {
    [self.stateLock lock];
    BOOL canAccept = self.generation == generation &&
        (self.phase == TSAIChatDeviceSessionPhaseStartRequested ||
         self.phase == TSAIChatDeviceSessionPhaseActive);
    [self.stateLock unlock];
    return canAccept;
}

/** 标记设备侧已关闭会话 */
- (void)markClosedByDeviceWithOrigin:(TSAIChatDeviceSessionEndOrigin)origin {
    [self.stateLock lock];
    BOOL hasOpenSession = self.phase == TSAIChatDeviceSessionPhaseStartRequested ||
        self.phase == TSAIChatDeviceSessionPhaseStartFailureReporting ||
        self.phase == TSAIChatDeviceSessionPhaseActive ||
        self.phase == TSAIChatDeviceSessionPhaseTerminationReporting;
    if (!hasOpenSession) {
        [self.stateLock unlock];
        return;
    }
    self.phase = TSAIChatDeviceSessionPhaseClosedByDevice;
    self.origin = origin;
    self.reportAttempts = 0;
    [self.stateLock unlock];
}

/** 准备启动失败回报 */
- (TSAIChatDeviceSessionReportRequest *)prepareStartFailureWithOrigin:
    (TSAIChatDeviceSessionEndOrigin)origin
                                                                      generation:(NSUInteger)generation {
    return [self prepareReportWithKind:TSAIChatDeviceSessionReportKindStartFailure
                                origin:origin
                            generation:generation
                         expectedPhase:TSAIChatDeviceSessionPhaseStartRequested
                        reportingPhase:TSAIChatDeviceSessionPhaseStartFailureReporting];
}

/** 准备终止回报 */
- (TSAIChatDeviceSessionReportRequest *)prepareTerminationWithOrigin:
    (TSAIChatDeviceSessionEndOrigin)origin
                                                                     generation:(NSUInteger)generation {
    return [self prepareReportWithKind:TSAIChatDeviceSessionReportKindTermination
                                origin:origin
                            generation:generation
                         expectedPhase:TSAIChatDeviceSessionPhaseActive
                        reportingPhase:TSAIChatDeviceSessionPhaseTerminationReporting];
}

/** 完成回报并在失败时最多重试一次 */
- (TSAIChatDeviceSessionReportRequest *)completeReport:
    (TSAIChatDeviceSessionReportRequest *)request
                                                              success:(BOOL)success {
    [self.stateLock lock];
    TSAIChatDeviceSessionPhase expectedPhase =
        request.kind == TSAIChatDeviceSessionReportKindStartFailure
        ? TSAIChatDeviceSessionPhaseStartFailureReporting
        : TSAIChatDeviceSessionPhaseTerminationReporting;
    BOOL isCurrent = self.generation == request.generation &&
        self.phase == expectedPhase &&
        self.reportKind == request.kind &&
        self.reportAttempts == request.attempt;
    if (!isCurrent) {
        [self.stateLock unlock];
        return nil;
    }
    if (success) {
        self.phase = TSAIChatDeviceSessionPhaseTerminated;
        [self.stateLock unlock];
        return nil;
    }
    if (self.reportAttempts >= kTSAIChatDeviceSessionMaximumReportAttempts) {
        self.phase = TSAIChatDeviceSessionPhaseReportFailed;
        [self.stateLock unlock];
        return nil;
    }
    self.reportAttempts += 1;
    TSAIChatDeviceSessionReportRequest *retryRequest =
        [[TSAIChatDeviceSessionReportRequest alloc] initWithGeneration:self.generation
                                                               attempt:self.reportAttempts
                                                                  kind:self.reportKind
                                                                origin:self.origin];
    [self.stateLock unlock];
    return retryRequest;
}

#pragma mark - 私有方法

/** 按指定阶段准备回报请求 */
- (TSAIChatDeviceSessionReportRequest *)prepareReportWithKind:
    (TSAIChatDeviceSessionReportKind)kind
                                                        origin:(TSAIChatDeviceSessionEndOrigin)origin
                                                    generation:(NSUInteger)generation
                                                 expectedPhase:(TSAIChatDeviceSessionPhase)expectedPhase
                                                reportingPhase:(TSAIChatDeviceSessionPhase)reportingPhase {
    [self.stateLock lock];
    BOOL canPrepare = self.generation == generation && self.phase == expectedPhase;
    if (!canPrepare) {
        [self.stateLock unlock];
        return nil;
    }
    self.phase = reportingPhase;
    self.origin = origin;
    self.reportAttempts = 1;
    self.reportKind = kind;
    TSAIChatDeviceSessionReportRequest *request =
        [[TSAIChatDeviceSessionReportRequest alloc] initWithGeneration:self.generation
                                                               attempt:self.reportAttempts
                                                                  kind:kind
                                                                origin:origin];
    [self.stateLock unlock];
    return request;
}

@end
