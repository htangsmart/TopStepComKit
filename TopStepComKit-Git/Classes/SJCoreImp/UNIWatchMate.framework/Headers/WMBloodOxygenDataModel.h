//
//  WMBloodOxygenDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每5分钟产生的血氧饱和度，5分钟内仅记录最后一次（0-100%） （Blood oxygen saturation generated every 5 minutes, only the last time recorded in 5 minutes (0-100%)）
@interface WMBloodOxygenDataModel : WMBaseDataModel

/// 实时血氧饱和度（5分钟内仅记录最后一次（次/分））； （Real-time blood oxygen saturation (only the last time (times/min) is recorded within 5 minutes);）
@property (nonatomic, assign) NSInteger value;

@end

NS_ASSUME_NONNULL_END
