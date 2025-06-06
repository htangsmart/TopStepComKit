//
//  TSPeripheral+Fw.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/25.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheral (Fw)

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
 * @brief 根据ability值设置设备能力
 * @chinese 根据ability值设置设备能力
 *
 * @param abilityValue 
 * EN: Device capability value, can be a NSString hexadecimal string or NSNumber
 * CN: 设备能力值，可以是NSString类型的十六进制字符串或NSNumber类型的数值
 *
 * @discussion
 * [EN]: Processes device capability information:
 * - Handles capability values in different formats (string or number)
 * - Maps individual capability bits to TopStep capability flags
 * - Sets default capabilities for basic features
 * - Updates the device capability property
 *
 * [CN]: 处理设备能力信息：
 * - 处理不同格式（字符串或数字）的能力值
 * - 将单个能力位映射到TopStep能力标志
 * - 为基本功能设置默认能力
 * - 更新设备能力属性
 */
- (void)requestCapabilityWithInfo:(id)abilityValue;

@end

NS_ASSUME_NONNULL_END
