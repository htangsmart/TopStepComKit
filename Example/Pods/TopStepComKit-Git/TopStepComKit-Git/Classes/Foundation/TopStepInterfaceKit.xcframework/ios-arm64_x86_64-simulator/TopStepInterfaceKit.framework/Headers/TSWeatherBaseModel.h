//
//  TSWeatherBaseModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "TSWeatherCode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Base model for weather information
 * @chinese 天气信息的基础模型
 *
 * @discussion
 * EN: This is the base model for all weather related models, containing common properties
 *     such as timestamp and weather code. Other weather models inherit from this base model.
 * CN: 这是所有天气相关模型的基类，包含时间戳和天气代码等共同属性。
 *     其他天气模型都继承自这个基础模型。
 */
@interface TSWeatherBaseModel : NSObject

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
@property (nonatomic, strong) TSWeatherCode *weatherCode;

@end

NS_ASSUME_NONNULL_END
