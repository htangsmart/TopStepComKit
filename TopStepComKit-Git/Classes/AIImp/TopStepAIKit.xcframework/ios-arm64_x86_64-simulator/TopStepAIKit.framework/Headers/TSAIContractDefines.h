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
};

NS_ASSUME_NONNULL_END
