//
//  TSAIAudioRecordTranscriptDelivery.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/9/24.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Block that performs one device send; the completion is the acknowledgement
 * @chinese 执行一次设备下发的闭包；completion 即设备应答
 */
typedef void (^TSAIAudioRecordTranscriptSendBlock)(NSString *text,
                                                    BOOL isFinal,
                                                    TSAICompletionBlock completion);

/**
 * @brief Ordered, acknowledged delivery of AI recording transcripts to a device screen
 * @chinese 按顺序、带应答跟踪地把 AI 录音转写文本下发到设备屏幕
 *
 * @discussion
 * [EN]: One sentence is in flight at a time. A newer partial of the same sentence
 *       replaces the queued partial, a final replaces every queued partial of that
 *       sentence, at most two partials wait in the queue, and finals are retried
 *       up to three times when the device does not acknowledge in time.
 * [CN]: 同一时间只有一句在途。同一句的新 partial 替换排队中的 partial，final 替换该句
 *       所有排队 partial，队列最多保留两条 partial，final 在设备未及时应答时最多重试三次。
 */
@interface TSAIAudioRecordTranscriptDelivery : NSObject

/**
 * @brief Create a delivery queue bound to one send implementation
 * @chinese 创建绑定单一下发实现的转写发送队列
 *
 * @param sendBlock
 * EN: Performs the device send; called on an arbitrary thread
 * CN: 执行设备下发；在任意线程调用
 *
 * @return
 * EN: Idle delivery queue
 * CN: 空闲的发送队列
 */
- (instancetype)initWithSendBlock:(TSAIAudioRecordTranscriptSendBlock)sendBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Queue the latest text of one transcript sentence
 * @chinese 排队一句转写的最新文本
 *
 * @param text
 * EN: Sentence text; empty text is ignored
 * CN: 句子文本；空文本忽略
 *
 * @param sentenceIndex
 * EN: Sentence index used to merge partials
 * CN: 用于合并 partial 的句序号
 *
 * @param isFinal
 * EN: Whether the sentence is final
 * CN: 该句是否已定稿
 */
- (void)enqueueText:(NSString *)text
      sentenceIndex:(NSInteger)sentenceIndex
            isFinal:(BOOL)isFinal;

/**
 * @brief Drop every queued item and ignore late acknowledgements
 * @chinese 清空队列并忽略迟到的应答
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
