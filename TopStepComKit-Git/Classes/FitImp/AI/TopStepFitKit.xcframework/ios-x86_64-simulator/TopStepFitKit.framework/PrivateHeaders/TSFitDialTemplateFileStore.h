//
//  TSFitDialTemplateFileStore.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Owned temporary-file store for downloaded dial resources
 * @chinese 已下载表盘资源的专用临时文件存储
 */
@interface TSFitDialTemplateFileStore : NSObject

/**
 * @brief Initialize an owned file store
 * @chinese 初始化专用文件存储
 * @param fileManager EN: File manager. CN: 文件管理器。
 * @param directoryURL EN: Owned temporary directory. CN: 专用临时目录。
 * @return EN: Initialized store, or nil. CN: 初始化后的存储，失败时为 nil。
 */
- (nullable instancetype)initWithFileManager:(NSFileManager *)fileManager
                                directoryURL:(NSURL *)directoryURL NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Move and validate a completed download
 * @chinese 移动并校验已完成的下载
 * @param location EN: URLSession temporary location. CN: URLSession 临时地址。
 * @param sourceURL EN: Final HTTPS response URL. CN: 最终 HTTPS 响应地址。
 * @param expectedSize EN: Expected size, or zero. CN: 预期大小，未指定时为零。
 * @param defaultExtension EN: Fallback file extension. CN: 备用文件扩展名。
 * @param error EN: File or validation error. CN: 文件或校验错误。
 * @return EN: Owned local file URL, or nil. CN: 存储持有的本地文件地址，失败时为 nil。
 */
- (nullable NSURL *)storeDownloadAtLocation:(NSURL *)location
                                  sourceURL:(NSURL *)sourceURL
                               expectedSize:(NSUInteger)expectedSize
                           defaultExtension:(NSString *)defaultExtension
                                      error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Remove a file inside the owned directory
 * @chinese 删除专用目录内的文件
 * @param fileURL EN: Local file URL. CN: 本地文件地址。
 * @param error EN: Removal error. CN: 删除错误。
 * @return EN: YES when removed or absent. CN: 已删除或不存在时返回 YES。
 */
- (BOOL)removeFileAtURL:(NSURL *)fileURL error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
