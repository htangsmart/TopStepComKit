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
 * @brief Party that supplies PCM audio to an AI recording session
 * @chinese AI 录音会话的音频提供方
 *
 * @discussion
 * [EN]: TopStepAIKit only consumes 16 kHz, mono, signed Int16 little-endian PCM
 *       and does not care about the physical microphone. Device means the
 *       connected device uploads audio through the SDK. App means the host App
 *       captures audio itself (phone microphone, Bluetooth headset, etc.) and
 *       pushes it with `appendAIAudioRecordingPCMData:error:`.
 * [CN]: TopStepAIKit 只消费 16 kHz、单声道、有符号 Int16 小端 PCM，
 *       不关心物理麦克风。Device 表示由已连接设备经 SDK 上传音频；
 *       App 表示由宿主 App 自行采集（手机麦克风、蓝牙耳机等），
 *       并通过 `appendAIAudioRecordingPCMData:error:` 推送。
 */
typedef NS_ENUM(NSInteger, TSAIAudioRecordInputSource) {
    TSAIAudioRecordInputSourceDevice = 0, ///< Device supplies audio / 设备提供音频
    TSAIAudioRecordInputSourceApp = 1     ///< Host App supplies PCM / 宿主 App 提供 PCM
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
    TSAIAudioRecordStateInterrupted,  ///< Interrupted / 已中断
    TSAIAudioRecordStatePaused        ///< Paused; audio is dropped until resume / 已暂停，恢复前丢弃音频
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
