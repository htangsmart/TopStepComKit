//
//  TSWeatherDayModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMWeatherForecastModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherDayModel (SJ)

/**
 * @brief Convert TSWeatherDayModel to WMWeatherForecastModel
 * @chinese 将TSWeatherDayModel转换为WMWeatherForecastModel
 *
 * @return 
 * EN: Converted WMWeatherForecastModel object
 * CN: 转换后的WMWeatherForecastModel对象
 */
- (WMWeatherForecastModel *)toWMWeatherForecastModel;

/**
 * @brief Convert WMWeatherForecastModel to TSWeatherDayModel
 * @chinese 将WMWeatherForecastModel转换为TSWeatherDayModel
 * 
 * @param model 
 * EN: WMWeatherForecastModel object to be converted
 * CN: 需要转换的WMWeatherForecastModel对象
 * 
 * @return 
 * EN: Converted TSWeatherDayModel object
 * CN: 转换后的TSWeatherDayModel对象
 */
+ (TSWeatherDayModel *)modelWithWMWeatherForecastModel:(WMWeatherForecastModel *)model;

@end

NS_ASSUME_NONNULL_END
