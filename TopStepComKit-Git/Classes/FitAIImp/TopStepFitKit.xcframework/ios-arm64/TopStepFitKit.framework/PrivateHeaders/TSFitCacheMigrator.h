//
//  TSFitCacheMigrator.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Migration error domain. @chinese 缓存迁移错误域。 */
FOUNDATION_EXPORT NSString * const TSFitCacheMigrationErrorDomain;

/** @brief Migration failure stages. @chinese 缓存迁移失败阶段。 */
typedef NS_ENUM(NSInteger, TSFitCacheMigrationErrorCode) {
    TSFitCacheMigrationErrorInvalidPath = 1001,
    TSFitCacheMigrationErrorRead,
    TSFitCacheMigrationErrorConflict,
    TSFitCacheMigrationErrorCopy,
    TSFitCacheMigrationErrorVerification,
    TSFitCacheMigrationErrorMarker,
    TSFitCacheMigrationErrorPublish,
    TSFitCacheMigrationErrorCleanup,
};

/**
 * @brief Prepares FitCloud cache before SDK initialization; internal API only.
 * @chinese FitCloud 初始化前的缓存准备器，仅限 SDK 内部使用。
 */
@interface TSFitCacheMigrator : NSObject

/** @brief Non-sensitive preparation summary. @chinese 不含用户信息的准备结果摘要。 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *summary;

/**
 * @brief Creates an isolated cache migrator.
 * @chinese 创建使用指定目录与文件管理器的迁移器。
 * @param documentsDirectory EN: Current sandbox Documents URL. CN: 当前沙盒 Documents 地址。
 * @param targetRelativePath EN: Cache path relative to Documents. CN: 相对 Documents 的缓存路径。
 * @param fileManager EN: File operations, injectable in tests. CN: 文件管理器，可在测试中注入故障。
 * @return EN: Migrator instance. CN: 迁移器实例。
 */
- (instancetype)initWithDocumentsDirectory:(NSURL *)documentsDirectory
                       targetRelativePath:(NSString *)targetRelativePath
                              fileManager:(NSFileManager *)fileManager NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Prepares the target synchronously without deleting legacy caches.
 * @chinese 同步准备目标目录，不删除旧缓存；失败后禁止继续初始化 FitCloud。
 * @param error EN: Preparation error. CN: 准备失败原因。
 * @return EN: YES when the target is ready. CN: 目标准备完成时返回 YES。
 */
- (BOOL)prepareCacheWithError:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Removes legacy caches after successful FitCloud initialization.
 * @chinese FitCloud 初始化成功后删除旧缓存；失败可重试，不影响已成功的初始化。
 * @param error EN: First cleanup error. CN: 首个清理错误。
 * @return EN: YES when cleanup succeeds. CN: 清理成功时返回 YES。
 */
- (BOOL)cleanupLegacyCachesWithError:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
