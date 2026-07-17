//
//  TSTempValueItem.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/4/17.
//

#import "TSHealthValueItem.h"
#import "TSComEnumDefines.h"

/**
 * @brief Temperature measurement type
 * @chinese 温度测量类型
 *
 * @discussion
 * [EN]: Distinguishes between body temperature and wrist temperature measurements.
 *       Body temperature is the estimated core body temperature, while wrist temperature
 *       is measured at the wrist and is typically lower.
 *
 * [CN]: 区分体温和腕温测量。
 *       体温是估算的核心体温，而腕温是在腕部测量的温度，通常较低。
 */
typedef NS_ENUM(NSInteger, TSTemperatureType) {
    /// 体温 (Body temperature)
    TSTemperatureTypeBody = 0,
    /// 腕温 (Wrist temperature)
    TSTemperatureTypeWrist = 1
};


NS_ASSUME_NONNULL_BEGIN

@interface TSTempValueItem : TSHealthValueItem

/**
 * @brief Temperature value
 * @chinese 温度值
 *
 * @discussion
 * [EN]: Temperature value in Celsius.
 *       The meaning of this value depends on temperatureType:
 *       - If temperatureType is TSTemperatureTypeBody: core body temperature
 *       - If temperatureType is TSTemperatureTypeWrist: wrist temperature
 *
 * [CN]: 温度值，单位为摄氏度。
 *       该值的含义取决于 temperatureType：
 *       - 如果 temperatureType 是 TSTemperatureTypeBody：核心体温
 *       - 如果 temperatureType 是 TSTemperatureTypeWrist：腕温
 */
@property (nonatomic, assign) CGFloat temperature;

/**
 * @brief Temperature measurement type
 * @chinese 温度测量类型
 *
 * @discussion
 * [EN]: Specifies whether this measurement is body temperature or wrist temperature.
 *       - TSTemperatureTypeBody: Core body temperature (normal range: 36.1-37.2°C)
 *       - TSTemperatureTypeWrist: Wrist temperature (typically lower than body temperature)
 *
 * [CN]: 指定此测量是体温还是腕温。
 *       - TSTemperatureTypeBody: 核心体温（正常范围：36.1-37.2°C）
 *       - TSTemperatureTypeWrist: 腕温（通常低于体温）
 */
@property (nonatomic, assign) TSTemperatureType temperatureType;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic, assign) BOOL isUserInitiated;

@end

NS_ASSUME_NONNULL_END
