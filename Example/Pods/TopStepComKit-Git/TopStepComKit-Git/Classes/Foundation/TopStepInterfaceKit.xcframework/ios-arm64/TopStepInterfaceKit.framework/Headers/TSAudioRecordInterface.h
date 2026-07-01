//
//  TSAudioRecordInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/30.
//

#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio recording stop reason
 * @chinese 录音结束原因
 */
typedef NS_ENUM(NSUInteger, TSAudioRecordStopReason) {
    TSAudioRecordStopReasonUnknown = 0,        ///< 未知原因
    TSAudioRecordStopReasonUserInitiated,      ///< 用户主动停止
    TSAudioRecordStopReasonMaxDurationReached, ///< 达到最大录音时长
    TSAudioRecordStopReasonDeviceError,        ///< 设备异常
    TSAudioRecordStopReasonStorageFull,        ///< 存储空间不足
    TSAudioRecordStopReasonDisconnected,       ///< 设备断连
    TSAudioRecordStopReasonInterrupted         ///< 录音被中断
};

/**
 * @brief Normal audio recording maximum duration result callback
 * @chinese 普通录音最大时长结果回调
 *
 * @param maximumDuration
 * EN: Maximum duration in minutes, valid for normal audio recording only
 * CN: 最大录音时长，单位分钟，仅对普通录音有效
 *
 * @param error
 * EN: Error information, nil when successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAudioRecordMaximumDurationResultBlock)(NSUInteger maximumDuration, NSError * _Nullable error);

/**
 * @brief Audio recording data callback
 * @chinese 录音数据回调
 *
 * @param audioData
 * EN: Real-time audio data reported by device during AI audio recording
 * CN: 设备在 AI 录音过程中上报的实时音频数据
 */
typedef void(^TSAudioRecordDataReceivedBlock)(NSData *audioData);

/**
 * @brief Audio recording finish callback
 * @chinese 录音结束回调
 *
 * @param stopReason
 * EN: Final stop reason of the current audio recording session
 * CN: 当前录音会话最终结束原因
 *
 * @param error
 * EN: Error information, nil when recording ends normally
 * CN: 错误信息，录音正常结束时为 nil
 */
typedef void(^TSAudioRecordFinishHandler)(TSAudioRecordStopReason stopReason, NSError * _Nullable error);

/**
 * @brief Audio recording interface
 * @chinese 录音功能接口
 */
@protocol TSAudioRecordInterface <TSKitBaseInterface>

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
                                    completion:(TSCompletionBlock)completion;

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
- (void)startNormalAudioRecording:(TSCompletionBlock)startCompletion
                    finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;

/**
 * @brief Stop normal audio recording
 * @chinese 停止普通录音
 *
 * @param completion
 * EN: Callback invoked when the stop command finishes
 * CN: 停止录音命令完成时回调
 */
- (void)stopNormalAudioRecording:(TSCompletionBlock)completion;

/**
 * @brief Start AI audio recording
 * @chinese 开始 AI 录音
 *
 * @param startCompletion
 * EN: Callback invoked when the start command finishes
 * CN: 开始录音命令完成时回调
 *
 * @param didReceiveAudioData
 * EN: Callback invoked when device reports real-time audio data
 * CN: 设备上报实时音频数据时回调
 *
 * @param finishHandler
 * EN: Callback invoked when the current recording session ends
 * CN: 当前录音会话结束时回调
 */
- (void)startAIAudioRecording:(TSCompletionBlock)startCompletion
          didReceiveAudioData:(nullable TSAudioRecordDataReceivedBlock)didReceiveAudioData
                finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;

/**
 * @brief Stop AI audio recording
 * @chinese 停止 AI 录音
 *
 * @param completion
 * EN: Callback invoked when the stop command finishes
 * CN: 停止录音命令完成时回调
 */
- (void)stopAIAudioRecording:(TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
