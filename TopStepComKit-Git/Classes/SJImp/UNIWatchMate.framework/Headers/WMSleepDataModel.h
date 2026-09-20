//
//  WMSleepDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 睡眠状态 （Sleep state）
typedef NS_ENUM(NSInteger, WMSleepStatusType) {
    //清醒 （sober）
    WMSleepStatusAwake = 0,
    //浅睡 （Light sleep）
    WMSleepStatusLight = 1,
    //深睡 （Deep sleep）
    WMSleepStatusDeep = 2,
    //REM
    WMSleepStatusREM = 3,
};

@interface WMSleepItemDataModel : NSObject

/// 睡眠状态 （Sleep state）
@property (nonatomic, assign) WMSleepStatusType sleep_status;
/// 持续时长（分钟）（Duration (minutes)）
@property (nonatomic, assign) NSInteger duration;
/// 时间戳（毫秒） （Time stamp (milliseconds)）
@property (nonatomic, assign) NSInteger datestamp;

@end

@interface WMSleepDataModel : NSObject

/// 日期时间戳 （Date and time stamp）
@property (nonatomic, assign) NSInteger dateStamp;
/// 入睡时间时间戳 （Bedtime time time stamp）
@property (nonatomic, assign) NSInteger bed_time;
/// 起床时间时间戳 （Wake up time timestamp）
@property (nonatomic, assign) NSInteger get_up_time;
/// 睡眠时长（分钟） （Sleep duration (minutes)）
@property (nonatomic, assign) NSInteger total_sleep_minutes;
/// 睡眠类型 0：白天睡眠， 1：夜晚睡眠 （Sleep type 0: daytime sleep, 1: night sleep）
@property (nonatomic, assign) NSInteger sleepType;
/// 清醒时长（分钟） （Awake duration (minutes)）
@property (nonatomic, assign) NSInteger awake_sleep_minutes;
/// 浅睡时长（分钟）（Light sleep duration (min)）
@property (nonatomic, assign) NSInteger light_sleep_minutes;
/// 深睡时长（分钟） （Deep Sleep duration (minutes)）
@property (nonatomic, assign) NSInteger deep_sleep_minutes;
/// 眼动时长（分钟） （Eye movement duration (min)）
@property (nonatomic, assign) NSInteger rem_sleep_minutes;
/// 清醒次数 （Wakefulness frequency）
@property (nonatomic, assign) NSInteger awake_count;
/// 浅睡次数 （Number of light sleeps）
@property (nonatomic, assign) NSInteger light_sleep_count;
/// 深睡次数 （Number of deep sleeps）
@property (nonatomic, assign) NSInteger deep_sleep_count;
/// 眼动次数 （Eye movement frequency）
@property (nonatomic, assign) NSInteger rem_sleep_count;
/// 清醒百分比 （Percentage of wakefulness）
@property (nonatomic, assign) NSInteger awake_percentage;
/// 浅睡百分比 （Percentage light sleep）
@property (nonatomic, assign) NSInteger light_sleep_percentage;
/// 深睡百分比 （Percent deep sleep）
@property (nonatomic, assign) NSInteger deep_sleep_percentage;
/// 眼动百分比 （Eye movement percentage）
@property (nonatomic, assign) NSInteger rem_sleep_percentage;
/// 睡眠得分 （Sleep score）
@property (nonatomic, assign) NSInteger sleep_score;

/// 睡眠详情 （Sleep detail）
@property (nonatomic, strong) NSArray<WMSleepItemDataModel *> *items;

@end

NS_ASSUME_NONNULL_END
