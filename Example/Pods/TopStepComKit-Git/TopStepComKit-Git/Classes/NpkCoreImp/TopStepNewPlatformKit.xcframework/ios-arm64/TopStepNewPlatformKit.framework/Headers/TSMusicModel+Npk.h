//
//  TSMusicModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSMusicModel extension for NPK platform
 * @chinese TSMusicModel的NPK平台扩展
 */
@interface TSMusicModel (Npk)

/**
 * @brief Convert TSMetaFileList array to TSMusicModel array
 * @chinese 将TSMetaFileList数组转换为TSMusicModel数组
 *
 * @param metaFileLists
 * EN: Array of TSMetaFileList objects from device
 * CN: 从设备获取的TSMetaFileList对象数组
 *
 * @return
 * EN: Array of TSMusicModel objects, empty array if input is nil or empty
 * CN: TSMusicModel对象数组，如果输入为nil或空则返回空数组
 *
 * @discussion
 * [EN]: Converts file list from device to music models.
 *       Extracts music information from file paths and sizes.
 *       Music ID is extracted from filename (without extension).
 *       File path is set to the device path.
 * [CN]: 将设备文件列表转换为音乐模型。
 *       从文件路径和大小中提取音乐信息。
 *       音乐ID从文件名（不含扩展名）中提取。
 *       文件路径设置为设备路径。
 */
+ (NSArray<TSMusicModel *> *)musicModelsWithMetaFileLists:(NSArray<TSMetaFileList *> *)metaFileLists;

/**
 * @brief Convert TSMetaFileInfo to TSMusicModel
 * @chinese 将TSMetaFileInfo转换为TSMusicModel
 *
 * @param metaFileInfo
 * EN: TSMetaFileInfo object from device
 * CN: 从设备获取的TSMetaFileInfo对象
 *
 * @return
 * EN: TSMusicModel object, nil if input is invalid
 * CN: TSMusicModel对象，如果输入无效则返回nil
 */
+ (nullable TSMusicModel *)musicModelWithMetaFileInfo:(TSMetaFileInfo *)metaFileInfo;

@end

NS_ASSUME_NONNULL_END

