//
//  TSAIBudsSpeechProvider.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>
#import "TSAISpeechProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds implementation of speech capability
 * @chinese AIBuds 语音能力实现
 *
 * @discussion
 * [EN]: Non-streaming TTS waits at most 60 seconds for the vendor result.
 *       Cancellation or timeout releases the local task immediately; the vendor
 *       request may continue, and its late result is ignored. A new request can
 *       start after local cancellation or timeout.
 * [CN]: 非流式 TTS 最长等待厂商结果 60 秒。
 *       取消或超时会立即释放本地任务；厂商请求可能继续执行，其迟到结果会被忽略。
 *       本地取消或超时后可发起新请求。
 */
@interface TSAIBudsSpeechProvider : NSObject <TSAISpeechProvider>

@end

NS_ASSUME_NONNULL_END
