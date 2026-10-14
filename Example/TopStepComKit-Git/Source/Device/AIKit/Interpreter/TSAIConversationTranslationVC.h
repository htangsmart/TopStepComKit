//
//  TSAIConversationTranslationVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/9/18.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSAIConversationTranslationConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversation translation live page (dark "对话中" screen)
 * @chinese 对话翻译进行中页（深色「对话中」屏）
 *
 * @discussion
 * [EN]: Pure render layer over the session-level
 *       `TSAIConversationTranslationInterface`. Starts the session with the
 *       config it was created with on first appearance, renders snapshots as
 *       a two-sided bubble list (self = cobalt on the right, peer = jade on
 *       the left; every bubble shows original + translation + playback
 *       state), drives turns with `beginTurn` / `endTurn` from the two
 *       hold-to-talk buttons, and ends the session only after the in-page
 *       confirmation sheet. When the session completes (user stop, device
 *       exit, disconnect, low battery, network error …) the page replaces
 *       itself with `TSAIConversationTranslationReportVC`, so the navigation
 *       stack stays setup → report.
 *
 *       Layout (top to bottom):
 *         - Top bar: round back button + status pill (dot · mode · timer · "屏端同步")
 *         - Language pair line: 我 · language ⇄ 对方 · language · playback route
 *         - Conversation list with "↓ 回到最新"
 *         - Status line (ready / listening / translating / speaking)
 *         - Hold-to-talk row: 我 (cobalt) · 64pt red stop · 对方 (jade)
 *         - In-page sheet: confirm-stop sheet with duration / turns / mode
 * [CN]: 会话级 `TSAIConversationTranslationInterface` 之上的纯渲染层。首次出现时
 *       用创建时传入的配置启动会话，把快照渲染成左右气泡列表（我方钴蓝靠右、
 *       对方翠绿靠左；每条气泡含原文 + 译文 + 播报状态），用两个按住说话按钮
 *       驱动 `beginTurn` / `endTurn`，只在页内确认面板确认后结束会话。会话完成
 *       （用户结束、设备退出、断连、低电、网络异常……）后，页面用
 *       `TSAIConversationTranslationReportVC` 替换自身，导航栈保持 准备页 → 报告页。
 *
 *       页面布局（自上而下）：
 *         - 顶栏：圆形返回 + 状态胶囊（指示点 · 模式 · 计时 · "屏端同步"）
 *         - 语言对：我 · 语言 ⇄ 对方 · 语言 · 播报出口
 *         - 对话列表，带「↓ 回到最新」
 *         - 状态行（就绪 / 聆听 / 翻译 / 播报）
 *         - 按住说话行：我（钴蓝）· 64pt 红色结束 · 对方（翠绿）
 *         - 页内面板：结束确认（时长 / 轮次 / 模式）
 */
@interface TSAIConversationTranslationVC : TSBaseVC

/**
 * @brief Create the live page for a config
 * @chinese 用配置创建对话页
 *
 * @param config
 * EN: Fully assembled config from the setup page (explicit endpoints, languages, auto-speak)
 * CN: 准备页组装好的完整配置（显式端点、语言、手机自动播报）
 *
 * @return
 * EN: Live page; push it, the session starts after the first appearance
 * CN: 对话页；push 后在首次出现时启动会话
 */
- (instancetype)initWithConfig:(TSAIConversationTranslationConfig *)config;

@end

NS_ASSUME_NONNULL_END
