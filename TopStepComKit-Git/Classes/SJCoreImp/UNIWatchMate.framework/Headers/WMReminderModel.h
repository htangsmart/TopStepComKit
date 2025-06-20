//
//  WMReminderModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 时间范围 （Time frame）
@interface WMTimeRange : NSObject

/// 开始（精确到小时分钟，年月日秒忽略） （Start (accurate to hour minute, year month day second ignored)）
@property (nonatomic, strong) NSDate * start;
/// 结束（精确到小时分钟，年月日秒忽略） （End (accurate to hour minute, year month day second ignored)）
@property (nonatomic, strong) NSDate * end;

@end

/// 时间频次 （Time frequency）
typedef NS_ENUM(NSInteger, WMTimeFrequency) {
    /// 每30分钟一次 （Every 30 minutes）
    WMTimeFrequencyEvery30Minutes,
    /// 每1小时一次 （Every hour）
    WMTimeFrequencyEvery1Hour,
    /// 每1小时30分钟一次 （Every hour and 30 minutes）
    WMTimeFrequencyEvery1Hour30Minutes
};

/// 免打扰 （No disturbing）
@interface WMNoDisturb : NSObject

/// 是否启用 （Enable or not）
@property (nonatomic, assign) BOOL isEnabled;

/// 时间范围 （Time frame）
@property (nonatomic, strong) WMTimeRange *timeRange;

@end

/// Sedentary reminder(久坐/喝水提醒)
@interface WMReminderModel : NSObject

/// Whether to enable(是否启用)
@property (nonatomic, assign) BOOL isEnabled;

/// Time range(时间范围)
@property (nonatomic, strong) WMTimeRange *timeRange;

/// Frequency(频率)
@property (nonatomic, assign) WMTimeFrequency frequency;

/// No-disturb lunch break(午休免打扰)
@property (nonatomic, strong) WMNoDisturb *noDisturbLunchBreak;

@end

NS_ASSUME_NONNULL_END
