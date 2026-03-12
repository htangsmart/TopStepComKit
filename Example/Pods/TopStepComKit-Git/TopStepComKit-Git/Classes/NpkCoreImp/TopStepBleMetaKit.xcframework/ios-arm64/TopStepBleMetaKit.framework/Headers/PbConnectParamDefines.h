//
//  PbConnectParamDefines.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/2/6.
//

#ifndef PbConnectParamDefines_h
#define PbConnectParamDefines_h

// MARK: - 认证参数相关宏定义
// Auth parameter related macro definitions

/** 用户ID最大长度 */
#define kAuthUserIdLength 32

// MARK: - 语言配置相关宏定义
// Language configuration related macro definitions

/** 语言列表最大字节数 */
#define kLanguageListSize 64

// MARK: - 设备信息相关宏定义
// Device info related macro definitions

/** 项目号最大长度 */
#define kDeviceProjectLength 16

/** 版本号最大长度 */
#define kDeviceVersionLength 16

/** 品牌最大长度 */
#define kDeviceBrandLength 16

/** 型号最大长度 */
#define kDeviceModelLength 16

/** 序列号最大长度 */
#define kDeviceSerialLength 16

/** 主板号最大长度 */
#define kDeviceMainBoardLength 16

/** 设备能力数据最大字节数 */
#define kDeviceAbilitySize 16

/** 活动记录配置最大字节数 */
#define kDeviceActivitySize 3

/** 设备通知支持标志位最大字节数 */
#define kDeviceNotificationsSize 8

// MARK: - 设备限制相关宏定义
// Device limits related macro definitions

/** 提醒限制数组最大数量 */
#define kDeviceLimitsRemindCount 8

// MARK: - 蓝牙信息相关宏定义
// Bluetooth info related macro definitions

/** BLE MAC地址最大长度 */
#define kBluetoothBleMacLength 32

/** BLE名称最大长度 */
#define kBluetoothBleNameLength 32

/** BT MAC地址最大长度 */
#define kBluetoothBtMacLength 32

/** BT名称最大长度 */
#define kBluetoothBtNameLength 32

#endif /* PbConnectParamDefines_h */
