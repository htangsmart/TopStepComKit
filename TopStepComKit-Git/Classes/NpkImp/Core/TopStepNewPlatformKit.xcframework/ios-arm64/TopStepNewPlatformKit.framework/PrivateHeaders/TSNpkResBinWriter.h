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
 *       Updates three header fields: image count, font table offset (only when the template used it to point at
 *       the table end) and total file length. The file is written atomically.
 * [CN]: 只负责拼装字节并写文件；地址、字体表、图片内容等决策全部由入参给出。
 *       会更新三个文件头字段：图片总数、字体表偏移（仅当模板里该字段确实指向索引表末尾时）、文件总长度。写入为原子操作。
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

@end

NS_ASSUME_NONNULL_END
