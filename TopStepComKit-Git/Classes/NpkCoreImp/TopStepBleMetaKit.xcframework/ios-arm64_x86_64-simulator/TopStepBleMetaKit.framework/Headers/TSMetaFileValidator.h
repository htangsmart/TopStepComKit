//
//  TSMetaFileValidator.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/11.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

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
 * @brief Validate local file against file header
 * @chinese 根据文件头校验本地文件
 *
 * @param localFilePath
 * EN: Path to the local file that should match the file header information
 * CN: 待校验的本地文件路径，需要与文件头信息匹配
 *
 * @param fileHeader
 * EN: The file header containing expected size and CRC32
 * CN: 包含期望大小和CRC32的文件头
 *
 * @return
 * EN: Validation error (nil if validation passes)
 * CN: 校验错误（nil表示校验通过）
 *
 * @discussion
 * [EN]: This method validates the file by:
 *       1. Checking if the file path and file header exist
 *       2. Reading file data from the given path
 *       3. Verifying that file size matches expected size in fileHeader
 *       4. Calculating CRC32 of fileData and comparing with expected CRC32 in fileHeader
 *       Returns nil if all checks pass, otherwise returns NSError with detailed description.
 * [CN]: 此方法通过以下步骤验证文件：
 *       1. 检查文件路径和文件头是否存在
 *       2. 从路径读取文件数据
 *       3. 验证文件大小是否与文件头中的期望大小匹配
 *       4. 计算文件的 CRC32 并与文件头中的期望 CRC32 比较
 *       如果所有检查都通过则返回 nil，否则返回带详细描述的 NSError。
 */
+ (NSError * _Nullable)validateFileAtPath:(NSString * _Nullable)localFilePath
                         withFileHeader:(TSMetaFileHead * _Nullable)fileHeader;

@end

NS_ASSUME_NONNULL_END

