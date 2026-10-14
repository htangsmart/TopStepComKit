//
//  TSNpkW30ImageHeader.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Size of the W30 per-image header @chinese W30 每张图片前的图片头长度（字节） */
FOUNDATION_EXTERN const NSUInteger kTSNpkW30ImageHeaderSize;
/** @brief Magic byte of an LVGL v9 image header @chinese LVGL v9 图片头魔数 */
FOUNDATION_EXTERN const uint8_t kTSNpkW30ImageHeaderMagic;
/** @brief Color format byte of TSC12 (no alpha) @chinese TSC12（不带透明）的格式编号 */
FOUNDATION_EXTERN const uint8_t kTSNpkW30ColorFormatTSC12;
/** @brief Color format byte of TSC12A (with alpha) @chinese TSC12A（带透明）的格式编号 */
FOUNDATION_EXTERN const uint8_t kTSNpkW30ColorFormatTSC12A;
/** @brief Header flag: pixel data is alpha-premultiplied @chinese 图片头标志位：像素数据为预乘 alpha */
FOUNDATION_EXTERN const uint16_t kTSNpkW30ImageFlagPremultiplied;

/**
 * @brief The 24-byte image header stored before every image in a W30 res.bin
 * @chinese W30 res.bin 中每张图片前的 24 字节图片头
 *
 * @discussion
 * [EN]: Layout (little endian): magic(1) colorFormat(1) flags(2) width(2) height(2) stride(2)
 *       reserved(2) dataSize(4) dataOffset(4) reserved(4). Only parses and serializes; knows nothing about files.
 * [CN]: 布局（小端）：魔数(1) 格式编号(1) 标志(2) 宽(2) 高(2) 行字节数(2) 保留(2) 数据长度(4) 数据偏移(4) 保留(4)。
 *       只负责解析与生成，不涉及文件读写。
 */
@interface TSNpkW30ImageHeader : NSObject

@property (nonatomic, assign) uint8_t magic;
@property (nonatomic, assign) uint8_t colorFormat;
@property (nonatomic, assign) uint16_t flags;
@property (nonatomic, assign) uint16_t width;
@property (nonatomic, assign) uint16_t height;
@property (nonatomic, assign) uint16_t stride;
@property (nonatomic, assign) uint32_t dataSize;
@property (nonatomic, assign) uint32_t dataOffset;

/**
 * @brief Parse a header from 24 bytes
 * @chinese 从 24 字节数据解析图片头
 *
 * @param data EN: Exactly 24 bytes or more; only the first 24 are read. CN: 不少于 24 字节，只读取前 24 字节。
 * @return EN: Header, or nil when data is too short. CN: 图片头；数据不足时返回 nil。
 */
+ (nullable instancetype)headerWithData:(NSData *)data;

/**
 * @brief Create an empty header for a newly added image
 * @chinese 为新增图片创建空图片头（保留字段为 0）
 */
+ (instancetype)emptyHeader;

/**
 * @brief Serialize to 24 bytes, keeping reserved bytes of the parsed source
 * @chinese 生成 24 字节数据，保留字段沿用解析来源的原值
 */
- (NSData *)serializedData;

@end

NS_ASSUME_NONNULL_END
