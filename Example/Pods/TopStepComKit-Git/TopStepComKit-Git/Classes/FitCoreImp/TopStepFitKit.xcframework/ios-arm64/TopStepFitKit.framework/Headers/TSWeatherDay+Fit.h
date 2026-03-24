//
//  TSWeatherDay+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWeatherForecast;
NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherDay (Fit)

/**
 * 将单个TopStep每日天气模型转换为FitCloud天气预报对象
 * Convert single TopStep daily weather model to FitCloud weather forecast object
 *
 * @param weatherDayModel TopStep每日天气模型
 *
 * @discussion 此方法将单个TSWeatherDay转换为FitCloud设备可识别的天气预报对象。
 * 转换内容包括：
 * - 白天天气类型
 * - 夜间天气类型
 * - 最高温度
 * - 最低温度
 * - 当前温度
 * - 气压
 * - 风力等级
 * - 风向角度
 * - 风速
 * - 湿度
 * - 紫外线指数
 * - 能见度
 *
 * @return FitCloud天气预报对象
 */
+ (FitCloudWeatherForecast *)fitCloudWeatherDayObjectFromWeatherModel:(TSWeatherDay *)weatherDayModel;

/**
 * 将TopStep每日天气模型数组转换为FitCloud天气预报对象数组
 * Convert TopStep daily weather model array to FitCloud weather forecast object array
 *
 * @param weatherDayModels TopStep每日天气模型数组
 *
 * @discussion 此方法将TSWeatherDay数组转换为FitCloud设备可识别的天气预报对象数组。
 * 主要用于转换未来7天的天气预报数据。
 * 转换内容与单个对象转换相同，包括：
 * - 天气类型（日间/夜间）
 * - 温度范围
 * - 风力相关数据
 * - 其他气象指标
 *
 * @return FitCloud天气预报对象数组
 */
+ (NSArray<FitCloudWeatherForecast *> *)fitCloudWeatherDayArrayFromWeatherModels:(NSArray<TSWeatherDay *> *)weatherDayModels;

@end

NS_ASSUME_NONNULL_END
