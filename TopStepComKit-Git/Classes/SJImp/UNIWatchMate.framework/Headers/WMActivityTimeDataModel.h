//
//  WMActivityTimeDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时持续活动的时长（秒）（Duration of continuous activity per hour (seconds)）
@interface WMActivityTimeDataModel : WMBaseDataModel

/// 活动时长（秒）（Activity duration (seconds)）
@property (nonatomic, assign) NSInteger activityTime;

@end

NS_ASSUME_NONNULL_END
