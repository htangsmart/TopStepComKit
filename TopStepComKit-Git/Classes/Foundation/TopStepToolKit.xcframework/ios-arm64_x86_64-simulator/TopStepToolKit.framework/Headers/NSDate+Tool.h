//
//  NSDate+Tool.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Tool)

+ (NSTimeInterval)getDayStartTimestampFromTimestamp:(NSTimeInterval)timestamp ;

+ (NSTimeInterval)getTodayStartTimestamp ;

@end

NS_ASSUME_NONNULL_END
