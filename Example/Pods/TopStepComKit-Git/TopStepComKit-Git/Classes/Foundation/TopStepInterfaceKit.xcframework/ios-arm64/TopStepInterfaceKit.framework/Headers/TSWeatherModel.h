//
//  TSWeatherModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>
#import "TSCity.h"
#import "TSWeatherBaseModel.h"
#import "TSWeatherDayModel.h"
#import "TSWeatherHourModel.h"

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
@interface TSWeatherModel : NSObject

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
@property (nonatomic, assign) long timeStamp;

/**
 * @brief Today's weather information
 * @chinese 今天的天气信息
 *
 * @discussion
 * EN: Detailed weather information for today
 *     Including temperature, humidity, wind, etc.
 * CN: 今天的详细天气信息
 *     包括温度、湿度、风力等
 */
@property (nonatomic, strong) TSWeatherDayModel *today;

/**
 * @brief Seven-day weather forecast
 * @chinese 未来七天天气预报
 *
 * @discussion
 * EN: Weather forecast for the next seven days
 *     Array of TSWeatherDayModel objects, ordered by date
 * CN: 未来七天的天气预报
 *     TSWeatherDayModel对象数组，按日期排序
 */
@property (nonatomic, strong) NSArray<TSWeatherDayModel *> *futhureSevenDays;

/**
 * @brief 24-hour weather forecast
 * @chinese 未来24小时天气预报
 *
 * @discussion
 * EN: Hourly weather forecast for the next 24 hours
 *     Array of TSWeatherHourModel objects, ordered by time
 * CN: 未来24小时的天气预报
 *     TSWeatherHourModel对象数组，按时间排序
 */
@property (nonatomic, strong) NSArray<TSWeatherHourModel *> *futhure24Hours;

@end

NS_ASSUME_NONNULL_END
