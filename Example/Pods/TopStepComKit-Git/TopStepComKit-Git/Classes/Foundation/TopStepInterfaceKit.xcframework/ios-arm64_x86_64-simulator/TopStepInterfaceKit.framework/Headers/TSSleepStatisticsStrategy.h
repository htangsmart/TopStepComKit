//
//  TSSleepStatisticsStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import <Foundation/Foundation.h>
#import "TSSleepDailyModel.h"
#import "TSSleepDetailItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep statistics processing strategy protocol
 * @chinese 睡眠统计处理策略协议
 *
 * @discussion
 * [EN]: Protocol for different sleep statistics processing strategies.
 * Each strategy implements a specific statistics rule (Basic/WithNap/LongestNight/LongestOnly).
 *
 * [CN]: 不同睡眠统计处理策略的协议。
 * 每个策略实现一种特定的统计规则（Basic/WithNap/LongestNight/LongestOnly）。
 */
@protocol TSSleepStatisticsStrategy <NSObject>

- (nullable TSSleepDailyModel *)processWithSleepDetailItems:(NSArray<TSSleepDetailItem *> *)sleepDetailItems ;

@end

NS_ASSUME_NONNULL_END

