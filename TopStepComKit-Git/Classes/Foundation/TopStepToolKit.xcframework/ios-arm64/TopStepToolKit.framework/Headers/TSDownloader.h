//
//  TSDownloader.h
//  TopStepToolKit
//
//  Created by 磐石 on 2026/7/8.
//

#import <Foundation/Foundation.h>

@class TSManagedDownloadedFile;

NS_ASSUME_NONNULL_BEGIN

/** @brief File download progress callback @chinese 文件下载进度回调 */
typedef void (^TSDownloaderProgressBlock)(NSInteger progress);

/**
 * @brief Legacy file download completion
 * @chinese 兼容文件下载完成回调
 */
typedef void (^TSDownloaderFileBlock)(NSString *_Nullable filePath,
                                      NSError *_Nullable error);

/**
 * @brief JSON request completion
 * @chinese JSON 请求完成回调
 */
typedef void (^TSDownloaderJSONBlock)(id _Nullable json,
                                      NSError *_Nullable error);

/**
 * @brief Managed-file download completion
 * @chinese 受管文件下载完成回调
 */
typedef void (^TSManagedFileCompletion)(TSManagedDownloadedFile *_Nullable file,
                                        NSError *_Nullable error);

/**
 * @brief Generic NSURLSession-based HTTP client and downloader
 * @chinese 基于 NSURLSession 的通用 HTTP 客户端与下载器
 */
@interface TSDownloader : NSObject

/**
 * @brief Create a downloader with a timeout
 * @chinese 使用指定超时创建下载器
 * @param timeoutInterval EN: Timeout in seconds; zero uses 30 seconds. CN: 秒级超时；零使用 30 秒。
 * @return EN: Initialized downloader. CN: 下载器实例。
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeoutInterval;

/**
 * @brief Create a downloader with an injectable session configuration
 * @chinese 使用可注入会话配置创建下载器
 * @param configuration EN: Session configuration. CN: 会话配置。
 * @param timeoutInterval EN: Timeout in seconds; zero uses 30 seconds. CN: 秒级超时；零使用 30 秒。
 * @return EN: Initialized downloader, or nil. CN: 下载器实例，参数无效时为 nil。
 */
- (nullable instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
                                               timeout:(NSTimeInterval)timeoutInterval
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Send a legacy GET request and parse JSON
 * @chinese 发送兼容 GET 请求并解析 JSON
 * @param urlString EN: Complete URL. CN: 完整 URL。
 * @param completion EN: Main-thread completion. CN: 主线程完成回调。
 * @return EN: Cancellable task, or nil. CN: 可取消任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)getJSONWithURL:(NSString *)urlString
                                   completion:(TSDownloaderJSONBlock)completion;

/**
 * @brief Send a legacy JSON POST request
 * @chinese 发送兼容 JSON POST 请求
 * @param urlString EN: Request URL. CN: 请求 URL。
 * @param parameters EN: Optional JSON body. CN: 可选 JSON 请求体。
 * @param completion EN: Main-thread completion. CN: 主线程完成回调。
 * @return EN: Cancellable task, or nil. CN: 可取消任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)postJSONWithURL:(NSString *)urlString
                                    parameters:(nullable NSDictionary *)parameters
                                    completion:(TSDownloaderJSONBlock)completion;

/**
 * @brief Execute an HTTPS request and parse its JSON response
 * @chinese 执行 HTTPS 请求并解析 JSON 响应
 * @param request EN: Fully constructed HTTPS request. CN: 已完整构建的 HTTPS 请求。
 * @param completion EN: Main-thread completion called once. CN: 主线程单次完成回调。
 * @return EN: Cancellable task, or nil. CN: 可取消任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)performJSONRequest:(NSURLRequest *)request
                                        completion:(TSDownloaderJSONBlock)completion;

/**
 * @brief Download a file through the legacy path API
 * @chinese 通过兼容路径 API 下载文件
 * @param urlString EN: Source URL. CN: 来源 URL。
 * @param directory EN: Destination directory. CN: 目标目录。
 * @param fileName EN: Optional destination name. CN: 可选目标文件名。
 * @param progress EN: Optional main-thread progress. CN: 可选主线程进度回调。
 * @param completion EN: Main-thread completion. CN: 主线程完成回调。
 * @return EN: Cancellable task, or nil. CN: 可取消任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)downloadFileWithURL:(NSString *)urlString
                                       toDirectory:(NSString *)directory
                                          fileName:(nullable NSString *)fileName
                                          progress:(nullable TSDownloaderProgressBlock)progress
                                        completion:(TSDownloaderFileBlock)completion;

/**
 * @brief Download, validate and atomically store a ToolKit-owned file
 * @chinese 下载、校验并原子保存 ToolKit 受管文件
 * @param request EN: Fully constructed HTTPS request. CN: 已完整构建的 HTTPS 请求。
 * @param expectedSize EN: Exact size, or zero to skip exact validation. CN: 期望精确大小，零表示跳过。
 * @param maximumSize EN: Maximum size, or zero for no explicit limit. CN: 最大大小，零表示不额外限制。
 * @param fileExtension EN: Destination extension without a dot. CN: 不含点的目标扩展名。
 * @param completion EN: Main-thread completion called once. CN: 主线程单次完成回调。
 * @return EN: Cancellable task, or nil. CN: 可取消任务，未启动时为 nil。
 */
- (nullable NSURLSessionTask *)downloadManagedFileWithRequest:(NSURLRequest *)request
                                                 expectedSize:(NSUInteger)expectedSize
                                                  maximumSize:(NSUInteger)maximumSize
                                                fileExtension:(NSString *)fileExtension
                                                   completion:(TSManagedFileCompletion)completion;

/** @brief Cancel all tasks @chinese 取消全部任务 */
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
