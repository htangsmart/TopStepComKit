//
//  WMActivityTypeTimeDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/30.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每类运动的运动时长 （The duration of each type of exercise）
@interface WMActivityTypeTimeDataModel : WMBaseDataModel

/// 活动时长（秒）（Activity duration (seconds)）
@property (nonatomic, assign) NSInteger activityTime;

/// 活动类型 （Activity type）
@property (nonatomic, assign) NSInteger activityType;

@end

NS_ASSUME_NONNULL_END
