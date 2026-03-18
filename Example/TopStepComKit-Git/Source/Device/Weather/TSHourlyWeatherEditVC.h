//
//  TSHourlyWeatherEditVC.h
//  TopStepComKit_Example
//
//  Created by AI on 2026/03/05.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion block for hourly weather editing
 * @chinese 小时天气编辑完成回调
 *
 * @param weatherIcon Weather icon / 天气图标
 * @param temperature Temperature value / 温度值
 * @param windScale Wind scale level / 风力等级
 */
typedef void(^TSHourlyWeatherEditCompletion)(NSString *weatherIcon, NSInteger temperature, NSInteger windScale);

/**
 * @brief View controller for editing hourly weather data
 * @chinese 小时天气编辑页面
 */
@interface TSHourlyWeatherEditVC : TSRootVC

/**
 * @brief Hour time string (e.g., "14:00")
 * @chinese 小时时间字符串（如 "14:00"）
 */
@property (nonatomic, copy) NSString *hourTime;

/**
 * @brief Current weather icon
 * @chinese 当前天气图标
 */
@property (nonatomic, copy) NSString *weatherIcon;

/**
 * @brief Current temperature
 * @chinese 当前温度
 */
@property (nonatomic, assign) NSInteger temperature;

/**
 * @brief Current wind scale
 * @chinese 当前风力等级
 */
@property (nonatomic, assign) NSInteger windScale;

/**
 * @brief Completion callback
 * @chinese 完成回调
 */
@property (nonatomic, copy) TSHourlyWeatherEditCompletion completion;

@end

NS_ASSUME_NONNULL_END
