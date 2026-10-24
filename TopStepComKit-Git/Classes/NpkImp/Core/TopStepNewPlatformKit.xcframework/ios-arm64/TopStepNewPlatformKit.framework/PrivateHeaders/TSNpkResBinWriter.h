//
//  TSNpkResBinWriter.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkResBinLayout;
@class TSNpkResBinReader;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Serializes a rebuilt res.bin to disk according to a layout
 * @chinese 按布局把重建后的 res.bin 写到磁盘
 *
 * @discussion
 * [EN]: Only assembles bytes and writes them; all decisions (addresses, font table, image content) are inputs.
 *       Updates image count, relocated preserved-region offset and file length. Output is streamed and
 *       atomically replaces the destination only after the complete write succeeds.
 * [CN]: 只负责拼装字节并写文件；地址、字体表、图片内容等决策全部由入参给出。
 *       更新图片数、迁移后的保留区偏移和文件长度；流式写入完成后原子替换目标。
 */
@interface TSNpkResBinWriter : NSObject

/**
 * @brief Write the rebuilt file
 * @chinese 写出重建后的文件
 *
 * @param reader EN: Parsed template, source of the file header and untouched images. CN: 已解析的模板，提供文件头和未改动的图片。
 * @param layout EN: Placement of every image. CN: 每张图片的位置。
 * @param fontTable EN: Font table bytes to store (same length as the template's). CN: 要写入的字体表（长度与模板一致）。
 * @param storedImages EN: Table index to "image header + payload" for every replaced or added image.
 *                     CN: 每张被替换或新增的图片：下标到"图片头 + 数据"。
 * @param filePath EN: Destination, may be the template path itself. CN: 目标路径，可以就是模板文件自身。
 * @param error EN: Failure reason. CN: 失败原因。
 */
+ (BOOL)writeWithReader:(TSNpkResBinReader *)reader
                 layout:(TSNpkResBinLayout *)layout
              fontTable:(NSData *)fontTable
           storedImages:(NSDictionary<NSNumber *, NSData *> *)storedImages
             toFilePath:(NSString *)filePath
                  error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Stream disk-cached image resources into an atomic replacement file.
 * @chinese 将磁盘缓存图片流式写入并原子替换文件。
 * @param reader EN: Validated template. CN: 已验证模板。
 * @param layout EN: Validated resource layout. CN: 已验证布局。
 * @param fontTable EN: Preserved and patched region. CN: 保留与修补后的中间区域。
 * @param storedImagePaths EN: Index to cached encoded resource path. CN: 索引到已编码资源路径。
 * @param cancellationCheck EN: Optional cancellation callback. CN: 可选取消检查。
 * @param filePath EN: Output path. CN: 输出路径。
 * @param error EN: Failure details. CN: 错误信息。
 * @return EN: YES after atomic replacement. CN: 原子替换成功返回 YES。
 */
+ (BOOL)writeWithReader:(TSNpkResBinReader *)reader layout:(TSNpkResBinLayout *)layout fontTable:(NSData *)fontTable storedImagePaths:(NSDictionary<NSNumber *, NSString *> *)storedImagePaths cancellationCheck:(nullable BOOL (^)(void))cancellationCheck toFilePath:(NSString *)filePath error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
