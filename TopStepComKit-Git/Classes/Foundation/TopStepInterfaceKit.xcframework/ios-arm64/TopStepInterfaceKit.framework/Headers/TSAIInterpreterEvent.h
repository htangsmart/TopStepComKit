//
//  TSAIInterpreterEvent.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Simultaneous-interpretation session-level event type
 * @chinese 同声传译会话级事件类型
 *
 * @discussion
 * [EN]: Session-level state transitions surfaced to the App for UX feedback
 *       (mic animations, translation playback indicators, error toasts).
 *       Keeps only events the App genuinely reacts to — internal pipeline
 *       states (link layer, auth, etc.) are intentionally not exposed.
 * [CN]: 会话级状态变更，供 App 用于 UI 反馈
 *       （话筒动画、译文播放指示、错误提示等）。
 *       仅保留 App 真正会响应的事件；
 *       内部链路状态（链路层、鉴权等）不暴露。
 */
typedef NS_ENUM(NSInteger, TSAIInterpreterEventType) {
    /// 未知 / 未设置 (Unknown / unset)
    TSAIInterpreterEventTypeUnknown                   = -1,
    /// 会话已成功启动 (Session started successfully)
    TSAIInterpreterEventTypeSessionStarted            = 1,
    /// VAD 检测到说话人开始说话 (VAD detected speech start)
    TSAIInterpreterEventTypeUtteranceStarted          = 2,
    /// VAD 检测到说话人结束说话 (VAD detected speech end)
    TSAIInterpreterEventTypeUtteranceEnded            = 3,
    /// 自动语言检测完成（详见 detectedLanguage） (Auto language detection finished; see detectedLanguage)
    TSAIInterpreterEventTypeLanguageDetected          = 4,
    /// 译文 TTS 开始播放 (Translation TTS playback started)
    TSAIInterpreterEventTypeTranslationPlaybackStarted = 5,
    /// 译文 TTS 正常结束 (Translation TTS playback ended)
    TSAIInterpreterEventTypeTranslationPlaybackEnded   = 6,
    /// 网络异常 (Network error during the session)
    TSAIInterpreterEventTypeNetworkError              = 7,
    /// 设备 BLE 已断开 (Device BLE disconnected)
    TSAIInterpreterEventTypeBleDisconnected           = 8,
};

/**
 * @brief Simultaneous-interpretation session-level event
 * @chinese 同声传译会话级事件
 *
 * @discussion
 * [EN]: Delivered through the `onEvent` callback. Distinct from `onContent`
 *       in that events are low-frequency state transitions, while content
 *       is high-frequency streaming data.
 *
 *       Most event types only carry `taskId / eventType / timestamp`.
 *       Some types additionally populate:
 *
 *       - `LanguageDetected` → `detectedLanguage` is the resolved source
 *         language of the speaker (after `sourceLanguage = Auto`).
 *       - `UtteranceStarted` / `UtteranceEnded` → `utteranceIndex`
 *         identifies the utterance.
 *
 * [CN]: 通过 `onEvent` 回调下发。
 *       与 `onContent` 区分：事件为低频状态变更，内容为高频流式数据。
 *
 *       大多数事件类型仅携带 `taskId / eventType / timestamp`，
 *       下列类型会额外填充字段：
 *
 *       - `LanguageDetected`：`detectedLanguage` 为说话人源语言
 *         （`sourceLanguage = Auto` 时由后端解析得到）。
 *       - `UtteranceStarted` / `UtteranceEnded`：`utteranceIndex`
 *         标识所属 utterance。
 */
@interface TSAIInterpreterEvent : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by startInterpretation...)
 * @chinese 任务唯一标识（与 startInterpretation... 同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Event type
 * @chinese 事件类型
 */
@property (nonatomic, assign) TSAIInterpreterEventType eventType;

/**
 * @brief Event timestamp
 * @chinese 事件发生时间
 */
@property (nonatomic, copy) NSDate *timestamp;

/**
 * @brief 0-based utterance ordinal this event refers to (utterance-scoped events only)
 * @chinese 本事件所属 utterance 序号（仅 utterance 级事件填充，从 0 开始）
 *
 * @discussion
 * [EN]: Populated for `UtteranceStarted` / `UtteranceEnded`. For other
 *       event types the value is `-1` and should be ignored.
 * [CN]: `UtteranceStarted` / `UtteranceEnded` 时填充；
 *       其他事件类型为 `-1`，请忽略。
 */
@property (nonatomic, assign) NSInteger utteranceIndex;

/**
 * @brief Auto-detected language (LanguageDetected event only)
 * @chinese 自动检测出的语言（仅 LanguageDetected 事件填充）
 *
 * @discussion
 * [EN]: Populated only for `TSAIInterpreterEventTypeLanguageDetected`.
 *       Lets the caller surface the detected language in UI (e.g. "Source:
 *       English (auto)") and decide whether to keep the session or stop
 *       and restart with an explicit `sourceLanguage`. Never
 *       `TSAILanguageAuto` (the event represents the resolved value);
 *       `TSAILanguageUnknown` for non-applicable event types.
 * [CN]: 仅 `TSAIInterpreterEventTypeLanguageDetected` 事件填充。
 *       便于调用方在 UI 上展示检测出的语言（如 "源语言：英语（自动）"），
 *       并据此决定是继续会话，还是 stop 后用显式 `sourceLanguage` 重启。
 *       本字段不会为 `TSAILanguageAuto`（事件代表的就是解析后的值），
 *       非该事件类型时为 `TSAILanguageUnknown`。
 */
@property (nonatomic, assign) TSAILanguage detectedLanguage;

@end

NS_ASSUME_NONNULL_END
