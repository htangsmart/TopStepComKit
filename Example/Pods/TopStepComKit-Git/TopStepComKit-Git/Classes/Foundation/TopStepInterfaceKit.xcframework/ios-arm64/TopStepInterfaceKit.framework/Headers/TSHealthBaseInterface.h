//
//  TSHealDatathInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/4/17.
//
#import "TSKitBaseInterface.h"
#import "TSActivityMeasureParam.h"
#import "TSAutoMonitorConfigs.h"
#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Health data management interface protocol
 * @chinese 健康数据管理接口协议
 *
 * @discussion
 * [EN]: This protocol defines the standard interface for health data management,
 * including manual measurements, automatic monitoring configuration, and data synchronization.
 * It provides methods to start/stop measurements, configure automatic monitoring,
 * and retrieve historical health data from the device.
 *
 * [CN]: 该协议定义了健康数据管理的标准接口，包括手动测量、自动监测配置和数据同步。
 * 它提供了启动/停止测量、配置自动监测以及从设备检索历史健康数据的方法。
 */
@protocol TSHealthBaseInterface <TSKitBaseInterface>

/**
 * @brief Block type for receiving measurement data
 * @chinese 接收测量数据的块类型
 *
 * @discussion
 * [EN]: Callback block that delivers an array of health value models during measurement.
 * Used to receive real-time measurement data from the device.
 *
 * [CN]: 在测量过程中传递健康值模型数组的回调块。
 * 用于接收来自设备的实时测量数据。
 */
typedef void (^TSMeasureDataBlock)(TSHealthValueItem *value);


@end

NS_ASSUME_NONNULL_END
