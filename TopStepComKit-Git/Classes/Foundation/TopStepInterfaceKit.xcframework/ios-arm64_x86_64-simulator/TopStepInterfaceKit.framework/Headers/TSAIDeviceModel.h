//
//  TSAIDeviceModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/12.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI chat status type
 * @chinese AI聊天状态类型
 */
typedef NS_ENUM(NSInteger, TSAIChatStatusType) {
    TSAIChatStatusTypeEnterChatGPT                 = 0x01,  ///< [中文]: 进入AI聊天 [EN]: Enter AI chat
    TSAIChatStatusTypeStartRecording               = 0x02,  ///< [中文]: 开始录音 [EN]: Start recording
    TSAIChatStatusTypeEndRecording                 = 0x03,  ///< [中文]: 结束录音 [EN]: End recording
    TSAIChatStatusTypeExitChatGPT                  = 0x04,  ///< [中文]: 退出AI聊天 [EN]: Exit AI chat
    TSAIChatStatusTypeReminderOpenApp              = 0x05,  ///< [中文]: 提醒打开APP [EN]: Reminder to open app
    TSAIChatStatusTypeIdentificationFailed         = 0x06,  ///< [中文]: 识别失败 [EN]: Identification failed
    TSAIChatStatusTypeIdentificationSuccessful     = 0x07,  ///< [中文]: 识别成功 [EN]: Identification successful
    TSAIChatStatusTypeConfirmContent               = 0x08,  ///< [中文]: 确认内容 [EN]: Confirm content
    TSAIChatStatusTypeStartAnswer                  = 0x09,  ///< [中文]: 开始回答 [EN]: Start answer
    TSAIChatStatusTypeAnswerCompleted              = 0x0a,  ///< [中文]: 回答完成 [EN]: Answer completed
    TSAIChatStatusTypeAnswering                    = 0x0b,  ///< [中文]: 回答中 [EN]: Answering
    TSAIChatStatusTypeAbnormalNoNetWork            = 0x0c,  ///< [中文]: 异常-无网络 [EN]: Abnormal - no network
    TSAIChatStatusTypeAbnormalSensitiveWord        = 0x0d,  ///< [中文]: 异常-敏感词 [EN]: Abnormal - sensitive word
    TSAIChatStatusTypeAbnormalCustom               = 0x0e,  ///< [中文]: 异常-自定义 [EN]: Abnormal - custom
};

/**
 * @brief AI device preset EQ type
 * @chinese AI设备预设均衡器类型
 */
typedef NS_ENUM(NSInteger, TSAIDevicePresetEQ) {
    TSAIDevicePresetEQUnknown = -1,           ///< [中文]: 未知 [EN]: Unknown
    TSAIDevicePresetEQSoundEffect1 = 0,      ///< [中文]: 音效 1 [EN]: Sound Effect 1
    TSAIDevicePresetEQSoundEffect2 = 1,      ///< [中文]: 音效 2 [EN]: Sound Effect 2
    TSAIDevicePresetEQSoundEffect3 = 2,      ///< [中文]: 音效 3 [EN]: Sound Effect 3
    TSAIDevicePresetEQSoundEffect4 = 3,      ///< [中文]: 音效 4 [EN]: Sound Effect 4
    TSAIDevicePresetEQSoundEffect5 = 4,      ///< [中文]: 音效 5 [EN]: Sound Effect 5
    TSAIDevicePresetEQSoundEffect6 = 5,      ///< [中文]: 音效 6 [EN]: Sound Effect 6
};

/**
 * @brief AI device noise reduction mode type
 * @chinese AI设备降噪模式类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceNoiseReductionMode) {
    TSAIDeviceNoiseReductionModeUnknown = -1,        ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceNoiseReductionModeOff = 0,             ///< [中文]: 关闭 [EN]: Off
    TSAIDeviceNoiseReductionModeOn = 1,              ///< [中文]: 打开 [EN]: On
    TSAIDeviceNoiseReductionModeTransparency = 2,    ///< [中文]: 通透模式 [EN]: Transparency
};

/**
 * @brief AI device low latency mode type
 * @chinese AI设备低延迟模式类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceLowLatencyMode) {
    TSAIDeviceLowLatencyModeUnknown = -1,    ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceLowLatencyModeOff = 0,         ///< [中文]: 关闭 [EN]: Off
    TSAIDeviceLowLatencyModeOn = 1,          ///< [中文]: 开启 [EN]: On
};

/**
 * @brief AI device connection status
 * @chinese AI设备连接状态
 */
typedef NS_ENUM(NSInteger, TSAIDeviceConnectionStatus) {
    TSAIDeviceConnectionStatusUnknown = -1,          ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceConnectionStatusDisconnected = 0,      ///< [中文]: 未连接 [EN]: Disconnected
    TSAIDeviceConnectionStatusConnected = 1,          ///< [中文]: 已连接 [EN]: Connected
};

/**
 * @brief AI device in case status
 * @chinese AI设备在仓状态
 */
typedef NS_ENUM(NSInteger, TSAIDeviceInCaseStatus) {
    TSAIDeviceInCaseStatusUnknown = -1,     ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceInCaseStatusOut = 0,          ///< [中文]: 不在仓 [EN]: Out
    TSAIDeviceInCaseStatusIn = 1,           ///< [中文]: 在仓 [EN]: In
};

/**
 * @brief AI device find status
 * @chinese AI设备查找状态
 */
typedef NS_ENUM(NSInteger, TSAIDeviceFindStatus) {
    TSAIDeviceFindStatusUnknown = -1,       ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceFindStatusNotFinding = 0,     ///< [中文]: 不在查找状态 [EN]: Not Finding
    TSAIDeviceFindStatusFinding = 1,        ///< [中文]: 处于查找状态 [EN]: Finding
};

/**
 * @brief AI device find event
 * @chinese AI设备查找事件
 */
typedef NS_ENUM(NSInteger, TSAIDeviceFindEvent) {
    TSAIDeviceFindEventUnknown = -1,        ///< [中文]: 未知 [EN]: Unknown
    TSAIDeviceFindEventFindLeft = 0,        ///< [中文]: 查找左耳 [EN]: Find Left
    TSAIDeviceFindEventFindRight = 1,       ///< [中文]: 查找右耳 [EN]: Find Right
    TSAIDeviceFindEventStopFindLeft = 2,   ///< [中文]: 停止查找左耳 [EN]: Stop Find Left
    TSAIDeviceFindEventStopFindRight = 3,   ///< [中文]: 停止查找右耳 [EN]: Stop Find Right
};

/**
 * @brief AI device side
 * @chinese AI设备左右侧
 */
typedef NS_ENUM(NSInteger, TSAIDeviceSide) {
    TSAIDeviceSideLeft = 0,                 ///< [中文]: 左耳 [EN]: Left
    TSAIDeviceSideRight = 1,                ///< [中文]: 右耳 [EN]: Right
};

/**
 * @brief AI device battery info model
 * @chinese AI设备电池信息模型
 */
@interface TSAIDeviceBatteryInfoModel : TSKitBaseModel

/**
 * @brief Battery level (0-100)
 * @chinese 电池电量（0-100）
 */
@property (nonatomic, assign) NSInteger batteryLevel;

/**
 * @brief Whether the device is charging
 * @chinese 设备是否正在充电
 */
@property (nonatomic, assign) BOOL isCharging;

@end

/**
 * @brief AI device status info model
 * @chinese AI设备状态信息模型
 */
@interface TSAIDeviceStatusInfoModel : TSKitBaseModel

/**
 * @brief Left device connection status
 * @chinese 左设备连接状态
 */
@property (nonatomic, assign) TSAIDeviceConnectionStatus leftConnectionStatus;

/**
 * @brief Right device connection status
 * @chinese 右设备连接状态
 */
@property (nonatomic, assign) TSAIDeviceConnectionStatus rightConnectionStatus;

/**
 * @brief Left device in case status
 * @chinese 左设备在仓状态
 */
@property (nonatomic, assign) TSAIDeviceInCaseStatus leftInCaseStatus;

/**
 * @brief Right device in case status
 * @chinese 右设备在仓状态
 */
@property (nonatomic, assign) TSAIDeviceInCaseStatus rightInCaseStatus;

/**
 * @brief Left device battery info
 * @chinese 左设备电池信息
 */
@property (nonatomic, strong, nullable) TSAIDeviceBatteryInfoModel *leftBatteryInfo;

/**
 * @brief Right device battery info
 * @chinese 右设备电池信息
 */
@property (nonatomic, strong, nullable) TSAIDeviceBatteryInfoModel *rightBatteryInfo;

@end

/**
 * @brief AI device find status info model
 * @chinese AI设备查找状态信息模型
 */
@interface TSAIDeviceFindStatusInfoModel : TSKitBaseModel

/**
 * @brief Left device find status
 * @chinese 左设备查找状态
 */
@property (nonatomic, assign) TSAIDeviceFindStatus leftFindStatus;

/**
 * @brief Right device find status
 * @chinese 右设备查找状态
 */
@property (nonatomic, assign) TSAIDeviceFindStatus rightFindStatus;

@end

NS_ASSUME_NONNULL_END
