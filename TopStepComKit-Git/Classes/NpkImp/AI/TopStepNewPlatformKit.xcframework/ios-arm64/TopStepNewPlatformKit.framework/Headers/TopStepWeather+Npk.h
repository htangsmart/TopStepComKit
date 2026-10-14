//
//  TopStepWeather+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopStepWeather (Npk)

/**
 * @brief Convert to TSMetaWeatherModel
 * @chinese 转换为 TSMetaWeatherModel
 *
 * @discussion
 * [EN]: Convert current TopStepWeather to protobuf model used by BLE meta layer.
 * [CN]: 将当前 TopStepWeather 转换为 BLE Meta 层使用的 Protobuf 模型。
 */
- (nullable TSMetaWeatherModel *)toMetaWeatherModel;

/**
 * @brief Convert to TSMetaWeatherDayModel array
 * @chinese 转换为 TSMetaWeatherDayModel 数组
 *
 * @discussion
 * [EN]: Convert futhureSevenDays array to TSMetaWeatherDayModel array for BLE transmission.
 *       Returns nil if futhureSevenDays is empty or conversion fails.
 * [CN]: 将 futhureSevenDays 数组转换为 TSMetaWeatherDayModel 数组用于蓝牙传输。
 *       如果 futhureSevenDays 为空或转换失败则返回 nil。
 */
- (nullable NSArray<TSMetaWeatherDayModel *> *)toMetaWeatherDayArray;

/**
 * @brief Convert to TSMetaWeatherHourModel array
 * @chinese 转换为 TSMetaWeatherHourModel 数组
 *
 * @discussion
 * [EN]: Convert futhure24Hours array to TSMetaWeatherHourModel array for BLE transmission.
 *       Returns nil if futhure24Hours is empty or conversion fails.
 * [CN]: 将 futhure24Hours 数组转换为 TSMetaWeatherHourModel 数组用于蓝牙传输。
 *       如果 futhure24Hours 为空或转换失败则返回 nil。
 */
- (nullable NSArray<TSMetaWeatherHourModel *> *)toMetaWeatherHourArray;

@end

NS_ASSUME_NONNULL_END
