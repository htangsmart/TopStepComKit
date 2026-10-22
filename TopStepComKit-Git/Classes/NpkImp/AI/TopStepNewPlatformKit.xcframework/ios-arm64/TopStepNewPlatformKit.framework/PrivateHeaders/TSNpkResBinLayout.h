//
//  TSNpkResBinLayout.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSBinImageTableItem;
@class TSNpkResBinReader;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Computes where every image goes in the rebuilt res.bin
 * @chinese 计算重建后的 res.bin 中每张图片的位置
 *
 * @discussion
 * [EN]: Pure calculation, no I/O. Images are placed in table-index order after the preserved region on
 *       4-byte boundaries. StorageFormat determines both the index size field and the real stored length.
 * [CN]: 纯计算，不做读写。图片按索引顺序排在保留区域之后，起始地址按 4 字节对齐。
 *       索引第二字段与实际存储长度分别由 StorageFormat 决定；不假设旧模板物理地址按索引递增。
 */
@interface TSNpkResBinLayout : NSObject

/**
 * @brief Number of image-table slots in the rebuilt file
 * @chinese 重建文件的图片索引槽位数
 *
 * @discussion
 * [EN]: Includes empty slots and cannot be smaller than the template count; equals tableItems.count.
 * [CN]: 包含空槽，不得小于模板槽位数；等于 tableItems.count，不是非空图片数量。
 */
@property (nonatomic, assign, readonly) NSUInteger imageCount;
/**
 * @brief Rebuilt image-table entries
 * @chinese 重建后的图片索引表项
 *
 * @discussion
 * [EN]: Indexed by resource slot; nonempty addresses are four-byte aligned after the preserved area, while removed slots are zeroed.
 * [CN]: 按资源槽位排列；非空图片从保留区后按 4 字节对齐分配地址，移除槽位清零。
 */
@property (nonatomic, copy, readonly) NSArray<TSBinImageTableItem *> *tableItems;
/**
 * @brief Stored record lengths in bytes
 * @chinese 实际存储记录长度，单位字节
 *
 * @discussion
 * [EN]: One value per table slot, excluding alignment added after each record; kept separate from the platform-specific index size field.
 * [CN]: 与表项逐个对应，不含记录之后新增的对齐填充；独立于平台特有的索引第二字段。
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *storedLengths;
/**
 * @brief Start offset of the rebuilt preserved region
 * @chinese 重建保留区的起始偏移
 *
 * @discussion
 * [EN]: File-byte offset immediately after the enlarged table: 512 plus imageCount times 8.
 * [CN]: 扩展后索引表紧随的文件字节偏移，计算为 512 加 imageCount 乘 8。
 */
@property (nonatomic, assign, readonly) NSUInteger fontTableOffset;
/**
 * @brief Surviving original image address mapping
 * @chinese 原有存活图片的地址映射
 *
 * @discussion
 * [EN]: NSNumber old-file address keys map to new-file address values for retained or replaced slots; newly added slots have no old address.
 * [CN]: NSNumber 键值分别为旧、新文件字节地址，包含保留及替换的旧槽位；新增槽位没有旧地址映射。
 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSNumber *> *addressMap;
/**
 * @brief Original addresses removed by the plan
 * @chinese 计划移除的原始图片地址
 *
 * @discussion
 * [EN]: Contains nonzero old addresses only; used to detect preserved references that would target removed resources.
 * [CN]: 仅包含被删除图片的非零旧地址，供检测保留引用是否指向已移除资源。
 */
@property (nonatomic, copy, readonly) NSSet<NSNumber *> *removedAddresses;
/**
 * @brief Whether a surviving original image moved
 * @chinese 是否有原有存活图片发生位移
 *
 * @discussion
 * [EN]: YES when any mapped old address differs from its new address; adding or removing a slot alone does not set it.
 * [CN]: 任一映射中的新旧地址不同即为 YES；仅新增或删除槽位本身不直接设置此标记。
 */
@property (nonatomic, assign, readonly) BOOL hasMovedImages;

/**
 * @brief Compute the layout
 * @chinese 计算布局
 *
 * @param reader EN: Parsed template res.bin. CN: 已解析的模板 res.bin。
 * @param payloadSizes EN: Table index to encoded payload size, for every replaced or added image.
 *                     CN: 每张被替换或新增的图片：下标到编码后数据长度。
 * @param removedIndexes EN: Table indexes to clear. CN: 要清空的下标。
 * @param imageCount EN: New image count; must not be smaller than the template's. CN: 新的图片总数，不能小于模板的图片总数。
 * @param error EN: Failure reason. CN: 失败原因。
 */
+ (nullable instancetype)layoutWithReader:(TSNpkResBinReader *)reader
                             payloadSizes:(NSDictionary<NSNumber *, NSNumber *> *)payloadSizes
                           removedIndexes:(NSIndexSet *)removedIndexes
                               imageCount:(NSUInteger)imageCount
                                    error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
