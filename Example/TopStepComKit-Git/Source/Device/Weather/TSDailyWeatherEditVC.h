//
//  TSDailyWeatherEditVC.h
//  TopStepComKit_Example
//
//  Created by AI on 2026/03/05.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion block for daily weather editing
 * @chinese 每日天气编辑完成回调
 *
 * @param dayIcon Day weather icon / 白天天气图标
 * @param nightIcon Night weather icon / 夜间天气图标
 * @param minTemp Minimum temperature / 最低温度
 * @param maxTemp Maximum temperature / 最高温度
 * @param windScale Wind scale level / 风力等级
 * @param hour Selected hour / 选择的小时
 * @param minute Selected minute / 选择的分钟
 */
typedef void(^TSDailyWeatherEditCompletion)(NSString *dayIcon, NSString *nightIcon, NSInteger minTemp, NSInteger maxTemp, NSInteger windScale, NSInteger hour, NSInteger minute);

/**
 * @brief View controller for editing daily weather data
 * @chinese 每日天气编辑页面
 */
@interface TSDailyWeatherEditVC : UIViewController

/**
 * @brief Date string (e.g., "明天 03/06")
 * @chinese 日期字符串（如 "明天 03/06"）
 */
@property (nonatomic, copy) NSString *dateString;

/**
 * @brief Day weather icon
 * @chinese 白天天气图标
 */
@property (nonatomic, copy) NSString *dayIcon;

/**
 * @brief Night weather icon
 * @chinese 夜间天气图标
 */
@property (nonatomic, copy) NSString *nightIcon;

/**
 * @brief Minimum temperature
 * @chinese 最低温度
 */
@property (nonatomic, assign) NSInteger minTemp;

/**
 * @brief Maximum temperature
 * @chinese 最高温度
 */
@property (nonatomic, assign) NSInteger maxTemp;

/**
 * @brief Wind scale level
 * @chinese 风力等级
 */
@property (nonatomic, assign) NSInteger windScale;

/**
 * @brief Selected hour (0-23)
 * @chinese 选择的小时（0-23）
 */
@property (nonatomic, assign) NSInteger hour;

/**
 * @brief Selected minute (0-59)
 * @chinese 选择的分钟（0-59）
 */
@property (nonatomic, assign) NSInteger minute;

/**
 * @brief Completion callback
 * @chinese 完成回调
 */
@property (nonatomic, copy) TSDailyWeatherEditCompletion completion;

@end

NS_ASSUME_NONNULL_END
