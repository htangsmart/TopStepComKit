//
//  TSAIChatEvent.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>

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

@end

NS_ASSUME_NONNULL_END
