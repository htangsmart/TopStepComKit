//
//  TSDeviceConnectVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSPeripheral;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device connection view controller
 * @chinese 设备连接页
 *
 * @discussion
 * [EN]: Shows connection animation and status when connecting to a BLE device
 * [CN]: 连接蓝牙设备时显示连接动画和状态
 */
@interface TSDeviceConnectVC : TSBaseVC

/**
 * @brief Peripheral to connect
 * @chinese 要连接的外设
 */
@property (nonatomic, strong) TSPeripheral *peripheral;

/**
 * @brief Device name to display
 * @chinese 要显示的设备名称
 */
@property (nonatomic, copy) NSString *deviceName;

/**
 * @brief Callback when connection succeeds
 * @chinese 连接成功时的回调
 */
@property (nonatomic, copy, nullable) void(^onConnectSuccess)(void);

/**
 * @brief Callback when connection fails
 * @chinese 连接失败时的回调
 */
@property (nonatomic, copy, nullable) void(^onConnectFailure)(NSError *error);

/**
 * @brief Callback when user cancels connection
 * @chinese 用户取消连接时的回调
 */
@property (nonatomic, copy, nullable) void(^onCancel)(void);

@end

NS_ASSUME_NONNULL_END
