//
//  TSAIKitInterpretationAdapter.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIInterpretationInterface.h"

@class TSAIContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Public facade of session-level interpretation bound to one Context
 * @chinese 绑定到单个 Context 的会话级同声传译公开门面
 *
 * @discussion
 * [EN]: Forwards every call to the Context-owned `TSAIInterpretationCoordinator`
 *       and answers with `TSAIErrorCodeContextInactive` once the Context is
 *       deactivated. Obtain it from `TSAIContext.interpretation`.
 * [CN]: 把所有调用转发给 Context 持有的 `TSAIInterpretationCoordinator`，
 *       Context 失活后统一返回 `TSAIErrorCodeContextInactive`。
 *       通过 `TSAIContext.interpretation` 获取。
 */
@interface TSAIKitInterpretationAdapter : NSObject <TSAIInterpretationInterface>

/**
 * @brief Create the facade for a Context
 * @chinese 为 Context 创建门面
 *
 * @param context
 * EN: Owning Context, held weakly
 * CN: 所属 Context，弱引用
 */
- (instancetype)initWithContext:(TSAIContext *)context NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
