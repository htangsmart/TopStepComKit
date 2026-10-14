//
//  TSMetaFileManager.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/11/27.
//

#import "TSBusinessBase.h"
#import "PbStreamParam.pbobjc.h"
#import "TSFileTransferDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaFileManager : TSBusinessBase

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
 


@end

NS_ASSUME_NONNULL_END
