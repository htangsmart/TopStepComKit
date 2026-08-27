//
//  TSFitDialTemplateDownloader.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateResource;
@class TSDownloader;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion for a downloaded dial-template file
 * @chinese 表盘模板文件下载完成回调
 */
typedef void (^TSFitDialTemplateDownloadCompletion)(NSURL *_Nullable localFileURL,
                                                     NSError *_Nullable error);

/**
 * @brief Downloader for per-session template and style files
 * @chinese 按会话下载模板与样式文件的下载器
 */
@interface TSFitDialTemplateDownloader : NSObject

/**
 * @brief Initialize with the shared ToolKit download mechanism
 * @chinese 使用 ToolKit 通用下载机制初始化
 * @return EN: Initialized downloader. CN: 初始化后的下载器。
 */
- (instancetype)init;

/**
 * @brief Initialize with an injectable ToolKit downloader
 * @chinese 使用可注入的 ToolKit 下载器初始化
 * @param downloader EN: Generic ToolKit downloader. CN: ToolKit 通用下载器。
 * @return EN: Initialized downloader, or nil. CN: 初始化后的下载器，依赖无效时为 nil。
 */
- (nullable instancetype)initWithDownloader:(TSDownloader *)downloader NS_DESIGNATED_INITIALIZER;

/**
 * @brief Download and validate the template binary
 * @chinese 下载并校验模板二进制
 * @param resource EN: Parsed template resource. CN: 已解析的模板资源。
 * @param completion EN: Completion called asynchronously on the main thread once. CN: 在主线程异步调用一次。
 * @return EN: Cancellable download task, or nil if no task started. CN: 可取消下载任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)downloadTemplateForResource:(TSFitDialTemplateResource *)resource
                                                 completion:(TSFitDialTemplateDownloadCompletion)completion;

/**
 * @brief Download and validate the selected first style image
 * @chinese 下载并校验选中的首个样式图片
 * @param resource EN: Parsed GUI template resource. CN: 已解析的 GUI 模板资源。
 * @param completion EN: Completion called asynchronously on the main thread once. CN: 在主线程异步调用一次。
 * @return EN: Cancellable download task, or nil if no task started. CN: 可取消下载任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)downloadFirstStyleImageForResource:
    (TSFitDialTemplateResource *)resource
    completion:(TSFitDialTemplateDownloadCompletion)completion;

/**
 * @brief Download and validate a dial style image
 * @chinese 下载并校验表盘样式图片
 * @param imageURL EN: HTTPS style image URL. CN: HTTPS 样式图片地址。
 * @param completion EN: Completion called asynchronously on the main thread once. CN: 在主线程异步调用一次。
 * @return EN: Cancellable download task, or nil if no task started. CN: 可取消下载任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)downloadStyleImageAtURL:(NSURL *)imageURL
                                             completion:(TSFitDialTemplateDownloadCompletion)completion;

/**
 * @brief Remove a file created by this downloader
 * @chinese 删除由当前下载器创建的文件
 * @param fileURL EN: Local file URL to remove. CN: 要删除的本地文件地址。
 * @param error EN: File-removal error. CN: 文件删除错误。
 * @return EN: YES when removed or already absent. CN: 已删除或原本不存在时返回 YES。
 */
- (BOOL)removeDownloadedFileAtURL:(NSURL *)fileURL
                            error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
