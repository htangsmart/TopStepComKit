//
//  WMDistanceDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMDistanceDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMDistanceDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMDistanceDataModel *> *>

@end

NS_ASSUME_NONNULL_END
