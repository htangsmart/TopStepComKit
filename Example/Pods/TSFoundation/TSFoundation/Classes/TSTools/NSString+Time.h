//
//  NSString+Time.h
//  JieliJianKang
//
//  Created by Topstep on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Time)

+ (NSString *)timeFormatted:(NSInteger)totalSeconds;
+ (NSString *)mmssTimeFormatted:(NSInteger)totalSeconds;
+ (NSString *)paceFormatted:(NSInteger)pace;
+ (NSDate *)dateTimeFormatted:(NSInteger)totalSeconds;

/*
 时间戳
 */
+ (NSString *)timeStamp;

@end

NS_ASSUME_NONNULL_END
