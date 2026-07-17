//
//  TSWristWakeUpModel.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/20.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Wrist wake up settings model
 * @chinese 抬腕亮屏设置模型
 * 
 * @discussion 
 * EN: This model defines the settings for wrist wake up feature, including:
 *     1. Enable/disable status
 *     2. Time period settings (begin and end time)
 *     Note: The end time must be greater than begin time to form a valid time period
 * CN: 该模型定义了抬腕亮屏功能的设置，包括：
 *     1. 功能开关状态
 *     2. 时间段设置（开始和结束时间）
 *     注意：结束时间必须大于开始时间才能形成有效的时间段
 */
@interface TSWristWakeUpModel : TSKitBaseModel

/**
 * @brief Enable status of wrist wake up feature
 * @chinese 抬腕亮屏功能的启用状态
 * 
 * @discussion 
 * EN: Controls whether the screen will wake up when user raises their wrist
 *     - YES: Feature is enabled
 *     - NO: Feature is disabled
 * CN: 控制用户抬起手腕时屏幕是否会被唤醒
 *     - YES: 功能已启用
 *     - NO: 功能已禁用
 */
@property (nonatomic, assign) BOOL isEnable;

/**
 * @brief Start time of wrist wake up period in minutes from midnight
 * @chinese 抬腕亮屏时间段的开始时间（从0点开始的分钟数）
 * 
 * @discussion 
 * EN: The number of minutes from midnight (00:00) when wrist wake up feature becomes active
 *     For example: 480 means 8:00 AM (8 hours * 60 minutes)
 *     Valid range: 0-1439 (00:00 to 23:59)
 *     Note: Must be less than end time
 * CN: 从午夜0点开始计算的分钟数，表示抬腕亮屏功能开始生效的时间
 *     例如：480表示早上8点（8小时 * 60分钟）
 *     有效范围：0-1439（00:00至23:59）
 *     注意：必须小于结束时间
 */
@property (nonatomic, assign) NSInteger startTime;

/**
 * @brief End time of wrist wake up period in minutes from midnight
 * @chinese 抬腕亮屏时间段的结束时间（从0点开始的分钟数）
 * 
 * @discussion 
 * EN: The number of minutes from midnight (00:00) when wrist wake up feature becomes inactive
 *     For example: 1320 means 10:00 PM (22 hours * 60 minutes)
 *     Valid range: 0-1439 (00:00 to 23:59)
 *     Note: Must be greater than begin time to form a valid time period
 * CN: 从午夜0点开始计算的分钟数，表示抬腕亮屏功能结束生效的时间
 *     例如：1320表示晚上10点（22小时 * 60分钟）
 *     有效范围：0-1439（00:00至23:59）
 *     注意：必须大于开始时间才能形成有效的时间段
 */
@property (nonatomic, assign) NSInteger endTime;

@end

NS_ASSUME_NONNULL_END
