//
//  TSWeatherHourModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMTodayWeatherModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherHourModel (SJ)

/**
 * @brief Convert TSWeatherHourModel to WMTodayWeatherModel
 * @chinese 将TSWeatherHourModel转换为WMTodayWeatherModel
 *
 * @return 
 * EN: Converted WMTodayWeatherModel object
 * CN: 转换后的WMTodayWeatherModel对象
 */
- (WMTodayWeatherModel *)toWMTodayWeatherModel;

/**
 * @brief Convert WMTodayWeatherModel to TSWeatherHourModel
 * @chinese 将WMTodayWeatherModel转换为TSWeatherHourModel
 * 
 * @param model 
 * EN: WMTodayWeatherModel object to be converted
 * CN: 需要转换的WMTodayWeatherModel对象
 * 
 * @return 
 * EN: Converted TSWeatherHourModel object
 * CN: 转换后的TSWeatherHourModel对象
 */
+ (TSWeatherHourModel *)modelWithWMTodayWeatherModel:(WMTodayWeatherModel *)model;

@end

NS_ASSUME_NONNULL_END
