//
//  TSAIChatDeviceSessionCoordinator.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/26.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSAIChatDeviceSessionState.h"

@class TSAIChatConfig;
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
 *       own the session lifetime.
 * [CN]: 仅在 AI Context 最终鉴权后绑定，统一管理请求代次与云端任务。
 *       TopStepAIKit 负责能力门禁与设备同步；UI 页面通过通知观察，
 *       不持有会话生命周期。
 */
@interface TSAIChatDeviceSessionCoordinator : NSObject <NSCopying, NSMutableCopying>

/** @brief Shared coordinator @chinese 共享协调器 */
+ (instancetype)sharedInstance;

/** @brief Current session phase @chinese 当前会话阶段 */
@property (nonatomic, assign, readonly) TSAIChatDeviceSessionPhase phase;

/** @brief Current cloud task identifier @chinese 当前云端任务标识 */
@property (nonatomic, copy, nullable, readonly) NSString *currentTaskId;

/** @brief Configuration used by the next device request @chinese 下一次设备请求使用的配置 */
@property (nonatomic, strong, readonly) TSAIChatConfig *config;

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
 * @brief Stop the current session from the App
 * @chinese 由 App 主动停止当前会话
 */
- (void)stopSessionFromApp;

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
