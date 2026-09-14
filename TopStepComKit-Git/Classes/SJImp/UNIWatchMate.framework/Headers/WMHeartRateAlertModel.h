//
//  WMHeartRateAlertModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateAlertModel : NSObject

/// 是否启动预警功能的开关。（Whether to enable the early warning function.）
@property (nonatomic, assign) BOOL isAlertEnabled;
/// 预警的心率阈值。（Heart rate threshold for warning.）
@property (nonatomic, assign) NSInteger alertThreshold;

@end

NS_ASSUME_NONNULL_END
