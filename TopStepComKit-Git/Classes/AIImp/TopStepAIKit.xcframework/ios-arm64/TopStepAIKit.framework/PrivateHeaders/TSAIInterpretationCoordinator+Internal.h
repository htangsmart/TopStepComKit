//
//  TSAIInterpretationCoordinator+Internal.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIInterpretationDefines.h"
#import "TSAIInterpretationRequest.h"
#import "TSAIInterpretationSnapshot.h"
#import "TSAIInterpreterDefines.h"
#import "TSAIStartEligibility.h"

@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Session engine behind `TSAIInterpretationInterface`
 * @chinese `TSAIInterpretationInterface` 背后的会话引擎
 *
 * @discussion
 * [EN]: Owned by `TSAIContext`, one per Context. `start` must be called from the
 *       main thread or a thread that is not blocked by the main thread (it hops to
 *       main synchronously); every other public method may be called from any
 *       thread. State lives on the main thread. The engine
 *       maps the pickup to an audio route, reserves the device session for the
 *       charging case through the VoiceTranslation handler override, drives
 *       the task-level interpreter, mirrors text through
 *       `TSAIDeviceVoiceTranslationTextSender`, and folds every terminal event
 *       into one `endReason`.
 * [CN]: 由 `TSAIContext` 持有，每个 Context 一个。`start` 会同步切到主线程，
 *       不得在被主线程同步等待的队列上调用；其余公开方法可在任意线程调用。
 *       状态只在主线程读写。引擎把拾音设备映射为音频路由，通过 VoiceTranslation
 *       处理器覆盖层为充电仓预留设备会话，驱动 task 级同传，经
 *       `TSAIDeviceVoiceTranslationTextSender` 镜像文本，并把所有终态事件收口为一个 `endReason`。
 */
@interface TSAIInterpretationCoordinator : NSObject

- (instancetype)initWithContext:(TSAIContext *)context NS_DESIGNATED_INITIALIZER;

/** @brief Whether a session is running (Preparing / Listening / Stopping) @chinese 是否有会话进行中 */
@property (nonatomic, assign, readonly) BOOL isSessionActive;

/** @brief Current snapshot @chinese 当前快照 */
@property (nonatomic, strong, readonly) TSAIInterpretationSnapshot *snapshot;

- (NSArray<NSNumber *> *)supportedLanguages;
- (NSArray<NSNumber *> *)availablePickups;
- (TSAIStartEligibility *)eligibilityForRequest:(TSAIInterpretationRequest *)request;

- (nullable NSString *)startWithRequest:(TSAIInterpretationRequest *)request
                              onContent:(nullable TSAIInterpreterContentBlock)onContent
                                onEvent:(nullable TSAIInterpreterEventBlock)onEvent
                             onSnapshot:(nullable TSAIInterpretationSnapshotBlock)onSnapshot
                             completion:(nullable TSAIInterpretationCompletionBlock)completion;

- (void)stopWithSessionId:(NSString *)sessionId;

/** @brief The charging case disconnected @chinese 充电仓断开 */
- (void)handleDeviceDisconnected;

/** @brief The charging case reported an interruption (low battery, incoming call, ...) @chinese 充电仓上报中断（低电量、来电等） */
- (void)handleDeviceInterruptionWithReason:(TSAIDeviceInterruptionReason)reason;

/** @brief End the session because the Context is going away @chinese 因 Context 失活结束会话 */
- (void)invalidate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
