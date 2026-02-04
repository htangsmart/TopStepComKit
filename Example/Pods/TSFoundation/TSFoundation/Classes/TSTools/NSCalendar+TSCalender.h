//
//  NSCalendar+TSCalender.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCalendar (TSCalender)
/// 获取几号
- (NSInteger)ts_dayFromDate:(NSDate *)date;

/// 获取周几 1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
- (NSInteger)ts_weekFromDate:(NSDate *)date;

/// 获取本月有多少天
- (NSInteger)ts_numberOfDaysInMonthFromDate:(NSDate *)date;

/// 获取本月的第一天是周几 1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
- (NSInteger)ts_firstWeekDayInMonthFromDate:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
