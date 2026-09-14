//
//  WMLocationModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/7/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMLocation2DModel : NSObject

/// 经度（longitude）
@property (nonatomic, assign) double longitude;
/// 纬度（latitude）
@property (nonatomic, assign) double latitude;
/// 时区（timeZone）
@property (nonatomic, assign) NSInteger timeZone;

@end

NS_ASSUME_NONNULL_END
