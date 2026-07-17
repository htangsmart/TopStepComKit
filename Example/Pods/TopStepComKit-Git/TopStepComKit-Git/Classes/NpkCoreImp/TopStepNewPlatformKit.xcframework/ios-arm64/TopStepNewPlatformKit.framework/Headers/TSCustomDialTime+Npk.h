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
 * @brief Get the actual time display rectangle
 * @chinese 获取实际的时间显示矩形区域
 *
 * @param dialSize
 * EN: Size of the dial (watch face size)
 * CN: 表盘尺寸（表盘大小）
 *
 * @return
 * EN: CGRect representing the actual time display area. If timeRect is set, returns timeRect.
 *     Otherwise, calculates and returns default position based on timePosition and dialSize.
 * CN: 表示实际时间显示区域的CGRect。如果timeRect已设置，返回timeRect。
 *     否则，根据timePosition和dialSize计算并返回默认位置。
 *
 * @discussion
 * [EN]: This method returns the actual rectangle area for time display.
 *       Priority: timeRect > timePosition (with default calculation).
 * [CN]: 此方法返回实际的时间显示矩形区域。
 *       优先级：timeRect > timePosition（使用默认计算）。
 */
- (CGRect)actualTimeRectWithDialSize:(CGSize)dialSize;


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
