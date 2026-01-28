//
//  TopStepWeather+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWeatherObject;

NS_ASSUME_NONNULL_BEGIN

@interface TopStepWeather (Fit)

/**
 * 将TopStep天气模型转换为FitCloud天气对象
 * Convert TopStep weather model to FitCloud weather object
 *
 * @param weatherModel TopStep天气模型
 *
 * @discussion 此方法将TopStepWeather转换为FitCloud设备可识别的天气对象。
 * 转换内容包括：
 * - 城市信息（经纬度、城市名等）
 * - 当天天气（温度、天气类型、风力等）
 * - 未来7天天气预报
 * - 24小时天气预报
 * - 时间戳信息
 *
 * @return FitCloud天气对象
 */
+ (FitCloudWeatherObject *)fitCloudWeatherObjectFromWeatherModel:(TopStepWeather *)weatherModel;

/**
 * 检查是否可以同步小时天气数据
 * Check if hourly weather data can be synchronized
 *
 * @discussion 此方法检查当前天气模型是否包含有效的小时天气数据，用于决定是否可以同步小时天气到设备。
 * 检查内容包括：
 * - 24小时天气预报数组是否存在
 * - 数组中是否包含有效数据
 * - 数据格式是否符合要求
 *
 * @return 是否可以同步小时天气数据
 */
- (BOOL)canSyncHourWeather;

@end

NS_ASSUME_NONNULL_END
