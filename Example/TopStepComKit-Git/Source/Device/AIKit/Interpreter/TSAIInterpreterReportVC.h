//
//  TSAIInterpreterReportVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSAIInterpretationRequest;
@class TSAIInterpreterUtteranceUI;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI interpretation report page ("同传已结束")
 * @chinese AI 同声传译结束报告页（「同传已结束」）
 *
 * @discussion
 * [EN]: Shown after a live session ends, replacing the live page in the
 *       navigation stack. Overview card (languages, route, duration, count,
 *       average latency, end reason), a per-utterance list with replay of
 *       the synthesized voice, "复制全部" / share, and a footer with
 *       "换个设置" (pop to setup) and "再来一次" (start a new live session
 *       with the same request in place of this page).
 * [CN]: 同传会话结束后展示，并在导航栈中替换同传页。包含概览卡（语言、
 *       路由、时长、句数、平均延迟、结束原因）、逐句记录（可回放合成语音）、
 *       「复制全部」/ 分享，以及底部「换个设置」（回准备页）和「再来一次」
 *       （用同一请求开启新会话并替换本页）。
 */
@interface TSAIInterpreterReportVC : TSBaseVC

/**
 * @brief Create the report page
 * @chinese 创建报告页
 *
 * @param request
 * EN: Request the session ran with
 * CN: 本次会话使用的请求
 *
 * @param utterances
 * EN: Utterances that carry original or translated text, in order
 * CN: 带原文或译文的句子，按顺序
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
- (instancetype)initWithRequest:(TSAIInterpretationRequest *)request
                     utterances:(NSArray<TSAIInterpreterUtteranceUI *> *)utterances
                       duration:(NSTimeInterval)duration
                  endReasonText:(NSString *)endReasonText
                        endDate:(NSDate *)endDate;

@end

NS_ASSUME_NONNULL_END
