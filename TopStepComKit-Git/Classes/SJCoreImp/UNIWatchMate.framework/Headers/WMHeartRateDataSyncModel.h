//
//  WMHeartRateDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMHeartRateDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMHeartRateDataModel *> *>

@end

NS_ASSUME_NONNULL_END
