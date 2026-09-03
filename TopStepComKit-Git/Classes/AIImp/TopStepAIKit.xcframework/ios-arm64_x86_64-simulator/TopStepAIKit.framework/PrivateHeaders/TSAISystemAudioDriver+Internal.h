//
//  TSAISystemAudioDriver+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Internal system capture and playback driver
 * @chinese 内部系统采音与播放驱动
 */
@protocol TSAISystemAudioDriver <NSObject>

/** @brief Whether the driver is available @chinese 驱动当前是否可用 */
@property (nonatomic, assign, readonly) BOOL isAvailable;

/** @brief Whether system voice processing is active @chinese 系统语音处理当前是否生效 */
@property (nonatomic, assign, readonly) BOOL isVoiceProcessingEnabled;

/**
 * @brief Start the system audio path for one complete route
 * @chinese 为一条完整路由启动系统音频链路
 * @param inputChannel EN: Effective input channel. CN: 生效输入通道。
 * @param outputChannel EN: Effective output channel. CN: 生效输出通道。
 * @param pcmHandler EN: Captured 16 kHz mono Int16LE PCM callback. CN: 采集到的 16 kHz 单声道 Int16LE PCM 回调。
 * @param errorHandler EN: Runtime audio-path error callback. CN: 音频链路运行时错误回调。
 * @param error EN: Start or route-validation error. CN: 启动或路由校验错误。
 * @return EN: YES after the route is active. CN: 路由激活后返回 YES。
 */
- (BOOL)startWithInputChannel:(TSAIAudioInputChannel)inputChannel
                outputChannel:(TSAIAudioOutputChannel)outputChannel
              pcmDataReceived:(nullable void (^)(NSData *pcmData))pcmHandler
                 errorOccurred:(nullable void (^)(NSError *error))errorHandler
                        error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Append output PCM for one voice
 * @chinese 为一段语音追加输出 PCM
 * @discussion EN: Pass completion only with the final chunk. The callback
 *             reports the real playback terminal state, not enqueue success.
 *             CN: 仅在最终分片传入 completion；该回调表示真实播放终态，
 *             而不是数据入队成功。
 */
- (void)appendPCMData:(NSData *)pcmData
              voiceId:(NSString *)voiceId
               isFinal:(BOOL)isFinal
            completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;

/** @brief Interrupt current output @chinese 中断当前输出 */
- (void)interruptOutput;

/** @brief Stop capture and playback @chinese 停止采音与播放 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
