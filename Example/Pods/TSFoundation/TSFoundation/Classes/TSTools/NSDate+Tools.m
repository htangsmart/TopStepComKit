//
//  NSDate+Tools.m
//  Test
//
//  Created by EzioChan on 2021/4/26.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "NSDate+Tools.h"

#import "JLPhoneUISetting.h"

@implementation StartAndEndDate

@end

@implementation NSDate (Tools)

- (NSString *)toYYYYMMdd {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"yyyy-MM-dd"];
    return [fm stringFromDate:self];
}

- (NSString *)toYYYYMMdd2 {
    NSDateFormatter *fm = [NSDateFormatter new];
    if ([kJL_GET hasPrefix:@"zh-Hans"]) {
        [fm setDateFormat:@"yyyy年MM月dd日"];
    }else{
        [fm setDateFormat:@"yyyy/MM/dd"];
    }
    return [fm stringFromDate:self];
}

- (NSString *)toYYYYMMddHHMM {
    NSDateFormatter *fm = [NSDateFormatter new];
    if ([kJL_GET hasPrefix:@"zh-Hans"]) {
        [fm setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    }else{
        [fm setDateFormat:@"yyyy/MM/dd HH:mm"];
    }
    return [fm stringFromDate:self];
}


- (NSString *)toYYYYMM{
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"yyyy-MM"];
    return [fm stringFromDate:self];
}

- (NSString *)toYYYYMM2{
    NSDateFormatter *fm = [NSDateFormatter new];
    if ([kJL_GET hasPrefix:@"zh-Hans"]) {
        [fm setDateFormat:@"yyyy年MM月"];
    }else{
        [fm setDateFormat:@"yyyy-MM"];
    }
    return [fm stringFromDate:self];
}

- (NSString *)toMMdd {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"MM-dd"];
    return [fm stringFromDate:self];
}

- (NSString *)toMMdd2 {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"MM/dd"];
    return [fm stringFromDate:self];
}

- (NSString *)toMMdd3 {
    NSDateFormatter *fm = [NSDateFormatter new];
    if ([kJL_GET hasPrefix:@"zh-Hans"]) {
        [fm setDateFormat:@"MM月dd日"];
    }else{
        [fm setDateFormat:@"MM/dd"];
    }
    return [fm stringFromDate:self];
}

-(NSString *)toMM{
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"MM"];
    int index = [[fm stringFromDate:self] intValue];
    NSArray *k = @[@"一月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"十二月"];
    if (![kJL_GET hasPrefix:@"zh-Hans"]) {
        k = @[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"June",@"July",@"Aug",@"Sept",@"Oct",@"Nov",@"Dec"];
    }
    return k[index-1];
}

- (NSString *)toHHmmss {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"HH:mm:ss"];
    return [fm stringFromDate:self];
}

- (NSString *)toHHmm {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"HH:mm"];
    return [fm stringFromDate:self];
}

- (NSString *)tommss {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"mm′ss″"];
    return [fm stringFromDate:self];
}


- (NSString *)toAllDate {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [fm stringFromDate:self];
}

- (NSData *)toBit32Data {
    NSDateFormatter *fm = [NSDateFormatter new];
    [fm setDateFormat:@"yyyy:MM:dd:HH:mm:ss"];
    NSString *str = [fm stringFromDate:self];
    NSArray *sArr = [str componentsSeparatedByString:@":"];
    
    
    uint32_t year = [[NSNumber numberWithInt:[sArr[0] intValue]] unsignedIntValue]-2010;
    uint32_t month = [[NSNumber numberWithInt:[sArr[1] intValue]] unsignedIntValue];
    uint32_t day = [[NSNumber numberWithInt:[sArr[2] intValue]] unsignedIntValue];
    uint32_t hour = [[NSNumber numberWithInt:[sArr[3] intValue]] unsignedIntValue];
    uint32_t minute = [[NSNumber numberWithInt:[sArr[4] intValue]] unsignedIntValue];
    uint32_t second = [[NSNumber numberWithInt:[sArr[5] intValue]] unsignedIntValue];
    uint32_t k = 0x00|(year<<26)|(month<<22)|(day<<17)|(hour<<12)|(minute<<6)|second;
    UInt32 mk[] = {k};
    return  [NSData dataWithBytes:mk length:4];
    //    return nil;
}

- (NSDate *)toStartOfDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger interval = [zone secondsFromGMTForDate:date];
    //    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return date;
}

- (NSDate *)toEndOfDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger interval = [zone secondsFromGMTForDate:date];
    //    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return date;
}


/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSDate *date = [dateFormatter dateFromString:dateFormatterString];
    return date;
}

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @prama dateFormat @"yyyy-MM-dd HH:mm:ss"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString withDateFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [dateFormatter dateFromString:dateFormatterString];
    return date;
}


-(NSDate *)next{
    return [NSDate dateWithTimeInterval:24*60*60 sinceDate:self];
}

-(NSDate *)before{
    return [NSDate dateWithTimeInterval:-24*60*60 sinceDate:self];
}

-(NSDate *)ts_nextWeek{
    return [NSDate dateWithTimeInterval:24*60*60*7 sinceDate:self];
}
-(NSDate *)beforeWeek{
    return [NSDate dateWithTimeInterval:-24*60*60*7 sinceDate:self];
}

-(NSDate *)nextMonth{
    NSDateComponents * components2 = [[NSDateComponents alloc] init];
    components2.year = 0;
    components2.month = 1;
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    NSDate *currentDate = self;
    return [calendar3 dateByAddingComponents:components2 toDate:currentDate options:NSCalendarMatchStrictly];
}

-(NSDate*)afterMonth:(int)after{
    NSDateComponents * components2 = [[NSDateComponents alloc] init];
    components2.year = 0;
    components2.month = after;
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    NSDate *currentDate = self;
    return [calendar3 dateByAddingComponents:components2 toDate:currentDate options:NSCalendarMatchStrictly];
}

-(NSDate *)beforeMonth{
    NSDateComponents * components2 = [[NSDateComponents alloc] init];
    components2.year = 0;
    components2.month = -1;
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    NSDate *currentDate = self;
    return [calendar3 dateByAddingComponents:components2 toDate:currentDate options:NSCalendarMatchStrictly];
}

-(NSDate *)nextYear{
    NSDateComponents * components2 = [[NSDateComponents alloc] init];
    components2.year = 1;
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    NSDate *currentDate = self;
    NSDate *nextDate = [calendar3 dateByAddingComponents:components2 toDate:currentDate options:NSCalendarMatchStrictly];
    return nextDate;
}

-(NSDate *)beforeYear{
    NSDateComponents * components2 = [[NSDateComponents alloc] init];
    components2.year = -1;
    NSCalendar *calendar3 = [NSCalendar currentCalendar];
    NSDate *currentDate = self;
    NSDate *nextDate = [calendar3 dateByAddingComponents:components2 toDate:currentDate options:NSCalendarMatchStrictly];
    return nextDate;
}

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    NSTimeInterval currentTimeInterval = [self timeIntervalSince1970];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];
    if ((currentTimeInterval >= startTimeInterval) && (currentTimeInterval <= endTimeInterval)) {
        return YES;
    }
    return NO;
}

-(StartAndEndDate *)ts_thisWeek{
    NSDate *now = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                         fromDate:now];
    NSInteger weekDay = [comp weekday];
    weekDay-=1;
    if (weekDay==0) {
        weekDay = 7;
    }
    StartAndEndDate *sae = [StartAndEndDate new];
    sae.end = [NSDate dateWithTimeInterval:24*60*60*(7-weekDay) sinceDate:self].toEndOfDate;
    sae.start = [sae.end.beforeWeek.toStartOfDate dateByAddingTimeInterval:24*60*60];//这个时间之前算到一周有8天,修改by leiwei
    return sae;
}

-(StartAndEndDate *)thisMonth
{
    StartAndEndDate *sae = [StartAndEndDate new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:self];
    NSDateComponents *lastDateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+dayNumberOfMonth-1];
    NSDate *lastDay = [calendar dateFromComponents:lastDateComponents];
    sae.start = firstDay.toStartOfDate;
    sae.end = lastDay.toEndOfDate;
    return sae;
}

-(StartAndEndDate *)thisYear{
    StartAndEndDate *sae = [StartAndEndDate new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&firstDay interval:nil forDate:self];
    NSDateComponents *lastDateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfYear = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]].length;
    if ([lastDateComponents year]%4 == 0) {
        [lastDateComponents setDay:dayNumberOfYear+1];
    }else{
        [lastDateComponents setDay:dayNumberOfYear];
    }
    NSDate *lastDay = [calendar dateFromComponents:lastDateComponents];
    sae.start = firstDay.toStartOfDate;
    sae.end = lastDay.toEndOfDate;
    return sae;
}

//1，2，3...7，1代表周一
-(NSInteger)witchWeekDay{
    NSDate *now = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                         fromDate:now];
    NSInteger weekDay = [comp weekday];
    weekDay-=1;
    if (weekDay==0) {
        weekDay = 7;
    }
    return weekDay;
}

/// 今天几号(1代表1号)
-(NSInteger)witchDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                         fromDate:self];
    return [comp day];
}
/// 当前时间是几月
-(NSInteger)witchMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                         fromDate:self];
    return [comp month];
}

/// 当前时间对应的月有多少天
-(NSInteger)monthDayCount{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return range.length;
}

/// 当前时间对应的年有多少天
-(NSInteger)yearDayCount{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:self];
    return range.length;
}


/// 获取当前时间的周格式
-(NSString *)standardDate{
    NSDateFormatter *fm = [NSDateFormatter new];
    if (![kJL_GET hasPrefix:@"zh-Hans"]) {
        [fm setDateFormat:@"yyyy/MM/dd"];
    }else{
        [fm setDateFormat:@"yyyy年MM月dd日"];
    }
    
    NSString *week = @"";
    switch (self.witchWeekDay) {
        case 1:{
            week = kJL_TXT("我的周一");
        }break;
        case 2:{
            week = kJL_TXT("我的周二");
        }break;
        case 3:{
            week = kJL_TXT("我的周三");
        }break;
        case 4:{
            week = kJL_TXT("我的周四");
        }break;
        case 5:{
            week = kJL_TXT("我的周五");
        }break;
        case 6:{
            week = kJL_TXT("我的周六");
        }break;
        case 7:{
            week = kJL_TXT("我的周日");
        }break;
            
        default:
            break;
    }
    NSString *kstr = [NSString stringWithFormat:@"%@ %@",[fm stringFromDate:self],week];
    return kstr;
}

-(NSString*)thisWeekName{
    NSString *week = @"";
    switch (self.witchWeekDay) {
        case 1:{
            week = kJL_TXT("星期一");
        }break;
        case 2:{
            week = kJL_TXT("星期二");
        }break;
        case 3:{
            week = kJL_TXT("星期三");
        }break;
        case 4:{
            week = kJL_TXT("星期四");
        }break;
        case 5:{
            week = kJL_TXT("星期五");
        }break;
        case 6:{
            week = kJL_TXT("星期六");
        }break;
        case 7:{
            week = kJL_TXT("星期日");
        }break;
            
        default:
            break;
    }
    return week;
}


-(NSArray *)thisMonthDays{
    
    NSMutableArray *newArray = [NSMutableArray new];
    double interval = (double)self.monthDayCount/13;
    double k = 1;
    while ((int)k<=self.monthDayCount) {
        NSString *str;
        if ([kJL_GET hasPrefix:@"zh-Hans"]) {
            str = [NSString stringWithFormat:@"%d%@",(int)k,@"日"];
        }else{
            str = [NSString stringWithFormat:@"%d",(int)k];
        }
        k+=interval;
        [newArray addObject:str];
    }
    return newArray;
    
}

-(NSArray *)thisYearMonths{
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 1; i<=12; i++) {
        NSString *str = [NSString stringWithFormat:@"%d%@",i,@"月"];
        [array addObject:str];
    }
    if (![kJL_GET hasPrefix:@"zh-Hans"]) {
        NSArray *k = @[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"June",@"July",@"Aug",@"Sept",@"Oct",@"Nov",@"Dec"];
        return k;
    }
    return array;
}

-(int)hour{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:self];
    return (int)[components hour];
}

-(int)minute{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitMinute fromDate:self];
    return (int)[components minute];
}

-(int)year{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear fromDate:self];
    return (int)[components year];
}

//从1开始，如果是1月，则返回1
-(int)month{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitMonth fromDate:self];
    return (int)[components month];
}

//从1开始，如果是1号，则返回1
-(int)day{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:self];
    return (int)[components day];
}

+ (NSString *)dateStringFormateUTCDate:(NSString *)utcDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

+ (NSString *)transEn_TimeToZH_Time:(NSString *)en_time{
    if (en_time && en_time.length>0) {
        NSArray *array = [en_time componentsSeparatedByString:@"-"];
        if (array.count==3) {
            return [NSString stringWithFormat:@"%@年%@月%@日",array.firstObject,[array objectAtIndex:1],array.lastObject];
        }
    }
    return nil;
}

// 获取某年某月总共多少天
+ (NSInteger)daysCountAtYear:(NSInteger)year month:(NSInteger)month {
    // imonth == 0的情况是应对在CourseViewController里month-1的情况
    if((month == 0)||(month == 1)||(month == 3)||(month == 5)||(month == 7)||(month == 8)||(month == 10)||(month == 12))
        return 31;
    if((month == 4)||(month == 6)||(month == 9)||(month == 11))
        return 30;
    if((year%4 == 1)||(year%4 == 2)||(year%4 == 3))
    {
        return 28;
    }
    if(year%400 == 0)
        return 29;
    if(year%100 == 0)
        return 28;
    return 29;
}

@end
