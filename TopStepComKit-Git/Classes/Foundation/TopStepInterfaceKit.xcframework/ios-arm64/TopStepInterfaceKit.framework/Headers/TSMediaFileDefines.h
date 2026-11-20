//
//  TSMediaFileDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device media file type
 * @chinese 设备媒体文件类型
 */
typedef NS_ENUM(NSInteger, TSMediaFileType) {
    /// Unknown type / 未知类型
    TSMediaFileTypeUnknown = 0,
    /// Audio recording / 录音文件
    TSMediaFileTypeAudioRecording = 1,
    /// Image / 图片
    TSMediaFileTypeImage = 2,
    /// Video / 视频
    TSMediaFileTypeVideo = 3,
};

/**
 * @brief Supported device media file operations
 * @chinese 设备媒体文件支持的操作
 */
typedef NS_OPTIONS(NSUInteger, TSMediaFileOperation) {
    /// No supported operation / 不支持任何操作
    TSMediaFileOperationNone = 0,
    /// List files / 获取文件列表
    TSMediaFileOperationList = 1 << 0,
    /// Download a file / 下载文件
    TSMediaFileOperationDownload = 1 << 1,
    /// Delete a file / 删除单个文件
    TSMediaFileOperationDelete = 1 << 2,
    /// Delete all files of a type / 删除指定类型的全部文件
    TSMediaFileOperationDeleteAll = 1 << 3,
    /// Observe list invalidation / 监听列表失效
    TSMediaFileOperationObserveChanges = 1 << 4,
    /// Prepare a session / 准备导入会话
    TSMediaFileOperationPrepareImport = 1 << 5,
    /// Import a batch / 批量导入
    TSMediaFileOperationImportBatch = 1 << 6,
    /// Cancel the active session / 取消会话
    TSMediaFileOperationCancelImport = 1 << 7,
    /// Finish the session / 会话收尾
    TSMediaFileOperationFinishImport = 1 << 8,
};

NS_ASSUME_NONNULL_END
