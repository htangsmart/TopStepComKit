//
//  TSTscCompressor.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSC compression format enumeration
 * @chinese TSC压缩格式枚举
 *
 * @discussion
 * [EN]: Defines various TSC compression formats for image compression.
 *       Different formats provide different compression ratios and quality levels.
 * [CN]: 定义各种TSC压缩格式，用于图像压缩。
 *       不同格式提供不同的压缩比和质量级别。
 */
typedef NS_ENUM(NSInteger, TSTscCompressionFormat) {
    /// TSC4F format
    TSTscCompressionFormatTSC4F = 0,
    /// TSC4HQ format (High Quality)
    TSTscCompressionFormatTSC4HQ = 1,
    /// TSC6F format
    TSTscCompressionFormatTSC6F = 2,
    /// TSC6HQ format (High Quality)
    TSTscCompressionFormatTSC6HQ = 3,
    /// TSC6AF format
    TSTscCompressionFormatTSC6AF = 4,
    /// TSC6AHQ format (High Quality)
    TSTscCompressionFormatTSC6AHQ = 5,
    /// TSC4 format
    TSTscCompressionFormatTSC4 = 6,
    /// TSC6 format
    TSTscCompressionFormatTSC6 = 7,
    /// TSC6A format
    TSTscCompressionFormatTSC6A = 8,
    /// TSC12 format
    TSTscCompressionFormatTSC12 = 9,
    /// TSC12A format
    TSTscCompressionFormatTSC12A = 10,
    /// TSC6APLUSF format
    TSTscCompressionFormatTSC6APLUSF = 11,
    /// TSC6APLUSHQ format (High Quality)
    TSTscCompressionFormatTSC6APLUSHQ = 12,
    /// TSC6AP format
    TSTscCompressionFormatTSC6AP = 13
};

/**
 * @brief TSC compression flags
 * @chinese TSC压缩标志
 *
 * @discussion
 * [EN]: Bit flags for controlling compression behavior.
 *       Use TSTscCompressionFlagIgnoreTransparentPixels to ignore transparent pixels during compression.
 * [CN]: 用于控制压缩行为的位标志。
 *       使用TSTscCompressionFlagIgnoreTransparentPixels可在压缩时忽略透明像素。
 */
typedef NS_OPTIONS(NSUInteger, TSTscCompressionFlags) {
    /// No flags
    TSTscCompressionFlagNone = 0,
    /// Ignore transparent pixels during compression (Applicable to TSC6AHQ)
    TSTscCompressionFlagIgnoreTransparentPixels = 1 << 0
};

/**
 * @brief TSC image compressor utility class
 * @chinese TSC图像压缩工具类
 *
 * @discussion
 * [EN]: This class provides TSC format image compression functionality.
 *       It wraps the C++ TscCompressor library to provide Objective-C interface.
 *       Supports compressing RGBA images to various TSC formats.
 * [CN]: 此类提供TSC格式的图像压缩功能。
 *       封装了C++ TscCompressor库，提供Objective-C接口。
 *       支持将RGBA图像压缩为各种TSC格式。
 */
@interface TSTscCompressor : NSObject

/**
 * @brief Compress an RGBA image to TSC format
 * @chinese 将RGBA图像压缩为TSC格式
 *
 * @param image
 * EN: Source UIImage to compress
 * CN: 要压缩的源UIImage对象
 *
 * @param format
 * EN: TSC compression format to use
 * CN: 要使用的TSC压缩格式
 *
 * @param error
 * EN: Error information if compression fails, nil if successful
 * CN: 压缩失败时的错误信息，成功时为nil
 *
 * @return
 * EN: NSData containing compressed TSC image data, nil if compression fails
 * CN: 包含压缩后的TSC图像数据的NSData对象，压缩失败时返回nil
 *
 * @discussion
 * [EN]: This method compresses a UIImage to TSC format.
 *       The image will be converted to RGBA format before compression.
 *       Returns nil if the image is invalid or compression fails.
 * [CN]: 此方法将UIImage压缩为TSC格式。
 *       图像在压缩前会转换为RGBA格式。
 *       如果图像无效或压缩失败，返回nil。
 */
+ (nullable NSData *)compressImage:(UIImage *)image
                            format:(TSTscCompressionFormat)format
                             error:(NSError **)error;

/**
 * @brief Compress RGBA image data to TSC format
 * @chinese 将RGBA图像数据压缩为TSC格式
 *
 * @param rgbaData
 * EN: Source RGBA image data (must be in RGBA format, 4 bytes per pixel)
 * CN: 源RGBA图像数据（必须是RGBA格式，每像素4字节）
 *
 * @param width
 * EN: Image width in pixels
 * CN: 图像宽度（像素）
 *
 * @param height
 * EN: Image height in pixels
 * CN: 图像高度（像素）
 *
 * @param format
 * EN: TSC compression format to use
 * CN: 要使用的TSC压缩格式
 *
 * @param error
 * EN: Error information if compression fails, nil if successful
 * CN: 压缩失败时的错误信息，成功时为nil
 *
 * @return
 * EN: NSData containing compressed TSC image data, nil if compression fails
 * CN: 包含压缩后的TSC图像数据的NSData对象，压缩失败时返回nil
 *
 * @discussion
 * [EN]: This method compresses RGBA image data directly to TSC format.
 *       The rgbaData must be in RGBA format (4 bytes per pixel: R, G, B, A).
 *       Data size must be width * height * 4 bytes.
 * [CN]: 此方法直接将RGBA图像数据压缩为TSC格式。
 *       rgbaData必须是RGBA格式（每像素4字节：R, G, B, A）。
 *       数据大小必须为 width * height * 4 字节。
 */
+ (nullable NSData *)compressRGBAData:(NSData *)rgbaData
                                width:(NSInteger)width
                               height:(NSInteger)height
                               format:(TSTscCompressionFormat)format
                                error:(NSError **)error;

/**
 * @brief Calculate the size needed for TSC compressed data
 * @chinese 计算TSC压缩数据所需的大小
 *
 * @param width
 * EN: Image width in pixels
 * CN: 图像宽度（像素）
 *
 * @param height
 * EN: Image height in pixels
 * CN: 图像高度（像素）
 *
 * @param format
 * EN: TSC compression format to use
 * CN: 要使用的TSC压缩格式
 *
 * @return
 * EN: Size in bytes needed for compressed TSC data
 * CN: 压缩后的TSC数据所需的大小（字节）
 *
 * @discussion
 * [EN]: Use this method to calculate the buffer size needed before compression.
 *       This helps allocate the correct amount of memory for compressed data.
 * [CN]: 使用此方法在压缩前计算所需的缓冲区大小。
 *       这有助于为压缩数据分配正确数量的内存。
 */
+ (NSInteger)calculateCompressedSizeForWidth:(NSInteger)width
                                      height:(NSInteger)height
                                      format:(TSTscCompressionFormat)format;

@end

NS_ASSUME_NONNULL_END

