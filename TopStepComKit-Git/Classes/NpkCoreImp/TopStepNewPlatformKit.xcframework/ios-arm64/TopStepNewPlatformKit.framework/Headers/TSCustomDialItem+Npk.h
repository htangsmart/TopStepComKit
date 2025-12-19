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
 * @brief Get position point based on time position
 * @chinese 根据时间位置获取位置坐标点
 *
 * @return
 * EN: CGPoint representing the position coordinates based on timePosition
 * CN: 根据timePosition返回的位置坐标点
 *
 * @discussion
 * [EN]: This method returns a CGPoint based on the timePosition property.
 *       The position coordinates are mapped according to TSDialTimePosition enum values.
 *       The returned coordinates are relative to the dial's coordinate system.
 * [CN]: 此方法根据timePosition属性返回一个CGPoint。
 *       位置坐标根据TSDialTimePosition枚举值进行映射。
 *       返回的坐标相对于表盘的坐标系。
 */
- (CGPoint)positionFromTimePosition;

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
- (nullable UIColor *)colorFromStyleIndex;




@end

NS_ASSUME_NONNULL_END
