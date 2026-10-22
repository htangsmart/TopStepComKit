//
//  TSAIContractDefines.h
//  TopStepAIKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Common completion block for AI operations
 * @chinese AI 操作通用完成回调
 *
 * @param success
 * EN: Whether the operation completed successfully
 * CN: 操作是否成功完成
 *
 * @param error
 * EN: Error information; nil on success
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSAICompletionBlock)(BOOL success, NSError * _Nullable error);

/**
 * @brief TopStepAIKit error domain
 * @chinese TopStepAIKit 错误域
 */
FOUNDATION_EXPORT NSErrorDomain const TSAIErrorDomain;

/**
 * @brief TopStepAIKit common error codes
 * @chinese TopStepAIKit 通用错误码
 */
typedef NS_ERROR_ENUM(TSAIErrorDomain, TSAIErrorCode) {
    TSAIErrorCodeInvalidParameter = 1001,
    TSAIErrorCodeNotSupported = 1002,
    TSAIErrorCodeContextInactive = 1003,
    TSAIErrorCodeProviderUnavailable = 1004,
    TSAIErrorCodeBridgeUnavailable = 1005,
    TSAIErrorCodeActivationSuperseded = 1006,
    TSAIErrorCodeBusy = 1007,
    TSAIErrorCodeCancelled = 1008,
    TSAIErrorCodeAuthorizationRequired = 1009,
    TSAIErrorCodeTaskFailed = 1010,
    TSAIErrorCodeContentRejected = 1011,
    TSAIErrorCodeTimeout = 1012,
    TSAIErrorCodeNetworkUnavailable = 1013,
    TSAIErrorCodeInvalidResponse = 1014,
    TSAIErrorCodeAudioRouteUnavailable = 1015,
    TSAIErrorCodeAudioRouteMismatch = 1016,
    /** @brief The service is temporarily unavailable. @chinese 服务暂时不可用，可按策略重试。 */
    TSAIErrorCodeServiceTemporarilyUnavailable = 1017,
    /** @brief The service rate limit was reached. @chinese 服务请求触发限流。 */
    TSAIErrorCodeRateLimited = 1018,
    /** @brief The service explicitly rejected device authorization. @chinese 服务明确拒绝设备授权。 */
    TSAIErrorCodeAuthorizationRejected = 1019,
    /**
     * @brief The cloud needed client-supplied context (e.g. location) that never arrived in time.
     * @chinese 云端需要客户端补充信息（如定位）但超时未提供；userInfo 带 `TSAIErrorUserInfoIntentIdKey` / `TSAIErrorUserInfoRoundIndexKey`。
     */
    TSAIErrorCodeIntentActionRequired = 1020,
    /**
     * @brief Microphone permission has not been granted.
     * @chinese 未获得麦克风权限。SDK 不会代为弹出授权窗，请先请求权限；
     *          userInfo 的 `TSAIErrorUserInfoMicrophonePermissionStatusKey` 区分未询问 / 已拒绝（TSAIMicrophonePermissionStatus）。
     */
    TSAIErrorCodeMicrophonePermissionDenied = 1021,
    /**
     * @brief The Bluetooth earbuds microphone could not be started.
     * @chinese 蓝牙耳机麦克风无法启动；userInfo 的 `TSAIErrorUserInfoEarbudsMicrophoneFailureReasonKey`
     *          为 TSAIEarbudsMicrophoneFailureReason，系统底层错误在 `NSUnderlyingErrorKey`。
     */
    TSAIErrorCodeEarbudsMicrophoneUnavailable = 1022,
    /**
     * @brief The audio input was lost during a session and did not recover.
     * @chinese 会话进行中音频输入丢失且未恢复；userInfo 的 `TSAIErrorUserInfoAudioInputLostReasonKey` 为 TSAIAudioInputLostReason。
     */
    TSAIErrorCodeAudioInputLost = 1023,
};

/**
 * @brief userInfo key: vendor intent identifier (NSString) of the pending intent
 * @chinese userInfo 键：待处理意图的厂商标识（NSString）
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoIntentIdKey;

/**
 * @brief userInfo key: round index (NSNumber) of the pending intent
 * @chinese userInfo 键：待处理意图所在轮次（NSNumber）
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoRoundIndexKey;

/**
 * @brief userInfo key: microphone permission status (NSNumber of TSAIMicrophonePermissionStatus), with 1021
 * @chinese userInfo 键：麦克风权限状态（NSNumber，TSAIMicrophonePermissionStatus），随 1021 返回
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoMicrophonePermissionStatusKey;

/**
 * @brief userInfo key: earbuds microphone failure reason (NSNumber of TSAIEarbudsMicrophoneFailureReason), with 1022
 * @chinese userInfo 键：耳机麦克风启动失败原因（NSNumber，TSAIEarbudsMicrophoneFailureReason），随 1022 返回
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoEarbudsMicrophoneFailureReasonKey;

/**
 * @brief userInfo key: name of the other Bluetooth device holding the call audio (NSString), with 1022 and
 *        TSAIEarbudsMicrophoneFailureReasonOtherDeviceActive
 * @chinese userInfo 键：占用蓝牙通话音频的另一台蓝牙设备名称（NSString），随 1022 且原因为
 *          TSAIEarbudsMicrophoneFailureReasonOtherDeviceActive 时返回
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoEarbudsMicrophoneRouteHolderNameKey;

/**
 * @brief userInfo key: audio input lost reason (NSNumber of TSAIAudioInputLostReason), with 1023
 * @chinese userInfo 键：音频输入丢失原因（NSNumber，TSAIAudioInputLostReason），随 1023 返回
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoAudioInputLostReasonKey;

/**
 * @brief userInfo key: why a task was cancelled (NSString, e.g. TSAICancellationReasonTooShort), with 1008
 * @chinese userInfo 键：任务被取消的原因（NSString，例如 TSAICancellationReasonTooShort），随 1008 返回
 */
FOUNDATION_EXPORT NSErrorUserInfoKey const TSAIErrorUserInfoCancellationReasonKey;

/**
 * @brief Cancellation reason: stopped before any usable speech was recorded ("speak a little longer")
 * @chinese 取消原因：停止时还没录到可用的语音（可提示「说话时间太短」）
 */
FOUNDATION_EXPORT NSString * const TSAICancellationReasonTooShort;

NS_ASSUME_NONNULL_END
