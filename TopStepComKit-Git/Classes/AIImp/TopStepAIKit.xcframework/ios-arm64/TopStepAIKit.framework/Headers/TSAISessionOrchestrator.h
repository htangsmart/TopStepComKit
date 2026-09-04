//
//  TSAISessionOrchestrator.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIContractDefines.h"

@class TSAIStartEligibility;
@class TSAIStartRequest;
@protocol TSAIDeviceAISessionBridge;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Transaction states for one device-coordinated AI session
 * @chinese 单次设备协同 AI 会话的事务状态
 */
typedef NS_ENUM(NSUInteger, TSAISessionOrchestratorState) {
    /// @brief No reserved transaction @chinese 当前没有已占位事务
    TSAISessionOrchestratorStateIdle = 0,
    /// @brief An eligible device request is waiting for App preparation
    /// @chinese 合格的设备请求正在等待 App 准备
    TSAISessionOrchestratorStatePendingDevice,
    /// @brief Local resources are being prepared @chinese 正在准备本地资源
    TSAISessionOrchestratorStatePreparing,
    /// @brief The prepared request is synchronizing with the device @chinese 已准备请求正在与设备同步
    TSAISessionOrchestratorStateSynchronizing,
    /// @brief Local and device sides are both ready @chinese 本地与设备两侧均已就绪
    TSAISessionOrchestratorStateActive,
    /// @brief The device result is uncertain and the reservation is retained
    /// @chinese 设备结果不确定并继续保留占位
    TSAISessionOrchestratorStateReconciling,
};

/**
 * @brief Fixed response deadline for a pending device-origin request
 * @chinese 设备发起请求等待响应的固定期限
 */
FOUNDATION_EXPORT NSTimeInterval const TSAISessionOrchestratorDevicePendingDeadline;

/**
 * @brief Side-effect-free eligibility evaluator invoked on the orchestrator queue
 * @chinese 在编排器队列上调用的无副作用资格校验器
 *
 * @param request
 * EN: Complete immutable request to evaluate
 * CN: 需要校验的完整不可变请求
 *
 * @return
 * EN: Binary eligibility result; nil is treated as unsupported
 * CN: 二态资格结果；nil 按不支持处理
 */
typedef TSAIStartEligibility * _Nullable (^TSAISessionEligibilityEvaluator)(
    TSAIStartRequest *request);

/**
 * @brief Notification that an eligible device request may start local preparation
 * @chinese 合格设备请求可以开始本地准备的通知
 *
 * @param request
 * EN: Reserved device-origin request
 * CN: 已占位的设备发起请求
 */
typedef void (^TSAISessionDevicePreparationHandler)(TSAIStartRequest *request);

/**
 * @brief Notify that a pending device preparation was aborted before App consumption
 * @chinese 通知设备 pending 准备在 App 消费前已被终止
 * @param request EN: Aborted device request. CN: 已终止的设备请求。
 * @param error EN: Exact abort reason. CN: 精确的终止原因。
 */
typedef void (^TSAISessionPendingDeviceAbortHandler)(TSAIStartRequest *request,
                                                      NSError *error);

/**
 * @brief Completion returning the effective request reserved for preparation
 * @chinese 返回已为准备阶段占位的实际请求
 *
 * @param preparedRequest
 * EN: Effective request, or nil on failure
 * CN: 实际请求，失败时为 nil
 *
 * @param error
 * EN: Failure reason, or nil on success
 * CN: 失败原因，成功时为 nil
 */
typedef void (^TSAISessionRequestPreparationCompletion)(
    TSAIStartRequest * _Nullable preparedRequest,
    NSError * _Nullable error);

/**
 * @brief Notify that an App-controlled active request has definitively finished
 * @chinese 通知一个由 App 控制的活动请求已被最终结束
 * @param request EN: Finished request. CN: 已结束的请求。
 */
typedef void (^TSAISessionFinishHandler)(TSAIStartRequest *request);

/**
 * @brief Atomic transaction kernel for direction-aware device AI sessions
 * @chinese 面向双向设备 AI 会话的原子事务内核
 *
 * @discussion
 * [EN]: Evaluation, reservation and state transitions run on one private serial
 *       queue. Handlers and completions are invoked on that queue; callers own
 *       local resource preparation and rollback and must not perform UI work there.
 * [CN]: 资格校验、占位与状态迁移均在同一私有串行队列执行。Handler 与 completion
 *       也在该队列回调；调用方负责本地资源准备和回滚，且不得直接执行 UI 操作。
 */
@interface TSAISessionOrchestrator : NSObject

/**
 * @brief Internal final-finish observer, including a successful background retry
 * @chinese 最终结束观察者，包含后台重试成功的情况
 */
@property (nonatomic, copy, nullable) TSAISessionFinishHandler requestDidFinishHandler;

/**
 * @brief Internal observer used to roll back pending-only local preparation
 * @chinese 用于回滚仅属于 pending 阶段本地准备的内部观察者
 */
@property (nonatomic, copy, nullable)
    TSAISessionPendingDeviceAbortHandler pendingDeviceRequestDidAbortHandler;

/** @brief Current thread-safe transaction state @chinese 当前线程安全的事务状态 */
@property (nonatomic, assign, readonly) TSAISessionOrchestratorState state;

/**
 * @brief Thread-safe snapshot of the pending device request
 * @chinese 待处理设备请求的线程安全快照
 */
@property (nonatomic, copy, readonly, nullable) TSAIStartRequest *pendingDeviceStartRequest;

/**
 * @brief Return the pending device request for one use case
 * @chinese 返回指定用例的待处理设备请求
 *
 * @param useCase
 * EN: Business use case to match
 * CN: 需要匹配的业务用例
 *
 * @return
 * EN: Thread-safe pending snapshot, or nil when it does not match
 * CN: 线程安全的 pending 快照；不匹配时返回 nil
 */
- (nullable TSAIStartRequest *)pendingDeviceRequestForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Return the current reserved request for one use case
 * @chinese 返回指定用例当前已占位的请求
 * @param useCase EN: Business use case to match. CN: 需要匹配的业务用例。
 * @return EN: Thread-safe reserved snapshot, or nil when unmatched. CN: 线程安全的占位快照；不匹配时返回 nil。
 */
- (nullable TSAIStartRequest *)currentRequestForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Return whether a request owns the current reservation in one exact state
 * @chinese 返回请求是否在指定状态下持有当前占位
 * @param request EN: Request to match. CN: 需要匹配的请求。
 * @param state EN: Exact transaction state. CN: 精确事务状态。
 * @return EN: YES when request identity and state match atomically. CN: 请求身份与状态原子匹配时返回 YES。
 */
- (BOOL)request:(TSAIStartRequest *)request
    ownsReservationInState:(TSAISessionOrchestratorState)state;

/**
 * @brief Create an orchestrator with its transport and live eligibility evaluator
 * @chinese 使用设备传输与实时资格校验器创建编排器
 *
 * @param deviceSessionBridge
 * EN: Direction-aware device session transport
 * CN: 带发起方向的设备会话传输
 *
 * @param eligibilityEvaluator
 * EN: Evaluator called before every reservation or pending-request consumption
 * CN: 每次占位或消费 pending 请求前调用的资格校验器
 *
 * @return
 * EN: Initialized orchestrator
 * CN: 初始化后的编排器
 */
- (instancetype)initWithDeviceSessionBridge:(id<TSAIDeviceAISessionBridge>)deviceSessionBridge
                       eligibilityEvaluator:(TSAISessionEligibilityEvaluator)eligibilityEvaluator
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Evaluate and atomically reserve a device-origin request
 * @chinese 校验并原子占位设备发起请求
 *
 * @param request
 * EN: Original device-origin request
 * CN: 原始设备发起请求
 *
 * @param preparationHandler
 * EN: Called only after eligibility and reservation succeed
 * CN: 仅资格校验与占位成功后调用
 */
- (void)receiveDeviceStartRequest:(TSAIStartRequest *)request
               preparationHandler:(TSAISessionDevicePreparationHandler)preparationHandler;

/**
 * @brief Reserve an App proposal or consume its matching device pending request
 * @chinese 占位 App 提案，或消费与其匹配的设备 pending 请求
 *
 * @discussion
 * [EN]: The completion is always invoked synchronously before this method returns.
 * [CN]: completion 始终在本方法返回前同步调用。
 *
 * @param request
 * EN: Proposed request; matching uses request identifier, use case and scene
 * CN: 提案请求；按请求标识、用例和场景匹配
 *
 * @param completion
 * EN: Effective reserved request or exact failure
 * CN: 实际占位请求或准确失败原因
 */
- (void)prepareRequestFromAppCandidate:(TSAIStartRequest *)request
                             completion:(TSAISessionRequestPreparationCompletion)completion;

/**
 * @brief Synchronize a locally prepared request with the device
 * @chinese 将本地已准备请求与设备同步
 *
 * @param request
 * EN: Effective request returned by preparation
 * CN: 准备阶段返回的实际请求
 *
 * @param completion
 * EN: Succeeds only after both sides are ready
 * CN: 仅双端均就绪后成功
 */
- (void)synchronizePreparedRequest:(TSAIStartRequest *)request
                         completion:(TSAICompletionBlock)completion;

/**
 * @brief Release a prepared reservation after the caller rolls back local resources
 * @chinese 调用方回滚本地资源后释放准备阶段占位
 *
 * @param request
 * EN: Current prepared request
 * CN: 当前已准备请求
 *
 * @param failure
 * EN: Failure used for device rejection mapping and diagnostics
 * CN: 用于映射设备拒绝与诊断的失败原因
 *
 * @param completion
 * EN: Optional local reservation-release result
 * CN: 可选的本地占位释放结果
 */
- (void)failPreparedRequest:(TSAIStartRequest *)request
                    failure:(NSError *)failure
                 completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Finish the active transaction with direction-safe device cleanup
 * @chinese 以方向安全的设备清理结束活动事务
 *
 * @param request
 * EN: Current active request
 * CN: 当前活动请求
 *
 * @param deviceAlreadyEnded
 * EN: YES when the device has already stopped or exited
 * CN: 设备已停止或退出时传 YES
 *
 * @param completion
 * EN: Optional finish result
 * CN: 可选的结束结果
 */
- (void)finishActiveRequest:(TSAIStartRequest *)request
         deviceAlreadyEnded:(BOOL)deviceAlreadyEnded
                  completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Consume a device stop or exit without echoing an end command
 * @chinese 消费设备停止或退出事件且不回声发送结束指令
 *
 * @discussion
 * [EN]: Matching transaction state is cleared synchronously before this method returns.
 * [CN]: 匹配事务的状态会在本方法返回前同步清理完成。
 *
 * @param useCase
 * EN: Business use case reported by the device event
 * CN: 设备事件报告的业务用例
 */
- (void)handleDeviceEndedForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Release the device input lease after natural single-round completion
 * @chinese 单轮输入自然完成后释放设备输入租约
 * @param useCase EN: Business use case whose input completed. CN: 输入已完成的业务用例。
 * @discussion EN: This does not represent cancellation and must not trigger local termination.
 *             CN: 该事件不表示取消，不得触发本地终止。
 */
- (void)handleDeviceInputCompletedForUseCase:(TSAIUseCase)useCase;

/**
 * @brief Synchronously invalidate the current transaction and all late callbacks
 * @chinese 同步使当前事务及全部迟到回调失效
 *
 * @discussion
 * [EN]: The reservation and callback generation are invalid before this method returns.
 * [CN]: 本方法返回前，占位与回调代次已经失效。
 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
