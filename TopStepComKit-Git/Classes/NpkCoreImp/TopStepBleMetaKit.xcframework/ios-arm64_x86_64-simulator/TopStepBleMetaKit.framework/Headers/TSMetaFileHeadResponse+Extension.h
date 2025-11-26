//
//  TSMetaFileHeadResponse+Extension.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/9/12.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaFileHeadResponse (Extension)

/**
 * @brief Get debug description for TSMetaFileHeadResponse
 * @chinese 获取TSMetaFileHeadResponse的调试描述信息
 *
 * @return
 * EN: Debug description string containing response details
 * CN: 包含响应详细信息的调试描述字符串
 *
 * @discussion
 * EN: This method provides a detailed debug description of the file head response,
 *     including the result code and human-readable description.
 * CN: 此方法提供文件头响应的详细调试描述，
 *     包括结果代码和人类可读的描述。
 */
- (NSString *)debugDescription;

/**
 * @brief Calculate upload position based on local file data
 * @chinese 根据本地文件数据计算上传位置
 *
 * @param fileData
 * EN: Local file data to verify
 * CN: 要验证的本地文件数据
 *
 * @return
 * EN: Upload position in bytes. Returns 0 if verification fails or starts from beginning
 * CN: 上传位置（字节）。如果验证失败或从头开始则返回0
 *
 * @discussion
 * EN: This method calculates the upload position based on the response and local file data:
 *     1. If oldSize == 0, return 0 (start from beginning)
 *     2. If oldSize != 0, get subdata from 0 to oldSize and calculate CRC32
 *     3. If CRC32 matches, continue from oldSize position
 *     4. If CRC32 doesn't match, data error occurred, return 0 (restart from beginning)
 * CN: 此方法根据响应和本地文件数据计算上传位置：
 *     1. 如果oldSize == 0，返回0（从头开始）
 *     2. 如果oldSize != 0，获取0到oldSize的子数据并计算CRC32
 *     3. 如果CRC32匹配，从oldSize位置继续
 *     4. 如果CRC32不匹配，数据出错，返回0（从头开始）
 */
- (NSInteger)calculateUploadPositionWithFileData:(NSData *)fileData;

/**
 * @brief Validate TSMetaFileHeadResponse with local file data
 * @chinese 使用本地文件数据验证TSMetaFileHeadResponse
 */
- (NSError * _Nullable)validateError ;

/**
 * @brief Generate file head response for receiving file
 * @chinese 为接收文件生成文件头响应
 *
 * @param localFilePath
 * EN: The local file path to save received file
 * CN: 保存接收文件的本地文件路径
 *
 * @return
 * EN: TSMetaFileHeadResponse object, returns nil if creation fails
 * CN: TSMetaFileHeadResponse对象，如果创建失败返回nil
 *
 * @discussion
 * [EN]: This method generates TSMetaFileHeadResponse for file receiving:
 *       1. Create directory if not exists
 *       2. If file exists, calculate oldSize and oldCrc32 for resume support
 *       3. If file not exists, return response with oldSize=0, oldCrc32=0
 *       4. Set packageSize=960, packageCount=50 as default values
 *       Note: Caller should read file data based on response.oldSize if needed
 * [CN]: 此方法为文件接收生成TSMetaFileHeadResponse：
 *       1. 如果目录不存在则创建
 *       2. 如果文件存在，计算oldSize和oldCrc32以支持断点续传
 *       3. 如果文件不存在，返回 oldSize=0, oldCrc32=0 的响应
 *       4. 设置默认值 packageSize=960, packageCount=50
 *       注意：调用者应根据 response.oldSize 判断是否需要读取文件数据
 */
+ (TSMetaFileHeadResponse * _Nullable)headerResponseWithFilePath:(NSString *)localFilePath;

@end

NS_ASSUME_NONNULL_END
