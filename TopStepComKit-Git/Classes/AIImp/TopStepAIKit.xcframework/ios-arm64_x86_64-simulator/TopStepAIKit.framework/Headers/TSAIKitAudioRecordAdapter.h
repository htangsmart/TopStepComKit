//
//  TSAIKitAudioRecordAdapter.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/30.
//

#import "TSAudioRecordInterface.h"

@class TSAIContext;
@protocol TSAIAudioRecordProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unified AI audio recording facade
 * @chinese 统一 AI 录音门面
 */
@interface TSAIKitAudioRecordAdapter : NSObject <TSAudioRecordInterface>

/**
 * @brief Create an audio recording adapter bound to one Context
 * @chinese 创建绑定到指定 Context 的录音适配器
 *
 * @param context
 * EN: Context that owns this adapter
 * CN: 持有当前适配器的 Context
 *
 * @param audioRecordProvider
 * EN: Audio recording Provider created for the same Context
 * CN: 为同一 Context 创建的录音 Provider
 *
 * @return
 * EN: A Context-bound audio recording adapter
 * CN: 绑定到 Context 的录音适配器
 */
- (instancetype)initWithContext:(TSAIContext *)context
            audioRecordProvider:(id<TSAIAudioRecordProvider>)audioRecordProvider
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
