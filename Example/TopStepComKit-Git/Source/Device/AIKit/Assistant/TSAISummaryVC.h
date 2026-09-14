//
//  TSAISummaryVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI text summarization test VC
 * @chinese AI 文本总结测试页
 *
 * @discussion
 * [EN]: Tests `TSAIAssistantInterface` text-summary capability. Input source
 *       text, trigger summarization, observe streaming partial results and
 *       final summary; supports cancellation via the synchronous taskId.
 * [CN]: 用于测试 `TSAIAssistantInterface` 的文本总结能力。输入源文本，
 *       触发总结，观察流式 partial 与最终结果；可通过同步 taskId 取消任务。
 */
@interface TSAISummaryVC : TSBaseVC

/**
 * @brief Create a summary page with prefilled source text.
 * @chinese 创建预填原文的总结页面。
 * @param sourceText Source text to summarize / 待总结的原文。
 * @return Summary page / 总结页面。
 */
- (instancetype)initWithSourceText:(NSString *)sourceText;

@end

NS_ASSUME_NONNULL_END
