//
//  TSAIBudsImageGenerationProvider+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSAIBudsImageGenerationProvider.h"

@class AIBudsAIGCStyleModel;
@class AIBudsAIGCTaskConfig;
@class TSAIBudsManager;
@class UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface TSAIBudsImageGenerationProvider (Internal)

/** @brief Create with a Context-owned manager @chinese 使用 Context 持有的 Manager 创建 */
- (nullable instancetype)initWithManager:(TSAIBudsManager *)manager;

/** @brief Read styles through AIBudsAISDK class facade @chinese 通过 AIBudsAISDK 类门面读取风格 */
- (nullable NSArray<AIBudsAIGCStyleModel *> *)tsai_aibudsStyles;

/** @brief Fetch styles through AIBudsAISDK class facade @chinese 通过 AIBudsAISDK 类门面查询风格 */
- (void)tsai_fetchAIBudsStylesWithCompletion:
    (void (^)(NSArray<AIBudsAIGCStyleModel *> * _Nullable styles,
              NSError * _Nullable error))completion;

/** @brief Generate through AIBudsAISDK class facade @chinese 通过 AIBudsAISDK 类门面生成图片 */
- (void)tsai_generateAIBudsImagesWithPrompt:(NSString *)prompt
                                     config:(AIBudsAIGCTaskConfig *)config
                                taskCreated:(void (^ _Nullable)(NSString *serviceTaskId))taskCreated
                                 completion:(void (^)(NSString * _Nullable serviceTaskId,
                                                      BOOL success,
                                                      NSArray<UIImage *> * _Nullable images,
                                                      NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
