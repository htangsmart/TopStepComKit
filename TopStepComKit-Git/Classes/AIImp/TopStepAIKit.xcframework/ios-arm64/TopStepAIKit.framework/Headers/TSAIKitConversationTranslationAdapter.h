//
//  TSAIKitConversationTranslationAdapter.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/24.
//

#import "TSAIConversationTranslationInterface.h"

@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified conversation-translation facade
 * @chinese 统一对话翻译门面
 *
 * @discussion
 * [EN]: Validates the Context and forwards every call to the internal
 *       `TSAIConversationTranslationCoordinator` owned by that Context.
 * [CN]: 校验 Context 后将所有调用转发给该 Context 持有的内部
 *       `TSAIConversationTranslationCoordinator`。
 */
@interface TSAIKitConversationTranslationAdapter : NSObject <TSAIConversationTranslationInterface>

/**
 * @brief Create an adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @return
 * EN: A Context-bound conversation-translation adapter
 * CN: 绑定到 Context 的对话翻译适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
