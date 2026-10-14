//
//  TSMetaTime.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Time management class
 * @chinese 时间管理类
 */
@interface TSMetaTime : TSBusinessBase

/**
 * @brief Set time information
 * @chinese 设置时间信息
 *
 * @param timeInfo 
 * EN: Time information object containing timestamp and timezone offset
 * CN: 包含时间戳和时区偏移的时间信息对象
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setTimeInfo:(TSMetaTimeModel *)timeInfo completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
