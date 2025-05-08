//
//  TSWeatherHourModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudHourWeatherObject;

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherHourModel (Fit)

/**
 * 将TopStep小时天气数组转换为FitCloud小时天气数组
 * Convert TopStep hourly weather array to FitCloud hourly weather array
 *
 * @param hourWeatherArray TopStep小时天气模型数组
 *
 * @discussion 此方法将TSWeatherHourModel数组转换为FitCloud设备可识别的小时天气对象数组。
 * 转换内容包括：
 * - 天气类型
 * - 温度
 * - 风力等级
 * - 紫外线指数
 * - 能见度
 *
 * @return FitCloud小时天气对象数组
 */
+ (NSArray<FitCloudHourWeatherObject *> *)fitCloudHourArrayWithArray:(NSArray <TSWeatherHourModel *> *)hourWeatherArray;

/**
 * 将单个TopStep小时天气模型转换为FitCloud小时天气对象
 * Convert single TopStep hourly weather model to FitCloud hourly weather object
 *
 * @param hourWeatherModel TopStep小时天气模型
 *
 * @discussion 此方法将单个TSWeatherHourModel转换为FitCloud设备可识别的小时天气对象。
 * 转换内容包括：
 * - 天气类型（通过TSWeatherCode+Fit分类转换）
 * - 温度值
 * - 风力等级
 * - 紫外线指数
 * - 能见度数据
 *
 * @return FitCloud小时天气对象
 */
+ (FitCloudHourWeatherObject *)fitCloudHourWeatherObjectFromHourWeatherModel:(TSWeatherHourModel *)hourWeatherModel;

@end

NS_ASSUME_NONNULL_END
