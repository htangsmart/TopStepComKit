//
//  TSMetaFileDataResponse+Extension.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/15.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaFileDataResponse (Extension)

/**
 * @brief Generate TSMetaFileDataResponse for file receiving
 * @chinese 为文件接收生成TSMetaFileDataResponse
 *
 * @param filePath
 * [EN]: The TSMetaFilePath object representing the device file path
 * [CN]: 表示设备文件路径的TSMetaFilePath对象
 *
 * @param localFilePath
 * [EN]: The local file path where received file is saved
 * [CN]: 接收文件保存的本地路径
 *
 * @param responseResult
 * [EN]: The result code for this data frame response
 * [CN]: 此数据帧响应的结果码
 *
 * @return
 * [EN]: TSMetaFileDataResponse object, returns nil if creation fails
 * [CN]: TSMetaFileDataResponse对象，创建失败时返回nil
 *
 * @discussion
 * [EN]: This method generates TSMetaFileDataResponse for file receiving:
 *       1. Set result from responseResult parameter
 *       2. Read local file to get current fileSize
 *       3. Calculate CRC32 of current received file data
 *       4. Return complete TSMetaFileDataResponse object
 * [CN]: 此方法为文件接收生成TSMetaFileDataResponse：
 *       1. 从responseResult参数设置result
 *       2. 读取本地文件获取当前fileSize
 *       3. 计算当前已接收文件数据的CRC32
 *       4. 返回完整的TSMetaFileDataResponse对象
 */
+ (TSMetaFileDataResponse * _Nullable)dataResponseWithFilePath:(NSString *)localFilePath
                                                        result:(TSFileDataResponseResult)responseResult;

@end

NS_ASSUME_NONNULL_END

