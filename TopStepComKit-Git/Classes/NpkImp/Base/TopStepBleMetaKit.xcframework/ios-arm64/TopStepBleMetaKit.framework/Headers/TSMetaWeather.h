//
//  TSMetaWeather.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "PbSettingParam.pbobjc.h"
#import "TSMetaWeatherDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaWeather : TSBusinessBase

/**
 * @brief Weather info completion
 * @chinese 天气信息完成回调
 *
 * @param weather
 * [EN]: Weather info model. Non-nil on success
 * [CN]: 天气信息模型。成功时非空
 *
 * @param error
 * [EN]: Error information. Nil on success
 * [CN]: 错误信息。成功时为nil
 */
typedef void(^TSMetaWeatherInfoCompletion)(TSMetaWeatherModel * _Nullable weather, NSError * _Nullable error);

/**
 * @brief Weather enable state completion
 * @chinese 天气开关状态完成回调
 *
 * @param enabled
 * [EN]: Whether weather feature is enabled
 * [CN]: 天气功能是否开启
 *
 * @param error
 * [EN]: Error information. Nil on success
 * [CN]: 错误信息。成功时为nil
 */
typedef void(^TSMetaWeatherEnableCompletion)(BOOL enabled, NSError * _Nullable error);

/**
 * @brief Fetch weather info
 * @chinese 获取天气信息
 *
 * @param completion
 * [EN]: Completion callback with weather info or error
 * [CN]: 完成回调，返回天气信息或错误
 *
 * @discussion
 * [EN]: Retrieves weather information from device if supported. If device does not support reading,
 *       the callback will return a "not supported" error.
 * [CN]: 从设备获取天气信息（若设备支持）。如果设备不支持读取，将返回“不支持”的错误。
 */
+ (void)fetchWeatherWithCompletion:(nullable TSMetaWeatherInfoCompletion)completion;

/**
 * @brief Push weather info to device
 * @chinese 推送天气信息到手表
 *
 * @param weather
 * [EN]: Weather info to push
 * [CN]: 要推送的天气信息
 *
 * @param completion
 * [EN]: Completion callback with operation result
 * [CN]: 完成回调，返回操作结果
 *
 * @discussion
 * [EN]: Serializes the weather model and sends it to the device.
 * [CN]: 将天气模型序列化并发送到设备。
 */
+ (void)pushWeather:(TSMetaWeatherModel *)weather completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Set weather enable state
 * @chinese 设置天气开启状态
 *
 * @param enable
 * [EN]: YES to enable, NO to disable
 * [CN]: YES开启，NO关闭
 *
 * @param completion
 * [EN]: Completion callback with operation result
 * [CN]: 完成回调，返回操作结果
 *
 * @discussion
 * [EN]: Updates the weather enable flag in function configuration.
 * [CN]: 通过修改功能配置中的天气开关标志位实现。
 */
+ (void)setWeatherEnable:(BOOL)enable completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Fetch weather enable state
 * @chinese 获取天气开启状态
 *
 * @param completion
 * [EN]: Completion callback with enable state
 * [CN]: 完成回调，返回开关状态
 *
 * @discussion
 * [EN]: Reads weather enable flag from function configuration.
 * [CN]: 读取功能配置中的天气开关标志位。
 */
+ (void)fetchWeatherEnableWithCompletion:(nullable TSMetaWeatherEnableCompletion)completion;

/**
 * @brief Push future N days weather data to device
 * @chinese 推送未来N天天气数据到设备
 *
 * @param weatherDayArray
 * EN: Weather day model array to push
 * CN: 要推送的未来天气模型数组
 *
 * @param completion
 * EN: Completion callback with operation result
 * CN: 完成回调，返回操作结果
 *
 * @discussion
 * [EN]: Pushes future N days weather data to device using list packet mode (0x53).
 *       The data will be automatically split into multiple packets if necessary.
 * [CN]: 使用列表分包模式(0x53)推送未来N天天气数据到设备。
 *       如果数据量较大，会自动分包发送。
 */
+ (void)pushWeatherDayList:(nullable NSArray<TSMetaWeatherDayModel *> *)weatherDayArray 
                completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief Push future N hours weather data to device
 * @chinese 推送未来N小时天气数据到设备
 *
 * @param weatherHourArray
 * EN: Weather hour model array to push
 * CN: 要推送的未来小时天气模型数组
 *
 * @param completion
 * EN: Completion callback with operation result
 * CN: 完成回调，返回操作结果
 *
 * @discussion
 * [EN]: Pushes future N hours weather data to device using list packet mode (0x54).
 *       The data will be automatically split into multiple packets if necessary.
 * [CN]: 使用列表分包模式(0x54)推送未来N小时天气数据到设备。
 *       如果数据量较大，会自动分包发送。
 */
+ (void)pushWeatherHourList:(nullable NSArray<TSMetaWeatherHourModel *> *)weatherHourArray 
                 completion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
