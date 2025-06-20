//
//  WMStepDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataSyncModel.h"
#import "WMStepDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WMStepDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMStepDataModel *> *>

@end

NS_ASSUME_NONNULL_END
