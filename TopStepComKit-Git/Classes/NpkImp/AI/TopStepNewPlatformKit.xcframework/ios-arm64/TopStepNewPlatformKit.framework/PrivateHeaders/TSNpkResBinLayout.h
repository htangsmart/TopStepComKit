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
 * [EN]: Pure calculation, no I/O. Images are placed in table-index order after the font table, each starting on
 *       a 4-byte boundary (as the dial tool does). With same-size replacements every address therefore equals
 *       the template's address. Table entries store the payload size without the 24-byte image header.
 * [CN]: 纯计算，不做任何读写。图片按索引表顺序排在字体表之后，每张图起始地址按 4 字节对齐（与表盘工具一致），
 *       所以同尺寸替换时所有地址与模板完全相同。索引表项的大小只记数据长度，不含 24 字节图片头。
 */
@interface TSNpkResBinLayout : NSObject

/** @brief Image count of the new file @chinese 新文件的图片总数 */
@property (nonatomic, assign, readonly) NSUInteger imageCount;
/** @brief New image table; address 0 means an empty slot @chinese 新索引表；地址为 0 表示空槽 */
@property (nonatomic, copy, readonly) NSArray<TSBinImageTableItem *> *tableItems;
/** @brief Offset of the font table in the new file @chinese 字体表在新文件中的偏移 */
@property (nonatomic, assign, readonly) NSUInteger fontTableOffset;
/** @brief Old image address to new image address, for every image that still exists @chinese 仍然存在的图片：旧地址到新地址的映射 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSNumber *> *addressMap;
/** @brief Old addresses of removed images @chinese 被移除图片的旧地址 */
@property (nonatomic, copy, readonly) NSSet<NSNumber *> *removedAddresses;
/** @brief YES when any surviving image moved @chinese 是否有图片的地址发生了变化 */
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
