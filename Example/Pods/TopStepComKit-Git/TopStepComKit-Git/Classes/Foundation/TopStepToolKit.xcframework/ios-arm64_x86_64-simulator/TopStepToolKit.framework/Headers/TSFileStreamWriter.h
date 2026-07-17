//
//  TSFileStreamWriter.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File stream writer for efficient incremental file writing
 * @chinese 文件流写入器，用于高效的增量文件写入
 *
 * @discussion
 * [EN]: TSFileStreamWriter manages NSFileHandle lifecycle for efficient sequential writes.
 *       It's designed for scenarios where data arrives in chunks and needs to be written
 *       incrementally, such as:
 *       - File transfer (download/upload with progress)
 *       - Log file writing
 *       - Incremental data saving
 *       - Resume-capable downloads
 *
 *       Key features:
 *       - One-time file handle opening (efficient for multiple writes)
 *       - Automatic seek to end of file (supports resume)
 *       - Thread-safe operations
 *       - Comprehensive error handling
 *
 * [CN]: TSFileStreamWriter 管理 NSFileHandle 的生命周期，用于高效的顺序写入。
 *       它专为数据分块到达并需要增量写入的场景设计，例如：
 *       - 文件传输（带进度的下载/上传）
 *       - 日志文件写入
 *       - 增量数据保存
 *       - 支持断点续传的下载
 *
 *       关键特性：
 *       - 一次性打开文件句柄（多次写入更高效）
 *       - 自动定位到文件末尾（支持续传）
 *       - 线程安全操作
 *       - 全面的错误处理
 *
 * @code
 * // Example usage:
 * TSFileStreamWriter *writer = [[TSFileStreamWriter alloc] init];
 * if ([writer openForWriting:@"/path/to/file.bin"]) {
 *     [writer writeData:chunk1];
 *     [writer writeData:chunk2];
 *     [writer writeData:chunk3];
 *     [writer close];
 * }
 * @endcode
 */
@interface TSFileStreamWriter : NSObject

/**
 * @brief Open file for writing in append mode
 * @chinese 以追加模式打开文件准备写入
 *
 * @param filePath
 * EN: The complete file path to write to (including filename)
 * CN: 要写入的完整文件路径（包含文件名）
 *
 * @return
 * EN: YES if file opened successfully, NO otherwise
 * CN: 如果文件打开成功返回 YES，否则返回 NO
 *
 * @discussion
 * [EN]: This method opens the file for writing in append mode.
 *       - If the file doesn't exist, it will be created automatically
 *       - If the file exists, the write position is set to the end (supports resume)
 *       - The directory will be created automatically if it doesn't exist
 *       - This method must be called before any write operations
 *       - Only one file can be open at a time; calling this again will close the previous file
 *
 * [CN]: 此方法以追加模式打开文件准备写入。
 *       - 如果文件不存在，会自动创建
 *       - 如果文件存在，写入位置设置到末尾（支持续传）
 *       - 如果目录不存在，会自动创建
 *       - 在任何写入操作前必须先调用此方法
 *       - 同时只能打开一个文件；再次调用会关闭之前的文件
 */
- (BOOL)openForWriting:(NSString *)filePath;

/**
 * @brief Write data to the opened file
 * @chinese 将数据写入已打开的文件
 *
 * @param data
 * EN: The data to write
 * CN: 要写入的数据
 *
 * @return
 * EN: YES if data written successfully, NO otherwise
 * CN: 如果数据写入成功返回 YES，否则返回 NO
 *
 * @discussion
 * [EN]: This method appends data to the currently opened file.
 *       - The file must be opened first by calling openForWriting:
 *       - Data is written immediately (not buffered)
 *       - The write position automatically advances after each write
 *       - Returns NO if file is not open or data is nil/empty
 *       - Thread-safe: can be called from any thread
 *
 * [CN]: 此方法将数据追加到当前打开的文件。
 *       - 必须先调用 openForWriting: 打开文件
 *       - 数据立即写入（不缓冲）
 *       - 写入位置在每次写入后自动前进
 *       - 如果文件未打开或数据为 nil/空，返回 NO
 *       - 线程安全：可以从任何线程调用
 */
- (BOOL)writeData:(NSData *)data;

/**
 * @brief Close the currently opened file
 * @chinese 关闭当前打开的文件
 *
 * @discussion
 * [EN]: This method closes the file handle and releases resources.
 *       - Safe to call multiple times (no-op if already closed)
 *       - Automatically called in dealloc
 *       - Should be called when writing is complete
 *       - After closing, must call openForWriting: again to write more data
 *
 * [CN]: 此方法关闭文件句柄并释放资源。
 *       - 可以安全地多次调用（如果已关闭则无操作）
 *       - 在 dealloc 中自动调用
 *       - 写入完成后应该调用
 *       - 关闭后，必须再次调用 openForWriting: 才能写入更多数据
 */
- (void)close;

/**
 * @brief Check if a file is currently open for writing
 * @chinese 检查当前是否有文件打开用于写入
 *
 * @return
 * EN: YES if a file is open, NO otherwise
 * CN: 如果有文件打开返回 YES，否则返回 NO
 */
- (BOOL)isOpen;

/**
 * @brief Get the current write position (file offset)
 * @chinese 获取当前写入位置（文件偏移量）
 *
 * @return
 * EN: Current file offset in bytes, 0 if no file is open
 * CN: 当前文件偏移量（字节），如果没有文件打开则返回 0
 *
 * @discussion
 * [EN]: This method returns the current write position in the file.
 *       - Useful for tracking progress
 *       - Returns 0 if no file is currently open
 *       - The offset increases after each write operation
 *
 * [CN]: 此方法返回文件中的当前写入位置。
 *       - 用于跟踪进度
 *       - 如果当前没有文件打开，返回 0
 *       - 偏移量在每次写入操作后增加
 */
- (unsigned long long)currentOffset;

/**
 * @brief Get the path of currently opened file
 * @chinese 获取当前打开文件的路径
 *
 * @return
 * EN: File path string, nil if no file is open
 * CN: 文件路径字符串，如果没有文件打开则返回 nil
 */
- (NSString * _Nullable)currentFilePath;

@end

NS_ASSUME_NONNULL_END

