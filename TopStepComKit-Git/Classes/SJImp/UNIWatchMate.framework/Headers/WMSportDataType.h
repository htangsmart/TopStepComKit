//
//  WMSportDataType.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#ifndef WMSportDataType_h
#define WMSportDataType_h

// 运动数据类型 （Motion data type）
typedef NS_ENUM(NSInteger, WMSportDataType) {
    WMSportDataTypeStartTimestamp,         // 运动开始时间（时间戳）（Movement start time (timestamp)）
    WMSportDataTypeEndTimestamp,           // 运动结束时间（时间戳）（Movement end time (timestamp)）
    WMSportDataTypeTotalDuration,          // 运动总时长（秒）（Total duration of exercise (seconds)）
    WMSportDataTypeTotalMileage,           // 总里程（米）（Total mileage (m)）
    WMSportDataTypeCalories,               // 活动卡路里（卡）（Activity calories）
    WMSportDataTypeFastestPace,            // 最快配速（秒/公里）（Fastest pace (seconds/km)）
    WMSportDataTypeSlowestPace,            // 最慢配速（秒/公里）（Slowest pace (seconds/km)）
    WMSportDataTypeFastestSpeed,           // 最快速度（秒/公里）（Maximum speed (seconds/km)）
    WMSportDataTypeTotalSteps,             // 总步数（步）（Total steps (steps)）
    WMSportDataTypeMaxStepFrequency,       // 最大步频（步/秒）（Maximum step frequency (steps per second)）
    WMSportDataTypeAverageHeartRate,       // 平均心率（次/分）（Average heart rate (times/min)）
    WMSportDataTypeMaxHeartRate,           // 最大心率（次/分）（Max heart rate (times/min)）
    WMSportDataTypeMinHeartRate,           // 最小心率（次/分）（Min heart rate (times/min)）
    WMSportDataTypeLimitHeartRateDuration, // 心率-极限时长（秒）（Heart rate - Maximum duration (seconds)）
    WMSportDataTypeAnaerobicEnduranceDuration, // 心率-无氧耐力时长（秒）（Heart rate - Duration of anaerobic endurance (seconds)）
    WMSportDataTypeAerobicEnduranceDuration,   // 心率-有氧耐力时长（秒）（Heart rate - Aerobic endurance duration (seconds)）
    WMSportDataTypeFatBurningDuration,         // 心率-燃脂时长（秒）（Heart rate - Fat burning time (seconds)）
    WMSportDataTypeWarmUpDuration              // 心率-热身时长（秒）（Heart rate - Warm-up time (seconds)）
};

#endif /* WMSportDataType_h */
