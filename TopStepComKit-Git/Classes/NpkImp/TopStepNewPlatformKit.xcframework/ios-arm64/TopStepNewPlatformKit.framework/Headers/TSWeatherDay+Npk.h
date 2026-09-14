//
//  TSWeatherDay+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherDay (Npk)

/**
 * @brief Convert to TSMetaWeatherDayModel
 * @chinese 转换为 TSMetaWeatherDayModel
 */
- (nullable TSMetaWeatherDayModel *)toMetaWeatherDayModel;

@end

NS_ASSUME_NONNULL_END
