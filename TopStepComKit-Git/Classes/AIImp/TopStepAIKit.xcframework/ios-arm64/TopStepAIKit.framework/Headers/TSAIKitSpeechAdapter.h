//
//  TSAIKitSpeechAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAISpeechInterface.h"

@class TSAIContext;
@protocol TSAISpeechProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified speech facade
 * @chinese 统一语音门面
 */
@interface TSAIKitSpeechAdapter : NSObject <TSAISpeechInterface>

/**
 * @brief Create a speech adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的语音适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param speechProvider
 * EN: Speech Provider created for the same Context
 * CN: 为同一 Context 创建的语音 Provider
 *
 * @return
 * EN: A Context-bound speech adapter
 * CN: 绑定到 Context 的语音适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
                 speechProvider:(id<TSAISpeechProvider>)speechProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
