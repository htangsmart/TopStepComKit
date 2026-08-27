//
//  TSFitDialTemplateMultipartRequestBuilder.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateCloudConfiguration;
@class TSFitDialTemplateRequestContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Builder for production-compatible multipart template requests
 * @chinese 兼容生产接口的 multipart 模板请求构建器
 */
@interface TSFitDialTemplateMultipartRequestBuilder : NSObject

/**
 * @brief Initialize with cloud configuration
 * @chinese 使用云服务配置初始化
 * @param configuration EN: Endpoint and timeout configuration. CN: 接口与超时配置。
 * @return EN: Initialized builder, or nil. CN: 初始化后的构建器，失败时为 nil。
 */
- (nullable instancetype)initWithConfiguration:(TSFitDialTemplateCloudConfiguration *)configuration
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Build a multipart POST request
 * @chinese 构建 multipart POST 请求
 * @param context EN: Current device request context. CN: 当前设备请求上下文。
 * @param error EN: Request construction error. CN: 请求构造错误。
 * @return EN: Multipart request, or nil. CN: multipart 请求，失败时为 nil。
 */
- (nullable NSURLRequest *)requestWithContext:(TSFitDialTemplateRequestContext *)context
                                        error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
