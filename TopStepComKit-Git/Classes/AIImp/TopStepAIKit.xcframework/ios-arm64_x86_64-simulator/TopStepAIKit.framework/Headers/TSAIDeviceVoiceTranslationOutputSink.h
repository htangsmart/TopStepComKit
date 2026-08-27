//
//  TSAIDeviceVoiceTranslationOutputSink.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceBridge.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief App-side output sink for device-initiated voice translation
 * @chinese 设备发起语音翻译的 App 侧输出协议
 *
 * @discussion
 * [EN]: AIKit owns recognition and translation. The App implements this sink
 *       only to buffer and play translated Int16 PCM on its preferred route.
 * [CN]: AIKit 负责识别与翻译；App 仅实现本协议，以缓存译文 Int16 PCM
 *       并按产品策略选择播放路由。
 */
@protocol TSAIDeviceVoiceTranslationOutputSink <NSObject>

/**
 * @brief Prepare one translated-speech output task
 * @chinese 准备一轮译文语音输出任务
 * @param taskId EN: AIKit task identifier. CN: AIKit 任务标识。
 * @param sampleRate EN: PCM sample rate in Hz. CN: PCM 采样率，单位 Hz。
 * @param channelCount EN: PCM channel count. CN: PCM 声道数。
 */
- (void)prepareForTaskId:(NSString *)taskId
              sampleRate:(NSInteger)sampleRate
            channelCount:(NSInteger)channelCount
    NS_SWIFT_NAME(prepare(taskId:sampleRate:channelCount:));

/**
 * @brief Append incremental signed Int16 little-endian PCM
 * @chinese 追加有符号 Int16 小端增量 PCM
 * @param pcmData EN: Incremental PCM bytes. CN: 增量 PCM 字节。
 * @param taskId EN: AIKit task identifier. CN: AIKit 任务标识。
 */
- (void)appendInt16PCMData:(NSData *)pcmData
                    taskId:(NSString *)taskId
    NS_SWIFT_NAME(appendInt16PCM(_:taskId:));

/**
 * @brief Finish buffering and begin App-side playback
 * @chinese 完成缓存并开始 App 侧播放
 * @param taskId EN: AIKit task identifier. CN: AIKit 任务标识。
 */
- (void)finishAndPlayTaskId:(NSString *)taskId
    NS_SWIFT_NAME(finishAndPlay(taskId:));

/**
 * @brief Apply a playback command from the device
 * @chinese 执行设备下发的播放指令
 * @param state EN: Requested playback state. CN: 请求的播放状态。
 * @param taskId EN: Output task to control. CN: 要控制的输出任务。
 */
- (void)setPlaybackState:(TSAIDeviceVoicePlaybackState)state
                forTaskId:(NSString *)taskId
    NS_SWIFT_NAME(setPlaybackState(_:taskId:));

/**
 * @brief Discard buffered audio and release playback resources
 * @chinese 丢弃缓存音频并释放播放资源
 * @param taskId EN: Output task to discard. CN: 要丢弃的输出任务。
 */
- (void)discardTaskId:(NSString *)taskId
    NS_SWIFT_NAME(discard(taskId:));

@end

NS_ASSUME_NONNULL_END
