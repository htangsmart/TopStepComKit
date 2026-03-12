//
//  TscEncoder.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSC format enumeration
 * @chinese TSC格式枚举
 */
typedef NS_ENUM(NSInteger, TscFormat) {
    TscFormatTSC12A = 0,  // TSC12A格式（预览图使用）
    TscFormatTSC12        // TSC12格式（背景图使用）
};

/**
 * @brief TSC encoder class
 * @chinese TSC编码器类
 *
 * @discussion
 * EN: This class provides TSC format encoding functionality for watch face images.
 *     TSC12A format is used for preview images (imageIndex == 0),
 *     TSC12 format is used for background images (imageIndex > 0).
 *     The implementation follows the same logic as the Java/Kotlin version.
 * CN: 该类提供表盘图片的TSC格式编码功能。
 *     TSC12A格式用于预览图（imageIndex == 0），
 *     TSC12格式用于背景图（imageIndex > 0）。
 *     实现逻辑与Java/Kotlin版本保持一致。
 */
@interface TscEncoder : NSObject

/**
 * @brief Get TSC encoded data size
 * @chinese 获取TSC编码后的数据大小
 *
 * @param width
 * EN: Image width
 * CN: 图片宽度
 *
 * @param height
 * EN: Image height
 * CN: 图片高度
 *
 * @param format
 * EN: TSC format (TSC12A or TSC12)
 * CN: TSC格式（TSC12A或TSC12）
 *
 * @return
 * EN: Encoded data size in bytes
 * CN: 编码后的数据大小（字节）
 *
 * @discussion
 * EN: This method calculates the required buffer size for TSC encoded data.
 *     The calculation is based on the image dimensions and format type.
 * CN: 此方法计算TSC编码数据所需的缓冲区大小。
 *     计算基于图片尺寸和格式类型。
 */
+ (NSUInteger)getTscSizeWithWidth:(NSInteger)width
                           height:(NSInteger)height
                           format:(TscFormat)format;

/**
 * @brief Encode RGBA image data to TSC format
 * @chinese 将RGBA图片数据编码为TSC格式
 *
 * @param rgbaBytes
 * EN: RGBA byte array, each pixel occupies 4 bytes (R, G, B, A)
 * CN: RGBA字节数组，每个像素占4个字节（R, G, B, A）
 *
 * @param buffer
 * EN: Output buffer for encoded TSC data (must be pre-allocated with size from getTscSizeWithWidth:height:format:)
 * CN: 输出缓冲区，用于存储编码后的TSC数据（必须预先分配，大小为getTscSizeWithWidth:height:format:的返回值）
 *
 * @param width
 * EN: Image width
 * CN: 图片宽度
 *
 * @param height
 * EN: Image height
 * CN: 图片高度
 *
 * @param format
 * EN: TSC format (TSC12A or TSC12)
 * CN: TSC格式（TSC12A或TSC12）
 *
 * @param flags
 * EN: Encoding flags (typically 0, can use FLAG_IGNORE_TRANSPARENT_PIXELS = 1)
 * CN: 编码标志位（通常为0，可以使用FLAG_IGNORE_TRANSPARENT_PIXELS = 1）
 *
 * @discussion
 * EN: This method encodes RGBA image data into TSC format.
 *     The buffer must be pre-allocated with the correct size obtained from getTscSizeWithWidth:height:format:.
 * CN: 此方法将RGBA图片数据编码为TSC格式。
 *     缓冲区必须预先分配，大小由getTscSizeWithWidth:height:format:确定。
 */
+ (void)encodeImageWithRgbaBytes:(const uint8_t *)rgbaBytes
                          buffer:(uint8_t *)buffer
                           width:(NSInteger)width
                          height:(NSInteger)height
                          format:(TscFormat)format
                           flags:(NSInteger)flags;

/**
 * @brief Decode TSC image data to RGBA format
 * @chinese 将TSC图片数据解码为RGBA格式
 *
 * @param tscBytes
 * EN: TSC compressed byte array
 * CN: TSC压缩字节数组
 *
 * @param buffer
 * EN: Output buffer for RGBA data (must be pre-allocated with size = width * height * 4)
 * CN: 输出缓冲区，用于存储RGBA数据（必须预先分配，大小为 width * height * 4）
 *
 * @param width
 * EN: Image width
 * CN: 图片宽度
 *
 * @param height
 * EN: Image height
 * CN: 图片高度
 *
 * @param format
 * EN: TSC format (TSC12A or TSC12)
 * CN: TSC格式（TSC12A或TSC12）
 */
+ (void)decodeImageWithTscBytes:(const uint8_t *)tscBytes
                         buffer:(uint8_t *)buffer
                          width:(NSInteger)width
                         height:(NSInteger)height
                         format:(TscFormat)format;

/**
 * @brief Get RGBA data size
 * @chinese 获取RGBA数据大小
 *
 * @param width
 * EN: Image width
 * CN: 图片宽度
 *
 * @param height
 * EN: Image height
 * CN: 图片高度
 *
 * @return
 * EN: RGBA data size in bytes (width * height * 4)
 * CN: RGBA数据大小（字节），等于 width * height * 4
 */
+ (NSUInteger)getRgbaSizeWithWidth:(NSInteger)width height:(NSInteger)height;

/**
 * @brief Encoding flags
 * @chinese 编码标志位
 */
+ (NSInteger)FLAG_IGNORE_TRANSPARENT_PIXELS;

@end

NS_ASSUME_NONNULL_END

