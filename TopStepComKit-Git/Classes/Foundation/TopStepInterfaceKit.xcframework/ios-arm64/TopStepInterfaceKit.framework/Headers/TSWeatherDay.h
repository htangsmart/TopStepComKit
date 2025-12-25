//
//  TSWeatherDay.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseModel.h"
#import "TSWeatherCodeModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Daily weather information model
 * @chinese 每日天气信息模型
 *
 * @discussion
 * EN: This model represents weather information for a specific day
 *     Contains detailed weather parameters for daily forecast
 *     Inherits from TSWeatherBaseModel for basic weather information
 * CN: 该模型表示特定日期的天气信息
 *     包含每日天气预报的详细参数
 *     继承自TSWeatherBaseModel以获取基本天气信息
 */
@interface TSWeatherDay : TSKitBaseModel

/**
 * @brief Timestamp of the weather information
 * @chinese 天气信息的时间戳
 *
 * @discussion
 * EN: Unix timestamp in seconds, representing when this weather information was recorded
 * CN: Unix时间戳（秒），表示该天气信息的记录时间
 */
@property (nonatomic, assign) NSTimeInterval timestamp;


/**
 * @brief Weather code information
 * @chinese 天气代码信息
 *
 * @discussion
 * EN: Contains the weather code and its corresponding description
 *     Used to identify different weather conditions (sunny, rainy, etc.)
 * CN: 包含天气代码和对应的描述信息
 *     用于标识不同的天气状况（晴天、雨天等）
 */
@property (nonatomic, strong) TSWeatherCodeModel *dayCode;

/**
 * @brief Night weather code
 * @chinese 夜间天气代码
 *
 * @discussion
 * EN: Weather code information for nighttime
 *     Used to identify different weather conditions during night
 * CN: 夜间的天气代码信息
 *     用于标识夜间的不同天气状况
 */
@property (nonatomic, strong) TSWeatherCodeModel *nightCode;

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
 * @brief Air pressure
 * @chinese 气压
 *
 * @discussion
 * EN: Atmospheric pressure in hPa (hectopascals)
 * CN: 大气压力，单位：百帕
 */
@property (nonatomic, assign) NSInteger airpressure;

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
@property (nonatomic, assign) UInt8 windScale;

/**
 * @brief Wind direction angle
 * @chinese 风向角度
 *
 * @discussion
 * EN: Wind direction in degrees (0-359)
 *     0/360: North, 90: East, 180: South, 270: West
 * CN: 风向角度（0-359）
 *     0/360：北，90：东，180：南，270：西
 */
@property (nonatomic, assign) NSInteger windAngle;

/**
 * @brief Wind speed
 * @chinese 风速
 *
 * @discussion
 * EN: Wind speed in meters per second (m/s)
 * CN: 风速，单位：米/秒
 */
@property (nonatomic, assign) UInt8 windSpeed;

/**
 * @brief Humidity
 * @chinese 湿度
 *
 * @discussion
 * EN: Relative humidity percentage (0-100)
 * CN: 相对湿度百分比（0-100）
 */
@property (nonatomic, assign) UInt8 humidity;

/**
 * @brief UV index
 * @chinese 紫外线指数
 *
 * @discussion
 * EN: UV radiation intensity index (0-11+)
 *     0-2: Low, 3-5: Moderate, 6-7: High, 8-10: Very High, 11+: Extreme
 * CN: 紫外线强度指数（0-11+）
 *     0-2：弱，3-5：中等，6-7：强，8-10：很强，11+：极强
 */
@property (nonatomic, assign) UInt8 uvIndex;

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
@property (nonatomic, assign) CGFloat visibility;

/**
 * @brief Create a weather day model with basic information
 * @chinese 使用基本信息创建天气日模型
 *
 * @param dayCode Day weather code / 白天天气代码
 * @param nightCode Night weather code, may be nil / 夜间天气代码，可为nil
 * @param curTemp Current temperature / 当前温度
 * @param minTemp Minimum temperature / 最低温度
 * @param maxTemp Maximum temperature / 最高温度
 * @return A new weather day model instance / 新的天气日模型实例
 */
+ (instancetype)modelWithDayCode:(TSWeatherCodeModel *)dayCode
                        nightCode:(nullable TSWeatherCodeModel *)nightCode
                          curTemp:(SInt8)curTemp
                          minTemp:(SInt8)minTemp
                          maxTemp:(SInt8)maxTemp;

/**
 * @brief Create a weather day model with complete information
 * @chinese 使用完整信息创建天气日模型
 *
 * @param dayCode Day weather code / 白天天气代码
 * @param nightCode Night weather code, may be nil / 夜间天气代码，可为nil
 * @param curTemp Current temperature / 当前温度
 * @param minTemp Minimum temperature / 最低温度
 * @param maxTemp Maximum temperature / 最高温度
 * @param airpressure Air pressure / 气压
 * @param windScale Wind scale / 风力等级
 * @param windAngle Wind direction angle / 风向角度
 * @param windSpeed Wind speed / 风速
 * @param humidity Humidity / 湿度
 * @param uvIndex UV index / 紫外线指数
 * @param visibility Visibility / 能见度
 * @return A new weather day model instance / 新的天气日模型实例
 */
+ (instancetype)modelWithDayCode:(TSWeatherCodeModel *)dayCode
                        nightCode:(nullable TSWeatherCodeModel *)nightCode
                          curTemp:(SInt8)curTemp
                          minTemp:(SInt8)minTemp
                          maxTemp:(SInt8)maxTemp
                      airpressure:(NSInteger)airpressure
                        windScale:(NSInteger)windScale
                        windAngle:(NSInteger)windAngle
                        windSpeed:(NSInteger)windSpeed
                         humidity:(NSInteger)humidity
                          uvIndex:(NSInteger)uvIndex
                       visibility:(CGFloat)visibility;

@end

NS_ASSUME_NONNULL_END
