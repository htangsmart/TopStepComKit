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
 * @brief Notification posted when the local AI-chat session is closed
 * @chinese 本地 AIChat 会话关闭时发送的通知
 */
FOUNDATION_EXPORT NSNotificationName const TSFitAIChatSessionDidCloseNotification;

/**
 * @brief Notify the Fit event route that the current AI-chat session closed
 * @chinese 通知 Fit 事件链路当前 AIChat 会话已关闭
 */
FOUNDATION_EXPORT void TSFitPostAIChatSessionDidCloseNotification(void);

NS_ASSUME_NONNULL_END
