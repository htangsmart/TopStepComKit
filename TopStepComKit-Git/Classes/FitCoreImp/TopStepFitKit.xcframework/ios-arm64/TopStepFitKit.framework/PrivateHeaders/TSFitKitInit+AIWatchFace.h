//
//  TSFitKitInit+AIWatchFace.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSFitKitInit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud callback routing for AI watch-face events
 * @chinese AI 表盘事件的 FitCloud 回调路由
 *
 * @discussion
 * [EN]: Raw callbacks are synchronously forwarded to TSFitAIEventSource.
 * [CN]: 原始回调会同步转发到 TSFitAIEventSource。
 */
@interface TSFitKitInit (AIWatchFace)

@end

NS_ASSUME_NONNULL_END
