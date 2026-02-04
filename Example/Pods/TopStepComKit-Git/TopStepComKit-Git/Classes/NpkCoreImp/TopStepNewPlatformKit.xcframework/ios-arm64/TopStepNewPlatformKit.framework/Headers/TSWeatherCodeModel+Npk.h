//
//  TSWeatherCodeModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherCodeModel (Npk)

/**
 * @brief Convert TSWeatherCodeModel to TSWeatherCategory
 * @chinese 将TSWeatherCodeModel转换为TSWeatherCategory
 *
 * @param code
 * EN: TSWeatherCodeModel enumeration value
 * CN: TSWeatherCodeModel枚举值
 *
 * @return
 * EN: TSWeatherCategory enumeration value
 * CN: TSWeatherCategory枚举值
 */
+ (TSWeatherCategory)categoryWithCode:(TSWeatherCode)code;

@end

NS_ASSUME_NONNULL_END
