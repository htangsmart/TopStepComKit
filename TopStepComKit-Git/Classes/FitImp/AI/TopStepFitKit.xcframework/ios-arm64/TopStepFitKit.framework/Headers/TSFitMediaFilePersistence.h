//
//  TSFitMediaFilePersistence.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/8/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persists FitCloud temporary media files safely
 * @chinese 安全持久化 FitCloud 临时媒体文件
 */
@interface TSFitMediaFilePersistence : NSObject

/**
 * @brief Validate and create a destination folder
 * @chinese 校验并创建设备媒体文件目标目录
 *
 * @param localFolderPath EN: Absolute destination directory path
 *                        CN: 绝对目标目录路径
 * @param error EN: Validation or file-system error
 *              CN: 参数校验或文件系统错误
 * @return EN: YES when the directory is ready
 *         CN: 目录就绪时返回 YES
 */
+ (BOOL)prepareLocalFolderPath:(NSString *)localFolderPath
                         error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Copy a vendor temporary file and atomically publish it
 * @chinese 复制厂商临时文件并原子发布到目标目录
 *
 * @param downloadedFilePath EN: Vendor temporary file path
 *                           CN: 厂商临时文件路径
 * @param mediaFile EN: Expected media file metadata
 *                  CN: 预期的媒体文件元数据
 * @param localFolderPath EN: Prepared destination directory
 *                        CN: 已准备好的目标目录
 * @param error EN: Validation or file-system error
 *              CN: 校验或文件系统错误
 * @return EN: Final local path on success; nil on failure
 *         CN: 成功时的最终本地路径；失败时为 nil
 */
+ (nullable NSString *)persistDownloadedFileAtPath:(nullable NSString *)downloadedFilePath
                                         mediaFile:(TSMediaFileModel *)mediaFile
                                   localFolderPath:(NSString *)localFolderPath
                                             error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
