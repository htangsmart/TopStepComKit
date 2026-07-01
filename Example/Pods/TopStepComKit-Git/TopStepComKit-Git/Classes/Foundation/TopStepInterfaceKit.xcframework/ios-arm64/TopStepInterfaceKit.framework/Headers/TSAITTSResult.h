//
//  TSAITTSResult.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/15.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TTS synthesis result
 * @chinese 文本转语音合成结果
 */
@interface TSAITTSResult : NSObject

/**
 * @brief Task identifier (the same one returned synchronously by the synthesize API)
 * @chinese 任务唯一标识（与合成接口同步返回的 taskId 相同）
 */
@property (nonatomic, copy) NSString *taskId;

/**
 * @brief Synthesized audio data
 * @chinese 合成后的音频数据
 */
@property (nonatomic, copy) NSData *audioData;

/**
 * @brief Audio format of audioData
 * @chinese audioData 对应的音频格式
 */
@property (nonatomic, assign) TSAIAudioFormat audioFormat;

/**
 * @brief Sample rate in Hz, e.g. 16000 / 24000 / 48000
 * @chinese 采样率（Hz），如 16000 / 24000 / 48000
 */
@property (nonatomic, assign) NSInteger sampleRate;

/**
 * @brief Audio duration in seconds
 * @chinese 音频时长（秒）
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
