//
//  TSAIEarbudsMicrophoneStatus.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

#import "TSAIFeatureDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Static availability of the earbuds microphone for one feature
 * @chinese 某功能使用耳机麦克风的静态可用状态
 *
 * @discussion
 * EN: Computed without side effects (no audio session change). Likely / Verified mean the
 *     earbuds microphone can be selected; the final check still happens when a session starts
 *     (failures return 1022).
 * CN: 零副作用计算（不改音频会话）。Likely / Verified 表示可以选择耳机收音；
 *     最终仍以会话开始时的校验为准（失败返回 1022）。
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsMicrophoneState) {
    /// Not supported for this feature, product, provider or session policy / 不支持（功能、产品、Provider 或会话策略）
    TSAIEarbudsMicrophoneStateUnsupported = 0,
    /// The charging case (device) must be connected / 需要连接充电仓（设备）
    TSAIEarbudsMicrophoneStateCaseRequired = 1,
    /// Microphone permission has not been requested / 尚未请求麦克风权限
    TSAIEarbudsMicrophoneStatePermissionNotDetermined = 2,
    /// Microphone permission was denied / 麦克风权限被拒绝
    TSAIEarbudsMicrophoneStatePermissionDenied = 3,
    /// The earbuds are not connected to the phone or are in the case / 耳机未连接手机或在仓内
    TSAIEarbudsMicrophoneStateNotConnected = 4,
    /// Likely usable, not verified yet / 大概率可用，尚未校验
    TSAIEarbudsMicrophoneStateLikely = 5,
    /// This earbuds microphone was verified before / 这副耳机的麦克风曾校验成功
    TSAIEarbudsMicrophoneStateVerified = 6,
};

/**
 * @brief Runtime state of an earbuds microphone session
 * @chinese 耳机麦克风会话的运行期状态
 */
typedef NS_ENUM(NSInteger, TSAIEarbudsMicrophoneInputState) {
    /// Bringing up HFP / 正在拉起耳机通话链路
    TSAIEarbudsMicrophoneInputStateConnecting = 0,
    /// Capturing from the earbuds / 正在从耳机采集
    TSAIEarbudsMicrophoneInputStateReady = 1,
    /// The earbuds left; waiting for them within the grace period (silence is sent) / 耳机离开，宽限期内等待（上送静音）
    TSAIEarbudsMicrophoneInputStateRecovering = 2,
    /// Capturing again after recovering / 恢复后继续采集
    TSAIEarbudsMicrophoneInputStateRecovered = 3,
    /// Interrupted by the system (call, Siri) / 被系统打断（来电、Siri）
    TSAIEarbudsMicrophoneInputStateInterrupted = 4,
    /// The input was lost; the session ends with 1022 / 1023 / 输入丢失，会话以 1022 / 1023 结束
    TSAIEarbudsMicrophoneInputStateLost = 5,
    /// Stopped normally / 正常停止
    TSAIEarbudsMicrophoneInputStateStopped = 6,
};

/**
 * @brief Posted on the main thread when the earbuds microphone status of a feature changes
 * @chinese 某功能的耳机麦克风状态变化时在主线程发出
 *
 * @discussion
 * EN: userInfo: TSAIEarbudsMicrophoneFeatureKey (NSNumber of TSAIFeatureOptions),
 *     TSAIEarbudsMicrophoneStatusKey (TSAIEarbudsMicrophoneStatus).
 * CN: userInfo：TSAIEarbudsMicrophoneFeatureKey（NSNumber，TSAIFeatureOptions）、
 *     TSAIEarbudsMicrophoneStatusKey（TSAIEarbudsMicrophoneStatus）。
 */
FOUNDATION_EXPORT NSNotificationName const TSAIEarbudsMicrophoneStatusDidChangeNotification;

/**
 * @brief Posted on the main thread when a running earbuds microphone session changes state
 * @chinese 运行中的耳机麦克风会话状态变化时在主线程发出
 *
 * @discussion
 * EN: userInfo: FeatureKey, TaskIdKey (route session identifier when there is no task), StateKey,
 *     and when available SampleRateKey (hardware input rate), ReasonKey (TSAIAudioInputLostReason
 *     for Lost) and ErrorKey.
 * CN: userInfo：FeatureKey、TaskIdKey（没有任务时为路由会话标识）、StateKey，
 *     以及可用时的 SampleRateKey（硬件输入采样率）、ReasonKey（Lost 时为 TSAIAudioInputLostReason）与 ErrorKey。
 */
FOUNDATION_EXPORT NSNotificationName const TSAIEarbudsMicrophoneInputDidChangeNotification;

/** @brief userInfo key: NSNumber of TSAIFeatureOptions @chinese userInfo 键：功能（NSNumber） */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneFeatureKey;
/** @brief userInfo key: TSAIEarbudsMicrophoneStatus @chinese userInfo 键：耳机麦克风状态对象 */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneStatusKey;
/** @brief userInfo key: NSString task identifier @chinese userInfo 键：任务标识 */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneTaskIdKey;
/** @brief userInfo key: NSNumber of TSAIEarbudsMicrophoneInputState @chinese userInfo 键：运行期状态 */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneStateKey;
/** @brief userInfo key: NSNumber hardware input sample rate (Hz) @chinese userInfo 键：硬件输入采样率（Hz） */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneSampleRateKey;
/** @brief userInfo key: NSNumber reason (TSAIAudioInputLostReason for Lost) @chinese userInfo 键：原因（Lost 时为 TSAIAudioInputLostReason） */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneReasonKey;
/** @brief userInfo key: NSError @chinese userInfo 键：错误 */
FOUNDATION_EXPORT NSString * const TSAIEarbudsMicrophoneErrorKey;

/**
 * @brief Earbuds microphone status of one feature
 * @chinese 某功能的耳机麦克风状态
 */
@interface TSAIEarbudsMicrophoneStatus : NSObject <NSCopying>

/** @brief Feature this status belongs to @chinese 所属功能 */
@property (nonatomic, assign, readonly) TSAIFeatureOptions feature;

/** @brief Static state @chinese 静态状态 */
@property (nonatomic, assign, readonly) TSAIEarbudsMicrophoneState state;

/** @brief Name of the Bluetooth headset on the current route @chinese 当前路由上的蓝牙耳机名称 */
@property (nonatomic, copy, readonly, nullable) NSString *deviceName;

/** @brief Expected (or verified) UID of the earbuds microphone port @chinese 预计（或已校验）的耳机麦克风端口 UID */
@property (nonatomic, copy, readonly, nullable) NSString *portUID;

/** @brief Debug reason for the state @chinese 状态原因（调试用） */
@property (nonatomic, copy, readonly, nullable) NSString *reason;

/** @brief Likely or Verified @chinese 是否可选择耳机收音（Likely 或 Verified） */
@property (nonatomic, assign, readonly, getter=isUsable) BOOL usable;

/**
 * @brief Create a status
 * @chinese 创建状态
 */
+ (instancetype)statusWithFeature:(TSAIFeatureOptions)feature
                            state:(TSAIEarbudsMicrophoneState)state
                       deviceName:(nullable NSString *)deviceName
                          portUID:(nullable NSString *)portUID
                           reason:(nullable NSString *)reason;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
