//
//  TSFitDialTemplateCloudService.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateCloudConfiguration;
@class TSFitDialTemplateRequestContext;
@class TSFitDialTemplateResource;
@class TSFitDialTemplateResponseParser;
@class TSDownloader;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion for resolving a cloud dial-template resource
 * @chinese 解析云端表盘模板资源的完成回调
 */
typedef void (^TSFitDialTemplateCloudCompletion)(TSFitDialTemplateResource *_Nullable resource,
                                                  NSError *_Nullable error);

/** @brief Template-catalog completion @chinese 模板目录完成回调 */
typedef void (^TSFitDialTemplateCatalogCompletion)(
    NSArray<TSFitDialTemplateResource *> *_Nullable resources,
    NSError *_Nullable error);

/**
 * @brief Production cloud service for Fit dial templates
 * @chinese Fit 表盘模板的生产云服务
 */
@interface TSFitDialTemplateCloudService : NSObject

/**
 * @brief Initialize with production endpoints and ToolKit networking
 * @chinese 使用生产接口和 ToolKit 网络能力初始化
 * @return EN: Initialized service. CN: 初始化后的服务。
 */
- (instancetype)init;

/**
 * @brief Initialize with injectable networking dependencies
 * @chinese 使用可注入的网络依赖初始化
 * @param configuration EN: Endpoint and timing configuration. CN: 接口与时间配置。
 * @param downloader EN: ToolKit network executor. CN: ToolKit 网络执行器。
 * @param parser EN: Response parser. CN: 响应解析器。
 * @return
 * EN: Initialized service, or nil for invalid dependencies.
 * CN: 初始化后的服务，依赖无效时为 nil。
 */
- (nullable instancetype)initWithConfiguration:(TSFitDialTemplateCloudConfiguration *)configuration
                                     downloader:(TSDownloader *)downloader
                                         parser:(TSFitDialTemplateResponseParser *)parser
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Fetch the first compatible template resource
 * @chinese 获取首个兼容模板资源
 * @param context EN: Current device request context. CN: 当前设备请求上下文。
 * @param completion EN: Completion called asynchronously on the main thread once. CN: 在主线程异步调用一次。
 */
- (nullable NSURLSessionTask *)fetchTemplateResourceWithContext:(TSFitDialTemplateRequestContext *)context
                                                      completion:(TSFitDialTemplateCloudCompletion)completion;

/**
 * @brief Fetch the complete compatible template catalog
 * @chinese 获取完整兼容模板目录
 * @param context EN: Current device request context. CN: 当前设备请求上下文。
 * @param completion EN: Main-thread completion called once. CN: 主线程单次完成回调。
 * @return EN: Cancellable metadata task, or nil for cached/immediate results. CN: 可取消元数据任务，缓存或立即完成时为 nil。
 */
- (nullable NSURLSessionTask *)fetchTemplateResourcesWithContext:(TSFitDialTemplateRequestContext *)context
                                                        completion:(TSFitDialTemplateCatalogCompletion)completion;

/** @brief Clear cached template catalogs @chinese 清空模板目录缓存 */
- (void)invalidateCache;

/**
 * @brief Build the production-compatible multipart request
 * @chinese 构建兼容生产接口的 multipart 请求
 * @param context EN: Current device request context. CN: 当前设备请求上下文。
 * @param error EN: Request construction error. CN: 请求构造错误。
 * @return EN: Multipart POST request, or nil. CN: multipart POST 请求，失败时为 nil。
 */
- (nullable NSURLRequest *)multipartRequestWithContext:(TSFitDialTemplateRequestContext *)context
                                                  error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
