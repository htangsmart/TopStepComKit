//
//  TSAIInterpretationSnapshot.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIInterpretationDefines.h"

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable view of one simultaneous-interpretation session
 * @chinese 一次同声传译会话的不可变快照
 *
 * @discussion
 * [EN]: Published on the main thread whenever the session state changes. The
 *       App renders the snapshot; it never keeps its own copy of the session
 *       state. `endReason` and `error` are meaningful only when `state` is
 *       `Ended`.
 * [CN]: 每次会话状态变化时在主线程发布。App 只渲染快照，不再自行维护会话状态。
 *       `endReason` 与 `error` 仅在 `state == Ended` 时有意义。
 */
@interface TSAIInterpretationSnapshot : NSObject

/**
 * @brief Session identifier returned by start
 * @chinese start 返回的会话标识
 */
@property (nonatomic, copy, readonly, nullable) NSString *sessionId;

/**
 * @brief Lifecycle state
 * @chinese 生命周期状态
 */
@property (nonatomic, assign, readonly) TSAIInterpretationState state;

/**
 * @brief Pickup chosen for this session
 * @chinese 本会话选定的拾音设备
 */
@property (nonatomic, assign, readonly) TSAIInterpretationPickup pickup;

/**
 * @brief Audio route resolved by the SDK; nil before Preparing completes
 * @chinese SDK 解析出的音频路由；Preparing 完成前为 nil
 */
@property (nonatomic, copy, readonly, nullable) TSAIAudioRouteConfiguration *resolvedRoute;

/**
 * @brief Whether the charging case joins this session (pickup == ChargingCase)
 * @chinese 充电仓是否参与本会话（pickup == ChargingCase）
 */
@property (nonatomic, assign, readonly) BOOL involvesChargingCase;

/**
 * @brief Interpreter task id echoed in every content / event payload; nil until the pipeline starts
 * @chinese 每个 content / event 载荷回填的同传任务 id；管线启动前为 nil
 */
@property (nonatomic, copy, readonly, nullable) NSString *taskId;

/**
 * @brief Wall-clock start of the session
 * @chinese 会话开始时间
 */
@property (nonatomic, copy, readonly, nullable) NSDate *startDate;

/**
 * @brief Why the session ended; `None` while running
 * @chinese 结束原因；运行中为 `None`
 */
@property (nonatomic, assign, readonly) TSAIInterpretationEndReason endReason;

/**
 * @brief Failure detail when `endReason` is not `UserStop`
 * @chinese `endReason` 非 `UserStop` 时的失败详情
 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 * @brief Build an immutable snapshot; used by the SDK, Apps only read snapshots
 * @chinese 构造不可变快照；由 SDK 使用，App 只读取快照
 */
+ (instancetype)snapshotWithSessionId:(nullable NSString *)sessionId
                                state:(TSAIInterpretationState)state
                               pickup:(TSAIInterpretationPickup)pickup
                        resolvedRoute:(nullable TSAIAudioRouteConfiguration *)resolvedRoute
                               taskId:(nullable NSString *)taskId
                            startDate:(nullable NSDate *)startDate
                            endReason:(TSAIInterpretationEndReason)endReason
                                error:(nullable NSError *)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
