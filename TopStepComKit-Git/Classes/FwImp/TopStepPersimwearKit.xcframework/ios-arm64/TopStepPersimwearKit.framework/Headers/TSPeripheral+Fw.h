//
//  TSPeripheral+Fw.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheral (Fw)

+ (BOOL)fwPeripheral:(TSPeripheral *)peripheral matchesScanParam:(nullable TSPeripheralScanParam *)scanParam;

+ (nullable NSString *)fwDiscoveryKeyForPeripheral:(TSPeripheral *)peripheral;

/**
 * @brief 处理固件外设信息
 * @chinese 从固件获取的外设信息
 *
 * @param values 
 * EN: Dictionary containing device information values
 * CN: 包含设备信息值的字典
 *
 * @discussion
 * [EN]: Processes peripheral information from firmware values including:
 * - System information
 * - Project information
 * - Device limitations
 * - Dial information
 * - Device capabilities from 'ability' value
 *
 * [CN]: 处理来自固件值的外设信息，包括：
 * - 系统信息
 * - 项目信息
 * - 设备限制
 * - 表盘信息
 * - 来自'ability'值的设备能力
 */
- (void)requestFwPeripheralDialInfoWithValues:(NSDictionary *)values;

/**
 * @brief Whether the latest device information reports blood oxygen alert support.
 * @chinese 最近一次设备信息是否上报支持血氧预警。
 */
@property (atomic, assign, readonly) BOOL fwSupportsBloodOxygenAlert;

/**
 * @brief Whether the latest device information identifies a model with stress alert support.
 * @chinese 最近一次设备信息是否标识为支持压力预警的机型。
 */
@property (atomic, assign, readonly) BOOL fwSupportsStressAlert;

/**
 * @brief Clear health alert capabilities from the previous connection.
 * @chinese 清除上一条连接的健康预警能力。
 */
- (void)clearFwHealthAlertCapabilities;

@end

NS_ASSUME_NONNULL_END
