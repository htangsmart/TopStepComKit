//
//  TSAIInterpreterSetupVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI interpretation preparation page (languages + devices + start)
 * @chinese AI 同声传译准备页（语言 + 设备 + 开始）
 *
 * @discussion
 * [EN]: Entry page of the interpreter flow, pushed from the AI kit root.
 *       Matches the prototype's "setup" screen: a custom top bar (back /
 *       title / help), a "what to translate" card with source ⇄ target
 *       language tiles and a swap button, a "which device" card with a
 *       3-column pickup grid and a 4-column playback grid, and a fixed
 *       footer holding the blocking reason and the "开始同传" call to action.
 *       Availability comes from `TSAIInterpretationInterface` (`eligibilityForPickup:`
 *       / `eligibilityForRequest:`); the page never touches device APIs.
 *       Language tiles present `TSAIInterpreterLanguageSheetVC`; the CTA
 *       pushes `TSAIInterpreterVC` with the assembled request.
 * [CN]: 同传流程的入口页，由 AI 能力首页 push 进入。对应原型的「准备」
 *       屏：自绘顶栏（返回 / 标题 / 帮助）、「翻译什么」卡片（源 ⇄ 目标语言
 *       块 + 交换按钮）、「用什么设备」卡片（3 列收音格 + 4 列播放格），
 *       以及固定底栏（不可开始原因 + 「开始同传」主按钮）。可用性全部来自
 *       `TSAIInterpretationInterface`（`eligibilityForPickup:` /
 *       `eligibilityForRequest:`），页面不碰设备接口。语言块 present
 *       `TSAIInterpreterLanguageSheetVC`；主按钮带着组装好的请求 push
 *       `TSAIInterpreterVC`。
 */
@interface TSAIInterpreterSetupVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
