//
//  TSFitDialTemplateRepository.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateCloudService;
@class TSFitDialTemplateRequestContext;
@class TSFitDialTemplateResource;

NS_ASSUME_NONNULL_BEGIN

/** @brief Template catalog completion @chinese 模板目录完成回调 */
typedef void (^TSFitDialTemplateRepositoryCompletion)(
    NSArray<TSFitDialTemplateResource *> *_Nullable resources,
    NSError *_Nullable error);

/**
 * @brief Cancellable repository request
 * @chinese 可取消的模板仓库请求
 */
@interface TSFitDialTemplateRepositoryRequest : NSObject

/** @brief Cancel this subscriber @chinese 取消当前订阅者 */
- (void)cancel;

@end

/**
 * @brief Shared Fit dial-template metadata repository
 * @chinese Fit 表盘模板元数据共享仓库
 */
@interface TSFitDialTemplateRepository : NSObject

/**
 * @brief Initialize with production cloud service
 * @chinese 使用生产云服务初始化
 * @return EN: Initialized repository. CN: 初始化后的仓库。
 */
- (instancetype)init;

/**
 * @brief Initialize with an injectable cloud service
 * @chinese 使用可注入云服务初始化
 * @param cloudService EN: Fit template cloud service. CN: Fit 模板云服务。
 * @return EN: Initialized repository, or nil. CN: 初始化后的仓库，参数无效时为 nil。
 */
- (nullable instancetype)initWithCloudService:(TSFitDialTemplateCloudService *)cloudService
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Fetch a catalog while merging requests with the same context
 * @chinese 获取模板目录，并合并相同上下文的请求
 * @param context EN: Current device context. CN: 当前设备上下文。
 * @param completion EN: Main-thread completion. CN: 主线程完成回调。
 * @return EN: Per-subscriber cancellation token. CN: 单个订阅者的取消令牌。
 */
- (TSFitDialTemplateRepositoryRequest *)fetchResourcesWithContext:
    (TSFitDialTemplateRequestContext *)context
    completion:(TSFitDialTemplateRepositoryCompletion)completion;

/** @brief Invalidate successful metadata cache @chinese 清空成功的元数据缓存 */
- (void)invalidateCache;

@end

NS_ASSUME_NONNULL_END
