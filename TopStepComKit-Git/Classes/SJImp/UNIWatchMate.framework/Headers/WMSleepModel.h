//
//  WMSleepModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMReminderModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 睡眠设置 （Sleep setting）
@interface WMSleepModel : NSObject

/// 是否启用 （Enable or not）
@property (nonatomic, assign) BOOL isEnabled;

/// 时间范围 （Time frame）
@property (nonatomic, strong) WMTimeRange *timeRange;

@end

NS_ASSUME_NONNULL_END
