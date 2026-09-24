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

/** @brief Root object; every container inside is mutable @chinese 根对象；内部所有容器均可变 */
@property (nonatomic, strong, readonly) NSMutableDictionary *root;
/** @brief File this document was loaded from @chinese 文档来源文件路径 */
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
