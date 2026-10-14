//
//  TSHsdModels+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/9/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbHsdParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

/// 2000-01-01 00:00:00 UTC 的 Unix 时间戳（协议中"距 2000 年始的秒数"的基准）
FOUNDATION_EXPORT const NSTimeInterval kTSNpkHsdEpoch2000;

/// TSAlarmRepeat 与协议星期位（bit0=周一 … bit6=周日）位定义一致，直接掩码转换
static inline TSAlarmRepeat TSNpkHsdRepeatFromProto(int32_t repeat) { return (TSAlarmRepeat)(repeat & 0x7F); }
static inline int32_t TSNpkHsdRepeatToProto(TSAlarmRepeat repeat) { return (int32_t)(repeat & 0x7F); }

@interface TSHsdParentalControlPeriodModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdParentalControlPeriod *)meta;
- (TSMetaHsdParentalControlPeriod *)toMeta;
@end

@interface TSHsdParentalControlItemModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdParentalControlItem *)meta;
- (TSMetaHsdParentalControlItem *)toMeta;
@end

@interface TSHsdParentalControlModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdParentalControl *)meta;
- (TSMetaHsdParentalControl *)toMeta;
@end

@interface TSHsdClassroomModeModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdClassroomMode *)meta;
- (TSMetaHsdClassroomMode *)toMeta;
@end

@interface TSHsdTaskModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdTask *)meta;
- (TSMetaHsdTask *)toMeta;
@end

@interface TSHsdTaskInfoModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdTaskInfo *)meta;
- (TSMetaHsdTaskInfo *)toMeta;
@end

@interface TSHsdHabitModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdHabit *)meta;
- (TSMetaHsdHabit *)toMeta;
@end

@interface TSHsdDailyUsageModel (Npk)
/**
 * 由一天的 proto 列表构建"天"模型。
 * @param meta        一天的使用统计
 * @param dayOffset   分包序号（距手表今天的天数偏移）
 * @param now         推算日期用的基准时间（通常为 [NSDate date]；单测可注入）
 * @discussion meta.timestamp > 0 时 date 取设备时间（dateSource=Device），否则取 now 所在日零点减 dayOffset 天（dateSource=Inferred）
 */
+ (instancetype)modelFromMeta:(TSMetaHsdUsageInfoList *)meta dayOffset:(NSInteger)dayOffset now:(NSDate *)now;
@end

@interface TSHsdGameRecordModel (Npk)
+ (instancetype)modelFromMeta:(TSMetaHsdGameRecord *)meta;
@end

@interface TSHsdGameRankingTrendModel (Npk)
- (TSMetaHsdGameRankingTrend *)toMeta;
@end

NS_ASSUME_NONNULL_END
