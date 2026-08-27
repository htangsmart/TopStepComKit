//
//  TSAIImageGenerationDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSAIImageGenerationResult;
@class TSAIImageGenerationStyle;

NS_ASSUME_NONNULL_BEGIN

/** @brief Style discovery completion @chinese 风格查询完成回调 */
typedef void(^TSAIImageGenerationStylesCompletionBlock)(
    NSArray<TSAIImageGenerationStyle *> * _Nullable styles,
    NSError * _Nullable error);

/** @brief Image generation completion @chinese 图片生成完成回调 */
typedef void(^TSAIImageGenerationCompletionBlock)(
    TSAIImageGenerationResult * _Nullable result,
    NSError * _Nullable error);

NS_ASSUME_NONNULL_END
