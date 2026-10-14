//
//  TSAIChatDeviceSessionCoordinator.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "TSAIChatDeviceSessionState.h"

#import <TopStepAIKit/TopStepAIKit.h>

@class TSAIChatContent;
@class TSAIChatEvent;
@class TSAIChatReport;
@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidRequestPresentationNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidChangeNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidReceiveContentNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidReceiveEventNotification;
FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidCompleteNotification;
/** 设备唤醒因已有会话被忽略（需求 B8） */
FOUNDATION_EXTERN NSNotificationName const TSAIChatDeviceSessionDidIgnoreDeviceRequestNotification;

FOUNDATION_EXTERN NSString * const TSAIChatDeviceSessionPhaseUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIChatDeviceSessionContentUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIChatDeviceSessionEventUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIChatDeviceSessionReportUserInfoKey;
FOUNDATION_EXTERN NSString * const TSAIChatDeviceSessionErrorUserInfoKey;

/**
 * @brief Process-wide coordinator for App- and device-initiated AI chat
 * @chinese App 与设备发起 AI 对话的进程级协调器
 *
 * @discussion
 * [EN]: Binds only after the AI context is authenticated. It owns the device
 *       request generation and cloud task. TopStepAIKit owns capability gating
 *       and device synchronization. UI pages observe notifications and never
 *       own the session lifetime. A device-initiated session is always an AI
 *       flow (Continuous) with charging-case pick-up and playback (Opus / Opus);
 *       the flow line's audio preference is switched to the case accordingly.
 * [CN]: 仅在 AI Context 最终鉴权后绑定，统一管理请求代次与云端任务。
 *       TopStepAIKit 负责能力门禁与设备同步；UI 页面通过通知观察，
 *       不持有会话生命周期。设备发起的会话固定为 AI 畅聊（Continuous），
 *       拾音与播放固定为耳机仓（Opus / Opus），并把 AI 畅聊线路的音频偏好切到耳机仓。
 */
@interface TSAIChatDeviceSessionCoordinator : NSObject <NSCopying, NSMutableCopying>

/** @brief Shared coordinator @chinese 共享协调器 */
+ (instancetype)sharedInstance;

/** @brief Current session phase @chinese 当前会话阶段 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionPhase phase;

/** @brief Current cloud task identifier @chinese 当前云端任务标识 */
@property (nonatomic, copy, nullable, readonly) NSString *currentTaskId;

/** @brief Base configuration (agent / prompt / timeouts) edited by the config sheet; its route is overridden by the line's `TSAIChatAudioPreference` @chinese 基础配置（Agent / prompt / 超时），由配置弹层编辑；路由由该线路（对话 / 畅聊）各自的 `TSAIChatAudioPreference` 决定 */
@property (nonatomic, strong, readonly) TSAIChatConfig *config;

/** @brief Configuration of the session in flight (nil when idle) @chinese 当前进行中会话的配置（空闲时为 nil） */
@property (nonatomic, strong, nullable, readonly) TSAIChatConfig *activeSessionConfig;

/** @brief Whether the session in flight was started by the device @chinese 当前会话是否由设备发起 */
@property (nonatomic, assign, readonly) BOOL activeSessionDeviceInitiated;

/** @brief Non-audio content history for the current session @chinese 当前会话的非音频内容历史 */
@property (nonatomic, copy, readonly) NSArray<TSAIChatContent *> *contentHistory;

/** @brief Event history for the current session @chinese 当前会话的事件历史 */
@property (nonatomic, copy, readonly) NSArray<TSAIChatEvent *> *eventHistory;

/** @brief Latest final report @chinese 最近一次最终报告 */
@property (nonatomic, strong, nullable, readonly) TSAIChatReport *lastReport;

/** @brief Latest completion error @chinese 最近一次完成错误 */
@property (nonatomic, strong, nullable, readonly) NSError *lastError;

/**
 * @brief Bind an authenticated AI context and register device events
 * @chinese 绑定已鉴权的 AI Context 并注册设备事件
 * @param context EN: Active authenticated context. CN: 已激活并鉴权的 Context。
 */
- (void)bindAuthenticatedContext:(TSAIContext *)context;

/**
 * @brief Unbind a context that is no longer usable
 * @chinese 解绑已不可用的 Context
 * @param context EN: Context to unbind. CN: 要解绑的 Context。
 */
- (void)unbindContext:(TSAIContext *)context;

/**
 * @brief Update the configuration for the next device request
 * @chinese 更新下一次设备请求使用的配置
 * @param config EN: New chat configuration. CN: 新的对话配置。
 */
- (void)updateConfig:(TSAIChatConfig *)config;

/**
 * @brief Start an App-initiated AI chat session
 * @chinese 启动一次 App 发起的 AI 对话会话
 *
 * @discussion
 * [EN]: The assistant Adapter performs the atomic eligibility check and
 *       synchronizes the device before the session becomes active.
 * [CN]: Assistant Adapter 在会话进入活动态前执行原子资格校验并同步设备。
 */
- (void)startSessionFromApp;

/**
 * @brief Start an App-initiated session with an explicit configuration
 * @chinese 以指定配置启动一次 App 发起的会话
 * @param config EN: Session configuration (mode / route / input rules). CN: 本次会话配置（模式 / 路由 / 输入规则）。
 */
- (void)startSessionFromAppWithConfig:(TSAIChatConfig *)config;

/**
 * @brief Stop the current session from the App
 * @chinese 由 App 主动停止当前会话
 */
- (void)stopSessionFromApp;

/**
 * @brief Finish the current input (release in press-to-talk)
 * @chinese 结束本次输入（按住说话松手）
 */
- (void)finishInputFromApp;

/**
 * @brief Send a text question into the active session
 * @chinese 向当前会话发送文字提问
 * @param text EN: Question text. CN: 问题文本。
 * @return EN: Whether accepted. CN: 是否受理。
 */
- (BOOL)sendTextFromApp:(NSString *)text;

/**
 * @brief Replay the round waiting for client-supplied context (e.g. after obtaining a location)
 * @chinese 重发等待客户端补充信息的那一轮（如取得定位之后）
 * @param text EN: Replay text containing the supplementary context and the original question. CN: 含补充信息与原问题的重发文本。
 * @return EN: Whether accepted. CN: 是否受理。
 */
- (BOOL)replayPendingIntentRoundFromApp:(NSString *)text;

/**
 * @brief Update the user's location in the AI context
 * @chinese 更新 AI 上下文中的用户位置
 * @param location EN: Current location, nil clears it. CN: 当前位置，nil 表示清除。
 * @discussion
 * [EN]: Forwarded to `-[TSAIContext updateCurrentLocation:]`; cached locally and re-applied when a context is bound later.
 * [CN]: 转发到 `-[TSAIContext updateCurrentLocation:]`；本地缓存，之后绑定 Context 时补发。
 */
- (void)updateCurrentLocationFromApp:(nullable CLLocation *)location;

/**
 * @brief Interrupt the AI reply playback
 * @chinese 打断 AI 回复播放
 */
- (void)interruptPlaybackFromApp;

/**
 * @brief Whether a session is starting or active
 * @chinese 是否有会话在启动中或进行中
 */
- (BOOL)isSessionActive;

/**
 * @brief Whether the bound headset is connected and ready
 * @chinese 已绑定的耳机是否连接就绪
 */
- (BOOL)isHeadsetConnected;

/**
 * @brief Build a session configuration from the base config
 * @chinese 以基础配置构造一次会话的配置
 * @param mode EN: Conversation mode. CN: 会话模式。
 * @param voiceInput EN: YES for voice (input per the line's `TSAIChatAudioPreference`), NO for text-only (`InputChannelNone`). CN: YES 为语音（拾音按该线路的 `TSAIChatAudioPreference`），NO 为纯文本（`InputChannelNone`）。
 * @param endsInputOnSilence EN: Single-round silence rule. CN: 单轮静默是否算说完。
 */
- (TSAIChatConfig *)sessionConfigForMode:(TSAIChatConversationMode)mode
                              voiceInput:(BOOL)voiceInput
                      endsInputOnSilence:(BOOL)endsInputOnSilence;

/**
 * @brief Whether the chat interface is ready to receive a start action
 * @chinese 对话接口当前是否可接收启动操作
 * @return
 * EN: YES when the authenticated Context and assistant route are ready.
 * CN: 已鉴权 Context 与 Assistant 路由就绪时返回 YES。
 */
- (BOOL)isChatInterfaceReady;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
