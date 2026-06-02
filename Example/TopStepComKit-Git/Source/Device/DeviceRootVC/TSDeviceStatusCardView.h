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
 * [EN]: Shows device connection status, name, MAC address, and battery info
 *       for all battery parts (horizontal scrollable capsules for multi-battery devices).
 * [CN]: 展示设备连接状态、名称、MAC 地址和所有部件的电量信息
 *       （多电池设备使用横向可滚动的胶囊样式）。
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
 * @param batteries
 * EN: Battery models for every available part. Nil or empty array hides the battery area.
 *     For single-battery devices the array should contain one element with part == TSBatteryPartMain.
 * CN: 各部件电量模型数组。传 nil 或空数组时隐藏电量区。
 *     单电池设备传一个 part 为 TSBatteryPartMain 的元素即可。
 */
- (void)updateConnected:(BOOL)connected
             deviceName:(nullable NSString *)name
             macAddress:(nullable NSString *)mac
              batteries:(nullable NSArray<TSBatteryModel *> *)batteries;

/**
 * @brief Apply an incremental battery update for one part
 * @chinese 对单个部件应用增量电量更新
 *
 * @param battery
 * EN: Updated battery model for a single part. Matched against the current
 *     batteries array by part; if no match is found the model is appended.
 * CN: 单个部件的更新电量模型。按 part 匹配当前数组中的元素；
 *     找不到时追加到末尾。
 */
- (void)applyBatteryUpdate:(TSBatteryModel *)battery;

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
