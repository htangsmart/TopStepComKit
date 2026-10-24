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
    /// @brief No audio capture (text-only round) @chinese 不采集音频（纯文本轮次）
    TSAIAudioInputChannelNone = 4,
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
    /// @brief Follow the current system media output without enforcing a port type
    /// @chinese 跟随系统当前媒体输出，不强制手机扬声器或蓝牙端口，也不改变输入通道
    TSAIAudioOutputChannelSystemDefault = 6,
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

/**
 * @brief Why the effective route differs from the requested route
 * @chinese 实际路由与请求路由不同的原因
 */
typedef NS_ENUM(NSInteger, TSAIAudioRouteFallbackReason) {
    /// @brief The requested route was used as is (or fully automatic) @chinese 按请求使用（或请求本就是自动）
    TSAIAudioRouteFallbackReasonNone = 0,
    /// @brief The requested input was kept and only the output was downgraded @chinese 保留请求的输入，只降级了输出
    TSAIAudioRouteFallbackReasonOutputDowngraded = 1,
    /// @brief The requested route was unavailable and an automatic route was used @chinese 请求路由不可用，改用自动路由
    TSAIAudioRouteFallbackReasonAutomaticRoute = 2,
};

/**
 * @brief Microphone permission status
 * @chinese 麦克风权限状态
 */
typedef NS_ENUM(NSInteger, TSAIMicrophonePermissionStatus) {
    /// @brief The user has not been asked yet @chinese 尚未询问用户
    TSAIMicrophonePermissionStatusNotDetermined = 0,
    /// @brief The user denied the permission @chinese 用户已拒绝
    TSAIMicrophonePermissionStatusDenied = 1,
    /// @brief The user granted the permission @chinese 用户已授权
    TSAIMicrophonePermissionStatusGranted = 2,
};

/**
 * @brief Why the Bluetooth earbuds microphone could not be started (TSAIErrorCodeEarbudsMicrophoneUnavailable)
 * @chinese 蓝牙耳机麦克风无法启动的原因（TSAIErrorCodeEarbudsMicrophoneUnavailable）
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsMicrophoneFailureReason) {
    /// @brief Another failure; see NSUnderlyingErrorKey @chinese 其他原因，见 NSUnderlyingErrorKey
    TSAIEarbudsMicrophoneFailureReasonUnknown = 0,
    /// @brief No earbuds microphone (HFP) was ever offered by the system @chinese 系统从未提供耳机麦克风（HFP）端口
    TSAIEarbudsMicrophoneFailureReasonNeverSeen = 1,
    /// @brief The earbuds microphone was offered but the system did not switch to it @chinese 有耳机麦克风端口，但系统没有切过去
    TSAIEarbudsMicrophoneFailureReasonNotRouted = 2,
    /// @brief Only microphones of other headsets were offered @chinese 只有其他耳机 / 车载等设备的麦克风，不是当前这副耳机
    TSAIEarbudsMicrophoneFailureReasonForeignHeadset = 3,
    /// @brief Another audio session has higher priority (e.g. a phone call) @chinese 其他音频会话优先级更高（如通话中）
    TSAIEarbudsMicrophoneFailureReasonPriority = 4,
    /// @brief Recording cannot start while the App is in the background @chinese App 在后台，系统不允许开始录音
    TSAIEarbudsMicrophoneFailureReasonBackground = 5,
    /// @brief The audio session was interrupted while starting @chinese 启动过程中音频会话被系统打断
    TSAIEarbudsMicrophoneFailureReasonInterrupted = 6,
    /// @brief The earbuds microphone was offered, but the system kept the Bluetooth call audio on another
    ///        connected device (e.g. a watch with Bluetooth calling or a car kit); its name is in
    ///        `TSAIErrorUserInfoEarbudsMicrophoneRouteHolderNameKey`
    /// @chinese 耳机麦克风可用，但系统把蓝牙通话音频留在另一台已连接的蓝牙设备上（如支持蓝牙通话的手表、车载），
    ///          该设备名称见 `TSAIErrorUserInfoEarbudsMicrophoneRouteHolderNameKey`
    TSAIEarbudsMicrophoneFailureReasonOtherDeviceActive = 7,
};

/**
 * @brief Why the audio input was lost during a session (TSAIErrorCodeAudioInputLost)
 * @chinese 会话进行中音频输入丢失的原因（TSAIErrorCodeAudioInputLost）
 */
typedef NS_ENUM(NSInteger, TSAIAudioInputLostReason) {
    /// @brief Another reason @chinese 其他原因
    TSAIAudioInputLostReasonUnknown = 0,
    /// @brief The earbuds disconnected (or went into the case) and did not come back in time @chinese 耳机断开或入仓，宽限期内未恢复
    TSAIAudioInputLostReasonTimeout = 1,
    /// @brief The user switched the audio route away from the earbuds @chinese 用户把音频路由切离了耳机（如控制中心切到 iPhone）
    TSAIAudioInputLostReasonUserRouteChange = 2,
    /// @brief A system interruption (call, Siri, ...) did not resume @chinese 系统打断（来电、Siri 等）后未恢复
    TSAIAudioInputLostReasonInterrupted = 3,
    /// @brief A higher-priority AI session took over the microphone @chinese 更高优先级的 AI 会话接管了麦克风
    TSAIAudioInputLostReasonPreempted = 4,
    /// @brief The audio session kept being reconfigured by another component @chinese 音频会话被进程内其他组件反复改写
    TSAIAudioInputLostReasonSessionReconfigured = 5,
    /// @brief The system media services were reset and the input could not be rebuilt @chinese 系统媒体服务重置后未能重建输入
    TSAIAudioInputLostReasonMediaServicesReset = 6,
};

/**
 * @brief Posted on the main thread when AIKit has no phone-microphone audio path left and every teardown finished
 * @chinese AIKit 已不再使用手机麦系统音频链路、且所有拆除都已完成时，在主线程发出
 *
 * @discussion
 * EN: Session completions no longer wait for the audio session teardown, so they may arrive up to
 *     about 1 s before it. A host that configures AVAudioSession itself right after a session ended
 *     (e.g. to play a recording) should check `isAudioSessionIdle` of the audio routing interface
 *     and, when it is NO, wait for this notification first. The teardowns include the phone
 *     microphone and the earbuds microphone (audio graph and session restore).
 * CN: 会话 completion 不再等待音频会话拆除，最多可能比拆除早约 1 秒到达。宿主在会话结束后立即自行
 *     配置 AVAudioSession（例如播放录音）时，应先查看音频路由接口的 `isAudioSessionIdle`，
 *     为 NO 时等待本通知。拆除包括手机麦与耳机麦（音频图与会话恢复）。
 */
FOUNDATION_EXPORT NSNotificationName const TSAIAudioSessionDidBecomeIdleNotification;

NS_ASSUME_NONNULL_END
