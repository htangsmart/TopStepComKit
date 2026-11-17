//
//  TSFitBaseAutoMonitor.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/4/23.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Write one Fit auto-monitor configuration item.
 * @chinese 写入一项 Fit 自动监测配置。
 *
 * @param completion
 * EN: Receives the result of the write command.
 * CN: 接收该条写入指令的结果。
 */
typedef void (^TSFitAutoMonitorWriteBlock)(TSCompletionBlock completion);

@interface TSFitBaseAutoMonitor : TSFitKitBase


+ (BOOL)isSupportIndividualMonitorConfig;

+ (BOOL)isSupportTimeIntervalSetting;

+ (BOOL)isSupportTimePeriodSetting;

/**
 * @brief Return firmware capabilities for a ready device.
 * @chinese 获取已就绪设备的固件能力。
 *
 * @param peripheral
 * EN: The device captured by the request.
 * CN: 本次请求所用的设备。
 *
 * @return
 * EN: Firmware capabilities, or nil if the device is unavailable.
 * CN: 固件能力，设备不可用时返回 nil。
 */
+ (nullable FitCloudFirmwareVersionObject *)firmwareForConnectedPeripheral:(nullable TSPeripheral *)peripheral;

/**
 * @brief Write a monitoring schedule followed by an optional alarm on the same connection.
 * @chinese 在同一连接上先写监测计划，再按需写入预警。
 *
 * @param peripheral
 * EN: The device captured by the request.
 * CN: 本次请求所用的设备。
 *
 * @param monitorWrite
 * EN: Issues the monitoring schedule write.
 * CN: 下发监测计划写入指令。
 *
 * @param alarmWrite
 * EN: Issues the alarm write after monitor success. Pass nil for a monitor-only request.
 * CN: 监测写入成功后下发预警指令。仅写监测计划时传 nil。
 *
 * @param completion
 * EN: Receives the terminal result on the main queue after a Bluetooth write starts.
 * CN: 蓝牙写入开始后，在主队列接收最终结果。
 */
+ (void)writeMonitorForPeripheral:(TSPeripheral *)peripheral
                     monitorWrite:(TSFitAutoMonitorWriteBlock)monitorWrite
                       alarmWrite:(nullable TSFitAutoMonitorWriteBlock)alarmWrite
                      completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
