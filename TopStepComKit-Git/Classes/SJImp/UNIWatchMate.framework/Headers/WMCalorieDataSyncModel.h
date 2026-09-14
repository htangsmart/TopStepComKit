//
//  WMCalorieDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataSyncModel.h"
#import "WMCalorieDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMCalorieDataSyncModel : WMBaseDataSyncModel<WMBaseByDayDataModel<WMCalorieDataModel *> *>

@end

NS_ASSUME_NONNULL_END
