//
//  TSAIDeviceAuthenticationInfo.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/11/9.
//

#import <Foundation/Foundation.h>

#import "TSAIDeviceIdentitySnapshot.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provider-neutral device information for AI service authentication
 * @chinese 与 Provider 无关的 AI 服务鉴权设备信息
 *
 * @discussion
 * [EN]: Filled by the host from TopStepComKit after the device connects. The active Provider
 *       converts it into its own vendor model, so the host never imports vendor modules.
 * [CN]: 设备连接成功后由宿主从 TopStepComKit 读取填写；当前 Provider 负责转换为厂商模型，
 *       宿主无需引入任何厂商模块。
 */
@interface TSAIDeviceAuthenticationInfo : NSObject <NSCopying>

/** @brief Physical product category; Unknown is rejected @chinese 物理产品类型，Unknown 会被拒绝 */
@property (nonatomic, assign, readonly) TSAIDeviceProductKind productKind;
/** @brief Display name @chinese 设备显示名称 */
@property (nonatomic, copy, readonly, nullable) NSString *name;
/** @brief Bluetooth name @chinese 蓝牙名称 */
@property (nonatomic, copy, readonly, nullable) NSString *bluetoothName;
/** @brief Hardware MAC address @chinese 硬件 MAC 地址 */
@property (nonatomic, copy, readonly, nullable) NSString *MACAddress;
/** @brief Device model @chinese 设备型号 */
@property (nonatomic, copy, readonly, nullable) NSString *model;
/** @brief Project number @chinese 项目号 */
@property (nonatomic, copy, readonly, nullable) NSString *projectNumber;
/** @brief Firmware version @chinese 固件版本 */
@property (nonatomic, copy, readonly, nullable) NSString *firmwareVersion;
/** @brief Account identifier bound to the device @chinese 设备绑定的账号标识 */
@property (nonatomic, copy, readonly, nullable) NSString *userID;

/**
 * @brief Create authentication device information
 * @chinese 创建鉴权设备信息
 *
 * @param productKind
 * EN: Physical product category
 * CN: 物理产品类型
 *
 * @param name
 * EN: Display name; when empty the Provider falls back to bluetooth name, model and MAC in order
 * CN: 显示名称；为空时 Provider 依次回退到蓝牙名、型号、MAC
 *
 * @param bluetoothName EN: Bluetooth name. CN: 蓝牙名称。
 * @param MACAddress EN: Hardware MAC address. CN: 硬件 MAC 地址。
 * @param model EN: Device model. CN: 设备型号。
 * @param projectNumber EN: Project number. CN: 项目号。
 * @param firmwareVersion EN: Firmware version. CN: 固件版本。
 * @param userID EN: Account identifier. CN: 账号标识。
 *
 * @return
 * EN: Immutable information; validation happens when authenticating
 * CN: 不可变信息；鉴权时再校验
 */
- (instancetype)initWithProductKind:(TSAIDeviceProductKind)productKind
                               name:(nullable NSString *)name
                      bluetoothName:(nullable NSString *)bluetoothName
                         MACAddress:(nullable NSString *)MACAddress
                              model:(nullable NSString *)model
                      projectNumber:(nullable NSString *)projectNumber
                    firmwareVersion:(nullable NSString *)firmwareVersion
                             userID:(nullable NSString *)userID
    NS_DESIGNATED_INITIALIZER
    NS_SWIFT_NAME(init(productKind:name:bluetoothName:macAddress:model:projectNumber:firmwareVersion:userID:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
