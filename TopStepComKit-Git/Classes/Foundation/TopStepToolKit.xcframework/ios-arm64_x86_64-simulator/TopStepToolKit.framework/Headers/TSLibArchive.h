//
//  TSLibArchive.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Archive format type enumeration
 * @chinese 归档格式类型枚举
 */
typedef NS_ENUM(NSInteger, TSArchiveFormat) {
    /// ZIP格式 (ZIP format)
    TSArchiveFormatZip = 0,
    /// TAR格式 (TAR format)
    TSArchiveFormatTar = 1
};

/**
 * @brief Archive utility class using SSZipArchive for iOS compatibility
 * @chinese 使用SSZipArchive的归档工具类（iOS兼容）
 *
 * @discussion
 * [EN]: This class provides compression and decompression functionality for ZIP format
 *       using SSZipArchive library (iOS compatible).
 *       Note: iOS system does not support libarchive, so we use SSZipArchive instead.
 *       Supports:
 *       - Compressing files/directories to ZIP format
 *       - Decompressing ZIP archives to directories
 *       - TAR format is not supported on iOS
 * [CN]: 此类使用SSZipArchive库提供ZIP格式的压缩和解压缩功能（iOS兼容）。
 *       注意：iOS系统不支持libarchive，因此使用SSZipArchive替代。
 *       支持：
 *       - 将文件/目录压缩为ZIP格式
 *       - 将ZIP归档文件解压到目录
 *       - iOS系统不支持TAR格式
 */
@interface TSLibArchive : NSObject

/**
 * @brief Compress files/directories to archive
 * @chinese 压缩文件/目录为归档文件
 *
 * @param sourcePath
 * EN: Source file or directory path to compress
 * CN: 要压缩的源文件或目录路径
 *
 * @param destinationPath
 * EN: Destination archive file path
 * CN: 目标归档文件路径
 *
 * @param format
 * EN: Archive format (ZIP or TAR)
 * CN: 归档格式（ZIP或TAR）
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
 * [EN]: This method compresses a file or directory to the specified archive format.
 *       If sourcePath is a directory, all files and subdirectories will be included.
 *       The destination directory will be created if it doesn't exist.
 *       Note: Only ZIP format is supported on iOS. TAR format will return an error.
 * [CN]: 此方法将文件或目录压缩为指定的归档格式。
 *       如果sourcePath是目录，将包含所有文件和子目录。
 *       如果目标目录不存在，将自动创建。
 *       注意：iOS系统仅支持ZIP格式，TAR格式将返回错误。
 */
+ (BOOL)compressPath:(NSString *)sourcePath
       toArchivePath:(NSString *)destinationPath
              format:(TSArchiveFormat)format
               error:(NSError **)error;

/**
 * @brief Decompress archive to directory
 * @chinese 解压归档文件到目录
 *
 * @param archivePath
 * EN: Archive file path to decompress
 * CN: 要解压的归档文件路径
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
 * [EN]: This method decompresses an archive file to the specified directory.
 *       Only ZIP format is supported on iOS. Other formats will return an error.
 *       The destination directory will be created if it doesn't exist.
 * [CN]: 此方法将归档文件解压到指定目录。
 *       iOS系统仅支持ZIP格式，其他格式将返回错误。
 *       如果目标目录不存在，将自动创建。
 */
+ (BOOL)decompressArchivePath:(NSString *)archivePath
                 toDirectoryPath:(NSString *)destinationPath
                       format:(TSArchiveFormat)format
                           error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
