//
//  TSFitDialTemplateError.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Dial-template error codes
 * @chinese 表盘模板错误码
 */
typedef NS_ENUM(NSInteger, TSFitDialTemplateErrorCode) {
    TSFitDialTemplateErrorCodeInvalidContext = 1001,
    TSFitDialTemplateErrorCodeInvalidEndpoint,
    TSFitDialTemplateErrorCodeTransportFailed,
    TSFitDialTemplateErrorCodeInvalidHTTPResponse,
    TSFitDialTemplateErrorCodeHTTPStatusFailed,
    TSFitDialTemplateErrorCodeInvalidJSON,
    TSFitDialTemplateErrorCodeBusinessFailure,
    TSFitDialTemplateErrorCodeEmptyData,
    TSFitDialTemplateErrorCodeInvalidResource,
    TSFitDialTemplateErrorCodeInsecureURL,
    TSFitDialTemplateErrorCodeNonGUIStyleResourceUnavailable,
    TSFitDialTemplateErrorCodeDownloadFailed,
    TSFitDialTemplateErrorCodeDownloadTimeout,
    TSFitDialTemplateErrorCodeDownloadEmpty,
    TSFitDialTemplateErrorCodeDownloadSizeMismatch,
    TSFitDialTemplateErrorCodeFileOperationFailed,
    TSFitDialTemplateErrorCodeUnsupportedStyle,
    TSFitDialTemplateErrorCodeCancelled,
};

/**
 * @brief Dial-template error domain
 * @chinese 表盘模板错误域
 */
FOUNDATION_EXPORT NSString *const TSFitDialTemplateErrorDomain;

/**
 * @brief Create a normalized dial-template error
 * @chinese 创建归一化的表盘模板错误
 * @param code EN: Stable error code. CN: 稳定错误码。
 * @param description EN: Human-readable description. CN: 可读错误描述。
 * @param underlyingError EN: Optional underlying error. CN: 可选的底层错误。
 * @return EN: Normalized error. CN: 归一化后的错误。
 */
FOUNDATION_EXPORT NSError *TSFitDialTemplateMakeError(
    TSFitDialTemplateErrorCode code,
    NSString *description,
    NSError *_Nullable underlyingError);

NS_ASSUME_NONNULL_END
