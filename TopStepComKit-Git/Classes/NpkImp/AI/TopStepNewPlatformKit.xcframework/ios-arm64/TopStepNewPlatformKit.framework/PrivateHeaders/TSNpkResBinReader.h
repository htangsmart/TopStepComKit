//
//  TSNpkResBinReader.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSBinImageTableItem;
@class TSNpkW30ImageHeader;

NS_ASSUME_NONNULL_BEGIN

/** @brief Length of the fixed file header; the image table starts here @chinese 固定文件头长度，图片索引表从这里开始 */
FOUNDATION_EXTERN const NSUInteger kTSNpkResBinFileHeaderSize;
/** @brief Bytes per image table entry (address + size) @chinese 索引表每项字节数（地址 + 大小） */
FOUNDATION_EXTERN const NSUInteger kTSNpkResBinTableEntrySize;
/** @brief Offset of the total file length field @chinese 文件总长度字段的偏移 */
FOUNDATION_EXTERN const NSUInteger kTSNpkResBinOffsetFileLength;
/** @brief Offset of the image count field @chinese 图片总数字段的偏移 */
FOUNDATION_EXTERN const NSUInteger kTSNpkResBinOffsetImageCount;
/** @brief Offset of the font table offset field @chinese 字体表偏移字段的偏移 */
FOUNDATION_EXTERN const NSUInteger kTSNpkResBinOffsetFontTableOffset;

/**
 * @brief Read-only parser of a dial res.bin
 * @chinese 表盘 res.bin 的只读解析器
 *
 * @discussion
 * [EN]: File layout: [512-byte header][image table][font table][images, each 4-byte aligned]["TOPSTEPE"].
 *       Header fields used: platform marker @16 (6 bytes), file length @28, image count @108, font table offset @112.
 *       A table entry stores the image address and the payload size (without the 24-byte image header).
 * [CN]: 文件布局：[512 字节文件头][图片索引表][字体表][各图片，起始地址 4 字节对齐]["TOPSTEPE"]。
 *       用到的文件头字段：偏移 16 平台标记（6 字节）、偏移 28 文件长度、偏移 108 图片总数、偏移 112 字体表偏移。
 *       索引表项记录图片地址和数据长度（不含 24 字节图片头）。
 */
@interface TSNpkResBinReader : NSObject

/** @brief Whole file content @chinese 整个文件内容 */
@property (nonatomic, strong, readonly) NSData *fileData;
/** @brief Platform marker, e.g. "Shenju" or "AB579X" @chinese 平台标记，例如 "Shenju"、"AB579X" */
@property (nonatomic, copy, readonly) NSString *platformMarker;
/** @brief Image table entries in index order; address 0 means an empty slot @chinese 按下标排列的索引表项；地址为 0 表示空槽 */
@property (nonatomic, copy, readonly) NSArray<TSBinImageTableItem *> *tableItems;
/** @brief Value of the font table offset header field @chinese 文件头里的字体表偏移字段值 */
@property (nonatomic, assign, readonly) uint32_t fontTableOffsetField;
/** @brief Bytes between the end of the image table and the first image @chinese 索引表结束到第一张图之间的字节（字体表） */
@property (nonatomic, strong, readonly) NSData *fontTableData;

/**
 * @brief Parse a res.bin file
 * @chinese 解析 res.bin 文件
 *
 * @param filePath EN: Path of res.bin. CN: res.bin 路径。
 * @param error EN: Failure reason (unreadable, truncated, bad footer...). CN: 失败原因（读不到、被截断、尾标不对等）。
 * @return EN: Reader, or nil on failure. CN: 解析器，失败返回 nil。
 */
+ (nullable instancetype)readerWithFilePath:(NSString *)filePath
                                      error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Parsed image header of a slot
 * @chinese 某个槽位的图片头
 *
 * @return EN: nil for an empty or out-of-range slot. CN: 空槽或越界时返回 nil。
 */
- (nullable TSNpkW30ImageHeader *)imageHeaderAtIndex:(NSUInteger)index;

/**
 * @brief Stored bytes of a slot: image header followed by payload
 * @chinese 某个槽位的存储内容：图片头加数据
 *
 * @return EN: nil for an empty or out-of-range slot. CN: 空槽或越界时返回 nil。
 */
- (nullable NSData *)storedImageDataAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
