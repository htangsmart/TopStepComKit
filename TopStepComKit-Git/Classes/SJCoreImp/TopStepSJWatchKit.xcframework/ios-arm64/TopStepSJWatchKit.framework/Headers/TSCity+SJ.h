//
//  TSCity+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class WMLocationModel;

NS_ASSUME_NONNULL_BEGIN

@interface TSCity (SJ)

/**
 * @brief Convert TSCity to WMLocationModel
 * @chinese 将TSCity转换为WMLocationModel
 *
 * @return 
 * EN: Converted WMLocationModel object
 * CN: 转换后的WMLocationModel对象
 */
- (WMLocationModel *)toWMLocationModel;

/**
 * @brief Convert WMLocationModel to TSCity
 * @chinese 将WMLocationModel转换为TSCity
 * 
 * @param model 
 * EN: WMLocationModel object to be converted
 * CN: 需要转换的WMLocationModel对象
 * 
 * @return 
 * EN: Converted TSCity object
 * CN: 转换后的TSCity对象
 */
+ (TSCity *)modelWithWMLocationModel:(WMLocationModel *)model;

@end

NS_ASSUME_NONNULL_END
