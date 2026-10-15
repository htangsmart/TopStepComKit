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

NS_ASSUME_NONNULL_END
