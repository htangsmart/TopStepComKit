//
//  TSHRAutoMonitorConfigs+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMHeartRateConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSHRAutoMonitorConfigs (SJ)

/**
 * @brief Convert TSAutoMonitorHeartRateModel to WMHeartRateConfigModel
 * @chinese 将TSAutoMonitorHeartRateModel转换为WMHeartRateConfigModel
 * 
 * @return 
 * EN: Converted WMHeartRateConfigModel object
 * CN: 转换后的WMHeartRateConfigModel对象
 */
- (WMHeartRateConfigModel *)toWMHeartRateConfigModel;

/**
 * @brief Convert WMHeartRateConfigModel to TSAutoMonitorHeartRateModel
 * @chinese 将WMHeartRateConfigModel转换为TSAutoMonitorHeartRateModel
 * 
 * @param wmModel 
 * EN: WMHeartRateConfigModel object to be converted
 * CN: 需要转换的WMHeartRateConfigModel对象
 * 
 * @return 
 * EN: Converted TSAutoMonitorHeartRateModel object, nil if conversion fails
 * CN: 转换后的TSAutoMonitorHeartRateModel对象，转换失败时返回nil
 */
+ (nullable TSHRAutoMonitorConfigs *)modelWithWMHeartRateConfigModel:(nullable WMHeartRateConfigModel *)wmModel;

@end

NS_ASSUME_NONNULL_END
