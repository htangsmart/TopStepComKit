//
//  TSAIChatEvent.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

@class TSAIChatIntent;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI chat session-level event type
 * @chinese AI 对话会话级事件类型
 *
 * @discussion
 * [EN]: Session-level state transitions surfaced to the App for UX feedback
 *       (mic animations, AI playback indicators, error toasts). Keeps only
 *       events the App genuinely reacts to — internal pipeline states
 *       (link layer, auth, etc.) are intentionally not exposed.
 * [CN]: 会话级状态变更，供 App 用于 UI 反馈
 *       （话筒动画、AI 播放指示、错误提示等）。
 *       仅保留 App 真正会响应的事件；
 *       内部链路状态（链路层、鉴权等）不暴露。
 */
typedef NS_ENUM(NSInteger, TSAIChatEventType) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIChatEventTypeUnknown                = -1,
    /// 会话已成功启动 (Session started successfully)
    TSAIChatEventTypeSessionStarted         = 1,
    /// VAD 检测到用户开始说话 (VAD detected user speech start)
    TSAIChatEventTypeUserSpeechStarted      = 2,
    /// VAD 检测到用户结束说话 (VAD detected user speech end)
    TSAIChatEventTypeUserSpeechEnded        = 3,
    /// AI 回复音频开始播放 (AI reply audio playback started)
    TSAIChatEventTypeAIPlaybackStarted      = 4,
    /// AI 回复音频正常结束 (AI reply audio playback ended)
    TSAIChatEventTypeAIPlaybackEnded        = 5,
    /// AI 回复音频被用户说话打断 (AI playback interrupted by user speech)
    TSAIChatEventTypeAIPlaybackInterrupted  = 6,
    /// 网络异常 (Network error during the session)
    TSAIChatEventTypeNetworkError           = 7,
    /// 设备 BLE 已断开 (Device BLE disconnected)
    TSAIChatEventTypeBleDisconnected        = 8,
    /// 因长时间无输入会话即将自动结束 (Session about to auto-end due to no input)
    TSAIChatEventTypeAutoEnding             = 9,
    /// 用户输入已结束（手动 / 静默 / 达到上限），等待回复 (Input finished, awaiting reply)
    TSAIChatEventTypeInputFinished          = 10,
    /// 一轮问答完成：回答定稿且播放结束或无播放 (Round completed: answer final and playback ended / none)
    TSAIChatEventTypeRoundCompleted         = 11,
    /**
     * @brief The cloud AI service connection is ready for input
     * @chinese 云端 AI 服务连接就绪，可接收输入
     *
     * @discussion
     * [EN]: Emitted after `SessionStarted` once the vendor reports the cloud
     *       link is connected. The SDK already gates all outbound data on this
     *       internally; Apps may use it for diagnostics or a "connecting" hint.
     * [CN]: `SessionStarted` 之后、厂商回报云端链路已连接时发出。SDK 内部已按此
     *       事件对所有出站数据做闸门；App 可用于诊断或「连接中」提示。
     */
    TSAIChatEventTypeServiceReady           = 12,
    /**
     * @brief Waiting for the App to act on a client-action intent timed out
     * @chinese 等待 App 处理「需客户端补充信息」的意图超时
     *
     * @discussion
     * [EN]: Emitted when a `requiresClientAction` intent (e.g. LocationQuery)
     *       stayed pending for `TSAIChatConfig.intentActionTimeout` without a
     *       replay or an answer. `roundIndex` / `intent` identify the round.
     *       SingleRound: the session then ends with
     *       `TSAIErrorCodeIntentActionRequired`. Continuous: only this round
     *       is given up, the session keeps running.
     * [CN]: `requiresClientAction` 的意图（如 LocationQuery）在
     *       `TSAIChatConfig.intentActionTimeout` 内既没有重发也没有回答时发出，
     *       `roundIndex` / `intent` 标识是哪一轮。单轮：随后会话以
     *       `TSAIErrorCodeIntentActionRequired` 结束；畅聊：仅放弃本轮，会话继续。
     */
    TSAIChatEventTypeIntentActionTimedOut   = 13,
    /**
     * @brief Local playback of an AI reply failed
     * @chinese AI 回复的本机播放失败
     *
     * @discussion
     * [EN]: Only emitted when the SDK plays the reply on the phone (built-in
     *       speaker / system default / A2DP output). Emitted once when one
     *       round's voice fails to finish (that round falls back to text, later
     *       rounds keep playing), or once per session when the output route
     *       itself becomes unusable (the rest of the session is text only).
     *       The session keeps running in both cases; Apps may show a hint.
     *       `roundIndex` is the failed round, or -1 for an output-route failure.
     * [CN]: 仅在 SDK 负责本机播放（手机扬声器 / 系统默认 / A2DP 输出）时发出。
     *       某一轮语音未能播完时发出（该轮仅保留文字，后续轮次照常播放）；
     *       或输出链路本身不可用时整场发出一次（此后仅文字）。两种情况会话都继续，
     *       App 可据此提示用户。`roundIndex` 为失败的轮次，输出链路故障时为 -1。
     */
    TSAIChatEventTypeAIPlaybackFailed       = 14,
};

/**
 * @brief AI chat session-level event
 * @chinese AI 对话会话级事件
 *
 * @discussion
 * [EN]: Delivered through the `onEvent` callback. Distinct from `onContent`
 *       in that events are low-frequency state transitions, while content is
 *       high-frequency streaming data.
 * [CN]: 通过 `onEvent` 回调下发。
 *       与 `onContent` 区分：事件为低频状态变更，内容为高频流式数据。
 */
@interface TSAIChatEvent : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by startChat...)
 * @chinese 任务唯一标识（与 startChat... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Event type
 * @chinese 事件类型
 */
@property (nonatomic, assign) TSAIChatEventType eventType;

/**
 * @brief Event timestamp
 * @chinese 事件发生时间
 */
@property (nonatomic, copy) NSDate *timestamp;

/**
 * @brief Round index this event belongs to, -1 when it is session-level
 * @chinese 事件所属轮次序号，会话级事件为 -1
 *
 * @note
 * [EN]: Currently set for `IntentActionTimedOut` and per-round
 *       `AIPlaybackFailed` only; other events are -1.
 * [CN]: 目前仅 `IntentActionTimedOut` 与按轮次的 `AIPlaybackFailed` 会设置，其它事件为 -1。
 */
@property (nonatomic, assign) NSInteger roundIndex;

/**
 * @brief The pending intent related to this event, if any
 * @chinese 与本事件相关的待处理意图（若有）
 *
 * @note
 * [EN]: Set for `IntentActionTimedOut`; nil for other events.
 * [CN]: `IntentActionTimedOut` 时携带，其它事件为 nil。
 */
@property (nonatomic, strong, nullable) TSAIChatIntent *intent;

@end

NS_ASSUME_NONNULL_END
