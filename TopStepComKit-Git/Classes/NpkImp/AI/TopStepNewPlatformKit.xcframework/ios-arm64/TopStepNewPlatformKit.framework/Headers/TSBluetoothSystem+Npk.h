//
//  TSBluetoothSystem+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/2.
//

#import "TSBluetoothSystem.h"

@class TSMetaBluetoothInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSBluetoothSystem Npk扩展
 * @chinese TSBluetoothSystem Npk扩展
 *
 * @discussion
 * [EN]: Provides conversion methods between TSMetaBluetoothInfo (Protobuf) and TSBluetoothSystem (Interface model).
 * [CN]: 提供TSMetaBluetoothInfo（Protobuf）和TSBluetoothSystem（接口模型）之间的转换方法。
 */
@interface TSBluetoothSystem (Npk)

/**
 * @brief Convert TSMetaBluetoothInfo to TSBluetoothSystem
 * @chinese 将TSMetaBluetoothInfo转换为TSBluetoothSystem
 *
 * @param metaBluetoothInfo
 * [EN]: TSMetaBluetoothInfo object from Protobuf
 * [CN]: 来自Protobuf的TSMetaBluetoothInfo对象
 *
 * @return
 * [EN]: Converted TSBluetoothSystem object, nil if metaBluetoothInfo is nil
 * [CN]: 转换后的TSBluetoothSystem对象，如果metaBluetoothInfo为nil则返回nil
 *
 * @discussion
 * [EN]: - Converts Protobuf TSMetaBluetoothInfo to interface model TSBluetoothSystem
 *       - Maps BLE and BT information including MAC addresses, names, and connection status
 *       - Connection status values: 0=Disconnected, 1=Connected, 2=Ready
 *       - Returns nil if metaBluetoothInfo is nil
 * [CN]: - 将Protobuf的TSMetaBluetoothInfo转换为接口模型TSBluetoothSystem
 *       - 映射BLE和BT信息，包括MAC地址、名称和连接状态
 *       - 连接状态值：0=未连接，1=已连接，2=已就绪
 *       - 如果metaBluetoothInfo为nil则返回nil
 */
+ (nullable TSBluetoothSystem *)bluetoothSystemWithMetaBluetoothInfo:(nullable TSMetaBluetoothInfo *)metaBluetoothInfo;

@end

NS_ASSUME_NONNULL_END
