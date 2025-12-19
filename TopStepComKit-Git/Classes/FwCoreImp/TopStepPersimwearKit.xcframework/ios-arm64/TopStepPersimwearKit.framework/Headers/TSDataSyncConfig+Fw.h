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
- (NSTimeInterval)startSyncTimeWithOption:(TSDataSyncOption)dataOption;

/**
 * @brief Get end sync time
 * @chinese 获取结束同步时间
 */
- (NSTimeInterval)endSyncTime;

@end

NS_ASSUME_NONNULL_END

