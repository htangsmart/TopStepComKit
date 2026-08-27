//
//  TSFitCustomDialTemplateResolver.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSFitDialTemplateDownloader;
@class TSFitDialTemplateRepository;
@class TSFitDialTemplateRequestContextLoader;
@class TSFitDialTemplateResource;
@class TSFitDialTemplateSelector;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Resolved Fit template file and its ownership
 * @chinese 已解析的 Fit 模板文件及其所有权
 */
@interface TSFitResolvedDialTemplate : NSObject

/** @brief Local raw .bin file URL @chinese 本地原始 .bin 文件地址 */
@property (nonatomic, strong, readonly) NSURL *fileURL;
/** @brief Cloud resource metadata, nil for a local override @chinese 云资源元数据，本地覆盖时为 nil */
@property (nonatomic, strong, readonly, nullable) TSFitDialTemplateResource *resource;
/** @brief Whether the SDK owns the local file @chinese 本地文件是否由 SDK 持有 */
@property (nonatomic, assign, readonly) BOOL isSDKOwned;

/** @brief Idempotently release an SDK-owned file @chinese 幂等释放 SDK 持有的文件 */
- (void)cleanup;

@end

/** @brief Cancellable template-resolution task @chinese 可取消的模板解析任务 */
@interface TSFitCustomDialTemplateResolutionTask : NSObject
/** @brief Cancel metadata or file download @chinese 取消元数据或文件下载 */
- (void)cancel;
@end

/** @brief Template resolution completion @chinese 模板解析完成回调 */
typedef void (^TSFitCustomDialTemplateResolutionCompletion)(
    TSFitResolvedDialTemplate *_Nullable resolution,
    NSError *_Nullable error);

/**
 * @brief Resolves a valid raw Fit .bin for a custom dial
 * @chinese 为自定义表盘解析有效的 Fit 原始 .bin
 */
@interface TSFitCustomDialTemplateResolver : NSObject

/**
 * @brief Initialize with production dependencies
 * @chinese 使用生产依赖初始化
 * @return EN: Initialized resolver. CN: 初始化后的解析器。
 */
- (instancetype)init;

/**
 * @brief Initialize with injectable dependencies
 * @chinese 使用可注入依赖初始化
 * @param contextLoader EN: Current-device context loader. CN: 当前设备上下文加载器。
 * @param repository EN: Shared metadata repository. CN: 共享元数据仓库。
 * @param selector EN: Provider template selector. CN: Provider 模板选择器。
 * @param downloader EN: Managed Fit resource downloader. CN: Fit 受管资源下载器。
 * @return EN: Initialized resolver, or nil. CN: 初始化后的解析器，参数无效时为 nil。
 */
- (nullable instancetype)initWithContextLoader:(TSFitDialTemplateRequestContextLoader *)contextLoader
                                    repository:(TSFitDialTemplateRepository *)repository
                                      selector:(TSFitDialTemplateSelector *)selector
                                    downloader:(TSFitDialTemplateDownloader *)downloader
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Resolve a local override or download the matching cloud template
 * @chinese 解析本地覆盖文件，或下载匹配的云端模板
 * @param style EN: Requested time style. CN: 请求的时间样式。
 * @param localFilePath EN: Optional caller-owned .bin path. CN: 可选的调用方持有 .bin 路径。
 * @param completion EN: Main-thread completion. CN: 主线程完成回调。
 * @return EN: Cancellable resolution task. CN: 可取消的解析任务。
 */
- (TSFitCustomDialTemplateResolutionTask *)resolveTemplateForTimeStyle:(TSDialTimeStyle)style
                                                         localFilePath:(nullable NSString *)localFilePath
                                                            completion:(TSFitCustomDialTemplateResolutionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
