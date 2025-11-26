//
//  TSMetaFileTransfer.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbStreamParam.pbobjc.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN


@interface TSMetaFileTransfer : TSBusinessBase

/**
 * @brief Get available space for specified device path
 * @chinese 获取设备指定路径的剩余空间
 *
 * @param filePath 
 * EN: The TSMetaFilePath object containing the device path to query for available space
 * CN: 包含要查询剩余空间的设备路径的TSMetaFilePath对象
 *
 * @param completion 
 * EN: Completion callback with directory space information and error
 * CN: 完成回调，包含目录空间信息和错误信息
 *
 * @discussion
 * [EN]: Queries the device for available space in the specified path.
 *        Returns TSMetaDirSpace containing total and free space information.
 * [CN]: 查询设备指定路径的可用空间，返回 TSMetaDirSpace（总空间与剩余空间）。
 */
+ (void)getAvailableSpaceForPath:(TSMetaFilePath *)filePath
                      completion:(void(^)(TSMetaDirSpace * _Nullable dirSpace, NSError * _Nullable error))completion;

/**
 * @brief Get file list under specified device path
 * @chinese 获取设备指定路径下的文件列表
 *
 * @param filePath 
 * EN: The TSMetaFilePath object representing the target folder path on device
 * CN: 设备上的目标文件夹路径（TSMetaFilePath 对象）
 *
 * @param completion 
 * EN: Completion callback with TSMetaFileList and error
 * CN: 完成回调，返回 TSMetaFileList 与错误信息
 *
 * @discussion
 * [EN]: Sends a request to device (eRequestFileList) to retrieve file list under the given path.
 * [CN]: 调用设备指令 eRequestFileList，返回该路径下的文件列表。
 */
+ (void)getFileListForPath:(TSMetaFilePath *)filePath
                 completion:(void(^)(NSArray<TSMetaFileList *> * _Nullable fileList, NSError * _Nullable error))completion;

/**
 * @brief Delete file at specified device path
 * @chinese 根据设备文件路径删除文件
 *
 * @param filePath 
 * EN: The TSMetaFilePath object representing the target file path on device
 * CN: 设备上的目标文件路径（TSMetaFilePath 对象）
 *
 * @param completion 
 * EN: Completion callback with success flag and error
 * CN: 完成回调，返回是否成功与错误信息
 *
 * @discussion
 * [EN]: Sends delete request to device (eDeleteFile) for the given path.
 * [CN]: 调用设备指令 eDeleteFile 删除指定路径的文件。
 */
+ (void)deleteFileAtPath:(TSMetaFilePath *)filePath
              completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Clear folder at specified device path
 * @chinese 根据设备文件路径清空文件夹
 *
 * @param filePath 
 * EN: The TSMetaFilePath object representing the target folder path on device
 * CN: 设备上的目标文件夹路径（TSMetaFilePath 对象）
 *
 * @param completion 
 * EN: Completion callback with success flag and error
 * CN: 完成回调，返回是否成功与错误信息
 *
 * @discussion
 * [EN]: Sends clear folder request to device (eClearFolder) for the given path.
 * [CN]: 调用设备指令 eClearFolder 清空指定路径的文件夹。
 */
+ (void)clearFolderAtPath:(TSMetaFilePath *)filePath
               completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Register folder content change observer
 * @chinese 注册文件夹内容变化监听
 *
 * @param observer 
 * EN: Callback invoked when device reports folder content changes (TSMetaFileOperation, error)
 * CN: 当设备上报文件夹内容变化时触发，回调参数为 TSMetaFileOperation 与错误信息
 *
 * @discussion
 * [EN]: Listens to device event eMonitorFileChange. Use to refresh UI/file list when files are added/removed/cleaned.
 * [CN]: 监听设备 eMonitorFileChange 事件，用于在新增/删除/清空等操作后刷新 UI 或文件列表。
 */
+ (void)registerFileChangeObserver:(void(^)(TSMetaFileOperation * _Nullable operation, NSError * _Nullable error))observer;
 

/**
 * @brief Start fetch file data from device (Facade API)
 * @chinese 开始从设备接收文件数据（外观层接口）
 *
 * @param filePath
 * EN: The TSMetaFilePath on device to receive
 * CN: 设备端目标文件路径
 *
 * @param progress
 * EN: Transfer progress callback (0.0 - 1.0), called multiple times during transfer
 * CN: 传输进度回调（0.0 - 1.0），在传输过程中会被多次调用
 *
 * @param success
 * EN: Success callback, called when file transfer completes successfully
 * CN: 成功回调，当文件传输成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when file transfer fails
 * CN: 失败回调，当文件传输失败时调用
 *
 * @discussion
 * EN: This method starts receiving a file from the device. The progress callback will be 
 *     called multiple times during the transfer to report current progress. The success 
 *     callback will be called once when transfer completes successfully, and the failure 
 *     callback will be called if transfer fails.
 * CN: 此方法开始从设备接收文件。进度回调在传输过程中会被多次调用来报告当前进度。
 *     成功回调在传输成功完成时会被调用一次，失败回调在传输失败时会被调用。
 *
 * @note
 * EN: Only one file transfer operation can be active at a time
 * CN: 同时只能有一个文件传输操作处于活跃状态
 */
+ (void)fetchFileWithPath:(TSMetaFilePath *)filePath
                 progress:(TSFileTransferProgressCallback _Nullable)progress
                  success:(TSReceiveFileSuccessCallback)success
                  failure:(TSReceiveFileFailureCallback)failure;


/**
 * @brief Start send file to device (Facade API)
 * @chinese 开始向设备发送文件（外观层接口）
 *
 * @param filePath
 * EN: Local file path to send
 * CN: 要发送的本地文件路径
 *
 * @param toPath
 * EN: Target path on device to save the file
 * CN: 设备端保存文件的目标路径
 *
 * @param progress
 * EN: Transfer progress callback (0.0 - 1.0), called multiple times during transfer
 * CN: 传输进度回调（0.0 - 1.0），在传输过程中会被多次调用
 *
 * @param success
 * EN: Success callback, called when file transfer completes successfully
 * CN: 成功回调，当文件传输成功完成时调用
 *
 * @param failure
 * EN: Failure callback, called when file transfer fails
 * CN: 失败回调，当文件传输失败时调用
 *
 * @discussion
 * EN: This method starts sending a local file to the device. The progress callback will be 
 *     called multiple times during the transfer to report current progress. The success 
 *     callback will be called once when transfer completes successfully, and the failure 
 *     callback will be called if transfer fails.
 * CN: 此方法开始向设备发送本地文件。进度回调在传输过程中会被多次调用来报告当前进度。
 *     成功回调在传输成功完成时会被调用一次，失败回调在传输失败时会被调用。
 *
 * @note
 * EN: Only one file transfer operation can be active at a time
 * CN: 同时只能有一个文件传输操作处于活跃状态
 */
+ (void)sendFileWithLocalPath:(NSString *)filePath
                       toPath:(NSString *)toPath
                     progress:(TSFileTransferProgressCallback _Nullable)progress
                      success:(TSSendFileSuccessCallback)success
                      failure:(TSSendFileFailureCallback)failure;

/**
 * @brief Cancel current file transfer operation
 * @chinese 取消当前文件传输操作
 *
 * @param completion
 * EN: Completion callback with success flag and error information
 * CN: 完成回调，包含成功标志和错误信息
 *
 * @discussion
 * EN: This method cancels the current file transfer operation (either sending or receiving).
 *     The transfer process will be stopped and the device will remain in its current state.
 *     This operation cannot be undone once completed.
 * CN: 此方法取消当前的文件传输操作（发送或接收）。传输过程将被停止，设备将保持在当前状态。
 *     此操作一旦完成将无法撤销。
 *
 * @note
 * EN: If no transfer operation is currently active, this method will return success immediately
 * CN: 如果当前没有活跃的传输操作，此方法将立即返回成功
 */
+ (void)cancelFileTransferWithCompletion:(TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
