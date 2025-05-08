//
//  TSWeatherCode+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherCode (Fit)

/**
 * 将TopStep天气类型转换为FitCloud天气类型
 * Convert TopStep weather type to FitCloud weather type
 *
 * @discussion 此方法将TSWeatherType类型的天气码转换为FitCloud设备可识别的天气类型。
 * 转换规则如下：
 * - 晴天类型 -> FITCLOUDWEATHERTYPE_SUNNY
 * - 多云类型 -> FITCLOUDWEATHERTYPE_CLOUDY
 * - 阵雨类型 -> FITCLOUDWEATHERTYPE_SHOWERS
 * - 雷雨类型 -> FITCLOUDWEATHERTYPE_THUNDERSHOWERSWITHHAIL
 * - 小雨类型 -> FITCLOUDWEATHERTYPE_LIGHTRAIN
 * - 中到大雨类型 -> FITCLOUDWEATHERTYPE_MHSRAIN
 * - 雨夹雪类型 -> FITCLOUDWEATHERTYPE_SLEET
 * - 小雪类型 -> FITCLOUDWEATHERTYPE_LIGHTSNOW
 * - 大雪类型 -> FITCLOUDWEATHERTYPE_HEAVYSNOW
 * - 沙尘暴类型 -> FITCLOUDWEATHERTYPE_SANDSTORM
 * - 雾霾类型 -> FITCLOUDWEATHERTYPE_FOGORHAZE
 * - 大风类型 -> FITCLOUDWEATHERTYPE_WINDY
 * - 未知类型 -> FITCLOUDWEATHERTYPE_UNKNOWN
 *
 * @return FitCloud天气类型的Byte值
 */
- (Byte)fitcloudWeatherType;

@end

NS_ASSUME_NONNULL_END
