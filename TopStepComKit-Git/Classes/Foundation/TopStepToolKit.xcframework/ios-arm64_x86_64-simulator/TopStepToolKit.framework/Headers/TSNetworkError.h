//
//  TSNetworkError.h
//  TopStepToolKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stable errors produced by the generic ToolKit network layer
 * @chinese ToolKit 通用网络层产生的稳定错误
 */
typedef NS_ENUM(NSInteger, TSToolNetworkErrorCode) {
    TSToolNetworkErrorCodeInvalidRequest = 1001,
    TSToolNetworkErrorCodeInsecureURL,
    TSToolNetworkErrorCodeCancelled,
    TSToolNetworkErrorCodeTransportFailed,
    TSToolNetworkErrorCodeInvalidResponse,
    TSToolNetworkErrorCodeHTTPStatusFailed,
    TSToolNetworkErrorCodeEmptyData,
    TSToolNetworkErrorCodeInvalidJSON,
    TSToolNetworkErrorCodeSizeMismatch,
    TSToolNetworkErrorCodeMaximumSizeExceeded,
    TSToolNetworkErrorCodeFileOperationFailed,
};

/** @brief ToolKit network error domain @chinese ToolKit 网络错误域 */
FOUNDATION_EXPORT NSString *const TSToolNetworkErrorDomain;

/**
 * @brief NSNumber HTTP status code in an HTTP failure error's userInfo
 * @chinese HTTP 失败错误 userInfo 中的 NSNumber 类型状态码
 */
FOUNDATION_EXPORT NSString *const TSToolNetworkHTTPStatusCodeKey;

/**
 * @brief Create a normalized ToolKit network error
 * @chinese 创建归一化的 ToolKit 网络错误
 * @param code EN: Stable error code. CN: 稳定错误码。
 * @param description EN: Human-readable description. CN: 可读错误说明。
 * @param underlyingError EN: Optional source error. CN: 可选原始错误。
 * @return EN: Normalized error. CN: 归一化错误。
 */
FOUNDATION_EXPORT NSError *TSToolNetworkMakeError(
    TSToolNetworkErrorCode code,
    NSString *description,
    NSError *_Nullable underlyingError);

NS_ASSUME_NONNULL_END
