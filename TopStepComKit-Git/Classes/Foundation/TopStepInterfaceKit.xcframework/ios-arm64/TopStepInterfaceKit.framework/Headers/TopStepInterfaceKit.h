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
#import <TopStepInterfaceKit/TSActivityMeasureParam.h>
#import <TopStepInterfaceKit/TSAutoMonitorConfigs.h>
#import <TopStepInterfaceKit/TSHealthValueModel.h>

// 心率
#import <TopStepInterfaceKit/TSHeartRateInterface.h>
#import <TopStepInterfaceKit/TSHRAutoMonitorConfigs.h>
#import <TopStepInterfaceKit/TSHRValueModel.h>

// 血氧
#import <TopStepInterfaceKit/TSBloodOxygenInterface.h>
#import <TopStepInterfaceKit/TSBOValueModel.h>

// 血压
#import <TopStepInterfaceKit/TSBloodPressureInterface.h>
#import <TopStepInterfaceKit/TSBPValueModel.h>
#import <TopStepInterfaceKit/TSBPAutoMonitorConfigs.h>

// 压力
#import <TopStepInterfaceKit/TSStressInterface.h>
#import <TopStepInterfaceKit/TSStressValueModel.h>

// 体温
#import <TopStepInterfaceKit/TSTemperatureInterface.h>
#import <TopStepInterfaceKit/TSTemperatureValueModel.h>

// 心电
#import <TopStepInterfaceKit/TSElectrocardioInterface.h>
#import <TopStepInterfaceKit/TSElectrocardioModel.h>

// 运动
#import <TopStepInterfaceKit/TSSportInterface.h>
#import <TopStepInterfaceKit/TSSportModel.h>
#import <TopStepInterfaceKit/TSSportItemModel.h>
#import <TopStepInterfaceKit/TSSportSummaryModel.h>

// 睡眠
#import <TopStepInterfaceKit/TSSleepInterface.h>
#import <TopStepInterfaceKit/TSSleepModel.h>
#import <TopStepInterfaceKit/TSSleepItemModel.h>
#import <TopStepInterfaceKit/TSSleepNapModel.h>
#import <TopStepInterfaceKit/TSSleepConcreteModel.h>
#import <TopStepInterfaceKit/TSSleepSummaryModel.h>

// 活动
#import <TopStepInterfaceKit/TSDailyActivityInterface.h>
#import <TopStepInterfaceKit/TSDailyActivityGoalsModel.h>
#import <TopStepInterfaceKit/TSDailyActivityValueModel.h>

// 通用接口
#import <TopStepInterfaceKit/TSComKitInterface.h>
#import <TopStepInterfaceKit/TSKitConfigOptions.h>

// bleConnect
#import <TopStepInterfaceKit/TSBleConnectInterface.h>
#import <TopStepInterfaceKit/TSPeripheral.h>
#import <TopStepInterfaceKit/TSPeripheralCapability.h>
#import <TopStepInterfaceKit/TSPeripheralDial.h>
#import <TopStepInterfaceKit/TSPeripheralProject.h>
#import <TopStepInterfaceKit/TSPeripheralSystem.h>
#import <TopStepInterfaceKit/TSPeripheralConnectParam.h>
#import <TopStepInterfaceKit/TSPeripheralLimitations.h>

// find
#import <TopStepInterfaceKit/TSPeripheralFindInterface.h>

// takePhoto
#import <TopStepInterfaceKit/TSCameraInterface.h>

// 联系人
#import <TopStepInterfaceKit/TSContactInterface.h>
#import <TopStepInterfaceKit/TSContactModel.h>

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

// OTA
#import <TopStepInterfaceKit/TSFileOTAInterface.h>
#import <TopStepInterfaceKit/TSFileOTAModel.h>

// 天气
#import <TopStepInterfaceKit/TSWeatherInterface.h>
#import <TopStepInterfaceKit/TSWeatherBaseModel.h>
#import <TopStepInterfaceKit/TSWeatherModel.h>
#import <TopStepInterfaceKit/TSWeatherCode.h>
#import <TopStepInterfaceKit/TSWeatherDayModel.h>
#import <TopStepInterfaceKit/TSWeatherHourModel.h>
#import <TopStepInterfaceKit/TSCity.h>

// 表盘
#import <TopStepInterfaceKit/TSPeripheralDialInterface.h>
#import <TopStepInterfaceKit/TSFwDialModel.h>
#import <TopStepInterfaceKit/TSFitDialModel.h>
#import <TopStepInterfaceKit/TSSJDialModel.h>
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
#import <TopStepInterfaceKit/TSAllDataModel.h>

// 基础数据存储
#import <TopStepInterfaceKit/TSComDataStorageInterface.h>

// 电子卡包
#import <TopStepInterfaceKit/TSECardBagInterface.h>

// 世界时钟
#import <TopStepInterfaceKit/TSWorldClockInterface.h>



#endif /* TopStepInterfaceKit_h */
