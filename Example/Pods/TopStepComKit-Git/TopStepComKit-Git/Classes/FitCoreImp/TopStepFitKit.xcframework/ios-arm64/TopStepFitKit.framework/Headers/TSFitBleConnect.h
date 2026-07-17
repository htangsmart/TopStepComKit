//
//  TSFitBleConnect.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/1/2.
//
/**
 * @class TSFitBleConnect
 * @brief 蓝牙设备连接管理类
 * @discussion 负责管理蓝牙设备的扫描、连接、绑定等操作，实现了TSBleConnectInterface协议
 *
 * 主要功能：
 * 1. 设备扫描：搜索周边可用的蓝牙设备
 * 2. 设备连接：建立与设备的蓝牙连接
 * 3. 设备绑定：完成设备的绑定流程
 * 4. 状态管理：监控和管理设备连接状态
 * 5. 重连机制：处理设备断开后的重新连接
 */


#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitBleConnect : TSFitKitBase<TSBleConnectInterface>



@end

NS_ASSUME_NONNULL_END
