//
//  TSAITranslateVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI text-translation test VC
 * @chinese AI 文本翻译测试页
 *
 * @discussion
 * [EN]: Tests `TSAITranslateInterface` streaming text translation. Input text,
 *       configure source / target language (source supports Auto), observe
 *       cumulative partial translation and the final result.
 * [CN]: 用于测试 `TSAITranslateInterface` 的流式文本翻译能力。输入文本，
 *       配置源 / 目标语言（源语言可用 Auto），观察累积 partial 与最终结果。
 */
@interface TSAITranslateVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
