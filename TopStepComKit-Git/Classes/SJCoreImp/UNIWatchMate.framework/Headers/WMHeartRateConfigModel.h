//
//  WMHeartRateConfigModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/10/30.
//

#import <Foundation/Foundation.h>
#import "WMHeartRateAlertModel.h"
#import "WMHeartRateRangeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateConfigModel : NSObject

/// 是否自动测量心率 （Whether the heart rate is automatically measured）
@property (nonatomic, assign) BOOL isAutoMeasure;
/// 最大心率（通过年龄和最大心率计算心率区间） （Max heart rate (Calculate heart rate interval by age and Max heart rate)）
@property (nonatomic, assign) NSInteger maxHeartRate;
/// 运动心率提醒 （Exercise heart rate reminder）
@property (nonatomic, strong) WMHeartRateAlertModel *exerciseAlert;
/// 静息心率提醒 （Resting heart rate alerts）
@property (nonatomic, strong) WMHeartRateAlertModel *restingAlert;

/// 获取心率区间 （Get heart rate interval）
- (WMHeartRateRangeModel *)heartRateRangeModel;

@end

NS_ASSUME_NONNULL_END
