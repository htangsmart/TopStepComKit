//
//  TSNpkScreenDocument.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief In-memory, mutable screen.json
 * @chinese 内存中可修改的 screen.json
 *
 * @discussion
 * [EN]: Only loads, holds and saves the JSON tree. Finding nodes is TSNpkScreenLocator's job; changing them is the editors' job.
 * [CN]: 只负责读入、持有、写回 JSON 树。查找节点由 TSNpkScreenLocator 负责，修改节点由各编辑器负责。
 */
@interface TSNpkScreenDocument : NSObject

/**
 * @brief Mutable screen JSON root
 * @chinese 可变的屏幕 JSON 根对象
 *
 * @discussion
 * [EN]: Non-nil dictionary after loading; nested containers are mutable and edits remain in memory until saveWithError: succeeds.
 * [CN]: 加载成功后为非空字典，内部容器均可变；编辑先保留在内存，saveWithError: 成功后才落盘。
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *root;
/**
 * @brief Source and save destination path
 * @chinese 文档来源及保存目标路径
 *
 * @discussion
 * [EN]: Copies the path supplied at load time; saveWithError: atomically writes the current root to this same path.
 * [CN]: 复制加载时传入的路径；saveWithError: 将当前根对象原子写回同一路径。
 */
@property (nonatomic, copy, readonly) NSString *filePath;

/**
 * @brief Load screen.json
 * @chinese 读入 screen.json
 */
+ (nullable instancetype)documentWithFilePath:(NSString *)filePath
                                        error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Write the tree back to filePath
 * @chinese 把 JSON 树写回 filePath
 */
- (BOOL)saveWithError:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Deep mutable copy of a JSON value
 * @chinese 深拷贝一个 JSON 值，结果内部容器均可变
 */
+ (nullable id)deepMutableCopyOfJSONObject:(id)object;

/**
 * @brief One-line JSON text of a value, for logging only
 * @chinese 把一个 JSON 值压成一行文本，仅用于日志
 */
+ (NSString *)compactTextOfJSONObject:(nullable id)object;

@end

NS_ASSUME_NONNULL_END
