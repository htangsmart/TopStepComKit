//
//  TSCustomDialItem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/5.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSCustomDialItem (Npk)

/**
 * @brief Get UIColor based on style index
 * @chinese 根据样式索引获取颜色
 *
 * @return
 * EN: UIColor object corresponding to the styleIndex, nil if styleIndex is invalid
 * CN: 根据styleIndex返回对应的UIColor对象，如果styleIndex无效则返回nil
 *
 * @discussion
 * [EN]: This method returns a UIColor based on the styleIndex property.
 *       Different style indices correspond to different colors for time display.
 *       The color mapping may vary depending on the dial design.
 * [CN]: 此方法根据styleIndex属性返回一个UIColor。
 *       不同的样式索引对应不同的时间显示颜色。
 *       颜色映射可能因表盘设计而异。
 */
//- (nullable UIColor *)colorFromStyleIndex;




@end

NS_ASSUME_NONNULL_END
