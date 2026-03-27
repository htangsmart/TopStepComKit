//
//  TSDeviceStatusCardView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSBatteryModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device status card view displayed at the top of the home page
 * @chinese 首页顶部的设备状态卡片视图
 *
 * @discussion
 * [EN]: Shows device connection status, name, MAC address, and battery info.
 * [CN]: 展示设备连接状态、名称、MAC 地址和电量信息。
 */
@interface TSDeviceStatusCardView : UIView

/**
 * @brief Callback when reconnect button is tapped
 * @chinese 点击重连按钮时的回调
 */
@property (nonatomic, copy, nullable) void(^onReconnectTap)(void);

/**
 * @brief Whether the reconnect button is currently visible
 * @chinese 重连按钮当前是否可见
 */
@property (nonatomic, readonly) BOOL isReconnectButtonVisible;

/**
 * @brief Update card to connected or disconnected state
 * @chinese 更新卡片为已连接或未连接状态
 *
 * @param connected
 * EN: Whether the device is connected
 * CN: 设备是否已连接
 *
 * @param name
 * EN: Device name, nil when disconnected
 * CN: 设备名称，断开时传 nil
 *
 * @param mac
 * EN: MAC address, nil when disconnected
 * CN: MAC 地址，断开时传 nil
 *
 * @param battery
 * EN: Battery model, nil when unavailable
 * CN: 电量模型，不可用时传 nil
 */
- (void)updateConnected:(BOOL)connected
             deviceName:(nullable NSString *)name
             macAddress:(nullable NSString *)mac
                battery:(nullable TSBatteryModel *)battery;

/**
 * @brief Update card to connecting state with animation
 * @chinese 更新卡片为连接中状态（带闪烁动画）
 */
- (void)updateConnecting;

/**
 * @brief Update card to connection failed state with reconnect button
 * @chinese 更新卡片为连接失败状态（显示重连按钮）
 */
- (void)updateConnectionFailed;

@end

NS_ASSUME_NONNULL_END
