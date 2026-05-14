//
//  TSDataSyncConfig+Fw.h
//  TopStepPersimwearKit
//
//  Created on 2025/12/19.
//

#import <TopStepInterfaceKit/TSDataSyncConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDataSyncConfig (Fw)

/**
 * @brief Get start sync time for specific data option
 * @chinese 获取指定数据选项的开始同步时间
 */
- (NSTimeInterval)fwStartSyncTimeWithOption:(TSDataSyncOption)dataOption;

/**
 * @brief Get end sync time
 * @chinese 获取结束同步时间
 */
- (NSTimeInterval)fwEndSyncTime;

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

