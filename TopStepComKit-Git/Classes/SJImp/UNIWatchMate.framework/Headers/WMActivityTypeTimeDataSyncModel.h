//
//  WMActivityTypeTimeDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/30.
//

#import "WMBaseDataSyncModel.h"
#import "WMActivityTypeTimeDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMActivityTypeTimeDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMActivityTypeTimeDataModel *> *>

@end

NS_ASSUME_NONNULL_END
