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

/**
 * @brief Image-header magic byte
 * @chinese 图片头魔数字节
 *
 * @discussion
 * [EN]: Stored at byte 0. emptyHeader sets 0x19; parsing preserves the source value without validating it here.
 * [CN]: 位于偏移 0；emptyHeader 设置为 0x19，解析入口保留原值，不在此类中校验魔数。
 */
@property (nonatomic, assign) uint8_t magic;
/**
 * @brief Color-format identifier
 * @chinese 颜色格式编号
 *
 * @discussion
 * [EN]: Stored at byte 1 and must agree with the encoded payload; the storage strategy assigns the encoder result.
 * [CN]: 位于偏移 1，必须与负载编码一致；存储策略使用编码器结果设置。
 */
@property (nonatomic, assign) uint8_t colorFormat;
/**
 * @brief Image encoding flags
 * @chinese 图片编码标志位
 *
 * @discussion
 * [EN]: Little-endian field at byte 2. The model preserves raw bits; rewritten images take flags from their encoder.
 * [CN]: 位于偏移 2 的小端字段；模型保留原始位，新编码图片使用编码器提供的标志。
 */
@property (nonatomic, assign) uint16_t flags;
/**
 * @brief Image width in pixels
 * @chinese 图片宽度，单位像素
 *
 * @discussion
 * [EN]: Unsigned little-endian field at byte 4; zero in an empty header until an encoder result is assigned.
 * [CN]: 位于偏移 4 的无符号小端字段；空头初始为 0，随后由编码结果赋值。
 */
@property (nonatomic, assign) uint16_t width;
/**
 * @brief Image height in pixels
 * @chinese 图片高度，单位像素
 *
 * @discussion
 * [EN]: Unsigned little-endian field at byte 6; paired with width to describe the encoded image.
 * [CN]: 位于偏移 6 的无符号小端字段，与 width 共同描述编码图片尺寸。
 */
@property (nonatomic, assign) uint16_t height;
/**
 * @brief Format-specific row stride in bytes
 * @chinese 与格式相关的行跨度，单位字节
 *
 * @discussion
 * [EN]: Little-endian field at byte 8; supplied by the selected encoder rather than inferred by this header model.
 * [CN]: 位于偏移 8 的小端字段，由具体编码器提供，图片头模型不自行推算。
 */
@property (nonatomic, assign) uint16_t stride;
/**
 * @brief Encoded payload length in bytes
 * @chinese 编码负载字节长度
 *
 * @discussion
 * [EN]: Little-endian field at byte 12, excluding the 24-byte image header; assigned from the encoded payload length.
 * [CN]: 位于偏移 12 的小端字段，不包含 24 字节图片头；写入时取编码负载长度。
 */
@property (nonatomic, assign) uint32_t dataSize;
/**
 * @brief Payload offset relative to the image record
 * @chinese 负载相对图片记录起点的偏移
 *
 * @discussion
 * [EN]: Little-endian field at byte 16; emptyHeader and rewritten records use 24, not an absolute res.bin file address.
 * [CN]: 位于偏移 16 的小端字段；空头及重写记录使用 24，不是 res.bin 内的绝对文件地址。
 */
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
