//
//  TSFitAITransportEvent.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Notification posted when the Fit AI transport identity changes
 * @chinese Fit AI 传输连接身份变化时发送的通知
 */
FOUNDATION_EXPORT NSNotificationName const TSFitAITransportDidResetNotification;

/**
 * @brief Notification posted before an App-origin AI-chat session opens
 * @chinese App 发起的 AIChat 会话即将打开时发送的通知
 */
FOUNDATION_EXPORT NSNotificationName const TSFitAIChatSessionWillOpenNotification;

/**
 * @brief Notification posted after an App-origin AI-chat session opens
 * @chinese App 发起的 AIChat 会话打开成功后发送的通知
 */
FOUNDATION_EXPORT NSNotificationName const TSFitAIChatSessionDidOpenNotification;

/**
 * @brief Notification posted when the local AI-chat session is closed
 * @chinese 本地 AIChat 会话关闭时发送的通知
 */
FOUNDATION_EXPORT NSNotificationName const TSFitAIChatSessionDidCloseNotification;

/**
 * @brief User-info key containing the AI-chat session request identifier
 * @chinese AIChat 会话请求标识在通知 userInfo 中使用的键
 */
FOUNDATION_EXPORT NSString * const TSFitAIChatSessionRequestIdentifierKey;

/**
 * @brief Notify the Fit event route that an App-origin AI-chat session will open
 * @chinese 通知 Fit 事件链路 App 发起的 AIChat 会话即将打开
 *
 * @param requestIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
FOUNDATION_EXPORT void TSFitPostAIChatSessionWillOpenNotification(
    NSString *requestIdentifier);

/**
 * @brief Notify the Fit event route that an App-origin AI-chat session opened
 * @chinese 通知 Fit 事件链路 App 发起的 AIChat 会话已打开
 *
 * @param requestIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
FOUNDATION_EXPORT void TSFitPostAIChatSessionDidOpenNotification(
    NSString *requestIdentifier);

/**
 * @brief Notify the Fit event route that the current AI-chat session closed
 * @chinese 通知 Fit 事件链路当前 AIChat 会话已关闭
 */
FOUNDATION_EXPORT void TSFitPostAIChatSessionDidCloseNotification(void);

/**
 * @brief Close a matching App-origin AI-chat session boundary
 * @chinese 关闭匹配的 App 发起 AIChat 会话边界
 *
 * @param requestIdentifier
 * EN: Stable identifier of the App-origin request
 * CN: App 发起请求的稳定标识
 */
FOUNDATION_EXPORT void TSFitPostAIChatSessionDidCloseNotificationForRequestIdentifier(
    NSString *requestIdentifier);

NS_ASSUME_NONNULL_END
