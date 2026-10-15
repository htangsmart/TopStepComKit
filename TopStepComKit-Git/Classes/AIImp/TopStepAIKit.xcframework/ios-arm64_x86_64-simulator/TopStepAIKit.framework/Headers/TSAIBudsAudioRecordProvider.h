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

/** @brief Reevaluate recording authorization @chinese 鉴权变化时重新评估当前录音转写 */
- (void)notifyTranscriptionAuthorizationChanged;

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
 * @brief Notify device request to start AI audio recording with request details
 * @chinese 通知携带请求详情的设备请求开始 AI 录音
 *
 * @param request
 * EN: Scene, input channel and identifier of the device request
 * CN: 设备请求的场景、输入通道与标识
 */
- (void)notifyRequestStartAIAudioRecordingWithRequest:(TSAIAudioRecordDeviceRequest *)request;

/**
 * @brief Decide how to handle a device pause/resume request
 * @chinese 决定设备暂停/继续请求的处置方式
 *
 * [EN]: Ignore while finishing (stop pending or cloud session finished) or when no
 *       recording is active; AcknowledgeOnly when already in the requested pause
 *       state (crossed operations, duplicate delivery, or a lost ACK); Forward otherwise.
 * [CN]: 收尾中（已请求停止或云端会话已结束）或无进行中录音时忽略；已处于请求的暂停态
 *       （两端操作交叉、重复上报、ACK 丢失）时仅应答；其余转发 App。
 *
 * @param paused EN: YES for a pause request, NO for resume. CN: 暂停请求为 YES，继续为 NO。
 */
- (TSAIAudioRecordDeviceRequestDisposition)dispositionForDeviceRequestToChangePauseState:(BOOL)paused;

/**
 * @brief Notify device request to pause AI audio recording
 * @chinese 通知设备请求暂停 AI 录音
 */
- (void)notifyRequestPauseAIAudioRecording;

/**
 * @brief Notify device request to resume AI audio recording
 * @chinese 通知设备请求继续 AI 录音
 */
- (void)notifyRequestResumeAIAudioRecording;

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
