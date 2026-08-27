//
//  TSAITTSStreamChunk.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/23.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable audio chunk emitted by streaming TTS
 * @chinese 流式 TTS 输出的不可变音频分片
 */
@interface TSAITTSStreamChunk : NSObject

/** @brief Client task identifier @chinese 客户端任务标识 */
@property (nonatomic, copy, readonly) NSString *taskId;
/** @brief Zero-based chunk sequence @chinese 从零开始的分片序号 */
@property (nonatomic, assign, readonly) NSUInteger sequenceIndex;
/** @brief Audio bytes carried by this chunk @chinese 当前分片携带的音频数据 */
@property (nonatomic, copy, readonly) NSData *audioData;
/** @brief Audio container or codec format @chinese 音频容器或编码格式 */
@property (nonatomic, assign, readonly) TSAIAudioFormat audioFormat;
/** @brief Sample rate in Hz @chinese 采样率，单位 Hz */
@property (nonatomic, assign, readonly) NSInteger sampleRate;
/** @brief Number of audio channels @chinese 音频声道数 */
@property (nonatomic, assign, readonly) NSInteger channelCount;
/** @brief Bits per audio sample @chinese 单个采样的位数 */
@property (nonatomic, assign, readonly) NSInteger bitsPerChannel;

/**
 * @brief Create an immutable streaming TTS chunk
 * @chinese 创建不可变的流式 TTS 音频分片
 * @param taskId EN: Client task identifier. CN: 客户端任务标识。
 * @param sequenceIndex EN: Zero-based sequence. CN: 从零开始的分片序号。
 * @param audioData EN: Audio bytes. CN: 音频数据。
 * @param audioFormat EN: Audio format. CN: 音频格式。
 * @param sampleRate EN: Sample rate in Hz. CN: 采样率，单位 Hz。
 * @param channelCount EN: Channel count. CN: 声道数。
 * @param bitsPerChannel EN: Bits per sample. CN: 单个采样位数。
 * @return EN: Immutable chunk instance. CN: 不可变分片实例。
 */
- (instancetype)initWithTaskId:(NSString *)taskId
                 sequenceIndex:(NSUInteger)sequenceIndex
                     audioData:(NSData *)audioData
                   audioFormat:(TSAIAudioFormat)audioFormat
                    sampleRate:(NSInteger)sampleRate
                  channelCount:(NSInteger)channelCount
                bitsPerChannel:(NSInteger)bitsPerChannel NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
