//
//  TSTarArchive.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSTarArchive : NSObject

/**
 * @brief Decompress TAR file to directory
 * @chinese 解压 TAR 文件到目录
 *
 * @param tarFilePath
 * EN: Path to the TAR file to decompress
 * CN: 要解压的TAR文件路径
 *
 * @param destinationPath
 * EN: Destination directory path for decompressed files
 * CN: 解压文件的目标目录路径
 *
 * @param error
 * EN: Error information if decompression fails, nil if successful
 * CN: 解压失败时的错误信息，成功时为nil
 *
 * @return
 * EN: YES if decompression succeeds, NO otherwise
 * CN: 解压成功返回YES，否则返回NO
 *
 * @discussion
 * [EN]: TAR file format:
 *       - TAR files consist of multiple 512-byte blocks
 *       - Each file/directory has a header block (512 bytes) containing filename, size, etc.
 *       - File data is stored aligned to 512-byte boundaries
 *       - Header uses ASCII string format
 * [CN]: TAR文件格式：
 *       - TAR文件由多个512字节的块组成
 *       - 每个文件/目录有一个文件头块（512字节），包含文件名、大小等信息
 *       - 文件数据按512字节对齐存储
 *       - 文件头使用ASCII字符串格式
 */
+ (BOOL)decompressTarFileAtPath:(NSString *)tarFilePath toDirectoryPath:(NSString *)destinationPath error:(NSError **)error;

/**
 * @brief Compress directory to TAR file
 * @chinese 将目录压缩为TAR文件
 *
 * @param sourceDirectoryPath
 * EN: Source directory path to compress
 * CN: 要压缩的源目录路径
 *
 * @param tarFilePath
 * EN: Destination TAR file path
 * CN: 目标TAR文件路径
 *
 * @param error
 * EN: Error information if compression fails, nil if successful
 * CN: 压缩失败时的错误信息，成功时为nil
 *
 * @return
 * EN: YES if compression succeeds, NO otherwise
 * CN: 压缩成功返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method recursively compresses all files and directories in the source directory
 *       into a TAR file. The TAR file format follows the POSIX ustar standard.
 *       Each file/directory entry includes a 512-byte header block followed by file data
 *       (aligned to 512-byte boundaries).
 * [CN]: 此方法递归压缩源目录中的所有文件和目录为TAR文件。
 *       TAR文件格式遵循POSIX ustar标准。
 *       每个文件/目录条目包含一个512字节的头块，后跟文件数据（对齐到512字节边界）。
 */
+ (BOOL)compressDirectoryAtPath:(NSString *)sourceDirectoryPath toTarFilePath:(NSString *)tarFilePath error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
