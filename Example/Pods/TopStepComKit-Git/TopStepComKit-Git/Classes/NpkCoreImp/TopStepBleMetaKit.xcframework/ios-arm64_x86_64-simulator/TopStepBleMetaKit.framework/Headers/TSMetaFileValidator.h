//
//  TSMetaFileValidator.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/11.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File status enumeration
 * @chinese 文件状态枚举
 *
 * @discussion
 * [EN]: Represents the status of a local file compared to the expected file header.
 * [CN]: 表示本地文件相对于期望文件头的状态。
 */
typedef NS_ENUM(NSInteger, TSMetaFileStatus) {
    TSMetaFileStatusDirNotExists = 0,         // 文件夹不存在
    TSMetaFileStatusFileNotExists = 1,        // 文件不存在
    TSMetaFileStatusIncomplete = 2,           // 文件未完整（需继续传输）
    TSMetaFileStatusDataError = 3,            // 文件数据错误（本地数据大于远程数据）
    TSMetaFileStatusCRC32Error = 4,           // 文件CRC32错误
    TSMetaFileStatusCorrect = 5               // 文件无错误
};

/**
 * @brief Meta protocol file validator
 * @chinese Meta协议文件校验器
 *
 * @discussion
 * [EN]: Validates file data integrity by checking size and CRC32 checksum.
 *       This validator is specifically designed for Meta protocol file transfers.
 *       It ensures that received/sent files match the expected specifications
 *       defined in TSMetaFileHead.
 * [CN]: 通过检查大小和CRC32校验和来验证文件数据完整性。
 *       此校验器专为Meta协议文件传输设计。
 *       它确保接收/发送的文件符合 TSMetaFileHead 中定义的预期规格。
 */
@interface TSMetaFileValidator : NSObject

/**
 * @brief Get file status by comparing local file with file header
 * @chinese 根据本地文件和文件头比较获取文件状态
 *
 * @param localFilePath
 * EN: Path to the local file
 * CN: 本地文件路径
 *
 * @param fileHeader
 * EN: The file header containing expected size and CRC32
 * CN: 包含期望大小和CRC32的文件头
 *
 * @return
 * EN: File status enumeration value
 * CN: 文件状态枚举值
 *
 * @discussion
 * [EN]: This method analyzes the local file status by:
 *       1. Checking if directory exists
 *       2. Checking if file exists
 *       3. Comparing file size with expected size
 *       4. Comparing file CRC32 with expected CRC32
 *       Returns appropriate status based on the analysis.
 * [CN]: 此方法通过以下步骤分析本地文件状态：
 *       1. 检查文件夹是否存在
 *       2. 检查文件是否存在
 *       3. 比较文件大小与期望大小
 *       4. 比较文件CRC32与期望CRC32
 *       根据分析结果返回相应的状态。
 */
+ (TSMetaFileStatus)validFileStatusAtPath:(NSString * _Nullable)localFilePath
                         withFileHeader:(TSMetaFileHead * _Nullable)fileHeader;

/**
 * @brief Generate NSError from file status
 * @chinese 根据文件状态生成NSError
 *
 * @param fileStatus
 * EN: File status enumeration value
 * CN: 文件状态枚举值
 *
 * @param localFilePath
 * EN: Local file path (optional, used for error message details)
 * CN: 本地文件路径（可选，用于错误消息详情）
 *
 * @return
 * EN: NSError object if status indicates an error, nil if status is correct or incomplete
 * CN: 如果状态表示错误则返回NSError对象，如果状态正确或未完整则返回nil
 *
 * @discussion
 * [EN]: This method converts file status to NSError:
 *       - TSMetaFileStatusCorrect: Returns nil (no error)
 *       - TSMetaFileStatusIncomplete: Returns nil (not an error, just needs continuation)
 *       - TSMetaFileStatusDirNotExists: Returns error for directory not found
 *       - TSMetaFileStatusFileNotExists: Returns error for file not found
 *       - TSMetaFileStatusDataError: Returns error for data format error
 *       - TSMetaFileStatusCRC32Error: Returns error for CRC32 mismatch
 * [CN]: 此方法将文件状态转换为NSError：
 *       - TSMetaFileStatusCorrect: 返回nil（无错误）
 *       - TSMetaFileStatusIncomplete: 返回nil（不是错误，只需继续传输）
 *       - TSMetaFileStatusDirNotExists: 返回文件夹不存在的错误
 *       - TSMetaFileStatusFileNotExists: 返回文件不存在的错误
 *       - TSMetaFileStatusDataError: 返回数据格式错误
 *       - TSMetaFileStatusCRC32Error: 返回CRC32不匹配错误
 */
+ (NSError * _Nullable)errorWithStatus:(TSMetaFileStatus)fileStatus
                            localFilePath:(NSString * _Nullable)localFilePath;

@end

NS_ASSUME_NONNULL_END

