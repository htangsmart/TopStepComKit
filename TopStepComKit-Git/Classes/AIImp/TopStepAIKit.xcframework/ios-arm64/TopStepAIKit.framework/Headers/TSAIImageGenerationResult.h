//
//  TSAIImageGenerationResult.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completed image generation result
 * @chinese 图片生成完成结果
 */
@interface TSAIImageGenerationResult : NSObject

/** @brief Client task identifier @chinese 客户端任务标识 */
@property (nonatomic, copy, readonly) NSString *taskId;

/** @brief Generated images @chinese 已生成图片 */
@property (nonatomic, copy, readonly) NSArray<UIImage *> *images;

/**
 * @brief Create a completed result
 * @chinese 创建完成结果
 *
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param images EN: Generated images. CN: 已生成图片。
 * @return EN: An immutable result. CN: 不可变结果对象。
 */
- (instancetype)initWithTaskId:(NSString *)taskId
                        images:(NSArray<UIImage *> *)images NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
