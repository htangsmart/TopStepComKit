//
//  TSCommandDefines.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, TSRequestCommand) {
    /** 保留 */
    eCommandReserve = 0x00,
    /** 固件升级 */
    eCommandFirmwareUpgrade = 0x01,
    /** 设置指令 */
    eCommandSetting = 0x02,
    /** 环境指令 */
    eCommandEnvSetting = 0x03,
    /** 通知指令 */
    eCommandNotification = 0x04,
    /** 数据指令 */
    eCommandSyncData = 0x05,
    /** 文件/流指令 */
    eCommandFileStream = 0x06
};

typedef NS_ENUM(UInt8, TSRequestSettingKey) {
    /** 获取所有配置 */
    eGetAll = 0x01,
    /** 获取设备信息 */
    eGetDeviceInfo = 0x02,
    /** 获取/设置/通知 功能配置 */
    eGetFunction = 0x03,
    eSetFunction = 0x04,
    eDeviceFunctionChanged = 0x19,
    /** 获取/设置/通知 单位配置 */
    eGetUnit = 0x05,
    eSetUnit = 0x06,
    eDeviceUnitChanged = 0x1A,
    /** 获取/设置/通知 目标配置 */
    eGetTarget = 0x07,
    eSetTarget = 0x08,
    eDeviceTargetChanged = 0x1B,
    /** 获取/设置/通知 勿扰配置 */
    eGetDND = 0x09,
    eSetDND = 0x0A,
    eDeviceDNDChanged = 0x1C,
    /** 获取/设置/通知 抬腕亮屏配置 */
    eGetWristBright = 0x0B,
    eSetWristBright = 0x0C,
    eDeviceWristBrightChanged = 0x1D,
    /** 获取/设置/通知 心率配置 */
    eGetHeartRate = 0x0D,
    eSetHeartRate = 0x0E,
    eDeviceHeartRateChanged = 0x1E,
    /** 获取/设置/通知 压力配置 */
    eGetStress = 0x0F,
    eSetStress = 0x10,
    eDeviceStressChanged  = 0x1F,
    /** 获取/设置/通知 血氧配置 */
    eGetBloodOxygen = 0x11,
    eSetBloodOxygen = 0x12,
    eDeviceBloodOxygenChanged = 0x20,
    /** 获取/设置/通知 血压配置 */
    eGetBloodPressure = 0x13,
    eSetBloodPressure = 0x14,
    eDeviceBloodPressureChanged = 0x21,
    /** 获取/设置/通知 女性健康配置 */
    eGetFemaleHealth = 0x15,
    eSetFemaleHealth = 0x16,
    eDeviceFemaleHealthChanged = 0x22,
    /** 获取/设置/通知 通知配置 */
    eGetNotification = 0x17,
    eSetNotification = 0x18,
    eDeviceNotificationChanged = 0x23,
    /** APP 查找手表 */
    eAppFindWatch = 0x30,
    /** APP 停止查找手表 */
    eAppStopFindWatch = 0x31,
    /** Device 报告已经找到 */
    eDeviceHasBeenFound = 0x32,
    /** Device 查找手机 */
    eDeviceFindPhone = 0x33,
    /** Device 停止查找手机 */
    eDeviceStopFindPhone = 0x34,
    /** 手机报告已经找到 */
    ePhoneHasBeenFound = 0x35,
    /** App 控制相机 */
    eAppControlCamera = 0x36,
    /** Device 控制App */
    eDeviceControlCamera = 0x37,
    /** 获取/设置/通知 闹钟列表 */
    eGetAllAlarms = 0x38,
    eSetAllAlarms = 0x39,
    /** 获取/设置 普通联系人列表 */
    eGetNormalContactList = 0x3A,
    eSetNormalContactList = 0x3B,
    /** 获取/设置 急救联系人列表 */
    eGetEmergencyContactList = 0x3C,
    eSetEmergencyContactList = 0x3D,
    /** 获取/设置 提醒列表 */
    eGetReminderList = 0x3E,
    eSetReminderList = 0x3F,
    /** 设置天气 */
    eSetWeather = 0x40,
    /** 设置天气-未来 N 天 */
    eSetWeatherDayList = 0x53,
    /** 设置天气-未来 N 小时 */
    eSetWeatherHourList = 0x54,
    /** Device 刷新音乐信息 */
    eDeviceRefreshMusicInfo = 0x41,
    /** Device 刷新音乐状态 */
    eDeviceRefreshMusicStatus = 0x42,
    /** App 通知音乐信息变化 */
    eAppMusicInfoChanged = 0x43,
    /** App 通知音乐状态变化 */
    eAppMusicStatusChanged = 0x44,
    /** 刷新音量 */
    eRefreshVolume = 0x45,
    /** 通知音量变化 */
    eVolumeChanged = 0x46,
    /** 媒体控制 */
    eMediaControl = 0x47,
    /** Device 通知数据变更 */
    eDeviceDataChanged = 0x48,
    /** 获取所有表盘列表 */
    eGetAllDials    = 0x49,
    /** 选中某个表盘 */
    eSetSelectDial  = 0x4A,
    /** 删除某个表盘 */
    eDeleteDial     = 0x4B,
    /** 获取所有世界时钟 */
    eGetAllWorldClocks  = 0x4C,
    /** 设置所有世界时钟 */
    eSetAllWorldClocks  = 0x4D,
    /** 获取祈祷配置 */
    eGetPrayerConfig = 0x4E,
    /** 设置祈祷配置 */
    eSetPrayerConfig = 0x4F,
    /** 设置祈祷数据 */
    eSetPrayerTimes  = 0x50,
    /** 设备通知祈祷配置变更 */
//    eDevicePrayerConfigChanged = 0x51

};


typedef NS_ENUM(UInt8, TSRequestEnvKey) {
    /** 绑定 */
    eBind = 0x01,
    /** 登录 */
    eLogin = 0x02,
    /** 解绑 */
    eUnbind = 0x03,
    /** 设置信息 */
    eSetUserInfo = 0x04,
    /** 设置时间 */
    eSetTime = 0x05,
    /** 关机 */
    ePowerOff = 0x06,
    /** 重启 */
    eReboot = 0x07,
    /** 恢复出厂 */
    eFactoryReset = 0x08,
    /** 电量获取/变化通知 */
    eGetBattery = 0x09,
    eBatteryChanged = 0x0A,
    /** 语言获取/设置 */
    eGetLanguage = 0x0B,
    eSetLanguage = 0x0C,
    /** 语言变更通知 */
    eLanguageChanged = 0x10,
    /** App 状态变化通知外设 */
    eAppStatusChanged = 0x0D,
    /** 设备刷新 App 状态 */
    eDeviceRefreshAppStatus = 0x0E,
    /** 获取设备支持的语言列表 */
    eGetSupportedLanguages = 0x0F,
    /** 设置定位信息 */
    eSetLocation = 0x10,
    /** 获取设备蓝牙信息 */
    eGetBluetoothInfo = 0x11,

};

typedef NS_ENUM(UInt8, TSRequestNotifyKey) {
    /** 发送应用通知 */
    eSendAppNotification = 0x01,
    /** 发送电话通知 */
    eSendCallNotification = 0x02,
    /** 挂断请求 */
    eHangupRequest = 0x03,
    /** 挂断回复 */
    eHangupResponse = 0x04
};

typedef NS_ENUM(UInt8, TSRequestDataSyncKey) {
    /** 心率 */
    eDataSyncHeartRate = 0x01,
    /** 血氧 */
    eDataSyncBloodOxygen = 0x02,
    /** 血压 */
    eDataSyncBloodPressure = 0x03,
    /** 压力 */
    eDataSyncStress = 0x04,
    /** 睡眠 */
    eDataSyncSleep = 0x05,
    /** 活动数据 */
    eDataSyncActivity = 0x06,
    /** 运动数据 */
    eDataSyncSport = 0x07,
    /** 开始同步 */
    eStartSync = 0x21,
    /** 结束同步 */
    eEndSync = 0x22,
    /** App 实时测量控制 */
    eAppRealtimeMeasureControl = 0x30,
    /** Device 通知App实时测量结束 */
    eDeviceRealtimeMeasureStop = 0x31,
    /** Device 返回测量数据 */
    eDeviceReturnMeasureData = 0x32
};

typedef NS_ENUM(UInt8, TSRequestFileStreamKey) {
    /** App 发送 H264 数据头 */
    eAppSendH264Header = 0x01,
    /** App 发送 H264 数据帧 */
    eAppSendH264Frame = 0x02,
    /** 发送 Opus 数据头 */
    eSendOpusHeader = 0x11,
    /** 发送 Opus 数据帧 */
    eSendOpusFrame = 0x12,
    /** App 发送文件数据头 */
    eAppSendFileHeader = 0x21,
    /** App 发送文件数据帧 */
    eAppSendFileFrame = 0x22,
    /** App 发送文件结束传输 */
    eAppSendFileEnd = 0x23,
    /** App 发送文件取消传输 */
    eAppSendFileCancel = 0x24,
    /** Device 发送文件数据头 */
    eDeviceSendFileHeader = 0x25,
    /** Device 发送文件数据帧 */
    eDeviceSendFileFrame = 0x26,
    /** Device 发送文件结束传输 */
    eDeviceSendFileEnd = 0x27,
    /** Device 发送文件取消传输 */
    eDeviceSendFileCancel = 0x28,
    /** 请求文件夹空间 */
    eRequestFolderSpace = 0x31,
    /** 请求文件列表 */
    eRequestFileList = 0x32,
    /** 删除文件 */
    eDeleteFile = 0x33,
    /** 清空文件夹 */
    eClearFolder = 0x34,
    /** 监听文件变化 */
    eMonitorFileChange = 0x35,
    /** 请求设备传输文件 */
    eRequestDeviceTransferFile = 0x36
};
