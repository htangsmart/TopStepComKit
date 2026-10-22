//
//  TSAIKitSpeechAdapter+Internal.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import "TSAIKitSpeechAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSAIKitSpeechAdapter (Internal)

/**
 * @brief Cancel every microphone recognition task (Context deactivation)
 * @chinese 取消所有麦克风识别任务（Context 停用时调用）
 */
- (void)tsai_cancelAllMicrophoneTasks;

@end

NS_ASSUME_NONNULL_END
