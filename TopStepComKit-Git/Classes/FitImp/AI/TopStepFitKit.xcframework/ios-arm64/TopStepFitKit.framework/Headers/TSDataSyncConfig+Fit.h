//
//  TSDataSyncConfig+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/12/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDataSyncConfig (Fit)

- (NSTimeInterval)fitStartSyncTimeWithOption:(TSDataSyncOption)dataOption;

- (NSTimeInterval)fitEndSyncTime;

/**
 * @brief Whether the sync end time falls within current day
 * @chinese 同步结束时间是否在当天范围内
 *
 * @return YES if the end time is within [today 00:00:00, today 23:59:59], otherwise NO
 * @return 结束时间在当天【00:00:00, 23:59:59】区间内返回 YES，否则返回 NO
 */
- (BOOL)isEndTimeInToday;

@end

NS_ASSUME_NONNULL_END
