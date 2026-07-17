//
//  TSWeatherHour+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherHour (Npk)

/**
 * @brief Convert to TSMetaWeatherHourModel
 * @chinese 转换为 TSMetaWeatherHourModel
 */
- (nullable TSMetaWeatherHourModel *)toMetaWeatherHourModel;

@end

NS_ASSUME_NONNULL_END
