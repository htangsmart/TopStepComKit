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

/** @brief Cancellation for a logical request spanning fallback tasks. @chinese 覆盖回退任务的逻辑请求取消接口。 */
@protocol TSNpkDialStyleCancellable <NSObject>
/** @brief Cancel the active transport and complete the logical request once. @chinese 取消当前传输并单次结束逻辑请求。 */
- (void)cancel;
@end

typedef void (^TSNpkDialStyleCloudCompletion)(TSNpkDialStyleResource *_Nullable resource,
                                               NSError *_Nullable error);

/** @brief NPK custom-dial metadata service @chinese NPK 自定义表盘元数据服务 */
@interface TSNpkDialStyleCloudService : NSObject

/**
 * @brief Initialize the configured service
 * @chinese 初始化已配置的服务
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
- (nullable id<TSNpkDialStyleCancellable>)fetchResourceWithContext:(TSNpkDialStyleRequestContext *)context
                                              completion:(TSNpkDialStyleCloudCompletion)completion;

/** @brief Build the Android-compatible multipart POST request @chinese 构建与 Android 一致的 multipart POST 请求 */
- (nullable NSURLRequest *)requestWithContext:(TSNpkDialStyleRequestContext *)context
                                        error:(NSError *_Nullable *_Nullable)error;

/** @brief Invalidate successful metadata cache @chinese 清空成功的元数据缓存 */
- (void)invalidateCache;

@end

NS_ASSUME_NONNULL_END
