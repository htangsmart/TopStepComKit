//
//  WMActivityTimeDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMActivityTimeDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMActivityTimeDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMActivityTimeDataModel *> *>

@end

NS_ASSUME_NONNULL_END
