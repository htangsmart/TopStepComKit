//
//  TSFileModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/28.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSFileModel extension for NPK platform
 * @chinese TSFileModel的NPK平台扩展
 */
@interface TSFileModel (Npk)

/**
 * @brief Convert TSMetaFileList array to TSFileModel array
 * @chinese 将TSMetaFileList数组转换为TSFileModel数组
 *
 * @param metaFileLists
 * EN: Array of TSMetaFileList objects from device
 * CN: 从设备获取的TSMetaFileList对象数组
 *
 * @return
 * EN: Array of TSFileModel objects, empty array if input is nil or empty
 * CN: TSFileModel对象数组，如果输入为nil或空则返回空数组
 */
+ (NSArray<TSFileModel *> *)fileModelsWithMetaFileLists:(NSArray<TSMetaFileList *> *)metaFileLists;

/**
 * @brief Convert TSMetaFileInfo to TSFileModel
 * @chinese 将TSMetaFileInfo转换为TSFileModel
 *
 * @param metaFileInfo
 * EN: TSMetaFileInfo object from device
 * CN: 从设备获取的TSMetaFileInfo对象
 *
 * @return
 * EN: TSFileModel object, nil if input is invalid
 * CN: TSFileModel对象，如果输入无效则返回nil
 */
+ (TSFileModel *)fileModelWithMetaFileInfo:(TSMetaFileInfo *)metaFileInfo;

@end

NS_ASSUME_NONNULL_END
