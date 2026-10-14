//
//  TSAIChatVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI chat screen with two modes: AI 对话 (single round) and AI 畅聊 (continuous)
 * @chinese AI 对话页：AI 对话（单轮）与 AI 畅聊（多轮）两种模式
 *
 * @discussion
 * [EN]: UI / interaction follow `Docs/TSAIChatVC/DualMode-04-UISpec.md` (aurora
 *       prototype). Chat mode drives `TSAIChatConversationModeSingleRound`
 *       sessions (press-to-talk / text); flow mode drives one
 *       `TSAIChatConversationModeContinuous` session. Sessions are owned by
 *       `TSAIChatDeviceSessionCoordinator`; this page observes notifications,
 *       maps SDK content / events to round states, and never owns the lifetime.
 * [CN]: UI / 交互严格按 `Docs/TSAIChatVC/DualMode-04-UISpec.md`（极光原型）。
 *       对话模式发起 `SingleRound` 会话（按住说话 / 文字）；畅聊模式发起一次
 *       `Continuous` 会话。会话由 `TSAIChatDeviceSessionCoordinator` 持有，
 *       页面通过通知观察并把 SDK 内容 / 事件映射为轮状态，不持有会话生命周期。
 */
@interface TSAIChatVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
