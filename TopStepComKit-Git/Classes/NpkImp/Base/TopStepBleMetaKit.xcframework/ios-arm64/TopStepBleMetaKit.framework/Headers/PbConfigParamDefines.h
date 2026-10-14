//
//  PbConfigParamDefines.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/2/6.
//

#ifndef PbConfigParamDefines_h
#define PbConfigParamDefines_h

// MARK: - 功能配置相关宏定义
// Function configuration related macro definitions

/** 功能配置标志位最大字节数 */
#define kFunctionFlagsSize 4

// MARK: - 单位配置相关宏定义
// Unit configuration related macro definitions

/** 单位配置标志位最大字节数 */
#define kUnitFlagsSize 4

// MARK: - 通知配置相关宏定义
// Notification configuration related macro definitions

/** 通知配置标志位最大字节数 */
#define kNotificationFlagsSize 8

// MARK: - 设备信息相关宏定义
// Device info related macro definitions

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

#endif /* PbConfigParamDefines_h */
