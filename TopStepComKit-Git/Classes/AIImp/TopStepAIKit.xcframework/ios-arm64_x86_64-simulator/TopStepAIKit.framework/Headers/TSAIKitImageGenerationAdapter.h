//
//  TSAIKitImageGenerationAdapter.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIImageGenerationInterface.h"

@class TSAIContext;
@protocol TSAIImageGenerationProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Context-bound image generation facade
 * @chinese 绑定 Context 的图片生成门面
 */
@interface TSAIKitImageGenerationAdapter : NSObject <TSAIImageGenerationInterface>

/**
 * @brief Create a Context-bound image generation adapter
 * @chinese 创建绑定 Context 的图片生成适配器
 *
 * @param context EN: Owning Context. CN: 所属 Context。
 * @param imageGenerationProvider EN: Provider from the same Context. CN: 同一 Context 的 Provider。
 * @return EN: A new adapter. CN: 新适配器。
 */
- (instancetype)initWithContext:(TSAIContext *)context
        imageGenerationProvider:(id<TSAIImageGenerationProvider>)imageGenerationProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
