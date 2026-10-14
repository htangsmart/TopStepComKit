//
//  TSAIConversationTranslationReportVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSAIConversationTranslationConfig;
@class TSAIConversationTranslationTurn;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversation translation report page ("对话翻译已结束")
 * @chinese 对话翻译结束报告页（「对话翻译已结束」）
 *
 * @discussion
 * [EN]: Shown after a live session ends, replacing the live page in the
 *       navigation stack. Overview card (self / peer languages, mode,
 *       duration, turn count, self / peer split, end reason), a per-turn
 *       list with replay of the synthesized voice, "复制全部" / share, and a
 *       footer with "换个设置" (pop to setup) and "再来一次" (start a new live
 *       session with the same config in place of this page).
 * [CN]: 对话会话结束后展示，并在导航栈中替换对话页。包含概览卡（双方语言、
 *       模式、时长、轮次、我方 / 对方各几轮、结束原因）、逐轮记录（可回放合成语音）、
 *       「复制全部」/ 分享，以及底部「换个设置」（回准备页）和「再来一次」
 *       （用同一配置开启新会话并替换本页）。
 */
@interface TSAIConversationTranslationReportVC : TSBaseVC

/**
 * @brief Create the report page
 * @chinese 创建报告页
 *
 * @param config
 * EN: Config the session ran with
 * CN: 本次会话使用的配置
 *
 * @param turns
 * EN: Turns that carry original or translated text, in order
 * CN: 带原文或译文的轮次，按顺序
 *
 * @param duration
 * EN: Session duration in seconds
 * CN: 会话时长（秒）
 *
 * @param endReasonText
 * EN: Localized end reason (with error detail when relevant)
 * CN: 本地化结束原因（必要时附错误详情）
 *
 * @param endDate
 * EN: When the session ended
 * CN: 会话结束时间
 *
 * @return
 * EN: Report page
 * CN: 报告页
 */
- (instancetype)initWithConfig:(TSAIConversationTranslationConfig *)config
                         turns:(NSArray<TSAIConversationTranslationTurn *> *)turns
                      duration:(NSTimeInterval)duration
                 endReasonText:(NSString *)endReasonText
                       endDate:(NSDate *)endDate;

@end

NS_ASSUME_NONNULL_END
