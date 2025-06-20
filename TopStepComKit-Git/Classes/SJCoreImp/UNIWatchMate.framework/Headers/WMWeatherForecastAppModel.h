//
//  WMWeatherForecastAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMWeatherModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 天气预报
@interface WMWeatherForecastAppModel : NSObject<WMSupportProtocol>

/// 设备请求刷新全部天气（参数语言BCP代码，收到代码后获取最新天气，使用pushWeather推送天气） （Device request to refresh all weather (parameter language BCP code, get the latest weather after receiving the code, use pushWeather to push the weather)）
@property (nonatomic, strong) RACSignal<NSString *> *requestAll;

/// 设备请求刷新未来7天天气（参数语言BCP代码，收到代码后获取最新天气，使用pushWeather推送天气） （The device requests to refresh the weather for the next 7 days (parameter language BCP code, get the latest weather after receiving the code, use pushWeather to push the weather)）
@property (nonatomic, strong) RACSignal<NSString *> *requestDay7;

/// 设备请求刷新未来24小时天气（参数语言BCP代码，收到代码后获取最新天气，使用pushWeather推送天气） （Device request to refresh the weather in the next 24 hours (parameter language BCP code, get the latest weather after receiving the code, use pushWeather to push the weather)）
@property (nonatomic, strong) RACSignal<NSString *> *requestHour24;

/// 推送天气给设备
/// - Parameter weather: 天气数据（weatherForecast必须要有7条数据，todayWeather必须要有24条数据） （Weather data (weatherForecast must have 7 data, todayWeather must have 24 data)）
- (RACSignal<NSNumber *> *)pushWeatherAll:(WMWeatherModel *)weather;

/// 推送未来7天天气给设备 （Push the next 7 days weather to the device）
/// - Parameter weather: 天气数据（weatherForecast必须要有7条数据）（Weather data (7 data sets are required for the weatherForecast)）
- (RACSignal<NSNumber *> *)pushWeatherDay7:(WMWeatherModel *)weather;

/// 推送未来24小时天气给设备 （Push the next 24 hours weather to the device）
/// - Parameter weather: 天气数据（todayWeather必须要有24条数据）（Weather data (todayWeather must have 24 data)）
- (RACSignal<NSNumber *> *)pushWeatherHour24:(WMWeatherModel *)weather;

@end

NS_ASSUME_NONNULL_END
