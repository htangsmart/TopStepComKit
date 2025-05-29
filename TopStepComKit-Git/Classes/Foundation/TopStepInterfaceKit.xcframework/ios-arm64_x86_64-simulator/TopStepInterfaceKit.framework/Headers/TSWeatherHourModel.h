//
//  TSWeatherHourModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSWeatherBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Hourly weather information model
 * @chinese 每小时天气信息模型
 *
 * @discussion
 * EN: This model represents weather information for a specific hour
 *     Contains detailed weather parameters for hourly forecast
 *     Inherits from TSWeatherBaseModel for basic weather information
 * CN: 该模型表示特定小时的天气信息
 *     包含每小时天气预报的详细参数
 *     继承自TSWeatherBaseModel以获取基本天气信息
 */
@interface TSWeatherHourModel : TSWeatherBaseModel

/**
 * @brief Temperature
 * @chinese 温度
 *
 * @discussion
 * EN: Current temperature in Celsius
 * CN: 当前温度，单位：摄氏度
 */
@property (nonatomic, assign) NSInteger temperature;

/**
 * @brief Wind scale
 * @chinese 风力等级
 *
 * @discussion
 * EN: Wind scale level (0-18). 0: Calm, 1: Light air, 2: Light breeze, 3: Gentle breeze, 4: Moderate breeze,
 *     5: Fresh breeze, 6: Strong breeze, 7: High wind, 8: Gale, 9: Strong gale, 10: Storm, 11: Violent storm,
 *     12: Typhoon, 13-17: Higher levels, 18: Above level 17
 * CN: 风力等级（0-18）。0级: 无风, 1级: 软风, 2级: 轻风, 3级: 微风, 4级: 和风, 5级: 清风, 6级: 强风,
 *     7级: 劲风, 8级: 大风, 9级: 烈风, 10级: 狂风, 11级: 暴风, 12级: 台风, 13-17级: 更高等级, 18级: 17级以上
 */
@property (nonatomic, assign) NSInteger windScale;

/**
 * @brief UV index
 * @chinese 紫外线指数
 *
 * @discussion
 * EN: UV radiation intensity index (0-11+)
 *     0-2: Low, 3-5: Moderate, 6-7: High ,8-10: Very High, 11+: Extreme
 * CN: 紫外线强度指数（0-11+）
 *     0-2：弱，3-5：中等，6-7：强 ,8-10：很强，11+：极强
 */
@property (nonatomic, assign) NSInteger uvIndex;

/**
 * @brief Visibility
 * @chinese 能见度
 *
 * @discussion
 * EN: Visibility in meters
 *     Maximum value: 30000 meters
 * CN: 能见度，单位：米
 *     最大值：30000米
 */
@property (nonatomic, assign) NSInteger visibility;

/**
 * @brief Humidity
 * @chinese 湿度
 *
 * @discussion
 * EN: Relative humidity percentage (0-100)
 * CN: 相对湿度百分比（0-100）
 */
@property (nonatomic, assign) NSInteger humidity;


/**
 * @brief Create a weather hour model with basic information
 * @chinese 使用基本信息创建天气小时模型
 *
 * @param weatherCode Weather code / 天气代码
 * @param temperature Temperature / 温度
 * @param windScale Wind scale / 风力等级
 * @return A new weather hour model instance / 新的天气小时模型实例
 */
+ (instancetype)modelWithWeatherCode:(TSWeatherCode *)weatherCode
                      temperature:(NSInteger)temperature
                        windScale:(NSInteger)windScale;

/**
 * @brief Create a weather hour model with complete information
 * @chinese 使用完整信息创建天气小时模型
 *
 * @param weatherCode Weather code / 天气代码
 * @param temperature Temperature / 温度
 * @param windScale Wind scale / 风力等级
 * @param uvIndex UV index / 紫外线指数
 * @param visibility Visibility / 能见度
 * @param humidity Humidity / 湿度
 * @return A new weather hour model instance / 新的天气小时模型实例
 */
+ (instancetype)modelWithWeatherCode:(TSWeatherCode *)weatherCode
                      temperature:(NSInteger)temperature
                        windScale:(NSInteger)windScale
                          uvIndex:(NSInteger)uvIndex
                       visibility:(CGFloat)visibility
                         humidity:(NSInteger)humidity;

@end

NS_ASSUME_NONNULL_END
