//
//  TSMediaFileInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/21.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSMediaFileModel.h"
#import "TSMediaFileImportSessionModel.h"
#import "TSMediaFileImportEventModel.h"
#import "TSMediaFileImportBatchResultModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Import preparation callback
 * @chinese 导入准备回调
 * @param session
 * EN: Prepared manifest; on failure a session may be returned for cancellation.
 * CN: 准备结果；失败时仍可能返回待取消清理的会话。
 * @param error
 * EN: Failure, nil on success.
 * CN: 失败原因，成功为空。
 */
typedef void (^TSMediaFileImportPrepareBlock)(TSMediaFileImportSessionModel * _Nullable session,
                                            NSError * _Nullable error);
/**
 * @brief Import phase and durable-file callback
 * @chinese 导入阶段与持久文件回调
 * @param event
 * EN: Main-queue event, never raw binary chunks.
 * CN: 主队列事件，不传原始二进制数据块。
 */
typedef void (^TSMediaFileImportEventBlock)(TSMediaFileImportEventModel *event);
/**
 * @brief Import batch terminal callback
 * @chinese 导入批次终态回调
 * @param batch
 * EN: Per-file results; may be partial on error.
 * CN: 逐文件结果，错误时可能部分成功。
 * @param error
 * EN: Batch failure, nil when all files are available.
 * CN: 批次错误，所有文件可用时为空。
 */
typedef void (^TSMediaFileImportBatchBlock)(TSMediaFileImportBatchResultModel * _Nullable batch,
                                          NSError * _Nullable error);


/**
 * @brief Device media file list callback
 * @chinese 设备媒体文件列表回调
 *
 * @param mediaFiles EN: Files on success, an empty array when no file exists; nil on failure
 *                   CN: 成功时的文件列表；没有文件时为空数组；失败时为 nil
 * @param error EN: Error on failure; nil on success
 *              CN: 失败时的错误；成功时为 nil
 */
typedef void (^TSMediaFileListBlock)(NSArray<TSMediaFileModel *> * _Nullable mediaFiles,
                                     NSError * _Nullable error);

/**
 * @brief Device media file download progress callback
 * @chinese 设备媒体文件下载进度回调
 *
 * @param progress EN: Download progress percentage in the range 0.0 to 100.0
 *                 CN: 下载进度百分比，范围为 0.0 到 100.0
 */
typedef void (^TSMediaFileDownloadProgressBlock)(double progress);

/**
 * @brief Device media file download completion callback
 * @chinese 设备媒体文件下载完成回调
 *
 * @param localFilePath EN: Final local file path on success; nil on failure
 *                      CN: 成功时的最终本地文件路径；失败时为 nil
 * @param error EN: Error on failure; nil on success
 *              CN: 失败时的错误；成功时为 nil
 */
typedef void (^TSMediaFileDownloadCompletionBlock)(NSString * _Nullable localFilePath,
                                                   NSError * _Nullable error);

/**
 * @brief Device media file list invalidation callback
 * @chinese 设备媒体文件列表失效回调
 *
 * @param type EN: The media file type whose list must be fetched again
 *             CN: 需要重新获取列表的媒体文件类型
 */
typedef void (^TSMediaFileListDidChangedBlock)(TSMediaFileType type);

/**
 * @brief Device media file management interface
 * @chinese 设备媒体文件管理接口
 */
@protocol TSMediaFileInterface <TSKitBaseInterface>

/**
 * @brief Query supported operations for a media file type
 * @chinese 查询指定媒体文件类型支持的操作
 *
 * @param type EN: Media file type
 *             CN: 媒体文件类型
 * @return EN: Supported operation bit mask; None when unsupported
 *         CN: 支持的操作位掩码；不支持时为 None
 */
- (TSMediaFileOperation)supportedOperationsForType:(TSMediaFileType)type;

/**
 * @brief Fetch device media files of a type
 * @chinese 获取指定类型的设备媒体文件
 *
 * @param type EN: Media file type
 *             CN: 媒体文件类型
 * @param completion EN: Main-thread completion called exactly once when non-nil
 *                   CN: 非 nil 时在主线程恰好回调一次
 */
- (void)fetchMediaFilesOfType:(TSMediaFileType)type
                   completion:(nullable TSMediaFileListBlock)completion;

/**
 * @brief Download a device media file to a local folder
 * @chinese 下载设备媒体文件到本地目录
 *
 * @param mediaFile EN: A model returned by fetchMediaFilesOfType:completion:
 *                  CN: fetchMediaFilesOfType:completion: 返回的模型
 * @param localFolderPath EN: Destination directory; created when missing
 *                        CN: 目标目录；不存在时自动创建
 * @param progress EN: Main-thread progress callback in the range 0.0 to 100.0
 *                 CN: 主线程进度回调，范围为 0.0 到 100.0
 * @param completion EN: Main-thread terminal callback called exactly once when non-nil
 *                   CN: 非 nil 时在主线程恰好回调一次的终态回调
 *
 * @note EN: Whether the device-side file is removed after a successful download is platform-defined.
 *           On FitCloud devices the vendor SDK deletes the device file once the download succeeds and
 *           then fires the list-changed callback; callers must not call deleteMediaFile:completion:
 *           for a file they have just downloaded. Re-query fetchMediaFilesOfType:completion: instead.
 *       CN: 下载成功后设备侧文件是否被移除由平台决定。FitCloud 设备在下载成功后由厂商 SDK 删除设备文件，
 *           随后触发列表变化回调；调用方不要对刚下载完成的文件再调 deleteMediaFile:completion:，
 *           应重新调用 fetchMediaFilesOfType:completion: 以设备清单为准。
 */
- (void)downloadMediaFile:(TSMediaFileModel *)mediaFile
          localFolderPath:(NSString *)localFolderPath
                 progress:(nullable TSMediaFileDownloadProgressBlock)progress
               completion:(nullable TSMediaFileDownloadCompletionBlock)completion;

/**
 * @brief Delete one device media file
 * @chinese 删除单个设备媒体文件
 *
 * @param mediaFile EN: A model returned by fetchMediaFilesOfType:completion:
 *                  CN: fetchMediaFilesOfType:completion: 返回的模型
 * @param completion EN: Main-thread completion called exactly once when non-nil
 *                   CN: 非 nil 时在主线程恰好回调一次
 */
- (void)deleteMediaFile:(TSMediaFileModel *)mediaFile
             completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Delete all device media files of a type
 * @chinese 删除指定类型的全部设备媒体文件
 *
 * @param type EN: Media file type
 *             CN: 媒体文件类型
 * @param completion EN: Main-thread completion called exactly once when non-nil
 *                   CN: 非 nil 时在主线程恰好回调一次
 */
- (void)deleteAllMediaFilesOfType:(TSMediaFileType)type
                       completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Register a media file list invalidation callback
 * @chinese 注册媒体文件列表失效回调
 *
 * @param changeBlock EN: Replaces the previous callback; pass nil to unregister
 *                    CN: 替换之前的回调；传 nil 取消注册
 */
- (void)registerMediaFileListDidChangedBlock:(nullable TSMediaFileListDidChangedBlock)changeBlock;

@optional

/**
 * @brief Prepare device Wi-Fi and fetch an import manifest
 * @chinese 准备设备 Wi-Fi 并获取导入清单
 *
 * @param types
 * EN: Explicit nonempty set of requested media types.
 * CN: 明确指定且非空的媒体类型集合。
 *
 * @param event
 * EN: Optional phase events delivered on the main queue.
 * CN: 可选阶段事件，在主队列交付。
 *
 * @param completion
 * EN: Called once on the main queue, including empty manifests and errors.
 * CN: 主队列恰好回调一次，空清单和失败均有回调。
 */
- (void)prepareMediaFileImportForTypes:(NSArray<NSNumber *> *)types
                               event:(nullable TSMediaFileImportEventBlock)event
                          completion:(TSMediaFileImportPrepareBlock)completion
    NS_SWIFT_NAME(prepareImport(types:event:completion:));

/**
 * @brief Import files from a prepared session into durable local storage
 * @chinese 将已准备会话的文件导入持久本地目录
 *
 * @param mediaFiles
 * EN: Models returned by this session, never reconstructed from names.
 * CN: 本会话返回的模型，不得从名称重建。
 *
 * @param sessionIdentifier
 * EN: Identifier returned by prepare.
 * CN: 准备阶段返回的会话标识。
 *
 * @param localFolderPath
 * EN: Absolute destination directory; audio uses its Audio subdirectory.
 * CN: 绝对目标目录，录音进入其 Audio 子目录。
 *
 * @param event
 * EN: Main-queue phase, progress and persisted-file events.
 * CN: 主队列阶段、进度和已落盘文件事件。
 *
 * @param completion
 * EN: One main-queue terminal result; partial results survive errors.
 * CN: 主队列一次终态；失败时保留部分成功结果。
 */
- (void)importMediaFiles:(NSArray<TSMediaFileModel *> *)mediaFiles
      sessionIdentifier:(NSString *)sessionIdentifier
        localFolderPath:(NSString *)localFolderPath
                  event:(nullable TSMediaFileImportEventBlock)event
             completion:(TSMediaFileImportBatchBlock)completion
    NS_SWIFT_NAME(importFiles(_:sessionIdentifier:localFolderPath:event:completion:));

/**
 * @brief Cancel only the identified import session
 * @chinese 只取消指定导入会话
 *
 * @param sessionIdentifier
 * EN: Session to cancel; a stale session cannot affect a new connection.
 * CN: 待取消会话，旧会话不能影响新连接。
 *
 * @param completion
 * EN: One main-queue callback; failure does not release an unknown device state.
 * CN: 主队列一次回调；失败不能把未知设备状态释放为空闲。
 */
- (void)cancelMediaFileImportWithSessionIdentifier:(NSString *)sessionIdentifier
                                      completion:(TSCompletionBlock)completion
    NS_SWIFT_NAME(cancelImport(sessionIdentifier:completion:));

/**
 * @brief Finish a session after all file operations have settled
 * @chinese 所有文件操作结束后收尾会话
 *
 * @param sessionIdentifier
 * EN: Session to finish.
 * CN: 待收尾会话。
 *
 * @param completion
 * EN: One main-queue callback; device idle must be observed before success.
 * CN: 主队列一次回调；必须观察到设备空闲才报告成功。
 */
- (void)finishMediaFileImportWithSessionIdentifier:(NSString *)sessionIdentifier
                                      completion:(TSCompletionBlock)completion
    NS_SWIFT_NAME(finishImport(sessionIdentifier:completion:));

@end

NS_ASSUME_NONNULL_END
