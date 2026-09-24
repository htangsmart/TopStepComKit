//
//  TSAIInterpretationInterface.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"
#import "TSAIInterpretationDefines.h"
#import "TSAIInterpretationRequest.h"
#import "TSAIInterpretationSnapshot.h"
#import "TSAIInterpreterContent.h"
#import "TSAIInterpreterDefines.h"
#import "TSAIInterpreterEvent.h"
#import "TSAIInterpreterReport.h"
#import "TSAIStartEligibility.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Session-level simultaneous interpretation
 * @chinese 会话级 AI 同声传译
 *
 * @discussion
 * [EN]: One object owns the whole session: pickup → audio route, device
 *       coordination for the charging case, screen text mirroring, TTS
 *       routing, and the folding of device / network / provider events into
 *       a single `endReason`. The App collects intent, calls `start`, renders
 *       snapshots and content, and calls `stop`. It never talks to the device
 *       session APIs or the task-level `TSAIInterpreterInterface` itself.
 *
 *       Compared with the task-level interface:
 *         - `startWithRequest:` reserves the device session when the pickup is
 *           the charging case, and skips it for phone / earbuds;
 *         - device exit, disconnect and unrecovered network errors terminate
 *           the pipeline and surface once through `completion`;
 *         - `onContent` keeps the `TSAIInterpreterContent` contract (three
 *           streams paired by `utteranceIndex`).
 *
 *       Session parameters are immutable; switching the pickup or a language
 *       means stop + start.
 *
 * [CN]: 一个对象拥有整个会话：拾音设备 → 音频路由、充电仓的设备协同、屏端文本
 *       镜像、TTS 路由，以及把设备 / 网络 / Provider 事件收口为单一 `endReason`。
 *       App 只负责收集意图、调用 `start`、渲染快照与内容、调用 `stop`，
 *       不再直接使用设备会话接口或 task 级的 `TSAIInterpreterInterface`。
 *
 *       相对 task 级接口：
 *         - `startWithRequest:` 在拾音为充电仓时预留设备会话，手机 / 耳机时跳过；
 *         - 设备退出、断连、未恢复的网络异常都会终止管线并通过 `completion` 上报一次；
 *         - `onContent` 沿用 `TSAIInterpreterContent` 契约（三路按 `utteranceIndex` 配对）。
 *
 *       会话参数不可中途修改；更换拾音设备或语言需 stop 后重新 start。
 */
@protocol TSAIInterpretationInterface <NSObject>

/**
 * @brief Languages the current provider can interpret between
 * @chinese 当前 Provider 支持的同传语言
 *
 * @return
 * EN: Concrete `TSAILanguage` values wrapped in NSNumber, ascending; never contains Auto / Unknown
 * CN: 以 NSNumber 包装的具体 `TSAILanguage`，升序；不含 Auto / Unknown
 */
- (NSArray<NSNumber *> *)supportedLanguages;

/**
 * @brief Pickups that can start right now
 * @chinese 当前可用的拾音设备
 *
 * @return
 * EN: `TSAIInterpretationPickup` values wrapped in NSNumber, filtered by the live route capabilities
 * CN: 以 NSNumber 包装的 `TSAIInterpretationPickup`，按实时路由能力过滤
 */
- (NSArray<NSNumber *> *)availablePickups;

/**
 * @brief Check whether a request could start without side effects
 * @chinese 无副作用地检查请求当前能否启动
 *
 * @param request
 * EN: Candidate request
 * CN: 待检查的请求
 *
 * @return
 * EN: Supported, or the concrete error the start would fail with
 * CN: 支持，或启动将失败的具体错误
 */
- (TSAIStartEligibility *)eligibilityForRequest:(TSAIInterpretationRequest *)request;

/**
 * @brief Start a session
 * @chinese 启动一次会话
 *
 * @param request
 * EN: Session parameters
 * CN: 会话参数
 *
 * @param onContent
 * EN: Original / translated text and TTS audio chunks; main thread
 * CN: 原文 / 译文 / TTS 音频片段；主线程
 *
 * @param onEvent
 * EN: Low-frequency interpreter events, forwarded for logging; main thread
 * CN: 低频同传事件，透传供日志使用；主线程
 *
 * @param onSnapshot
 * EN: State-change callback; main thread
 * CN: 状态变化回调；主线程
 *
 * @param completion
 * EN: Called exactly once when the session ends, with the final report when one exists
 * CN: 会话结束时调用一次，有报告时携带最终报告
 *
 * @return
 * EN: Session id, or nil when the request fails validation. A request that passes
 *     validation but fails to start still returns its session id; `completion`
 *     fires in both cases with the reason
 * CN: 会话 id；请求校验失败时返回 nil。校验通过但启动失败时仍返回会话 id；
 *     两种情况下 `completion` 都会带原因回调
 */
- (nullable NSString *)startWithRequest:(TSAIInterpretationRequest *)request
                              onContent:(nullable TSAIInterpreterContentBlock)onContent
                                onEvent:(nullable TSAIInterpreterEventBlock)onEvent
                             onSnapshot:(nullable TSAIInterpretationSnapshotBlock)onSnapshot
                             completion:(nullable TSAIInterpretationCompletionBlock)completion;

/**
 * @brief Stop the session; idempotent
 * @chinese 结束会话；幂等
 *
 * @param sessionId
 * EN: Session id returned by start; other ids are ignored
 * CN: start 返回的会话 id；其他 id 被忽略
 *
 * @discussion
 * [EN]: Flushes the pipeline, delivers outstanding screen text, releases the
 *       device, then fires `completion` with `endReason = UserStop`.
 * [CN]: 冲刷管线、补发屏端文本、释放设备，然后以 `endReason = UserStop` 回调 `completion`。
 */
- (void)stopWithSessionId:(NSString *)sessionId;

/**
 * @brief Current snapshot
 * @chinese 当前快照
 */
@property (nonatomic, strong, readonly) TSAIInterpretationSnapshot *snapshot;

@end

NS_ASSUME_NONNULL_END
