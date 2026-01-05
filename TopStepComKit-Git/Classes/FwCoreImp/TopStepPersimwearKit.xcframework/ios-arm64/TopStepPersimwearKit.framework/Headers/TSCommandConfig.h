#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define TS_COMMAND_DICT(CMD, KEY, VALUE) @{ @"cmd": CMD, @"key": KEY, @"values": VALUE?:@"" }


/**
 * @class TSCommandConfig
 * @brief Persimwear命令配置类
 * @discussion 统一管理所有Persimwear相关的命令和键值
 */
@interface TSCommandConfig : NSObject

#pragma mark - APP ID
/// 相机
FOUNDATION_EXPORT NSString * const TSACamerAppID;

#pragma mark - System Commands
/// 系统指令
FOUNDATION_EXPORT NSString * const TSSystemCommand;



#pragma mark - Auth Commands
/// 授权相关命令
FOUNDATION_EXPORT NSString * const TSAuthCommand;
/// 解绑命令
FOUNDATION_EXPORT NSString *const TSUnbindKey;
/// 绑定命令
FOUNDATION_EXPORT NSString *const TSBindKey;
/// 登录命令
FOUNDATION_EXPORT NSString *const TSLoginKey;

#pragma mark - Device Commands
/// 设备相关命令
FOUNDATION_EXPORT NSString *const TSDeviceCommand;
/// 设备信息键
FOUNDATION_EXPORT NSString *const TSDeviceInfoKey;
/// 电池信息键
FOUNDATION_EXPORT NSString *const TSDeviceBatteryKey;
/// OTA 失败
FOUNDATION_EXPORT NSString *const TSDeviceOTAFailedKey;
/// 寻找手机键
FOUNDATION_EXPORT NSString *const TSDeviceFindPhoneKey;
/// 停止寻找手机键
FOUNDATION_EXPORT NSString *const TSDeviceStopFindPhoneKey;
/// 查找手表键
FOUNDATION_EXPORT NSString *const TSDeviceFindWatchKey;
/// 停止查找手表键
FOUNDATION_EXPORT NSString *const TSDeviceStopFindWatchKey;
/// 找到手表键
FOUNDATION_EXPORT NSString *const TSDeviceWatchHasBeenFoundKey;
/// 配置改变键
FOUNDATION_EXPORT NSString *const TSDeviceConfigChangeKey;
/// 蓝牙状态键
FOUNDATION_EXPORT NSString *const TSDeviceBtStatusKey;
/// 语言设置键
FOUNDATION_EXPORT NSString *const TSDeviceLanguageSetKey;
/// 语言获取
FOUNDATION_EXPORT NSString *const TSDeviceLanguageGetKey;
/// 语言结果键
FOUNDATION_EXPORT NSString *const TSDeviceLanguageResultKey;
/// 重启设备键
FOUNDATION_EXPORT NSString *const TSDeviceRebootKey;
/// 关机键
FOUNDATION_EXPORT NSString *const TSDeviceShutdownKey;
/// 重启
FOUNDATION_EXPORT NSString *const TSDeviceResetKey;


#pragma mark - Navigation Commands
/// 导航相关命令
FOUNDATION_EXPORT NSString *const TSNavCommand;
/// 导航退出键
FOUNDATION_EXPORT NSString *const TSNavExitKey;

#pragma mark - Contacts Commands
/// 联系人相关命令
FOUNDATION_EXPORT NSString *const TSContactsCommand;
/// 联系人列表键
FOUNDATION_EXPORT NSString *const TSContactsListKey;
/// 更新
FOUNDATION_EXPORT NSString *const TSContactsUpdateKey;

/// 紧急联系人
FOUNDATION_EXPORT NSString *const TSContactsEmergencyCommand;

/// App Store
FOUNDATION_EXPORT NSString *const TSAppStoreCommand;
FOUNDATION_EXPORT NSString *const TSAppAppListKey;
FOUNDATION_EXPORT NSString *const TSAppInstalledKey;
FOUNDATION_EXPORT NSString *const TSAppUninstalledKey;

/// 祈祷
FOUNDATION_EXPORT NSString *const TSPrayersStatusKey;
FOUNDATION_EXPORT NSString *const TSPrayersListKey;

/// Female Health
FOUNDATION_EXPORT NSString *const TSFemaleHealthCommand;

#pragma mark - Files Commands
/// 文件相关命令
FOUNDATION_EXPORT NSString *const TSFilesCommand;
/// 文件列表键
FOUNDATION_EXPORT NSString *const TSFilesListKey;

#pragma mark - Dial Commands
/// 表盘相关命令
FOUNDATION_EXPORT NSString *const TSDialCommand;
/// 所有小部件键
FOUNDATION_EXPORT NSString *const TSDialWidgetsAllKey;
/// 删除自定义表盘
FOUNDATION_EXPORT NSString *const TSDialWidgetDeleteKey;
/// 删除表盘键
FOUNDATION_EXPORT NSString *const TSDialBeenDeletedKey;
/// 切换表盘键
FOUNDATION_EXPORT NSString *const TSDialBeenSwitchedKey;

#pragma mark - Camera Commands
/// 相机相关命令
FOUNDATION_EXPORT NSString *const TSCameraCommand;
/// 快门键
FOUNDATION_EXPORT NSString *const TSCameraShutterKey;
/// 进入拍照键
FOUNDATION_EXPORT NSString *const TSCameraEnterKey;
/// 退出拍照键
FOUNDATION_EXPORT NSString *const TSCameraExitKey;

#pragma mark - HTTP Commands
/// HTTP相关命令
FOUNDATION_EXPORT NSString *const TSHttpCommand;
/// HTTP请求键
FOUNDATION_EXPORT NSString *const TSHttpRequestKey;


#pragma mark - Notification Commands
/// 消息通知
FOUNDATION_EXPORT NSString *const TSNotificationCommand;
FOUNDATION_EXPORT NSString *const TSNotificationTelephoneCommand;


#pragma mark - Clocks Commands
/// 闹钟指令
FOUNDATION_EXPORT NSString *const TSAlarmsCommand;
/// 修改闹钟
FOUNDATION_EXPORT NSString *const TSAlarmsModifyKey;
/// 世界时钟
FOUNDATION_EXPORT NSString *const TSWorldClockCommand;


#pragma mark - Unit
/// 天气单位
FOUNDATION_EXPORT NSString *const TSWeatherUnitKey;
/// 天气开关
FOUNDATION_EXPORT NSString *const TSWeatherEnableKey;
/// 时间单位
FOUNDATION_EXPORT NSString *const TSTimeUnitKey;
/// 长度单位
FOUNDATION_EXPORT NSString *const TSLengthUnitKey;
/// 重量单位
FOUNDATION_EXPORT NSString *const TSWeightUnitKey;
/// 穿戴习惯
FOUNDATION_EXPORT NSString *const TSWearHabitKey;
/// 抬腕亮屏
FOUNDATION_EXPORT NSString *const TSRaiseWakeUpKey;
/// 午休免打扰
FOUNDATION_EXPORT NSString *const TSDoNotDisturbKey;

#pragma mark - UserInfo
FOUNDATION_EXPORT NSString *const TSUserAgetKey;
FOUNDATION_EXPORT NSString *const TSUserSextKey;
FOUNDATION_EXPORT NSString *const TSUserWeightKey;
FOUNDATION_EXPORT NSString *const TSUserHeightKey;


#pragma mark - Reminders
FOUNDATION_EXPORT NSString *const TSReminderCommand;
FOUNDATION_EXPORT NSString *const TSReminderIndexCommand;


#pragma mark - HealthMonitor
/// 健康监测指令
FOUNDATION_EXPORT NSString *const TSHealthMeasureCommand;
/// 心率监测
FOUNDATION_EXPORT NSString *const TSHealthMeasureHRKey;
/// 血压监测
FOUNDATION_EXPORT NSString *const TSHealthMeasureBPKey;
/// 血氧监测
FOUNDATION_EXPORT NSString *const TSHealthMeasureBOKey;
/// 压力监测
FOUNDATION_EXPORT NSString *const TSHealthMeasureStressKey;
/// 心率poolName
FOUNDATION_EXPORT NSString *const TSHealthMeasureHRValueKey;
/// 血压poolName
FOUNDATION_EXPORT NSString *const TSHealthMeasureBPValueKey;
/// 血氧poolName
FOUNDATION_EXPORT NSString *const TSHealthMeasureBOValueKey;
/// 压力poolName
FOUNDATION_EXPORT NSString *const TSHealthMeasureStressValueKey;

#pragma mark - AutoMonitorSetting
/// 心率配置
FOUNDATION_EXPORT NSString *const TSHRAutoMonitorCommand;
/// 血压配置
FOUNDATION_EXPORT NSString *const TSBPAutoMonitorCommand;
/// 血氧配置
FOUNDATION_EXPORT NSString *const TSBOAutoMonitorCommand;
/// 压力配置
FOUNDATION_EXPORT NSString *const TSStressAutoMonitorCommand;
/// 睡眠配置
FOUNDATION_EXPORT NSString *const TSSleepAutoMonitorCommand;

#pragma mark -  Electronic Card
/// 电子钱包
FOUNDATION_EXPORT NSString *const TSEWalletCommand;
/// 电子名片
FOUNDATION_EXPORT NSString *const TSEBusinessCardCommand;

#pragma mark - DailyExercise
/// 活动时间
FOUNDATION_EXPORT NSString *const TSDailyExStandTimeKey;
/// 步数
FOUNDATION_EXPORT NSString *const TSDailyExStepsKey;
/// 运动时间
FOUNDATION_EXPORT NSString *const TSDailyExSportTimeKey;
/// 运动次数
FOUNDATION_EXPORT NSString *const TSDailyExSportNumKey;
/// 热量
FOUNDATION_EXPORT NSString *const TSDailyExCaloriesKey;
/// 距离
FOUNDATION_EXPORT NSString *const TSDailyExDistanceKey;
///
FOUNDATION_EXPORT NSString *const TSDailyExSitTimeKey;

#pragma mark - FWDataBasePath
/// 静息心率
FOUNDATION_EXPORT NSString *const TSDataBaseRestHRPathKey;
/// 历史心率
FOUNDATION_EXPORT NSString *const TSDataBaseHistoryHRPathKey;
/// 手动测量心率
FOUNDATION_EXPORT NSString *const TSDataBaseManualHRPathKey;
/// 血压
FOUNDATION_EXPORT NSString *const TSDataBaseBPPathKey;
/// 血氧
FOUNDATION_EXPORT NSString *const TSDataBaseBOPathKey;
/// 手动测量血氧
FOUNDATION_EXPORT NSString *const TSDataBaseManualBOPathKey;
/// 压力
FOUNDATION_EXPORT NSString *const TSDataBaseStressPathKey;
/// 睡眠
FOUNDATION_EXPORT NSString *const TSDataBaseSleepPathKey;
/// 每日活动数据
FOUNDATION_EXPORT NSString *const TSDataBaseDailyExercisePathKey;
/// 运动数据总结
FOUNDATION_EXPORT NSString *const TSDataBaseSportSummaryPathKey;
/// 运动数据详情
FOUNDATION_EXPORT NSString *const TSDataBaseSportDetailPathKey;



@end



NS_ASSUME_NONNULL_END
