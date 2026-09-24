//
//  TSHsdClassroomModeModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"
#import "TSAlarmClockModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Classroom mode model
 * @chinese 课堂模式模型
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature.
 *      Read with TSHuashengdaInterface.fetchClassroomMode: and written with setClassroomMode:completion:.
 * [CN]: 华盛达定制能力。
 *      通过 TSHuashengdaInterface.fetchClassroomMode: 读取，setClassroomMode:completion: 设置。
 */
@interface TSHsdClassroomModeModel : TSKitBaseModel <NSCopying>

/**
 * @brief Whether classroom mode is enabled
 * @chinese 是否开启课堂模式
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Start time of classroom mode
 * @chinese 课堂模式开始时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 540 = 09:00).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 540 表示 09:00）。
 */
@property (nonatomic, assign) NSInteger startMinute;

/**
 * @brief End time of classroom mode
 * @chinese 课堂模式结束时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 1020 = 17:00).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 1020 表示 17:00）。
 */
@property (nonatomic, assign) NSInteger endMinute;

/**
 * @brief Weekly repeat options
 * @chinese 星期重复选项
 *
 * @discussion
 * [EN]: Uses TSAlarmRepeat, e.g. TSAlarmRepeatWorkday; combine days with |.
 * [CN]: 使用闹钟的 TSAlarmRepeat，如 TSAlarmRepeatWorkday；多天用 | 组合。
 */
@property (nonatomic, assign) TSAlarmRepeat repeatOptions;

@end

NS_ASSUME_NONNULL_END
