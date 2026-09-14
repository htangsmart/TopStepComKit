//
//  WMSportGoalModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 运动目标设置 （Moving goal setting）
@interface WMSportGoalModel : NSObject

/// 步数，步 （Step number, Unit step）
@property (nonatomic, assign) NSInteger steps;

/// 卡路里，千卡（calorie, Unit kilocalorie）
@property (nonatomic, assign) double calories;

/// 距离，米（distance, Unit meter）
@property (nonatomic, assign) double distance;

/// 活动时长，分钟（Activity duration, Unit minute）
@property (nonatomic, assign) long activityDuration;

@end

NS_ASSUME_NONNULL_END
