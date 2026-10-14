//
//  TSAIConversationTranslationSetupVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversation translation preparation page (languages + mode + devices + start)
 * @chinese 对话翻译准备页（语言 + 交流方式 + 设备 + 开始）
 *
 * @discussion
 * [EN]: Entry page of the conversation translation flow, pushed from the AI
 *       kit root. Top to bottom: custom top bar (back / title / help), a
 *       "languages" card (self ⇄ peer tiles with swap), three preset cards
 *       (face-to-face / private / portable), a "who captures, who listens"
 *       matrix (self / peer × capture / playback, three devices each), a
 *       "phone auto-speak" switch and a fixed footer with the blocking reason
 *       and the "开始对话翻译" call to action.
 *
 *       Tapping a preset fills the four matrix cells; changing any cell
 *       re-derives the preset (a match selects that card, otherwise no card
 *       is selected and "自定义组合" is shown). Device availability comes from
 *       `TSAIInterpretationInterface.eligibilityForPickup:`, start
 *       availability from `TSAIConversationTranslationInterface.eligibilityForConfig:`.
 *       The CTA pushes `TSAIConversationTranslationVC` with the assembled config.
 * [CN]: 对话翻译流程的入口页，由 AI 能力首页 push 进入。自上而下：自绘顶栏
 *       （返回 / 标题 / 帮助）、「双方语言」卡（我说 ⇄ 对方说 + 交换）、三张预设卡
 *       （面对面 / 私密听译 / 便携交流）、「谁收音、在哪听译文」矩阵（我方 / 对方 ×
 *       收音 / 播报，每格三个设备）、「手机自动播报译文」开关，以及固定底栏
 *       （不可开始原因 + 「开始对话翻译」主按钮）。
 *
 *       点预设卡会回填矩阵四格；改任一格后重新反推预设（完全一致则选中该卡，
 *       否则无卡选中并显示「自定义组合」）。设备可用性来自
 *       `TSAIInterpretationInterface.eligibilityForPickup:`，能否开始来自
 *       `TSAIConversationTranslationInterface.eligibilityForConfig:`。
 *       主按钮带着组装好的配置 push `TSAIConversationTranslationVC`。
 */
@interface TSAIConversationTranslationSetupVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
