//
//  TSWeatherInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseInterface.h"
#import "TopStepWeather.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @brief Weather interface protocol
 * @chinese 天气接口协议
 * 
 * @discussion 
 * EN: This protocol defines all operations related to weather information, including:
 *     1. Set weather information
 *     2. Get weather information
 *     3. Control weather display status
 * CN: 该协议定义了与天气信息相关的所有操作，包括：
 *     1. 设置天气信息
 *     2. 获取天气信息
 *     3. 控制天气显示状态
 */
@protocol TSWeatherInterface <TSKitBaseInterface>

/**
 * @brief Get weather information
 * @chinese 获取天气信息
 *
 * @param completion
 * EN: Completion callback
 *     - weather: Weather information model containing all weather data
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - weather: 包含所有天气数据的天气信息模型
 *     - error: 获取失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method retrieves the current weather information from the device.
 *     The weather information includes:
 *     1. Current weather conditions
 *     2. Daily forecast
 *     3. Hourly forecast
 *     4. Location information
 * CN: 此方法从设备获取当前天气信息。
 *     天气信息包括：
 *     1. 当前天气状况
 *     2. 每日预报
 *     3. 每小时预报
 *     4. 位置信息
 */
- (void)fetchWeatherWithCompletion:(void (^)(TopStepWeather *_Nullable weather, NSError *_Nullable error))completion;


/**
 * @brief Set weather information
 * @chinese 设置天气信息
 * 
 * @param weather
 * EN: Weather information model containing all weather data
 * CN: 包含所有天气数据的天气信息模型
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method will synchronize the weather information to the device.
 *     The weather information includes:
 *     1. Current weather conditions
 *     2. Daily forecast
 *     3. Hourly forecast
 * CN: 此方法将天气信息同步到设备。
 *     天气信息包括：
 *     1. 当前天气状况
 *     2. 每日预报
 *     3. 每小时预报
 */
- (void)pushWeather:(TopStepWeather *)weather completion:(TSCompletionBlock)completion;

/**
 * @brief Set weather enable status
 * @chinese 设置天气功能开关状态
 * 
 * @param enable 
 * EN: Whether to enable weather function
 *     YES: Enable weather function
 *     NO: Disable weather function
 * CN: 是否启用天气功能
 *     YES: 启用天气功能
 *     NO: 禁用天气功能
 * 
 * @param completion 
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method controls whether the device displays weather information.
 *     When disabled, the device will not display any weather information.
 *     When enabled, the device will display weather information if available.
 * CN: 此方法控制设备是否显示天气信息。
 *     禁用时，设备将不会显示任何天气信息。
 *     启用时，如果有天气信息，设备将显示天气信息。
 */
- (void)setWeatherEnable:(BOOL)enable completion:(TSCompletionBlock)completion;

/**
 * @brief Get weather enable status
 * @chinese 获取天气功能开关状态
 * 
 * @param completion 
 * EN: Completion callback
 *     - enabled: Whether weather function is enabled
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - enabled: 天气功能是否启用
 *     - error: 获取失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: This method retrieves the current status of weather display function from the device.
 *     The status indicates whether the device is currently displaying weather information.
 * CN: 此方法从设备获取当前天气显示功能的状态。
 *     该状态表明设备当前是否正在显示天气信息。
 */
- (void)fetchWeatherEnableWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
