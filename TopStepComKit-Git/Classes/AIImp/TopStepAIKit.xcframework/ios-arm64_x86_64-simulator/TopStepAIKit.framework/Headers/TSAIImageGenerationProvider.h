//
//  TSAIImageGenerationProvider.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIImageGenerationInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provider contract for image generation
 * @chinese 图片生成 Provider 契约
 */
@protocol TSAIImageGenerationProvider <NSObject>

/** @brief Whether the active route supports image generation @chinese 当前路由是否支持图片生成 */
- (BOOL)isSupport;

/** @brief Current valid style snapshot; an empty array is valid @chinese 当前有效风格快照；空数组为合法结果 */
- (nullable NSArray<TSAIImageGenerationStyle *> *)availableStyles;

/** @brief Fetch available styles @chinese 查询可用风格 */
- (void)fetchAvailableStylesWithCompletion:
    (nullable TSAIImageGenerationStylesCompletionBlock)completion;

/** @brief Maximum images per task @chinese 单任务最大图片数量 */
- (NSInteger)maximumImageCount;

/**
 * @brief Generate images
 * @chinese 生成图片
 * @param prompt EN: Prompt. CN: 提示词。
 * @param config EN: Generation configuration. CN: 生图配置。
 * @param completion EN: Completion callback. CN: 完成回调。
 * @return EN: Client task identifier. CN: 客户端任务标识。
 */
- (NSString *)generateImagesWithPrompt:(NSString *)prompt
                                config:(TSAIImageGenerationConfig *)config
                            completion:(nullable TSAIImageGenerationCompletionBlock)completion;

/** @brief Logically cancel one task @chinese 逻辑取消单个任务 */
- (void)cancelImageGenerationWithTaskId:(NSString *)taskId;

/** @brief Cancel all owned tasks and clear snapshots @chinese 取消全部任务并清空快照 */
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
