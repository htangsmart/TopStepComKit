//
//  WMDeviceFindModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMDeviceFindModel : NSObject

/// 响铃次数 依赖于设备  （Number of ringing Equipment dependent）
@property (nonatomic, assign) NSInteger count;

/// 响铃时长（单位秒）（Ring duration (in seconds)）
@property (nonatomic, assign) NSInteger timeSeconds;

@end

NS_ASSUME_NONNULL_END
