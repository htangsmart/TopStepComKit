//
//  TSMediaFileInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/21.
//

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSMediaFileModel.h"

NS_ASSUME_NONNULL_BEGIN

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
 * @param progress EN: Download progress in the range 0.0 to 1.0
 *                 CN: 下载进度，范围为 0.0 到 1.0
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
 * @param progress EN: Main-thread progress callback in the range 0.0 to 1.0
 *                 CN: 主线程进度回调，范围为 0.0 到 1.0
 * @param completion EN: Main-thread terminal callback called exactly once when non-nil
 *                   CN: 非 nil 时在主线程恰好回调一次的终态回调
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

@end

NS_ASSUME_NONNULL_END
