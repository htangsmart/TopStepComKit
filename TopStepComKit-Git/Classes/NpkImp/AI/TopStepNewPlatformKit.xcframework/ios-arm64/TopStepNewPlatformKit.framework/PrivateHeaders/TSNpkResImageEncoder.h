//
//  TSNpkResImageEncoder.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkResImageSpec;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Result of encoding one image for res.bin
 * @chinese 一张图片编码后的结果
 *
 * @discussion
 * [EN]: Carries the payload together with every header field that depends on the encoding, so the format label
 *       and the data always come from the same place.
 * [CN]: 同时携带数据和所有取决于编码方式的图片头字段，保证格式标签与数据出自同一处。
 */
@interface TSNpkResEncodedImage : NSObject
/**
 * @brief Encoded image payload
 * @chinese 编码后的图片负载
 *
 * @discussion
 * [EN]: Nonempty on successful encoding. W30 excludes its 24-byte storage header; 579X contains the complete PAR bytes.
 * [CN]: 编码成功时非空；W30 不含 24 字节存储头，579X 则包含完整 PAR 字节。
 */
@property (nonatomic, strong) NSData *data;
/**
 * @brief W30 color-format byte
 * @chinese W30 颜色格式字节
 *
 * @discussion
 * [EN]: Set by the W30 encoder and copied into the image header; unused by the headerless 579X storage strategy.
 * [CN]: 由 W30 编码器设置并写入图片头；无 W30 图片头的 579X 存储策略不使用此值。
 */
@property (nonatomic, assign) uint8_t colorFormat;
/**
 * @brief W30 encoding flags
 * @chinese W30 编码标志位
 *
 * @discussion
 * [EN]: Produced alongside the payload, including premultiplied-alpha state; replaces the old header flags on rewrite.
 * [CN]: 与负载同时产生，包含预乘透明状态；重写时替换旧头标志，不沿用不匹配的旧值。
 */
@property (nonatomic, assign) uint16_t flags;
/**
 * @brief W30 encoded row stride
 * @chinese W30 编码行跨度
 *
 * @discussion
 * [EN]: Byte count defined by the selected W30 encoding and required to be nonzero for storage; not a universal width multiplier.
 * [CN]: 由选定 W30 编码定义的行字节数，写入时须非零；不同格式不能统一按宽度乘固定系数计算。
 */
@property (nonatomic, assign) uint16_t stride;
/**
 * @brief Encoded image width in pixels
 * @chinese 编码图片宽度，单位像素
 *
 * @discussion
 * [EN]: Set from the actual encoder result and stored as an unsigned 16-bit dimension.
 * [CN]: 来自实际编码结果，按 16 位无符号尺寸保存；成功图片应为正值。
 */
@property (nonatomic, assign) uint16_t width;
/**
 * @brief Encoded image height in pixels
 * @chinese 编码图片高度，单位像素
 *
 * @discussion
 * [EN]: Set from the actual encoder result, paired with width for storage metadata.
 * [CN]: 来自实际编码结果，与 width 一起供存储元数据使用；成功图片应为正值。
 */
@property (nonatomic, assign) uint16_t height;
@end

/**
 * @brief Encodes a planned image into the pixel format of one platform/quality
 * @chinese 把计划中的图片编码成某个平台/画质对应的像素格式
 *
 * @discussion
 * [EN]: One implementation per format (W30 TSC now; W30 raw RGB and 579X ParV3 later).
 * [CN]: 一种格式一个实现（当前为 W30 TSC；后续有 W30 无损 RGB、579X ParV3）。
 */
@protocol TSNpkResImageEncoder <NSObject>

/**
 * @brief Encode the image described by a spec
 * @chinese 编码计划项描述的图片
 *
 * @param spec EN: A non-removal spec. CN: 非移除类型的计划项。
 * @param error EN: Failure reason. CN: 失败原因。
 * @return EN: Encoded image, or nil on failure. CN: 编码结果，失败返回 nil。
 */
- (nullable TSNpkResEncodedImage *)encodeImageWithSpec:(TSNpkResImageSpec *)spec
                                                error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
