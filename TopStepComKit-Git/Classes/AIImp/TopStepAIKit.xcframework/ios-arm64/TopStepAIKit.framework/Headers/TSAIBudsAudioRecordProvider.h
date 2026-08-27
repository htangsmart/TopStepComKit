//
//  TSAIBudsAudioRecordProvider.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/27.
//

#import <Foundation/Foundation.h>
#import "TSAIAudioRecordProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds implementation of AI audio recording
 * @chinese AIBuds AI 录音能力实现
 */
@interface TSAIBudsAudioRecordProvider : NSObject <TSAIAudioRecordProvider>

/**
 * @brief Notify device request to start AI audio recording
 * @chinese 通知设备请求开始 AI 录音
 *
 * @param scene
 * EN: Recording scene requested by device
 * CN: 设备请求的录音场景
 */
- (void)notifyRequestStartAIAudioRecordingWithScene:(TSAIAudioRecordScene)scene;

/**
 * @brief Notify device request to stop AI audio recording
 * @chinese 通知设备请求停止 AI 录音
 */
- (void)notifyRequestStopAIAudioRecording;

/**
 * @brief Notify AI audio recording interrupt
 * @chinese 通知 AI 录音中断
 *
 * @param reason
 * EN: Interrupt reason
 * CN: 中断原因
 */
- (void)notifyAIAudioRecordingDidInterruptWithReason:(TSAIAudioRecordInterruptReason)reason;

/**
 * @brief Notify AI audio recording voice data
 * @chinese 通知 AI 录音语音数据
 *
 * @param opusData
 * EN: Opus data
 * CN: Opus 数据
 *
 * @param pcmData
 * EN: PCM data
 * CN: PCM 数据
 */
- (void)notifyAIAudioRecordingVoiceDataWithOpusData:(NSData * _Nullable)opusData
                                            pcmData:(NSData * _Nullable)pcmData;

/**
 * @brief Notify AI audio recording state change
 * @chinese 通知 AI 录音状态变化
 *
 * @param state
 * EN: Latest AI audio recording state
 * CN: 最新 AI 录音状态
 */
- (void)notifyAIAudioRecordingStateDidChange:(TSAIAudioRecordState)state;

/**
 * @brief Notify AI audio recording finish
 * @chinese 通知 AI 录音结束
 *
 * @param stopReason
 * EN: Stop reason
 * CN: 结束原因
 *
 * @param error
 * EN: Error info; nil on normal finish
 * CN: 错误信息，正常结束时为 nil
 */
- (void)notifyAIAudioRecordingDidFinishWithStopReason:(TSAudioRecordStopReason)stopReason
                                                error:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
