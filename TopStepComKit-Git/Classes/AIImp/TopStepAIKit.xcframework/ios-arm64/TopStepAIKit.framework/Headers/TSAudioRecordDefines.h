//
//  TSAudioRecordDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio recording stop reason
 * @chinese 录音结束原因
 */
typedef NS_ENUM(NSUInteger, TSAudioRecordStopReason) {
    TSAudioRecordStopReasonUnknown = 0,        ///< Unknown reason / 未知原因
    TSAudioRecordStopReasonUserInitiated,      ///< Stopped by user / 用户主动停止
    TSAudioRecordStopReasonMaxDurationReached, ///< Maximum duration reached / 达到最大录音时长
    TSAudioRecordStopReasonDeviceError,        ///< Device error / 设备异常
    TSAudioRecordStopReasonStorageFull,        ///< Storage full / 存储空间不足
    TSAudioRecordStopReasonDisconnected,       ///< Device disconnected / 设备断连
    TSAudioRecordStopReasonInterrupted         ///< Recording interrupted / 录音被中断
};

/**
 * @brief AI audio recording scene
 * @chinese AI 录音场景
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordScene) {
    TSAIAudioRecordSceneUnknown = -1, ///< Unknown scene / 未知场景
    TSAIAudioRecordSceneOnSite = 1,   ///< On-site recording / 现场录音
    TSAIAudioRecordSceneCall = 2      ///< Call recording / 通话录音
};

/**
 * @brief AI audio recording state
 * @chinese AI 录音状态
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordState) {
    TSAIAudioRecordStateUnknown = 0,  ///< Unknown state / 未知状态
    TSAIAudioRecordStateIdle,         ///< Idle / 空闲
    TSAIAudioRecordStateStarting,     ///< Starting / 启动中
    TSAIAudioRecordStateRecording,    ///< Recording / 录音中
    TSAIAudioRecordStateStopping,     ///< Stopping / 停止中
    TSAIAudioRecordStateInterrupted   ///< Interrupted / 已中断
};

/**
 * @brief AI audio recording interrupt reason
 * @chinese AI 录音中断原因
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordInterruptReason) {
    TSAIAudioRecordInterruptReasonUnknown = -1,      ///< Unknown reason / 未知原因
    TSAIAudioRecordInterruptReasonLowBattery = 1,    ///< Low battery / 低电量
    TSAIAudioRecordInterruptReasonIncomingCall = 2,  ///< Incoming call / 来电
    TSAIAudioRecordInterruptReasonOther = 255        ///< Other reason / 其他原因
};

NS_ASSUME_NONNULL_END
