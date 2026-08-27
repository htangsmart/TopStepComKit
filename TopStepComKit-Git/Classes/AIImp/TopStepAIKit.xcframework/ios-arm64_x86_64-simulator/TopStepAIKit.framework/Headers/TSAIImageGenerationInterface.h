//
//  TSAIImageGenerationInterface.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIImageGenerationConfig.h"
#import "TSAIImageGenerationDefines.h"
#import "TSAIImageGenerationResult.h"
#import "TSAIImageGenerationStyle.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Vendor-neutral image generation interface
 * @chinese 厂商无关的图片生成接口
 */
@protocol TSAIImageGenerationInterface <NSObject>

/**
 * @brief Current valid style snapshot
 * @chinese 当前有效的风格快照
 * @return EN: The last fetched snapshot or the active Provider snapshot; an empty array is valid and nil means no snapshot is available.
 * CN: 最近查询快照或当前 Provider 快照；空数组为合法结果，nil 表示暂无快照。
 */
- (nullable NSArray<TSAIImageGenerationStyle *> *)availableStyles;

/**
 * @brief Fetch styles available for image generation
 * @chinese 查询可用的图片生成风格
 * @param completion EN: Called asynchronously on the main thread exactly once. CN: 在主线程异步且仅调用一次。
 */
- (void)fetchAvailableStylesWithCompletion:(nullable TSAIImageGenerationStylesCompletionBlock)completion;

/**
 * @brief Maximum image count accepted by the active Provider
 * @chinese 当前 Provider 允许的单任务最大图片数量
 * @return EN: Positive limit when supported, otherwise zero. CN: 支持时为正数，否则为零。
 */
- (NSInteger)maximumImageCount;

/**
 * @brief Generate images from a prompt
 * @chinese 根据提示词生成图片
 *
 * @param prompt EN: Non-empty generation prompt. CN: 非空生图提示词。
 * @param config EN: Optional style, count, size and language configuration. CN: 可选风格、数量、尺寸与语言配置。
 * @param completion EN: Called asynchronously on the main thread exactly once. CN: 在主线程异步且仅调用一次。
 * @return EN: Stable client task identifier. CN: 稳定的客户端任务标识。
 */
- (NSString *)generateImagesWithPrompt:(NSString *)prompt
                                config:(TSAIImageGenerationConfig *)config
                            completion:(nullable TSAIImageGenerationCompletionBlock)completion;

/**
 * @brief Logically cancel an image generation task
 * @chinese 逻辑取消图片生成任务
 *
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @discussion
 * [EN]: Cancellation suppresses late Provider results but may not stop server-side work.
 * [CN]: 取消会丢弃迟到的 Provider 结果，但可能无法停止服务端任务。
 */
- (void)cancelImageGenerationWithTaskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
