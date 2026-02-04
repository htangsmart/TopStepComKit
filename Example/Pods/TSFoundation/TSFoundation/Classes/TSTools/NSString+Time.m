//
//  NSString+Time.m
//  JieliJianKang
//
//  Created by Topstep on 2021/4/12.
//

#import "NSString+Time.h"

@implementation NSString (Time)

+ (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

+ (NSString *)mmssTimeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = totalSeconds / 60;
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

+ (NSString *)paceFormatted:(NSInteger)pace {
    NSInteger seconds = pace % 60;
    NSInteger minutes = pace / 60;
//    NSInteger minutes = (pace / 60) % 60;
//    minutes = pace / 3600 * 60 + minutes;
    return [NSString stringWithFormat:@"%ld′%02ld″", (long)minutes, (long)seconds];
}

+ (NSDate *)dateTimeFormatted:(NSInteger)totalSeconds {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
//    NSLog(@"enddate=%@", localeDate);
    return localeDate;
}


+ (NSString *)timeStamp{
    return [NSString stringWithFormat:@"%zd",(NSInteger)[[NSDate date] timeIntervalSince1970]];
}

@end
