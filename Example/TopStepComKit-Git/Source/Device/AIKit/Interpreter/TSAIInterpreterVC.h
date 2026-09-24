//
//  TSAIInterpreterVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI simultaneous-interpretation test VC
 * @chinese AI 同声传译测试页
 *
 * @discussion
 * [EN]: Renders one `TSAIInterpretationInterface` session. The page collects
 *       intent (pickup, languages, voice) in `TSAIInterpreterSetupSheetVC`,
 *       calls `startWithRequest:`, renders snapshots and content, and calls
 *       `stopWithSessionId:` after a confirmation. It never touches the device
 *       session APIs or the task-level interpreter — the SDK session owns
 *       routing, device coordination, screen text and error folding.
 *
 *       Layout (top to bottom):
 *         - Language bar: read-only source ⇄ target of the running session
 *         - Status strip: session state + pickup + taskId
 *         - Split transcript (`TSAIInterpreterSplitView`): source panel on top,
 *           target panel below; rows pair by `utteranceIndex`
 *         - Bottom bar: mic (Start → setup sheet / Stop → confirm) / info+logs drawer
 * [CN]: 渲染一次 `TSAIInterpretationInterface` 会话。页面在
 *       `TSAIInterpreterSetupSheetVC` 中收集意图（拾音设备、语言、语音），调用
 *       `startWithRequest:`，渲染快照与内容，二次确认后调用 `stopWithSessionId:`。
 *       页面不再接触设备会话接口或 task 级同传——路由、设备协同、屏端文本、
 *       异常收口都由 SDK 会话负责。
 *
 *       页面布局（自上而下）：
 *         - 语言条：只读展示进行中会话的源 ⇄ 目标语言
 *         - 状态条：会话状态 + 拾音设备 + taskId
 *         - 分栏字幕（`TSAIInterpreterSplitView`）：上原文、下译文，按 `utteranceIndex` 配对
 *         - 底栏：麦克风（开始 → 设置抽屉 / 结束 → 二次确认）/ 信息与日志抽屉
 */
@interface TSAIInterpreterVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
