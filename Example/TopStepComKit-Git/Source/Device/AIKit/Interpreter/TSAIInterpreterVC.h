//
//  TSAIInterpreterVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSAIInterpretationRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI interpretation live page (dark "同传中" screen)
 * @chinese AI 同声传译进行中页（深色「同传中」屏）
 *
 * @discussion
 * [EN]: Renders one `TSAIInterpretationInterface` session for the request it
 *       was created with. Starts the session on first appearance, renders
 *       snapshots / content / events, and ends the session only after the
 *       in-page confirmation sheet. When the session completes (user stop,
 *       device exit, disconnect, network error …) the page replaces itself
 *       with `TSAIInterpreterReportVC`, so the navigation stack stays
 *       setup → report.
 *
 *       Layout (top to bottom):
 *         - Top bar: round back button + status pill (dot · "X收音" · timer · "屏端同步")
 *         - Language pair line: source → target · playback target
 *         - History: last three finished utterances, dimmed
 *         - Latest utterance: original block (jade) with level bars, translated
 *           block (cobalt) with TTS state
 *         - Footer: 76pt red stop button + info button (session info & logs sheet)
 *         - In-page sheets: confirm-stop sheet, log sheet
 * [CN]: 按创建时传入的请求渲染一次 `TSAIInterpretationInterface` 会话。
 *       首次出现时启动会话，渲染快照 / 内容 / 事件，只在页内确认面板确认后
 *       结束会话。会话完成（用户结束、设备退出、断连、网络异常……）后，
 *       页面用 `TSAIInterpreterReportVC` 替换自身，导航栈保持 准备页 → 报告页。
 *
 *       页面布局（自上而下）：
 *         - 顶栏：圆形返回 + 状态胶囊（指示点 · "X收音" · 计时 · "屏端同步"）
 *         - 语言对：源 → 目标 · 朗读端
 *         - 历史：最近三句已完成的内容，淡化显示
 *         - 最新一句：原文块（翠绿）带音量条，译文块（钴蓝）带 TTS 状态
 *         - 底栏：76pt 红色结束按钮 + 信息按钮（会话信息与日志面板）
 *         - 页内面板：结束确认面板、日志面板
 */
@interface TSAIInterpreterVC : TSBaseVC

/**
 * @brief Create the live page for a request
 * @chinese 用请求创建同传页
 *
 * @param request
 * EN: Fully assembled request from the setup page
 * CN: 准备页组装好的完整请求
 *
 * @return
 * EN: Live page; push it, the session starts after the first appearance
 * CN: 同传页；push 后在首次出现时启动会话
 */
- (instancetype)initWithRequest:(TSAIInterpretationRequest *)request;

@end

NS_ASSUME_NONNULL_END
