//
//  TSFitBPAutoMonitor.h
//  Pods
//
//  Created by 磐石 on 2025/4/20.
//

#import "TSFitBaseAutoMonitor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Read and write Fit blood pressure auto-monitor configuration.
 * @chinese 读写 Fit 血压自动监测配置。
 */
@interface TSFitBPAutoMonitor : TSFitBaseAutoMonitor

/**
 * @brief Read the monitoring schedule and any supported alarms.
 * @chinese 读取监测计划及设备支持的预警设置。
 *
 * @param completion
 * EN: Called once with the configuration on success or nil and an error on failure.
 *     Bluetooth results arrive on the main queue. Validation errors may arrive on the calling thread.
 * CN: 成功时返回配置，失败时返回 nil 和错误。蓝牙结果在主队列回调一次，校验失败可在调用线程回调。
 */
+ (void)fetchAutoMonitorConfigsWithCompletion:(void (^)(TSAutoMonitorBPConfigs * _Nullable configs,
                                                       NSError * _Nullable error))completion;

/**
 * @brief Write the schedule before writing supported alarms.
 * @chinese 先写监测计划，再按设备能力写入预警。
 *
 * @param setting
 * EN: The blood pressure auto-monitor configuration to write.
 * CN: 待写入的血压自动监测配置。
 *
 * @param completion
 * EN: Called once with success after all required writes succeed, or with the error that stopped the request.
 *     Bluetooth results arrive on the main queue. Validation errors may arrive on the calling thread.
 * CN: 所需指令均成功后回调一次成功，失败时返回失败阶段的错误。
 *     蓝牙结果在主队列回调，校验失败可在调用线程回调。
 */
+ (void)pushAutoMonitorConfigs:(TSAutoMonitorBPConfigs *)setting completion:(TSCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END
