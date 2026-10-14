//
//  TSMetaFileData+Extension.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/15.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaFileData (Extension)

/**
 * @brief Create TSMetaFileData with offset and data, then convert to NSData
 * @chinese 根据offset和data创建TSMetaFileData并转为NSData
 *
 * @param offset
 * [EN]: File data offset position
 * [CN]: 文件数据偏移位置
 *
 * @param data
 * [EN]: File data content
 * [CN]: 文件数据内容
 *
 * @return
 * [EN]: NSData representation of TSMetaFileData, nil if creation fails
 * [CN]: TSMetaFileData的NSData表示，创建失败时返回nil
 *
 * @discussion
 * [EN]: This method creates a TSMetaFileData object with the specified offset and data,
 *       then converts it to NSData format for transmission. The offset represents
 *       the position in the original file where this data segment belongs.
 * [CN]: 此方法使用指定的offset和data创建TSMetaFileData对象，然后转换为NSData格式
 *       用于传输。offset表示此数据段在原始文件中的位置。
 */
+ (NSData * _Nullable)dataWithOffset:(int32_t)offset data:(NSData * _Nullable)data;

@end

NS_ASSUME_NONNULL_END
