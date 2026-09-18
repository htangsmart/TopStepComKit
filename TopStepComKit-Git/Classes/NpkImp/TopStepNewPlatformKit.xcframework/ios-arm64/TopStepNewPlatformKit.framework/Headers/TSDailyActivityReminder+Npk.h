//
//  TSDailyActivityReminder+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/4.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbConfigParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDailyActivityReminder (Npk)

/**
 * @brief Create reminder model from meta goals config (flags)
 * @chinese 自底层 TSMetaDailyConfig 的 flags 生成 TSDailyActivityReminder
 */
+ (TSDailyActivityReminder *_Nullable)reminderFromMetaGoals:(TSMetaDailyConfig *_Nullable)meta;

/**
 * @brief Build flags bitmap from reminder switches
 * @chinese 由提醒开关生成 flags 位图
 */
+ (int32_t)flagsFromReminder:(TSDailyActivityReminder *)reminder;

@end

NS_ASSUME_NONNULL_END
