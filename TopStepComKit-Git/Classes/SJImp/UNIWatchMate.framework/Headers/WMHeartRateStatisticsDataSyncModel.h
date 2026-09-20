//
//  WMHeartRateStatisticsDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMHeartRateStatisticsDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateStatisticsDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMHeartRateStatisticsDataModel *> *>

@end

NS_ASSUME_NONNULL_END
