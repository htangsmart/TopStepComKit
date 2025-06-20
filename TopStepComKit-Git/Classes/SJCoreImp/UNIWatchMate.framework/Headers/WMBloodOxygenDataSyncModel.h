//
//  WMBloodOxygenDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMBloodOxygenDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMBloodOxygenDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMBloodOxygenDataModel *> *>

@end

NS_ASSUME_NONNULL_END
