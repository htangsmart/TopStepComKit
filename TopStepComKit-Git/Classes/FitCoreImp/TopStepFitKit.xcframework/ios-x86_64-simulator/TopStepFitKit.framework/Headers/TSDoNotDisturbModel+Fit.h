//
//  TSDoNotDisturbModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudDNDSetting;

NS_ASSUME_NONNULL_BEGIN

@interface TSDoNotDisturbModel (Fit)

/**
 * @brief Convert TSLunchBreakDNDModel to FitCloudDNDSetting
 * @chinese 将TSLunchBreakDNDModel转换为FitCloudDNDSetting
 * 
 * @return 
 * EN: Converted FitCloudDNDSetting object
 * CN: 转换后的FitCloudDNDSetting对象
 * 
 * @discussion
 * EN: This method converts the lunch break DND settings to FitCloud format.
 *     The conversion rules are:
 *     1. isEnabled -> on
 *     2. startTime -> periodBegin
 *     3. endTime -> periodEnd
 *     Note: dndPeriodOn is always set to YES as this is specifically for lunch break
 * CN: 此方法将午休免打扰设置转换为FitCloud格式。
 *     转换规则如下：
 *     1. isEnabled -> on
 *     2. startTime -> periodBegin
 *     3. endTime -> periodEnd
 *     注意：dndPeriodOn始终设置为YES，因为这是专门用于午休的
 */
- (FitCloudDNDSetting *)toFitCloudDNDSetting;

/**
 * @brief Convert FitCloudDNDSetting to TSLunchBreakDNDModel
 * @chinese 将FitCloudDNDSetting转换为TSLunchBreakDNDModel
 * 
 * @param setting 
 * EN: FitCloudDNDSetting object to be converted
 * CN: 需要转换的FitCloudDNDSetting对象
 * 
 * @return 
 * EN: Converted TSLunchBreakDNDModel object
 * CN: 转换后的TSLunchBreakDNDModel对象
 * 
 * @discussion
 * EN: This method converts FitCloud DND settings to lunch break DND model.
 *     The conversion rules are:
 *     1. on -> isEnabled
 *     2. periodBegin -> startTime
 *     3. periodEnd -> endTime
 *     Note: Only converts if dndPeriodOn is YES
 * CN: 此方法将FitCloud免打扰设置转换为午休免打扰模型。
 *     转换规则如下：
 *     1. on -> isEnabled
 *     2. periodBegin -> startTime
 *     3. periodEnd -> endTime
 *     注意：仅当dndPeriodOn为YES时才进行转换
 */
+ (TSDoNotDisturbModel *)modelWithFitCloudDNDSetting:(FitCloudDNDSetting *)setting;

@end

NS_ASSUME_NONNULL_END
