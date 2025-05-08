//
//  TSTemperatureValueModel.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/4/17.
//

#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSTemperatureValueModel : TSHealthValueModel

/**
 * @brief Wrist temperature
 * @chinese 腕温
 *
 * @discussion
 * [EN]: Temperature measured at the wrist in Celsius.
 * Note: This is typically lower than core body temperature.
 *
 * [CN]: 腕部测量的温度，单位为摄氏度。
 * 注意：这通常低于核心体温。
 */
@property (nonatomic, assign) CGFloat wristTemperature;

/**
 * @brief Body temperature
 * @chinese 体温
 *
 * @discussion
 * [EN]: Estimated core body temperature in Celsius.
 * Normal range: 36.1-37.2°C (97-99°F).
 *
 * [CN]: 估算的核心体温，单位为摄氏度。
 * 正常范围：36.1-37.2°C（97-99°F）。
 */
@property (nonatomic, assign) CGFloat bodyTemperature;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic,assign) BOOL isUserInitiated;

@end

NS_ASSUME_NONNULL_END
