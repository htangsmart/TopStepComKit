//
//  WMActivityDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>
#import "WMSportDataType.h"
#import "WMActivityType.h"
#import "WMHeartRateDataModel.h"
#import "WMStepDataModel.h"
#import "WMCalorieDataModel.h"
#import "WMDistanceDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每次运动过的运动小结数据；（Exercise summary data for each exercise;）
@interface WMActivityDataModel : NSObject

// 训练开始日期 （Training start date）
@property (assign, nonatomic) NSInteger timestamp;
// 训练开始时间戳(毫秒) （Training Start Time stamp (milliseconds)）
@property (assign, nonatomic) NSInteger ts_start;
// 训练结束时间戳(毫秒) （End of Training timestamp (milliseconds)）
@property (assign, nonatomic) NSInteger ts_end;
// 训练时长 （Training duration）
@property (assign, nonatomic) NSInteger duration;
// 运动类型 （Movement type）
@property (assign, nonatomic) NSInteger sport_id;
// 训练类型 （Training type）
@property (assign, nonatomic) NSInteger sport_type;
// 步数 （Step number）
@property (assign, nonatomic) NSInteger step;
// 卡路里 （calorie）
@property (assign, nonatomic) double calories;
// 距离 （distance）
@property (assign, nonatomic) NSInteger distance;
// 活动时长 （Activity duration）
@property (assign, nonatomic) NSInteger act_time;
// 最大心率 （Maximum heart rate）
@property (assign, nonatomic) NSInteger max_hr;
// 平均心率 （Mean heart rate）
@property (assign, nonatomic) NSInteger avg_hr;
// 最小心率 （Minimum heart rate）
@property (assign, nonatomic) NSInteger min_hr;
// 心率 -- 极限时长 （Heart rate - maximum duration）
@property (assign, nonatomic) NSInteger hr_limit_time;
// 心率 -- 无氧耐力时长 （Heart rate - duration of anaerobic endurance）
@property (assign, nonatomic) NSInteger hr_anaerobic;
// 心率 -- 有氧耐力时长 （Heart rate - duration of aerobic endurance）
@property (assign, nonatomic) NSInteger hr_aerobic;
// 心率 -- 燃脂时长 （Heart rate - how long you burn fat）
@property (assign, nonatomic) NSInteger hr_fat_burning;
// 心率 -- 热身时长 （Heart rate - warm-up time）
@property (assign, nonatomic) NSInteger hr_warm_up;
// 最大步频 （Maximum step frequency）
@property (assign, nonatomic) NSInteger max_step_speed;
// 最小步频 （Minimum step frequency）
@property (assign, nonatomic) NSInteger min_step_speed;
// 平均步频 （Average step frequency）
@property (assign, nonatomic) NSInteger avg_step_speed;
// 最快配速 （Maximum pace）
@property (assign, nonatomic) NSInteger fast_pace;
// 最慢配速 （The slowest pace）
@property (assign, nonatomic) NSInteger slowest_pace;
// 平均配速 （Average pace）
@property (assign, nonatomic) NSInteger avg_pace;
// 最快速度 （Maximum speed）
@property (assign, nonatomic) NSInteger fast_speed;
// 最慢速度 （Minimum speed）
@property (assign, nonatomic) NSInteger slowest_speed;
// 平均速度 （Average velocity）
@property (assign, nonatomic) NSInteger avg_speed;

/// 10秒心率 （10-second heart rate）
@property (strong, nonatomic) NSArray<WMHeartRateDataModel *> *rate_items;
/// 10秒步数 （10 second steps）
@property (strong, nonatomic) NSArray<WMStepDataModel *> *step_items;
/// 10秒热量 （10 second heat）
@property (strong, nonatomic) NSArray<WMCalorieDataModel *> *calories_items;
/// 10秒距离 （10 second distance）
@property (strong, nonatomic) NSArray<WMDistanceDataModel *> *distance_items;

@end

NS_ASSUME_NONNULL_END
