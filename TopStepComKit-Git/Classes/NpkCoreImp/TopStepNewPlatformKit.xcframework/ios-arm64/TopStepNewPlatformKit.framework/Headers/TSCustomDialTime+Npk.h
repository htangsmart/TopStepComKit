//
//  TSCustomDialTime+Npk.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/24.
//

#import "TSCustomDialTime.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSCustomDialTime (Npk)


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
- (CGPoint)rectFromTimePosition;

@end

NS_ASSUME_NONNULL_END
