//
//  TopStepInterfaceKit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/30.
//

#ifndef TopStepInterfaceKit_h
#define TopStepInterfaceKit_h

// 基础定义
#import <TopStepInterfaceKit/TSComEnumDefines.h>
#import <TopStepInterfaceKit/TSComConstDefines.h>

// base
#import <TopStepInterfaceKit/TSKitBaseInterface.h>
#import <TopStepInterfaceKit/TSKitPath.h>
#import <TopStepInterfaceKit/TopStepComKitConstants.h>

// sdk初始化
#import <TopStepInterfaceKit/TSKitInitInterface.h>

// 健康相关
#import <TopStepInterfaceKit/TSHealthBaseInterface.h>
#import <TopStepInterfaceKit/TSAutoMonitorInterface.h>
#import <TopStepInterfaceKit/TSActiveMeasureInterface.h>
#import <TopStepInterfaceKit/TSActivityMeasureParam.h>
#import <TopStepInterfaceKit/TSAutoMonitorConfigs.h>
#import <TopStepInterfaceKit/TSHealthValueModel.h>

// 心率
#import <TopStepInterfaceKit/TSHeartRateInterface.h>
#import <TopStepInterfaceKit/TSAutoMonitorHRConfigs.h>
#import <TopStepInterfaceKit/TSHRValueItem.h>

// 血氧
#import <TopStepInterfaceKit/TSBloodOxygenInterface.h>
#import <TopStepInterfaceKit/TSBOValueItem.h>

// 血压
#import <TopStepInterfaceKit/TSBloodPressureInterface.h>
#import <TopStepInterfaceKit/TSBPValueItem.h>
#import <TopStepInterfaceKit/TSAutoMonitorBPConfigs.h>

// 压力
#import <TopStepInterfaceKit/TSStressInterface.h>
#import <TopStepInterfaceKit/TSStressValueItem.h>

// 体温
#import <TopStepInterfaceKit/TSTemperatureInterface.h>
#import <TopStepInterfaceKit/TSTempValueItem.h>

// 心电
#import <TopStepInterfaceKit/TSElectrocardioInterface.h>
#import <TopStepInterfaceKit/TSECGValueItem.h>

// 运动
#import <TopStepInterfaceKit/TSSportInterface.h>
#import <TopStepInterfaceKit/TSSportModel.h>
#import <TopStepInterfaceKit/TSSportItemModel.h>
#import <TopStepInterfaceKit/TSSportSummaryModel.h>

// 睡眠
#import <TopStepInterfaceKit/TSSleepInterface.h>
#import <TopStepInterfaceKit/TSSleepDailyModel.h>
#import <TopStepInterfaceKit/TSSleepDetailItem.h>
#import <TopStepInterfaceKit/TSSleepSummary.h>

// 活动
#import <TopStepInterfaceKit/TSDailyActivityInterface.h>
#import <TopStepInterfaceKit/TSDailyActivityGoals.h>
#import <TopStepInterfaceKit/TSDailyActivityItem.h>

// 通用接口
#import <TopStepInterfaceKit/TSComKitInterface.h>
#import <TopStepInterfaceKit/TSKitConfigOptions.h>

// bleConnect
#import <TopStepInterfaceKit/TSBleConnectInterface.h>
#import <TopStepInterfaceKit/TSPeripheralScanParam.h>
#import <TopStepInterfaceKit/TSPeripheral.h>
#import <TopStepInterfaceKit/TSPeripheralCapability.h>
#import <TopStepInterfaceKit/TSPeripheralScreen.h>
#import <TopStepInterfaceKit/TSPeripheralProject.h>
#import <TopStepInterfaceKit/TSPeripheralSystem.h>
#import <TopStepInterfaceKit/TSPeripheralConnectParam.h>
#import <TopStepInterfaceKit/TSPeripheralLimitations.h>
#import <TopStepInterfaceKit/TSBluetoothSystem.h>

// find
#import <TopStepInterfaceKit/TSPeripheralFindInterface.h>

// takePhoto
#import <TopStepInterfaceKit/TSCameraInterface.h>
#import <TopStepInterfaceKit/TSCameraVideoData.h>

// 联系人
#import <TopStepInterfaceKit/TSContactInterface.h>
#import <TopStepInterfaceKit/TopStepContactModel.h>

// 闹钟
#import <TopStepInterfaceKit/TSAlarmClockInterface.h>
#import <TopStepInterfaceKit/TSAlarmClockModel.h>

// 语言
#import <TopStepInterfaceKit/TSLanguageInterface.h>
#import <TopStepInterfaceKit/TSLanguageModel.h>

// 用户信息
#import <TopStepInterfaceKit/TSUserInfoInterface.h>
#import <TopStepInterfaceKit/TSUserInfoModel.h>

// 消息通知
#import <TopStepInterfaceKit/TSMessageInterface.h>
#import <TopStepInterfaceKit/TSMessageModel.h>

// 固件升级
#import <TopStepInterfaceKit/TSFirmwareUpgradeInterface.h>

// 文件传输
#import <TopStepInterfaceKit/TSFileTransferInterface.h>
#import <TopStepInterfaceKit/TSFileTransferModel.h>
#import <TopStepInterfaceKit/TSFileModel.h>

// 天气
#import <TopStepInterfaceKit/TSWeatherInterface.h>
#import <TopStepInterfaceKit/TopStepWeather.h>
#import <TopStepInterfaceKit/TSWeatherCodeModel.h>
#import <TopStepInterfaceKit/TSWeatherDay.h>
#import <TopStepInterfaceKit/TSWeatherHour.h>
#import <TopStepInterfaceKit/TSWeatherCity.h>

// 表盘
#import <TopStepInterfaceKit/TSPeripheralDialInterface.h>
#import <TopStepInterfaceKit/TSDialModel.h>

// 设备控制
#import <TopStepInterfaceKit/TSRemoteControlInterface.h>

// 单位设置
#import <TopStepInterfaceKit/TSUnitInterface.h>

// 开关设置
#import <TopStepInterfaceKit/TSSettingInterface.h>
#import <TopStepInterfaceKit/TSWristWakeUpModel.h>
#import <TopStepInterfaceKit/TSDoNotDisturbModel.h>

// 电量
#import <TopStepInterfaceKit/TSBatteryInterface.h>
#import <TopStepInterfaceKit/TSBatteryModel.h>

// 时间
#import <TopStepInterfaceKit/TSTimeInterface.h>
#import <TopStepInterfaceKit/TSWorldClockModel.h>

// 提醒
#import <TopStepInterfaceKit/TSRemindersInterface.h>
#import <TopStepInterfaceKit/TSRemindersModel.h>

// 数据同步
#import <TopStepInterfaceKit/TSDataSyncInterface.h>

// 基础数据存储
#import <TopStepInterfaceKit/TSComDataStorageInterface.h>

// 电子卡包
#import <TopStepInterfaceKit/TSECardBagInterface.h>

// 世界时钟
#import <TopStepInterfaceKit/TSWorldClockInterface.h>

// 眼镜
#import <TopStepInterfaceKit/TSGlassesInterface.h>
#import <TopStepInterfaceKit/TSGlassesMediaCount.h>
#import <TopStepInterfaceKit/TSGlassesStorageInfo.h>

// App状态
#import <TopStepInterfaceKit/TSAppStatusInterface.h>
#import <TopStepInterfaceKit/TSAppStatusModel.h>

// 祈祷
#import <TopStepInterfaceKit/TSPrayersInterface.h>
#import <TopStepInterfaceKit/TSPrayerConfigs.h>
#import <TopStepInterfaceKit/TSPrayerTimes.h>

// 女性健康
#import <TopStepInterfaceKit/TSFemaleHealthInterface.h>
#import <TopStepInterfaceKit/TSFemaleHealthConfig.h>

// 音乐
#import <TopStepInterfaceKit/TSMusicInterface.h>
#import <TopStepInterfaceKit/TSMusicModel.h>

// 应用商店
#import <TopStepInterfaceKit/TSAppStoreInterface.h>
#import <TopStepInterfaceKit/TSApplicationModel.h>

// AI 设备管理
#import <TopStepInterfaceKit/TSAIManagerInterface.h>

// 设备日志
#import <TopStepInterfaceKit/TSPeripheralLogInterface.h>


#endif /* TopStepInterfaceKit_h */
