//
//  WMHeartRateStatisticsDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时的最高、最低和平均心率 （Maximum, minimum and average heart rate per hour）
@interface WMHeartRateStatisticsDataModel : WMBaseDataModel

/// 最高心率 （Maximum heart rate）
@property (nonatomic, assign) NSInteger highestHeartRate;
/// 最低心率 （Minimum heart rate）
@property (nonatomic, assign) NSInteger lowestHeartRate;
/// 平均心率 （Mean heart rate）
@property (nonatomic, assign) double averageHeartRate;

@end

NS_ASSUME_NONNULL_END
