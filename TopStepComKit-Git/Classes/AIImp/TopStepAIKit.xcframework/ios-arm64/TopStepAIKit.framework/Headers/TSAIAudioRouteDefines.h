//
//  TSAIAudioRouteDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio input channels available to an AI session
 * @chinese AI 会话可使用的音频输入通道
 */
typedef NS_ENUM(NSInteger, TSAIAudioInputChannel) {
    /// @brief Unknown input channel @chinese 未知输入通道
    TSAIAudioInputChannelUnknown = -1,
    /// @brief Let AIKit resolve the input channel @chinese 由 AIKit 解析输入通道
    TSAIAudioInputChannelAutomatic = 0,
    /// @brief Built-in microphone PCM @chinese 系统内置麦克风 PCM
    TSAIAudioInputChannelBuiltInMic = 1,
    /// @brief Bluetooth HFP/SCO microphone @chinese 蓝牙 HFP/SCO 麦克风
    TSAIAudioInputChannelSCO = 2,
    /// @brief Device Opus data decoded to PCM @chinese 设备 Opus 数据解码后的 PCM
    TSAIAudioInputChannelOpus = 3,
};

/**
 * @brief Audio output channels available to an AI session
 * @chinese AI 会话可使用的音频输出通道
 */
typedef NS_ENUM(NSInteger, TSAIAudioOutputChannel) {
    /// @brief Unknown output channel @chinese 未知输出通道
    TSAIAudioOutputChannelUnknown = -1,
    /// @brief Do not synthesize or play audio @chinese 不合成且不播放音频
    TSAIAudioOutputChannelNone = 0,
    /// @brief Let AIKit resolve the output channel @chinese 由 AIKit 解析输出通道
    TSAIAudioOutputChannelAutomatic = 1,
    /// @brief Built-in speaker @chinese 系统内置扬声器
    TSAIAudioOutputChannelBuiltInSpeaker = 2,
    /// @brief Bluetooth HFP/SCO output @chinese 蓝牙 HFP/SCO 输出
    TSAIAudioOutputChannelSCO = 3,
    /// @brief Bluetooth A2DP output @chinese 蓝牙 A2DP 输出
    TSAIAudioOutputChannelA2DP = 4,
    /// @brief PCM sent through the device data channel @chinese 通过设备数据通道下发的 PCM
    TSAIAudioOutputChannelOpus = 5,
};

/**
 * @brief Policy applied when a requested route is unavailable
 * @chinese 请求路由不可用时采用的策略
 */
typedef NS_ENUM(NSInteger, TSAIAudioRouteUnavailablePolicy) {
    /// @brief Fail without changing either channel @chinese 不修改任一通道并直接失败
    TSAIAudioRouteUnavailablePolicyFail = 0,
    /// @brief Resolve another complete automatic route @chinese 重新解析另一条完整自动路由
    TSAIAudioRouteUnavailablePolicyUseAutomaticRoute = 1,
};

/**
 * @brief Echo cancellation used by a complete audio route
 * @chinese 完整音频路由使用的回声消除方式
 */
typedef NS_ENUM(NSInteger, TSAIAudioEchoCancellationMode) {
    /// @brief Echo cancellation is unknown @chinese 回声消除状态未知
    TSAIAudioEchoCancellationModeUnknown = -1,
    /// @brief No echo cancellation @chinese 不具备回声消除
    TSAIAudioEchoCancellationModeNone = 0,
    /// @brief System duplex echo cancellation @chinese 系统双工回声消除
    TSAIAudioEchoCancellationModeSystem = 1,
    /// @brief Device-side echo cancellation @chinese 设备侧回声消除
    TSAIAudioEchoCancellationModeDevice = 2,
};

/**
 * @brief Lifecycle state of an AI audio route
 * @chinese AI 音频路由生命周期状态
 */
typedef NS_ENUM(NSInteger, TSAIAudioRouteState) {
    TSAIAudioRouteStateUnknown = 0,
    TSAIAudioRouteStateResolving,
    TSAIAudioRouteStateActivating,
    TSAIAudioRouteStateActive,
    TSAIAudioRouteStateStopping,
    TSAIAudioRouteStateInterrupted,
    TSAIAudioRouteStateFailed,
};

NS_ASSUME_NONNULL_END
