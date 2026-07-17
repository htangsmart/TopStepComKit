//
//  TSPeripheralLogInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/27.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSFileModel.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral log list callback
 * @chinese 外设日志列表回调
 *
 * @param logFiles
 * EN: Array of log file models containing path and size information, nil if operation failed
 * CN: 包含路径和大小信息的日志文件模型数组，操作失败时为nil
 *
 * @param error
 * EN: Error information if operation failed, nil if successful
 * CN: 操作失败时的错误信息，成功时为nil
 */
typedef void(^TSPeripheralLogListBlock)(NSArray<TSFileModel *> * _Nullable logFiles, NSError * _Nullable error);

/**
 * @brief Peripheral log interface protocol
 * @chinese 外设设备日志接口协议
 *
 * @discussion
 * EN: This protocol defines all operations related to peripheral device logs, including:
 *     1. Fetch log list from device
 *     2. Start fetching all logs with progress tracking and save to local directory
 *     3. Cancel log fetching operation
 *     4. Fetch single log by file model
 *     5. Delete all logs
 *     6. Delete single log by file model
 * CN: 该协议定义了与外设设备日志相关的所有操作，包括：
 *     1. 从设备获取日志列表
 *     2. 开始获取所有日志（带进度跟踪并保存到本地目录）
 *     3. 取消日志获取操作
 *     4. 根据文件模型获取单个日志
 *     5. 删除所有日志
 *     6. 根据文件模型删除单个日志
 */
@protocol TSPeripheralLogInterface <TSKitBaseInterface>

#pragma mark - Fetch Log List

/**
 * @brief Fetch peripheral log list
 * @chinese 获取外设日志列表
 *
 * @param completion
 * EN: Completion callback
 *     - logFiles: Array of log file models containing path and size information, nil if operation failed
 *     - error: Error information if operation failed, nil if successful
 * CN: 完成回调
 *     - logFiles: 包含路径和大小信息的日志文件模型数组，操作失败时为nil
 *     - error: 操作失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the list of all available log files from the peripheral device.
 *     Each log file model contains the file path and size information.
 *     The returned file models can be used to fetch individual log files or delete specific logs.
 *     Important notes:
 *     1. Device must be connected before calling this method
 *     2. The operation may take some time depending on the number of logs
 *     3. If no logs are available, an empty array will be returned
 *     4. The completion handler is called on the main thread
 *
 * CN: 此方法从外设设备获取所有可用日志文件的列表。
 *     每个日志文件模型包含文件路径和大小信息。
 *     返回的文件模型可用于获取单个日志文件或删除特定日志。
 *     重要说明：
 *     1. 调用此方法前设备必须已连接
 *     2. 操作可能需要一些时间，取决于日志数量
 *     3. 如果没有可用日志，将返回空数组
 *     4. 完成回调在主线程中调用
 */
- (void)fetchPeripheralLogList:(nullable TSPeripheralLogListBlock)completion;

#pragma mark - Fetch All Logs

/**
 * @brief Start fetching all peripheral logs and save to local directory
 * @chinese 开始获取所有外设日志并保存到本地目录
 *
 * @param localFolderPath
 * EN: Local directory path where log files will be saved, cannot be nil.
 *     The SDK will create this directory if it doesn't exist.
 *     Each log file will be saved with its original filename from the device.
 *     Example: @"/Users/username/Documents/DeviceLogs"
 * CN: 日志文件将保存到的本地目录路径，不能为空。
 *     SDK会在目录不存在时自动创建。
 *     每个日志文件将使用设备上的原始文件名保存。
 *     示例：@"/Users/username/Documents/DeviceLogs"
 *
 * @param progress
 * EN: Progress callback, called multiple times during the fetch process.
 *     - state: Operation state (eTSFileTransferStatusStart, eTSFileTransferStatusProgress)
 *     - progress: Overall progress (0-100) across all log files
 *     Progress is calculated as: (completedFiles + currentFileProgress/100) / totalFileCount * 100
 *     Called on the main thread.
 * CN: 进度回调，在获取过程中会被多次调用。
 *     - state: 操作状态（eTSFileTransferStatusStart, eTSFileTransferStatusProgress）
 *     - progress: 所有日志文件的整体进度（0-100）
 *     进度计算公式：(已完成文件数 + 当前文件进度/100) / 文件总数 * 100
 *     在主线程中调用。
 *
 * @param success
 * EN: Success callback, called when all log files have been successfully fetched and saved.
 *     - state: Operation status (eTSFileTransferStatusSuccess)
 *     - savedFilePaths: Array of local file paths where logs were saved (optional, can be nil)
 *     Called on the main thread.
 * CN: 成功回调，当所有日志文件成功获取并保存时调用。
 *     - state: 操作状态（eTSFileTransferStatusSuccess）
 *     - savedFilePaths: 日志保存的本地文件路径数组（可选，可为nil）
 *     在主线程中调用。
 *
 * @param failure
 * EN: Failure callback, called when the fetch operation fails or is canceled.
 *     - state: Operation status (eTSFileTransferStatusFailed or eTSFileTransferStatusCanceled)
 *     - error: Error information describing the failure reason, nil if canceled
 *     Called on the main thread.
 * CN: 失败回调，当获取操作失败或被取消时调用。
 *     - state: 操作状态（eTSFileTransferStatusFailed 或 eTSFileTransferStatusCanceled）
 *     - error: 描述失败原因的错误信息，如果是取消操作则为nil
 *     在主线程中调用。
 *
 */
- (void)startFetchAllPeripheralLogsAtLocalFolderPath:(NSString *_Nonnull)localFolderPath
                                            progress:(nullable TSFileTransferProgressBlock)progress
                                             success:(nullable TSFileTransferSuccessBlock)success
                                             failure:(nullable TSFileTransferFailureBlock)failure;

#pragma mark - Cancel Log Fetch

/**
 * @brief Cancel log fetching operation
 * @chinese 取消日志获取操作
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the cancellation was successful
 *     - error: Error information if cancellation failed
 * CN: 完成回调
 *     - success: 取消是否成功
 *     - error: 取消失败时的错误信息
 */
- (void)cancelLogFetch:(nullable TSCompletionBlock)completion;

#pragma mark - Fetch Single Log

/**
 * @brief Fetch single peripheral log by file model and save to local path
 * @chinese 根据文件模型获取单个外设日志并保存到本地路径
 *
 * @param logFile
 * EN: Log file model containing path information, cannot be nil
 * CN: 包含路径信息的日志文件模型，不能为空
 *
 * @param localFolderPath
 * EN: Local file path where the log file will be saved, cannot be nil.
 *     The SDK will create the directory if it doesn't exist.
 *     If a file with the same path already exists, it will be overwritten.
 *     Example: @"/Users/username/Documents/DeviceLogs/log_20251127.txt"
 * CN: 日志文件将保存到的本地文件路径，不能为空。
 *     SDK会在目录不存在时自动创建。
 *     如果同名文件已存在，将被覆盖。
 *     示例：@"/Users/username/Documents/DeviceLogs/log_20251127.txt"
 *
 * @param progress
 * EN: Progress callback, called multiple times during the fetch process.
 *     - state: Operation state (eTSFileTransferStatusStart, eTSFileTransferStatusProgress)
 *     - progress: Current file transfer progress (0-100)
 *     Called on the main thread.
 * CN: 进度回调，在获取过程中会被多次调用。
 *     - state: 操作状态（eTSFileTransferStatusStart, eTSFileTransferStatusProgress）
 *     - progress: 当前文件传输进度（0-100）
 *     在主线程中调用。
 *
 * @param success
 * EN: Success callback, called when the log file has been successfully fetched and saved.
 *     - state: Operation status (eTSFileTransferStatusSuccess)
 *     - savedFilePath: Local file path where the log was saved
 *     Called on the main thread.
 * CN: 成功回调，当日志文件成功获取并保存时调用。
 *     - state: 操作状态（eTSFileTransferStatusSuccess）
 *     - savedFilePath: 日志保存的本地文件路径
 *     在主线程中调用。
 *
 * @param failure
 * EN: Failure callback, called when the fetch operation fails or is canceled.
 *     - state: Operation status (eTSFileTransferStatusFailed or eTSFileTransferStatusCanceled)
 *     - error: Error information describing the failure reason, nil if canceled
 *     Called on the main thread.
 * CN: 失败回调，当获取操作失败或被取消时调用。
 *     - state: 操作状态（eTSFileTransferStatusFailed 或 eTSFileTransferStatusCanceled）
 *     - error: 描述失败原因的错误信息，如果是取消操作则为nil
 *     在主线程中调用。
 *
 */
- (void)startFetchPeripheralLogWithFile:(TSFileModel *_Nonnull)logFile
                        localFolderPath:(NSString *_Nonnull)localFolderPath
                               progress:(nullable TSFileTransferProgressBlock)progress
                                success:(nullable TSFileTransferSuccessBlock)success
                                failure:(nullable TSFileTransferFailureBlock)failure;

#pragma mark - Delete Logs

/**
 * @brief Delete all peripheral logs
 * @chinese 删除所有外设日志
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the deletion was successful
 *     - error: Error information if deletion failed
 * CN: 完成回调
 *     - success: 删除是否成功
 *     - error: 删除失败时的错误信息
 *
 */
- (void)deleteAllPeripheralLogs:(nullable TSCompletionBlock)completion;

/**
 * @brief Delete single peripheral log by file model
 * @chinese 根据文件模型删除单个外设日志
 *
 * @param logFile
 * EN: Log file model containing path information, cannot be nil
 * CN: 包含路径信息的日志文件模型，不能为空
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the deletion was successful
 *     - error: Error information if deletion failed
 * CN: 完成回调
 *     - success: 删除是否成功
 *     - error: 删除失败时的错误信息
 *
 * @discussion
 * EN: This method deletes a single log file from the peripheral device using the file model.
 *     The logFile should be one of the file models returned by fetchPeripheralLogList:completion: or fetchAllPeripheralLogs:completion:.
 *     This operation will permanently remove the log and cannot be undone.
 *     Important notes:
 *     1. Device must be connected before calling this method
 *     2. The logFile.path must be a valid path returned from the device
 *     3. This operation cannot be undone once completed
 *     4. The completion handler is called on the main thread
 *     5. If the log file does not exist, an error will be returned
 *
 * CN: 此方法使用文件模型从外设设备删除单个日志文件。
 *     logFile应该是fetchPeripheralLogList:completion:或fetchAllPeripheralLogs:completion:返回的文件模型之一。
 *     此操作将永久删除日志且无法撤销。
 *     重要说明：
 *     1. 调用此方法前设备必须已连接
 *     2. logFile.path必须是设备返回的有效路径
 *     3. 此操作一旦完成将无法撤销
 *     4. 完成回调在主线程中调用
 *     5. 如果日志文件不存在，将返回错误
 */
- (void)deletePeripheralLogWithFile:(TSFileModel *_Nonnull)logFile
                         completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
