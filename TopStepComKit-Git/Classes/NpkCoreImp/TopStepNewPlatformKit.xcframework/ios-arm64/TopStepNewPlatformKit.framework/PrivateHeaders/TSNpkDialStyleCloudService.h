//
//  TSNpkDialStyleCloudService.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

@class TSDownloader;
@class TSNpkDialStyleRequestContext;
@class TSNpkDialStyleResource;
@class TSNpkDialStyleResponseParser;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSNpkDialStyleCloudCompletion)(TSNpkDialStyleResource *_Nullable resource,
                                               NSError *_Nullable error);

/** @brief NPK custom-dial metadata service @chinese NPK 自定义表盘元数据服务 */
@interface TSNpkDialStyleCloudService : NSObject

/**
 * @brief Initialize the production service
 * @chinese 初始化生产服务
 * @param endpointURL EN: Configured HTTPS endpoint. CN: 已配置的 HTTPS 服务地址。
 */
- (nullable instancetype)initWithEndpointURL:(NSURL *)endpointURL;

/** @brief Initialize with injectable dependencies @chinese 使用可注入依赖初始化 */
- (nullable instancetype)initWithEndpointURL:(NSURL *)endpointURL
                                  downloader:(TSDownloader *)downloader
                                      parser:(TSNpkDialStyleResponseParser *)parser
                               cacheInterval:(NSTimeInterval)cacheInterval NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/** @brief Fetch and cache the current NPK resource @chinese 获取并缓存当前 NPK 资源 */
- (nullable NSURLSessionTask *)fetchResourceWithContext:(TSNpkDialStyleRequestContext *)context
                                              completion:(TSNpkDialStyleCloudCompletion)completion;

/** @brief Build the JSON POST request @chinese 构建 JSON POST 请求 */
- (nullable NSURLRequest *)requestWithContext:(TSNpkDialStyleRequestContext *)context
                                        error:(NSError *_Nullable *_Nullable)error;

/** @brief Invalidate successful metadata cache @chinese 清空成功的元数据缓存 */
- (void)invalidateCache;

@end

NS_ASSUME_NONNULL_END
