//
//  WMDatasSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMStepDataSyncModel.h"
#import "WMCalorieDataSyncModel.h"
#import "WMActivityTimeDataSyncModel.h"
#import "WMDistanceDataSyncModel.h"
#import "WMHeartRateDataSyncModel.h"
#import "WMHeartRateStatisticsDataSyncModel.h"
#import "WMBloodOxygenDataSyncModel.h"
#import "WMActivityDataSyncModel.h"
#import "WMSleepDataSyncModel.h"
#import "WMActivityTypeTimeDataSyncModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 数据同步 （Data synchronization）
@interface WMDatasSyncModel : NSObject

/// 同步步数数据 （Synchronize step data）
@property (nonatomic, strong) WMStepDataSyncModel *syncStep;
/// 活动热量数据 （Active heat data）
@property (nonatomic, strong) WMCalorieDataSyncModel *syncCalorie;
/// 同步活动时长数据 （Synchronize activity duration data）
@property (nonatomic, strong) WMActivityTimeDataSyncModel *syncActivityTime;
/// 同步每类活动时长数据 （Synchronize duration data for each activity）
@property (nonatomic, strong) WMActivityTypeTimeDataSyncModel *syncActivityTypeTime;
/// 同步活动距离数据 （Synchronize active distance data）
@property (nonatomic, strong) WMDistanceDataSyncModel *syncDistance;
/// 同步实时心率数据 （Synchronize real-time heart rate data）
@property (nonatomic, strong) WMHeartRateDataSyncModel *syncHeartRate;
/// 同步心率统计数据 （Synchronize heart rate statistics）
@property (nonatomic, strong) WMHeartRateStatisticsDataSyncModel *syncHeartRateStatistics;
/// 同步血氧数据 （Synchronize blood oxygen data）
@property (nonatomic, strong) WMBloodOxygenDataSyncModel *syncBloodOxygen;
@property (nonatomic, strong) WMSleepDataSyncModel *syncSleep;
/// 同步运动小结数据 （Synchronous motion summary data）
@property (nonatomic, strong) WMActivityDataSyncModel *syncActivity;

@end

NS_ASSUME_NONNULL_END
