//
//  TSNpkResPlan.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSNpkDialBuildRequest;
@class TSNpkResBinReader;
@class TSNpkResImageSpec;
@class TSNpkScreenLocator;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief The complete list of res.bin image changes for one build
 * @chinese 一次造包对 res.bin 的全部图片改动
 */
@interface TSNpkResPlan : NSObject

/** @brief Replace/add/remove entries, at most one per table index @chinese 替换、新增、移除项，每个下标至多一项 */
@property (nonatomic, copy, readonly) NSArray<TSNpkResImageSpec *> *specs;
/** @brief Image count of the rebuilt file @chinese 重建后文件的图片总数 */
@property (nonatomic, assign, readonly) NSUInteger imageCount;
/** @brief Table index written for each user background, in user order @chinese 每张用户背景写入的图片下标，按用户顺序 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *backgroundTableIndexes;

- (instancetype)initWithSpecs:(NSArray<TSNpkResImageSpec *> *)specs
                   imageCount:(NSUInteger)imageCount
       backgroundTableIndexes:(NSArray<NSNumber *> *)backgroundTableIndexes NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Decides which images of res.bin change for one draft type
 * @chinese 针对一种草稿类型，决定 res.bin 里哪些图片要改
 *
 * @discussion
 * [EN]: One implementation per draft type. Index 0 is always the preview image.
 * [CN]: 每种草稿类型一个实现。下标 0 固定是预览图。
 */
@protocol TSNpkResPlanner <NSObject>

- (nullable TSNpkResPlan *)planWithRequest:(TSNpkDialBuildRequest *)request
                              previewImage:(UIImage *)previewImage
                                    reader:(TSNpkResBinReader *)reader
                                   locator:(TSNpkScreenLocator *)locator
                                     error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
