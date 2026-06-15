//
//  TSAIASRResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Streaming ASR final result
 * @chinese 流式语音识别最终结果
 *
 * @discussion
 * [EN]: Delivered exactly once via the completion handler when the whole
 *       audio file has been recognized. `text` is the full transcription;
 *       intermediate updates are received via the partial-result callback.
 * [CN]: 整段音频识别完成后通过 completion 回调一次。`text` 为完整识别文本；
 *       中间过程文本通过 partial 回调接收。
 */
@interface TSAIASRResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the recognize API)
 * @chinese 任务唯一标识（与识别接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Full recognized text
 * @chinese 完整识别文本
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Audio duration in seconds
 * @chinese 音频总时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
