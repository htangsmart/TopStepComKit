//
//  TSWeatherModel+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMWeatherModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherModel (SJ)

/**
 * @brief Convert TSWeatherModel to WMWeatherModel
 * @chinese 将TSWeatherModel转换为WMWeatherModel
 *
 * @return 
 * EN: Converted WMWeatherModel object
 * CN: 转换后的WMWeatherModel对象
 */
- (WMWeatherModel *)toWMWeatherModel;

/**
 * @brief Convert WMWeatherModel to TSWeatherModel
 * @chinese 将WMWeatherModel转换为TSWeatherModel
 * 
 * @param model 
 * EN: WMWeatherModel object to be converted
 * CN: 需要转换的WMWeatherModel对象
 * 
 * @return 
 * EN: Converted TSWeatherModel object
 * CN: 转换后的TSWeatherModel对象
 */
+ (TSWeatherModel *)modelWithWMWeatherModel:(WMWeatherModel *)model;

@end

NS_ASSUME_NONNULL_END
