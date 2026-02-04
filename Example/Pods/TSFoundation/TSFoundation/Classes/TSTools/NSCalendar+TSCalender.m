//
//  NSCalendar+TSCalender.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/26.
//

#import "NSCalendar+TSCalender.h"

@implementation NSCalendar (TSCalender)

/// 获取几号
- (NSInteger)ts_dayFromDate:(NSDate *)date {
    NSDateComponents *comp = [self components:(NSCalendarUnitDay) fromDate:date];
    return [comp day];
}

/// 获取周几 1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
- (NSInteger)ts_weekFromDate:(NSDate *)date {
    NSDateComponents *comp = [self components:(NSCalendarUnitWeekday) fromDate:date];
    return [comp weekday];
}

/// 获取本月有多少天
- (NSInteger)ts_numberOfDaysInMonthFromDate:(NSDate *)date {
    NSRange range = [self rangeOfUnit:(NSCalendarUnitDay) inUnit:(NSCalendarUnitMonth) forDate:date];
    return range.length;
}

/// 获取本月的第一天是周几 1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
- (NSInteger)ts_firstWeekDayInMonthFromDate:(NSDate *)date {
    NSDateComponents *comps = [self components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [comps setDay:1];
    NSDate *newDate = [self dateFromComponents:comps];
    NSUInteger firstDay = [self ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:newDate];
    return firstDay;
}



@end
