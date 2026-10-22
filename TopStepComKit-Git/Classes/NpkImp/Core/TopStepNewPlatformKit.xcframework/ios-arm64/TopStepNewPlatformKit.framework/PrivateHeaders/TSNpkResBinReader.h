//
//  TSNpkResBinReader.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSBinImageTableItem;
@class TSNpkW30ImageHeader;
@protocol TSNpkResStorageFormat;

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
 * [EN]: File layout: [512-byte header][image table][preserved region][images][file padding]["TOPSTEPE"].
 *       Header fields used: platform marker @16 (6 bytes), file length @28, image count @108, font table offset @112.
 *       W30 entries store payload size without the 24-byte image header; 579X lengths use validated physical boundaries.
 * [CN]: 文件布局：[512 字节文件头][图片索引表][保留区域][各图片][文件对齐字节]["TOPSTEPE"]；Android 可紧密排列图片。
 *       用到的文件头字段：偏移 16 平台标记（6 字节）、偏移 28 文件长度、偏移 108 图片总数、偏移 112 字体表偏移。
 *       W30 表项长度不含 24 字节图片头；579X 通过已验证的物理边界确定长度，不套 W30 布局。
 */
@interface TSNpkResBinReader : NSObject

/**
 * @brief Validated source file bytes
 * @chinese 已校验的源文件字节
 *
 * @discussion
 * [EN]: Retains the complete res.bin, including header, preserved region and footer, for subsequent immutable range reads.
 * [CN]: 持有完整 res.bin，包括文件头、保留区与尾标，供后续按范围只读获取原始数据。
 */
@property (nonatomic, strong, readonly) NSData *fileData;
/**
 * @brief Validated six-byte platform marker
 * @chinese 已校验的六字节平台标记
 *
 * @discussion
 * [EN]: ASCII bytes at file offset 16: Shenju selects W30 and AB579X selects LVGL 579X; other values are rejected.
 * [CN]: 文件偏移 16 的 ASCII 字节；Shenju 对应 W30，AB579X 对应 LVGL 579X，其余值拒绝解析。
 */
@property (nonatomic, copy, readonly) NSString *platformMarker;
/**
 * @brief Storage rules selected from the file marker
 * @chinese 按文件标记选择的存储规则
 *
 * @discussion
 * [EN]: Non-nil on successful parsing; determines record sizes, header handling and preserved-region interpretation.
 * [CN]: 解析成功时非空，决定记录长度、图片头处理及保留区解释方式。
 */
@property (nonatomic, strong, readonly) id<TSNpkResStorageFormat> storageFormat;
/**
 * @brief Stored byte lengths in table-index order
 * @chinese 按表项下标排列的实际存储字节数
 *
 * @discussion
 * [EN]: One NSNumber per table item; empty slots are zero. W30 includes its header; 579X spans validated physical boundaries.
 * [CN]: 每个表项对应一个 NSNumber，空槽为 0；W30 含图片头，579X 取已验证物理边界间的跨度。
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *storedLengths;
/**
 * @brief Parsed image-table entries
 * @chinese 已解析的图片索引表项
 *
 * @discussion
 * [EN]: Preserves table-index order, not physical address order. Address zero marks an empty slot; size-field semantics vary by platform.
 * [CN]: 保留索引顺序，不代表物理地址顺序；地址 0 表示空槽，第二字段含义取决于平台。
 */
@property (nonatomic, copy, readonly) NSArray<TSBinImageTableItem *> *tableItems;
/**
 * @brief Original preserved-region offset field
 * @chinese 原始保留区偏移字段
 *
 * @discussion
 * [EN]: Raw uint32 at file offset 112, in file bytes; zero is allowed. Nonzero values must lie between table end and first image.
 * [CN]: 文件偏移 112 处的原始 uint32，以文件字节为单位；允许为 0，非零时须位于表尾与首图之间。
 */
@property (nonatomic, assign, readonly) uint32_t fontTableOffsetField;
/**
 * @brief Bytes preserved between the table and first image
 * @chinese 索引表与首张图片之间的保留字节
 *
 * @discussion
 * [EN]: Starts at table end, not necessarily fontTableOffsetField; may be empty. 579X bytes are not interpreted as W30 glyph references.
 * [CN]: 从索引表末尾开始，不一定从 fontTableOffsetField 开始，可为空；579X 数据不按 W30 字形引用解释。
 */
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
