//
//  TSAIConversationTranslationVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/4.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bidirectional conversation translation page
 * @chinese 双向对话翻译页面
 *
 * @discussion
 * [EN]: Builds a two-party press-to-talk conversation on top of the one-way
 *       `TSAIInterpreterInterface`. Normal and face-to-face layouts share the
 *       same conversation turns and session state.
 * [CN]: 基于单向 `TSAIInterpreterInterface` 编排双人按住说话式翻译。
 *       普通模式与面对面模式共用同一份对话轮次和会话状态。
 */
@interface TSAIConversationTranslationVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
