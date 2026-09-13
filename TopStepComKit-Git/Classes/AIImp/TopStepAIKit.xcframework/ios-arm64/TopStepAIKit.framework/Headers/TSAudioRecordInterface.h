//
//  TSAudioRecordInterface.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/4/30.
//

#import "TSAIContractDefines.h"
#import "TSAudioRecordBlocks.h"
#import "TSAudioRecordDefines.h"
#import "TSAIAudioRecordSpeakerSegment.h"
#import "TSAIAudioRecordSessionResult.h"

@class TSAIAudioRecordConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio recording interface
 * @chinese 录音功能接口
 *
 * @discussion
 * [EN]: This protocol contains legacy normal recording APIs and AI recording APIs. AI recording supports both
 * app-initiated commands and device-initiated request callbacks.
 * [CN]: 该协议包含历史普通录音接口和 AI 录音接口。AI 录音同时支持 App 主动控制与设备主动请求回调。
 */
@protocol TSAudioRecordInterface <NSObject>

/**
 * @brief Set maximum duration for normal audio recording
 * @chinese 设置普通录音最大时长
 *
 * @param maximumDuration
 * EN: Maximum duration in minutes, valid range is 1~240
 * CN: 最大录音时长，单位分钟，有效范围 1~240
 *
 * @param completion
 * EN: Callback invoked when the setting command finishes
 * CN: 设置命令完成时回调
 */
- (void)setNormalAudioRecordingMaximumDuration:(NSUInteger)maximumDuration
                                    completion:(TSAICompletionBlock)completion;

/**
 * @brief Get maximum duration for normal audio recording
 * @chinese 获取普通录音最大时长
 *
 * @param completion
 * EN: Callback invoked when the query finishes
 * CN: 查询完成时回调
 */
- (void)getNormalAudioRecordingMaximumDuration:(nullable TSAudioRecordMaximumDurationResultBlock)completion;

/**
 * @brief Start normal audio recording
 * @chinese 开始普通录音
 *
 * @param startCompletion
 * EN: Callback invoked when the start command finishes
 * CN: 开始录音命令完成时回调
 *
 * @param finishHandler
 * EN: Callback invoked when the current recording session ends
 * CN: 当前录音会话结束时回调
 */
- (void)startNormalAudioRecording:(TSAICompletionBlock)startCompletion
                    finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;

/**
 * @brief Stop normal audio recording
 * @chinese 停止普通录音
 *
 * @param completion
 * EN: Callback invoked when the stop command finishes
 * CN: 停止录音命令完成时回调
 */
- (void)stopNormalAudioRecording:(TSAICompletionBlock)completion;

/**
 * @brief Start AI audio recording with configuration
 * @chinese 通过配置开始 AI 录音
 *
 * @param config
 * EN: AI audio recording session configuration. When nil, implementation uses `TSAIAudioRecordConfig.defaultConfig`
 * CN: AI 录音会话配置。为 nil 时实现层使用 `TSAIAudioRecordConfig.defaultConfig`
 *
 * @param startCompletion
 * EN: Callback invoked when the start command finishes
 * CN: 开始录音命令完成时回调
 *
 * @param didReceiveAudioData
 * EN: Callback invoked when device reports real-time decoded audio data
 * CN: 设备上报实时解码音频数据时回调
 *
 * @param didReceiveSessionResult
 * EN: The only channel for AI semantic results: transcript, event, runtime error, and final report.
 *     The Finish result represents AI session completion and is independent of the audio stream finish callback.
 * CN: AI 语义结果唯一通道：转写、事件、运行期错误和最终报告。
 *     Finish 结果表示 AI 会话完成，与底层音频流结束回调相互独立。
 *
 * @param finishHandler
 * EN: Callback invoked when the underlying audio stream ends; this does not mean ASR is complete.
 * CN: 底层音频流结束时回调；不代表 ASR 或 AI 会话已结束。
 */
- (void)startAIAudioRecordingWithConfig:(nullable TSAIAudioRecordConfig *)config
                        startCompletion:(TSAICompletionBlock)startCompletion
                    didReceiveAudioData:(nullable TSAudioRecordDataReceivedBlock)didReceiveAudioData
                didReceiveSessionResult:(nullable TSAIAudioRecordSessionResultHandler)didReceiveSessionResult
                          finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;

/**
 * @brief Stop AI audio recording
 * @chinese 停止 AI 录音
 *
 * @param completion
 * EN: Callback invoked when the stop command finishes
 * CN: 停止录音命令完成时回调
 */
- (void)stopAIAudioRecording:(TSAICompletionBlock)completion;

/**
 * @brief Report that AI audio recording has started successfully
 * @chinese 回报 AI 录音已成功开始
 *
 * @param scene
 * EN: Recording scene requested by device
 * CN: 设备请求的录音场景
 *
 * @param completion
 * EN: Callback invoked when the report command finishes
 * CN: 回报命令完成时回调
 */
- (void)reportAIAudioRecordingStartSuccessWithScene:(TSAIAudioRecordScene)scene
                                         completion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Report that AI audio recording has stopped
 * @chinese 回报 AI 录音已停止
 *
 * @param completion
 * EN: Callback invoked when the report command finishes
 * CN: 回报命令完成时回调
 */
- (void)reportAIAudioRecordingStoppedWithCompletion:(nullable TSAICompletionBlock)completion;

/**
 * @brief Register device request to start AI audio recording
 * @chinese 注册设备请求开始 AI 录音回调
 *
 * @param block
 * EN: Callback invoked only after a device start request passes eligibility.
 *     Use it to call `startAIAudioRecordingWithConfig:...` for local
 *     preparation; open the recording UI only after `startCompletion`
 *     succeeds, when both App and device are active.
 * CN: 仅当设备开始请求通过启动资格校验后触发。收到后调用
 *     `startAIAudioRecordingWithConfig:...` 准备本地录音；只有
 *     `startCompletion` 成功、App 与设备均已激活后才能打开录音页面。
 */
- (void)registerOnRequestStartAIAudioRecording:(nullable TSAIAudioRecordRequestStartBlock)block;

/**
 * @brief Register device request to stop AI audio recording
 * @chinese 注册设备请求停止 AI 录音回调
 *
 * @param block
 * EN: Callback invoked when device requests to stop AI audio recording
 * CN: 设备请求停止 AI 录音时触发的回调
 */
- (void)registerOnRequestStopAIAudioRecording:(nullable dispatch_block_t)block;

/**
 * @brief Register AI audio recording interrupt callback
 * @chinese 注册 AI 录音中断回调
 *
 * @param block
 * EN: Callback invoked when device reports that recording is interrupted
 * CN: 设备上报录音中断时触发的回调
 */
- (void)registerAIAudioRecordingDidInterrupt:(nullable TSAIAudioRecordInterruptBlock)block;

/**
 * @brief Register AI audio recording voice data callback
 * @chinese 注册 AI 录音语音数据回调
 *
 * @param block
 * EN: Callback invoked when device reports incremental Opus or PCM voice data
 * CN: 设备上报增量 Opus 或 PCM 语音数据时触发的回调
 */
- (void)registerOnAIAudioRecordingVoiceDataReceived:(nullable TSAudioRecordVoiceDataReceivedBlock)block;

/**
 * @brief Register AI audio recording state callback
 * @chinese 注册 AI 录音状态回调
 *
 * @param block
 * EN: Callback invoked when SDK-side AI recording state changes
 * CN: SDK 侧 AI 录音状态变化时触发的回调
 */
- (void)registerAIAudioRecordingStateDidChanged:(nullable TSAIAudioRecordStateBlock)block;

@end

NS_ASSUME_NONNULL_END
