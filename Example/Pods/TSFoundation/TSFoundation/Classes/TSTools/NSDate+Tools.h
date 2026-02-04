//
//  NSDate+Tools.h
//  Test
//
//  Created by EzioChan on 2021/4/26.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StartAndEndDate:NSObject

@property(nonatomic,strong)NSDate *start;

@property(nonatomic,strong)NSDate *end;

@end

@interface NSDate (Tools)

- (NSString *)toYYYYMMdd;

- (NSString *)toYYYYMMdd2;

- (NSString *)toYYYYMM;

- (NSString *)toYYYYMM2;

- (NSString *)toYYYYMMddHHMM ;

-(NSString *)toMM;

- (NSString *)toMMdd;

- (NSString *)toMMdd2;

- (NSString *)toMMdd3;

- (NSString *)toHHmmss;

- (NSString *)toHHmm;

- (NSString *)tommss;

- (NSString *)toAllDate;

- (NSData *)toBit32Data;

/**
 *  获取当天零时
 */
- (NSDate *)toStartOfDate;

/**
 *  获取当天23时59分59秒
 */
- (NSDate *)toEndOfDate;

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString;

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @prama dateFormat @"yyyy-MM-dd HH:mm:ss"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString withDateFormat:(NSString *)dateFormat;

/// 下一天
-(NSDate *)next;

/// 上一天
-(NSDate *)before;

/// 下一周
-(NSDate *)ts_nextWeek;

/// 上一周
-(NSDate *)beforeWeek;

/// 下个月
-(NSDate *)nextMonth;

/// 上个月
-(NSDate *)beforeMonth;

///下一年
-(NSDate *)nextYear;

///上一年
-(NSDate *)beforeYear;

/// 当前是否在某个区间之间
- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/// 当前这一天的一周始末
-(StartAndEndDate *)ts_thisWeek;

/// 当前这个月的始末
-(StartAndEndDate *)thisMonth;

/// 当前这个年的始末
-(StartAndEndDate *)thisYear;

/// 判断是周几：1~7
-(NSInteger)witchWeekDay;

/// 当前时间对应几号
-(NSInteger)witchDay;

/// 当前时间是几月
-(NSInteger)witchMonth;

/// 当前时间对应的月有多少天
-(NSInteger)monthDayCount;

/// 当前时间对应的年有多少天
-(NSInteger)yearDayCount;

/// 获取当前时间的周格式
-(NSString *)standardDate;

-(NSString*)thisWeekName;

/// 获取当前时间整月的列表
-(NSArray *)thisMonthDays;

-(NSArray *)thisYearMonths;

-(NSDate*)afterMonth:(int)after;

-(int)hour;
-(int)minute;
-(int)year;
-(int)month;
-(int)day;

+ (NSString *)dateStringFormateUTCDate:(NSString *)utcDate;

+ (NSInteger)daysCountAtYear:(NSInteger)year month:(NSInteger)month ;

+ (NSString *)transEn_TimeToZH_Time:(NSString *)en_time;

@end

NS_ASSUME_NONNULL_END
