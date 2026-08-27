//
//  TSAIChatDeviceSessionState.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device-initiated AI chat session phase
 * @chinese 设备发起 AI 对话的会话阶段
 */
typedef NS_ENUM(NSInteger, TSAIChatDeviceSessionPhase) {
    TSAIChatDeviceSessionPhaseIdle = 0,
    TSAIChatDeviceSessionPhaseStartRequested,
    TSAIChatDeviceSessionPhaseStartFailureReporting,
    TSAIChatDeviceSessionPhaseActive,
    TSAIChatDeviceSessionPhaseTerminationReporting,
    TSAIChatDeviceSessionPhaseTerminated,
    TSAIChatDeviceSessionPhaseClosedByDevice,
    TSAIChatDeviceSessionPhaseReportFailed,
};

/**
 * @brief Device AI chat session end origin
 * @chinese 设备 AI 对话会话结束来源
 */
typedef NS_ENUM(NSInteger, TSAIChatDeviceSessionEndOrigin) {
    TSAIChatDeviceSessionEndOriginNone = 0,
    TSAIChatDeviceSessionEndOriginDevice,
    TSAIChatDeviceSessionEndOriginApp,
    TSAIChatDeviceSessionEndOriginAutoTimeout,
    TSAIChatDeviceSessionEndOriginRuntimeError,
    TSAIChatDeviceSessionEndOriginBleDisconnected,
};

/**
 * @brief Device session report kind
 * @chinese 设备会话回报类型
 */
typedef NS_ENUM(NSInteger, TSAIChatDeviceSessionReportKind) {
    TSAIChatDeviceSessionReportKindStartFailure = 0,
    TSAIChatDeviceSessionReportKindTermination,
};

/**
 * @brief Immutable device session report request
 * @chinese 不可变的设备会话回报请求
 */
@interface TSAIChatDeviceSessionReportRequest : NSObject

/** @brief Session generation @chinese 会话代次 */
@property (nonatomic, assign, readonly) NSUInteger generation;

/** @brief Report attempt, starting at one @chinese 回报次数，从一开始 */
@property (nonatomic, assign, readonly) NSUInteger attempt;

/** @brief Report kind @chinese 回报类型 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionReportKind kind;

/** @brief Session end origin @chinese 会话结束来源 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionEndOrigin origin;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Thread-safe state machine for device-initiated AI chat
 * @chinese 设备发起 AI 对话的线程安全状态机
 */
@interface TSAIChatDeviceSessionState : NSObject

/** @brief Current session generation @chinese 当前会话代次 */
@property (nonatomic, assign, readonly) NSUInteger generation;

/** @brief Current session phase @chinese 当前会话阶段 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionPhase phase;

/** @brief Current end origin @chinese 当前结束来源 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionEndOrigin origin;

/** @brief Current report attempt count @chinese 当前回报尝试次数 */
@property (nonatomic, assign, readonly) NSUInteger reportAttempts;

/**
 * @brief Begin a new device start request
 * @chinese 开始新的设备启动请求
 * @param generation EN: Receives the accepted generation. CN: 接收获准的会话代次。
 * @return EN: YES when accepted. CN: 接受请求时返回 YES。
 */
- (BOOL)beginDeviceStartWithGeneration:(nullable NSUInteger *)generation;

/**
 * @brief Mark the cloud AI session as started
 * @chinese 标记云端 AI 会话已启动
 * @param generation EN: Target generation. CN: 目标会话代次。
 * @return EN: YES when the transition is accepted. CN: 状态转换成功时返回 YES。
 */
- (BOOL)markAIStartedForGeneration:(NSUInteger)generation;

/**
 * @brief Check whether a returned task is still accepted
 * @chinese 检查返回的任务是否仍可接受
 * @param generation EN: Target generation. CN: 目标会话代次。
 * @return EN: YES when the task belongs to the active start. CN: 任务仍属于当前启动流程时返回 YES。
 */
- (BOOL)canAcceptTaskForGeneration:(NSUInteger)generation;

/**
 * @brief Mark the session as closed by the device side
 * @chinese 标记会话已由设备侧关闭
 * @param origin EN: Device-side close origin. CN: 设备侧关闭来源。
 */
- (void)markClosedByDeviceWithOrigin:(TSAIChatDeviceSessionEndOrigin)origin;

/**
 * @brief Prepare an exactly-once start-failure report
 * @chinese 准备一次性启动失败回报
 * @param origin EN: Failure origin. CN: 失败来源。
 * @param generation EN: Target generation. CN: 目标会话代次。
 * @return EN: Report request or nil when no report is needed. CN: 回报请求；无需回报时为 nil。
 */
- (nullable TSAIChatDeviceSessionReportRequest *)prepareStartFailureWithOrigin:
    (TSAIChatDeviceSessionEndOrigin)origin
                                                                      generation:(NSUInteger)generation;

/**
 * @brief Prepare an exactly-once termination report
 * @chinese 准备一次性终止回报
 * @param origin EN: Termination origin. CN: 终止来源。
 * @param generation EN: Target generation. CN: 目标会话代次。
 * @return EN: Report request or nil when no report is needed. CN: 回报请求；无需回报时为 nil。
 */
- (nullable TSAIChatDeviceSessionReportRequest *)prepareTerminationWithOrigin:
    (TSAIChatDeviceSessionEndOrigin)origin
                                                                     generation:(NSUInteger)generation;

/**
 * @brief Complete a report attempt and optionally create one retry
 * @chinese 完成一次回报，并在需要时创建一次重试
 * @param request EN: Completed request. CN: 已完成的请求。
 * @param success EN: Whether transport succeeded. CN: 传输是否成功。
 * @return EN: Retry request or nil. CN: 重试请求；无需重试时为 nil。
 */
- (nullable TSAIChatDeviceSessionReportRequest *)completeReport:
    (TSAIChatDeviceSessionReportRequest *)request
                                                              success:(BOOL)success;

@end

NS_ASSUME_NONNULL_END
