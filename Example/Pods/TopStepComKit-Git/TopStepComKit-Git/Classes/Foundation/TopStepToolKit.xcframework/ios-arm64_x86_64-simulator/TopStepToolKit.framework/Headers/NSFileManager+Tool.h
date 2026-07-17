//
//  NSFileManager+Tool.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Tool)

/**
 * @brief Get file size with multiple fallback methods
 * @chinese 获取文件大小（多种备选方法）
 *
 * @param filePath
 * EN: The file path to get size for
 * CN: 要获取大小的文件路径
 *
 * @return
 * EN: File size in bytes, returns 0 if all methods fail
 * CN: 文件大小（字节），如果所有方法都失败则返回0
 *
 * @discussion
 * EN: This method tries multiple approaches to get file size:
 *     1. NSFileManager attributesOfItemAtPath (primary method)
 *     2. NSData dataWithContentsOfFile (fallback method)
 *     3. NSFileHandle seekToEndOfFile (last resort)
 * CN: 此方法使用多种方式获取文件大小：
 *     1. NSFileManager attributesOfItemAtPath（主要方法）
 *     2. NSData dataWithContentsOfFile（备选方法）
 *     3. NSFileHandle seekToEndOfFile（最后备选）
 */
+ (double)fileSizeAtPath:(NSString *)filePath;

/**
 * @brief Calculate CRC16 checksum for file
 * @chinese 计算文件的CRC16校验和
 *
 * @param filePath
 * EN: The file path to calculate CRC16 for
 * CN: 要计算CRC16的文件路径
 *
 * @return
 * EN: CRC16 checksum value, returns 0 if file reading fails
 * CN: CRC16校验和值，如果文件读取失败则返回0
 *
 * @discussion
 * EN: This method reads the entire file content and calculates CRC16 checksum.
 *     Returns 0 if file doesn't exist or reading fails.
 * CN: 此方法读取整个文件内容并计算CRC16校验和。
 *     如果文件不存在或读取失败则返回0。
 */
+ (UInt16)fileCRC16AtPath:(NSString *)filePath;

/**
 * @brief Calculate CRC32 checksum for file
 * @chinese 计算文件的CRC32校验和
 *
 * @param filePath
 * EN: The file path to calculate CRC32 for
 * CN: 要计算CRC32的文件路径
 *
 * @return
 * EN: CRC32 checksum value, returns 0 if file reading fails
 * CN: CRC32校验和值，如果文件读取失败则返回0
 *
 * @discussion
 * EN: This method reads the entire file content and calculates CRC32 checksum.
 *     Returns 0 if file doesn't exist or reading fails.
 * CN: 此方法读取整个文件内容并计算CRC32校验和。
 *     如果文件不存在或读取失败则返回0。
 */
+ (UInt32)fileCRC32AtPath:(NSString *)filePath;

/**
 * @brief Check if file exists and is readable
 * @chinese 检查文件是否存在且可读
 *
 * @param filePath
 * EN: The file path to check
 * CN: 要检查的文件路径
 *
 * @return
 * EN: YES if file exists and is readable, NO otherwise
 * CN: 如果文件存在且可读返回YES，否则返回NO
 */
+ (BOOL)isFileReadableAtPath:(NSString *)filePath;


+ (NSData *)fileDataAtPath:(NSString *)filePath ;

/**
 * @brief Create directory at path if not exists
 * @chinese 创建目录（如果不存在）
 *
 * @param directoryPath
 * EN: The directory path to create
 * CN: 要创建的目录路径
 *
 * @return
 * EN: YES if directory exists or created successfully, NO otherwise
 * CN: 如果目录存在或创建成功返回YES，否则返回NO
 *
 * @discussion
 * EN: This method creates the directory and all intermediate directories if they don't exist.
 *     If the directory already exists, it returns YES immediately.
 * CN: 此方法创建目录及其所有中间目录（如果不存在）。
 *     如果目录已存在，立即返回 YES。
 */
+ (BOOL)createDirectoryAtPath:(NSString *)directoryPath;

/**
 * @brief Create directory for file path if not exists
 * @chinese 为文件路径创建目录（如果不存在）
 *
 * @param filePath
 * EN: The complete file path (including filename)
 * CN: 完整的文件路径（包含文件名）
 *
 * @return
 * EN: YES if directory exists or created successfully, NO otherwise
 * CN: 如果目录存在或创建成功返回YES，否则返回NO
 *
 * @discussion
 * EN: This method creates all intermediate directories for the given file path.
 *     For example, if filePath is "/path/to/file.txt", it will create "/path/to/" directory.
 *     If the directory already exists, it returns YES immediately.
 * CN: 此方法为给定的文件路径创建所有中间目录。
 *     例如，如果 filePath 是 "/path/to/file.txt"，它会创建 "/path/to/" 目录。
 *     如果目录已存在，立即返回 YES。
 */
+ (BOOL)createDirectoryForFilePath:(NSString *)filePath;

/**
 * @brief Get Documents directory path
 * @chinese 获取 Documents 目录路径
 *
 * @return
 * EN: Full path to Documents directory, returns nil if not found
 * CN: Documents 目录的完整路径，如果未找到则返回 nil
 *
 * @discussion
 * EN: Returns the standard Documents directory path for the current application.
 *     Example: "/var/mobile/Containers/Data/Application/.../Documents"
 * CN: 返回当前应用的标准 Documents 目录路径。
 *     例如："/var/mobile/Containers/Data/Application/.../Documents"
 */
+ (NSString * _Nullable)documentsDirectory;

/**
 * @brief Get file receiver root directory path (auto-create if not exists)
 * @chinese 获取文件接收器根目录路径（如果不存在则自动创建）
 *
 * @return
 * EN: Full path to file receiver root directory, returns nil if creation failed
 * CN: 文件接收器根目录的完整路径，如果创建失败则返回 nil
 *
 * @discussion
 * EN: Returns the root directory path for file receiver operations.
 *     Path structure: Documents/TopStepComKit/FileReceiver/
 *     If the directory doesn't exist, it will be created automatically.
 *     Example: "/var/mobile/.../Documents/TopStepComKit/FileReceiver"
 * CN: 返回文件接收器操作的根目录路径。
 *     路径结构：Documents/TopStepComKit/FileReceiver/
 *     如果目录不存在，会自动创建。
 *     例如："/var/mobile/.../Documents/TopStepComKit/FileReceiver"
 */
+ (NSString * _Nullable)fileReceiverRootDirectory;

/**
 * @brief Build local file path for file receiver (auto-create directories if not exist)
 * @chinese 构建文件接收器的本地文件路径（如果目录不存在则自动创建）
 *
 * @param relativePath
 * EN: The relative file path (e.g., "sport/20251112105830.bin")
 * CN: 相对文件路径（例如："sport/20251112105830.bin"）
 *
 * @return
 * EN: Full local file path in Documents directory, returns nil if directory creation failed
 * CN: Documents目录中的完整本地文件路径，如果目录创建失败则返回nil
 *
 * @discussion
 * EN: This method constructs the full local file path by combining:
 *     - Documents directory (via documentsDirectory)
 *     - Fixed subdirectory: "TopStepComKit/FileReceiver/" (via fileReceiverRootDirectory)
 *     - Relative path provided
 *     All necessary directories will be created automatically if they don't exist.
 *     For example, if relativePath is "sport/20251112105830.bin", it will:
 *     1. Create Documents/TopStepComKit/FileReceiver/ (if not exists)
 *     2. Create Documents/TopStepComKit/FileReceiver/sport/ (if not exists)
 *     3. Return "/path/to/Documents/TopStepComKit/FileReceiver/sport/20251112105830.bin"
 * CN: 此方法通过组合以下部分构建完整的本地文件路径：
 *     - Documents 目录（通过 documentsDirectory）
 *     - 固定子目录："TopStepComKit/FileReceiver/"（通过 fileReceiverRootDirectory）
 *     - 提供的相对路径
 *     所有必要的目录都会自动创建（如果不存在）。
 *     例如，如果 relativePath 是 "sport/20251112105830.bin"，它将：
 *     1. 创建 Documents/TopStepComKit/FileReceiver/ （如果不存在）
 *     2. 创建 Documents/TopStepComKit/FileReceiver/sport/ （如果不存在）
 *     3. 返回 "/path/to/Documents/TopStepComKit/FileReceiver/sport/20251112105830.bin"
 */
+ (NSString * _Nullable)fileReceiverPathForRelativePath:(NSString *)relativePath;

/**
 * @brief Move file from origin path to target path
 * @chinese 将文件从源路径移动到目标路径
 *
 * @param originFilePath
 * EN: The source file path to move from
 * CN: 源文件路径（要移动的文件）
 *
 * @param targetFilePath
 * EN: The target file path to move to
 * CN: 目标文件路径（移动后的文件路径）
 *
 * @param error
 * EN: Pointer to NSError object for error information, can be nil
 * CN: 指向NSError对象的指针，用于获取错误信息，可以为nil
 *
 * @return
 * EN: YES if file moved successfully, NO otherwise
 * CN: 如果文件移动成功返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method moves a file from origin path to target path:
 *       1. Validates both file paths
 *       2. Checks if origin file exists
 *       3. Creates target directory if not exists
 *       4. Removes target file if already exists
 *       5. Moves the file to target path
 *       Returns NO and sets error if any step fails.
 * [CN]: 此方法将文件从源路径移动到目标路径：
 *       1. 验证两个文件路径
 *       2. 检查源文件是否存在
 *       3. 如果目标目录不存在则创建
 *       4. 如果目标文件已存在则先删除
 *       5. 将文件移动到目标路径
 *       如果任何步骤失败，返回NO并设置错误信息。
 */
+ (BOOL)moveFileFromPath:(NSString *)originFilePath
                  toPath:(NSString *)targetFilePath
                   error:(NSError * _Nullable * _Nullable)error;


+ (NSString * _Nullable)topStepComKitDirectory ;

+ (NSString * _Nullable)topStepTempRootDirectory ;

+ (NSString * _Nullable)pathForRoot:(NSString *)rootPath relativePath:(NSString *)relativePath ;

/**
 * @brief Remove directory at path if exists
 * @chinese 删除指定路径的目录（如果存在）
 *
 * @param directoryPath
 * EN: The directory path to remove
 * CN: 要删除的目录路径
 *
 * @return
 * EN: YES if directory removed successfully or doesn't exist, NO if removal fails
 * CN: 如果目录删除成功或不存在返回YES，如果删除失败返回NO
 *
 * @discussion
 * [EN]: This method removes the directory at the specified path if it exists.
 *       If the directory doesn't exist, it returns YES (no error).
 *       Logs success or failure messages for debugging.
 * [CN]: 此方法删除指定路径的目录（如果存在）。
 *       如果目录不存在，返回YES（不视为错误）。
 *       记录成功或失败消息用于调试。
 */
+ (BOOL)removeDirectoryAtPath:(NSString *)directoryPath;

/**
 * @brief Remove multiple directories
 * @chinese 删除多个目录
 *
 * @param directoryPaths
 * EN: Array of directory paths to remove
 * CN: 要删除的目录路径数组
 *
 * @return
 * EN: YES if all directories removed successfully or don't exist, NO if any removal fails
 * CN: 如果所有目录删除成功或不存在返回YES，如果任何删除失败返回NO
 *
 * @discussion
 * [EN]: This method removes multiple directories at the specified paths.
 *       Continues removing even if one fails, but returns NO if any removal fails.
 * [CN]: 此方法删除指定路径的多个目录。
 *       即使某个删除失败也会继续删除其他目录，但如果任何删除失败则返回NO。
 */
+ (BOOL)removeDirectoriesAtPaths:(NSArray<NSString *> *)directoryPaths;

@end

NS_ASSUME_NONNULL_END
