//
//  TSPeripheral+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/14.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "PbConnectParam.pbobjc.h"
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheral (Npk)

/**
 * @brief Create TSPeripheral instance from TSMetaScanPeripheral
 * @chinese 根据TSMetaScanPeripheral创建TSPeripheral实例
 * 
 * @param scanPeripheral 
 * EN: TSMetaScanPeripheral object containing peripheral, advertisement data and RSSI
 * CN: 包含外设、广播数据和信号强度的TSMetaScanPeripheral对象
 * 
 * @return 
 * EN: Created TSPeripheral instance, nil if creation fails
 * CN: 创建的TSPeripheral实例，创建失败时返回nil
 */
+ (nullable instancetype)peripheralWithMetaScanPeripheral:(TSMetaScanPeripheral *)scanPeripheral;

+ (BOOL)isErrorPeripheral:(TSPeripheral *)peripheral;

/**
 * @brief Fill TSPeripheral with TSMetaPeripheralInfo content
 * @chinese 使用TSMetaPeripheralInfo的内容填充TSPeripheral
 * 
 * @param peripheral
 * EN: CBPeripheral object from CoreBluetooth
 * CN: 来自CoreBluetooth的CBPeripheral对象
 * 
 * @param peripheralInfo 
 * EN: TSMetaPeripheralInfo object containing device information
 * CN: 包含设备信息的TSMetaPeripheralInfo对象
 * 
 * @discussion
 * EN: This method populates the TSPeripheral's project and system information
 *     with data from the TSMetaPeripheralInfo object, including project details,
 *     device shape, limits, and other configuration information.
 * CN: 此方法使用TSMetaPeripheralInfo对象的数据填充TSPeripheral的项目和系统信息，
 *     包括项目详情、设备外形、限制和其他配置信息。
 */
- (void)fillWithPeripheral:(CBPeripheral *)peripheral PeripheralInfo:(TSMetaPeripheralInfo *)peripheralInfo;

/**
 * @brief Set device message notification ability from message capability data
 * @chinese 根据消息能力数据设置设备消息通知能力
 * 
 * @param messageAbilityData 
 * EN: Message capability data from device (_NotificationConfig.flags, typically 4-8 bytes)
 * CN: 从设备获取的消息能力数据（_NotificationConfig.flags，通常为4-8字节）
 * 
 * @discussion
 * EN: This method converts the device protocol's notification flags to TSMessageType format,
 *     then creates a TSMessageAbility object to represent which specific message types 
 *     (SMS, WeChat, QQ, etc.) are supported. The device protocol uses a different bit mapping
 *     than TSMessageType, so conversion is required.
 *     If the data is nil or empty, messageAbility will be set to nil.
 * 
 * CN: 此方法将设备协议的通知标志转换为TSMessageType格式，
 *     然后创建TSMessageAbility对象表示设备支持哪些具体的消息类型（SMS、微信、QQ等）。
 *     设备协议使用的位映射与TSMessageType不同，因此需要转换。
 *     如果数据为nil或空，messageAbility将被设置为nil。
 *
 * @note
 * EN: Device protocol bit mapping (0=Other, 1=SMS, 2=QQ, 3=WECHAT...) differs from 
 *     TSMessageType enum values. This method handles the conversion automatically.
 * CN: 设备协议的位映射（0=其他, 1=SMS, 2=QQ, 3=WECHAT...）与TSMessageType枚举值不同。
 *     此方法会自动处理转换。
 */
- (void)requestMessageAbilityWithInfo:(nullable NSData *)messageAbilityData;

/**
 * @brief Set device daily activity ability from activity capability data
 * @chinese 根据每日活动能力数据设置设备每日活动能力
 * 
 * @param dailyActivityData 
 * EN: Daily activity capability data from device (typically 3 bytes, each byte represents an activity type ID)
 * CN: 从设备获取的每日活动能力数据（通常为3字节，每个字节表示一个活动类型ID）
 * 
 * @discussion
 * EN: This method parses the activity capability data and creates a TSDailyActivityAbility object
 *     to represent which activity types (steps, exercise duration, etc.) are supported and displayed.
 *     The first 3 types are typically shown in the main interface rings.
 *     If the data is nil or empty, default configuration [1, 2, 3] will be used.
 * 
 * CN: 此方法解析活动能力数据并创建TSDailyActivityAbility对象，
 *     表示设备支持并显示哪些活动类型（步数、锻炼时长等）。
 *     前3个类型通常在主界面三环中显示。
 *     如果数据为nil或空，将使用默认配置 [1, 2, 3]。
 */
- (void)requestDailyActivityAbilityWithInfo:(nullable NSData *)dailyActivityData;

@end

NS_ASSUME_NONNULL_END
