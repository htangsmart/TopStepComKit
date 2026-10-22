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

/**
 * @brief Resource replacement, addition and removal entries
 * @chinese 资源替换、新增及移除项
 *
 * @discussion
 * [EN]: Planners provide at most one operation per table index; the initializer copies the array, not the individual spec objects.
 * [CN]: 规划器为每个表项至多提供一项操作；初始化时复制数组，不深拷贝各 spec 对象。
 */
@property (nonatomic, copy, readonly) NSArray<TSNpkResImageSpec *> *specs;
/**
 * @brief Final image-table slot count
 * @chinese 最终图片索引槽位数
 *
 * @discussion
 * [EN]: Includes preserved and empty slots, not only specs; supplied to binary layout for table growth validation.
 * [CN]: 包含保留槽与空槽，不仅是 specs 数量；交给二进制布局层校验索引表扩容。
 */
@property (nonatomic, assign, readonly) NSUInteger imageCount;
/**
 * @brief Resource indices consumed by screen editing
 * @chinese 屏幕编辑使用的资源下标
 *
 * @discussion
 * [EN]: In input order: background indices for ordinary modes, or DanMu static-image indices whose following slots hold their GIF frames.
 * [CN]: 按输入顺序保存；普通模式为背景下标，弹幕模式为各静态图下标，其 GIF 帧连续分配在该下标之后。
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *backgroundTableIndexes;
/**
 * @brief Fixed DanMu background resource index
 * @chinese 弹幕固定背景资源下标
 *
 * @discussion
 * [EN]: Separate resource preserving the complete background UIImage in DanMu mode; the ordinary initializer sets NSNotFound.
 * [CN]: 弹幕模式单独保存完整背景 UIImage 的资源下标；普通初始化入口设置为 NSNotFound。
 */
@property (nonatomic, assign, readonly) NSUInteger fixedBackgroundTableIndex;

- (instancetype)initWithSpecs:(NSArray<TSNpkResImageSpec *> *)specs
                   imageCount:(NSUInteger)imageCount
       backgroundTableIndexes:(NSArray<NSNumber *> *)backgroundTableIndexes;
/**
 * @brief Initialize a resource plan with an optional fixed background.
 * @chinese 使用可选固定背景初始化资源计划。
 * @param specs EN: Resource changes. CN: 资源修改项。
 * @param imageCount EN: Final table size. CN: 最终资源表项数。
 * @param backgroundTableIndexes EN: Per-item image indexes. CN: 各素材索引。
 * @param fixedBackgroundTableIndex EN: Fixed background or NSNotFound. CN: 固定背景索引或 NSNotFound。
 * @return EN: Immutable plan. CN: 不可变计划。
 */
- (instancetype)initWithSpecs:(NSArray<TSNpkResImageSpec *> *)specs imageCount:(NSUInteger)imageCount backgroundTableIndexes:(NSArray<NSNumber *> *)backgroundTableIndexes fixedBackgroundTableIndex:(NSUInteger)fixedBackgroundTableIndex NS_DESIGNATED_INITIALIZER;
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
