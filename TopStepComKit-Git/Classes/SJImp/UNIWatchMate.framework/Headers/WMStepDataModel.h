//
//  WMStepDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时步数数据 （Number of steps per hour）
@interface WMStepDataModel : WMBaseDataModel

/// 步数 （Step number）
@property (nonatomic, assign) NSInteger steps;

@end

NS_ASSUME_NONNULL_END
