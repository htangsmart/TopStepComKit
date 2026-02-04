//
//  TSMetaSportDataSync.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSMetaBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaSportDataSync : TSMetaBaseDataSync

/**
 * @brief Convert watch UI sport type (TopStep) to watch sport type (TopStep 16-bit hex)
 * @chinese 将手表UI运动类型（拓步）转换为手表运动类型（拓步16进制）
 * 
 * @param type 
 * EN: Watch UI sport type value from device (TopStep)
 * CN: 设备返回的手表UI运动类型值（拓步）
 * 
 * @return 
 * EN: Converted watch sport type value (TopStep 16-bit hex), returns original value if no mapping found
 * CN: 转换后的手表运动类型值（拓步16进制），如果未找到映射则返回原值
 */
+ (int32_t)sportUITypeTo16Type:(int32_t)type;

@end

NS_ASSUME_NONNULL_END
