//
//  TSAIInterpretationDefines.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

@class TSAIInterpretationSnapshot;
@class TSAIInterpreterReport;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Microphone source of one simultaneous-interpretation session
 * @chinese 一次同声传译会话的拾音设备
 *
 * @discussion
 * [EN]: The pickup decides the audio input channel and whether the charging
 *       case joins the session. Phone and Earbuds never involve the charging
 *       case: no device AI session is reserved and no text is pushed to the
 *       screen. ChargingCase reserves a device session (Opus upload) and mirrors
 *       original / translated text to the screen.
 * [CN]: 拾音设备决定音频输入通道以及充电仓是否参与会话。Phone / Earbuds 不涉及
 *       充电仓：不预留设备 AI 会话，也不向屏端推送文本。ChargingCase 预留设备
 *       会话（Opus 上传）并把原文 / 译文镜像到屏端。
 */
typedef NS_ENUM(NSInteger, TSAIInterpretationPickup) {
    /// @brief Not chosen @chinese 未选择
    TSAIInterpretationPickupUnknown = 0,
    /// @brief Phone built-in microphone @chinese 手机麦克风
    TSAIInterpretationPickupPhone = 1,
    /// @brief Earbuds over SCO @chinese 耳机（SCO）
    TSAIInterpretationPickupEarbuds = 2,
    /// @brief Charging case over Opus @chinese 充电仓（Opus）
    TSAIInterpretationPickupChargingCase = 3,
};

/**
 * @brief Lifecycle state of one simultaneous-interpretation session
 * @chinese 一次同声传译会话的生命周期状态
 */
typedef NS_ENUM(NSInteger, TSAIInterpretationState) {
    /// @brief No session @chinese 无会话
    TSAIInterpretationStateIdle = 0,
    /// @brief Resolving the route, reserving the device and starting the pipeline @chinese 解析路由、预留设备并启动管线
    TSAIInterpretationStatePreparing = 1,
    /// @brief Streaming audio in, text and audio out @chinese 音频流入，文本 / 音频流出
    TSAIInterpretationStateListening = 2,
    /// @brief Flushing the pipeline, finishing text delivery, releasing the device @chinese 冲刷管线、补发文本、释放设备
    TSAIInterpretationStateStopping = 3,
    /// @brief Ended; `endReason` explains why @chinese 已结束，`endReason` 说明原因
    TSAIInterpretationStateEnded = 4,
};

/**
 * @brief Reason why a simultaneous-interpretation session ended
 * @chinese 同声传译会话结束的原因
 */
typedef NS_ENUM(NSInteger, TSAIInterpretationEndReason) {
    /// @brief Not ended yet @chinese 尚未结束
    TSAIInterpretationEndReasonNone = 0,
    /// @brief App asked to stop @chinese App 主动结束
    TSAIInterpretationEndReasonUserStop = 1,
    /// @brief The charging case left the session (key press or screen exit) @chinese 充电仓退出（按键或屏端退出）
    TSAIInterpretationEndReasonDeviceExit = 2,
    /// @brief The charging case disconnected @chinese 充电仓断开连接
    TSAIInterpretationEndReasonDeviceDisconnected = 3,
    /// @brief The network stayed unavailable @chinese 网络异常且未恢复
    TSAIInterpretationEndReasonNetworkError = 4,
    /// @brief The system audio session was interrupted (incoming call, ...) @chinese 系统音频会话被抢占（来电等）
    TSAIInterpretationEndReasonAudioInterrupted = 5,
    /// @brief The AI Context became inactive @chinese AI Context 失活
    TSAIInterpretationEndReasonContextInactive = 6,
    /// @brief Another failure; see the error @chinese 其他失败，见错误对象
    TSAIInterpretationEndReasonFailure = 7,
};

/**
 * @brief Snapshot callback, invoked on the main thread on every state change
 * @chinese 快照回调，每次状态变化在主线程调用
 */
typedef void (^TSAIInterpretationSnapshotBlock)(TSAIInterpretationSnapshot *snapshot);

/**
 * @brief Completion callback, invoked exactly once on the main thread when the session ends
 * @chinese 完成回调，会话结束时在主线程调用一次
 *
 * @discussion
 * [EN]: `report` is nil when the pipeline never produced one (start failure,
 *       disconnect before the first utterance); `snapshot.endReason` and
 *       `snapshot.error` always describe why the session ended.
 * [CN]: 管线未产出报告时（启动失败、首句前断连）`report` 为 nil；
 *       `snapshot.endReason` 与 `snapshot.error` 始终说明结束原因。
 */
typedef void (^TSAIInterpretationCompletionBlock)(TSAIInterpreterReport *_Nullable report,
                                                  TSAIInterpretationSnapshot *snapshot);

NS_ASSUME_NONNULL_END
