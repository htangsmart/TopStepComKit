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

/**
 * @brief Build a request for the protocol of the current attempt
 * @chinese 为当前尝试的协议构造请求
 * @param context
 * EN: Device snapshot.
 * CN: 设备快照。
 * @param usesNewAPI
 * EN: YES for the new protocol; NO for the legacy protocol, including fallback.
 * CN: YES 表示新协议；NO 表示旧协议，包括回退请求。
 * @param error
 * EN: Construction error.
 * CN: 构造错误。
 * @return
 * EN: Multipart request, or nil on failure.
 * CN: multipart 请求，失败时为 nil。
 */
- (nullable NSURLRequest *)requestWithContext:(TSFitDialTemplateRequestContext *)context
                                   usesNewAPI:(BOOL)usesNewAPI
                                        error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Resolve the validated endpoint shared by inspection and networking
 * @chinese 解析请求检查和网络发送共用的有效地址
 * @param context
 * EN: Device snapshot.
 * CN: 设备快照。
 * @param usesNewAPI
 * EN: Protocol used by this attempt.
 * CN: 本次尝试使用的协议。
 * @param error
 * EN: Endpoint error.
 * CN: 地址错误。
 * @return
 * EN: HTTPS endpoint, or nil.
 * CN: HTTPS 地址，失败时为 nil。
 */
- (nullable NSURL *)endpointURLWithContext:(TSFitDialTemplateRequestContext *)context
                               usesNewAPI:(BOOL)usesNewAPI
                                    error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Resolve the fields shared by inspection and networking
 * @chinese 解析请求检查和网络发送共用的字段
 * @param context
 * EN: Device snapshot retaining the original tool version.
 * CN: 保留原始工具版本的设备快照。
 * @param usesNewAPI
 * EN: Protocol used by this attempt.
 * CN: 本次尝试使用的协议。
 * @param error
 * EN: Parameter or version error.
 * CN: 参数或版本错误。
 * @return
 * EN: Multipart text fields, or nil.
 * CN: multipart 文本字段，失败时为 nil。
 */
- (nullable NSDictionary<NSString *, NSString *> *)fieldsWithContext:(TSFitDialTemplateRequestContext *)context
                                                         usesNewAPI:(BOOL)usesNewAPI
                                                              error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
