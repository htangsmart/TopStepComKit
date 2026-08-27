//
//  TSManagedDownloadedFile.h
//  TopStepToolKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A downloaded file whose lifecycle is owned by TopStepToolKit
 * @chinese 生命周期由 TopStepToolKit 管理的下载文件
 */
@interface TSManagedDownloadedFile : NSObject

/** @brief Local file URL @chinese 本地文件地址 */
@property (nonatomic, strong, readonly) NSURL *fileURL;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Idempotently remove the managed file
 * @chinese 幂等删除受管文件
 * @param error EN: Optional removal error. CN: 可选删除错误。
 * @return EN: YES if removed or already absent. CN: 已删除或原本不存在时返回 YES。
 */
- (BOOL)cleanup:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
