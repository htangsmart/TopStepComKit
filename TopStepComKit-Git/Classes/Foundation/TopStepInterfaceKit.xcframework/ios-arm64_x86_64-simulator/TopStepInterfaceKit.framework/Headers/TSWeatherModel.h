//
//  TSWeatherModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSWeatherBaseModel.h"
#import <TopStepInterfaceKit/TSCity.h>
#import <TopStepInterfaceKit/TSWeatherBaseModel.h>
#import <TopStepInterfaceKit/TSWeatherDayModel.h>
#import <TopStepInterfaceKit/TSWeatherHourModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Weather information model
 * @chinese 天气信息模型
 *
 * @discussion
 * EN: This model represents complete weather information for a location
 *     Including current weather, daily forecast and hourly forecast
 *     Used as the main container for all weather-related data
 * CN: 该模型表示某个位置的完整天气信息
 *     包括当前天气、每日预报和每小时预报
 *     作为所有天气相关数据的主要容器
 */
@interface TSWeatherModel : TSWeatherBaseModel

/**
 * @brief City information
 * @chinese 城市信息
 *
 * @discussion
 * EN: Contains information about the city for which weather is being reported
 * CN: 包含正在报告天气的城市信息
 */
@property (nonatomic, strong) TSCity *city;

/**
 * @brief Weather information timestamp
 * @chinese 天气信息时间戳
 *
 * @discussion
 * EN: Unix timestamp in seconds when the weather information was last updated
 * CN: 天气信息最后更新时的Unix时间戳（秒）
 */
@property (nonatomic, assign) NSTimeInterval updateTimestamp;

/**
 * @brief Minimum temperature
 * @chinese 最低温度
 *
 * @discussion
 * EN: Minimum temperature for the day in Celsius
 * CN: 当天的最低温度，单位：摄氏度
 */
@property (nonatomic, assign) SInt8 minTemperature;

/**
 * @brief Maximum temperature
 * @chinese 最高温度
 *
 * @discussion
 * EN: Maximum temperature for the day in Celsius
 * CN: 当天的最高温度，单位：摄氏度
 */
@property (nonatomic, assign) SInt8 maxTemperature;

/**
 * @brief Current temperature
 * @chinese 当前温度
 *
 * @discussion
 * EN: Current temperature in Celsius
 * CN: 当前温度，单位：摄氏度
 */
@property (nonatomic, assign) SInt8 curTemperature;

/**
 * @brief Air pressure
 * @chinese 气压
 *
 * @discussion
 * EN: Atmospheric pressure in hPa (hectopascals)
 * CN: 大气压力，单位：百帕（hPa）
 */
@property (nonatomic, assign) NSInteger airpressure;

/**
 * @brief Air quality
 * @chinese 空气质量
 *
 * @discussion
 * EN: Air quality index value (AQI). The specific range depends on data source.
 * CN: 空气质量指数（AQI）数值，具体范围取决于数据来源。
 */
@property (nonatomic, assign) NSInteger quality;

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
 * @brief Ultraviolet index
 * @chinese 紫外线指数
 *
 * @discussion
 * EN: UV radiation intensity index (0-11+)
 * CN: 紫外线强度指数（0-11+）
 */
@property (nonatomic, assign) NSInteger uvIndex;

/**
 * @brief Wind direction angle
 * @chinese 风向角度
 *
 * @discussion
 * EN: Wind direction in degrees (0-359). 0/360: North, 90: East, 180: South, 270: West
 * CN: 风向角度（0-359）。0/360：北，90：东，180：南，270：西
 */
@property (nonatomic, assign) CGFloat windAngle;


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
 * @brief Wind speed
 * @chinese 风速
 *
 * @discussion
 * EN: Wind speed in meters per second (m/s)
 * CN: 风速，单位：米/秒
 */
@property (nonatomic, assign) CGFloat windSpeed;

/**
 * @brief Visibility
 * @chinese 能见度
 *
 * @discussion
 * EN: Visibility in meters
 * CN: 能见度，单位：米
 */
@property (nonatomic, assign) CGFloat visibility;

/**
 * @brief Seven-day weather forecast
 * @chinese 未来七天天气预报
 *
 * @discussion
 * EN: Weather forecast for the next seven days, including today
 *     Array of TSWeatherDayModel objects, ordered by date
 *     The first element is today's weather data
 * CN: 未来七天的天气预报，包含当天
 *     TSWeatherDayModel对象数组，按日期排序
 *     第一个元素为当天的天气数据
 */
@property (nonatomic, strong) NSArray<TSWeatherDayModel *> *futhureSevenDays;

/**
 * @brief 24-hour weather forecast
 * @chinese 未来24小时天气预报
 *
 * @discussion
 * EN: Hourly weather forecast for the next 24 hours, including current hour
 *     Array of TSWeatherHourModel objects, ordered by time
 *     The first element is the current hour's weather data
 * CN: 未来24小时的天气预报，包含当前小时
 *     TSWeatherHourModel对象数组，按时间排序
 *     第一个元素为当前小时的天气数据
 */
@property (nonatomic, strong) NSArray<TSWeatherHourModel *> *futhure24Hours;

@end

NS_ASSUME_NONNULL_END
