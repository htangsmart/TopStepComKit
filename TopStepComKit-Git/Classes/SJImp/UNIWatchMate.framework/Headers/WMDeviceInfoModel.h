//
//  WMDeviceInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WMFeature) {
    WMFeatureWeatherSync = 0,        // 天气同步开关 （Weather sync switch）
    WMFeatureFitnessRecord,          // 健身记录 （Fitness record）
    WMFeatureHeartRate,              // 心率 （Heart rate）
    WMFeatureCameraRemoteV1,         // 相机遥控器（V1）（Camera Remote Control (V1)）
    WMFeatureNotificationManagement, // 通知管理 （Notification management）
    WMFeatureAlarmSetting,           // 闹钟设置 （Alarm setting）
    WMFeatureLocalMusicSync,         // 本地音乐同步 （Local music synchronization）
    WMFeatureContactSync,            // 联系人同步 （Contact synchronization）
    WMFeatureFindWatch,              // 查找手表 （Find a watch）
    WMFeatureFindPhone,              // 查找手机 （Find your phone）
    WMFeatureAppViewSetting,         // 【设置】应用视图 （[Settings] Application view）
    WMFeatureIncomingCallRing,       // 【设置】来电响铃 （【 Setting 】 The incoming call rings）
    WMFeatureNotificationFeedback,   // 【设置】通知触感 （[Settings] Notification touch）
    WMFeatureCrownFeedback,          // 【设置】表冠触感反馈 （[Settings] Crown touch feedback）
    WMFeatureSystemFeedback,         // 【设置】系统触感反馈 （[Settings] System touch feedback）
    WMFeatureWristWakeScreen,        // 【设置】抬腕亮屏 （[Settings] Raise the wrist and light the screen）
    WMFeatureBloodOxygen,            // 血氧 （Blood oxygen）
    WMFeatureBloodPressure,          // 血压 （Blood pressure）
    WMFeatureBloodSugar,             // 血糖 （Blood Sugar）
    WMFeatureSleepTracking,          // 睡眠（设置+数据）（Sleep (Settings + Data)）
    WMFeatureEbookSync,              // 电子书同步 （E-book synchronization）
    WMFeatureSlowMode,               // 是否是慢速模式（w20a） （Is it Slow mode (w20a)?）
    WMFeatureCameraRemotePreview,    // 相机遥控器支持预览 （Camera remote supports preview）
    WMFeatureVideoFileSync,          // 视频文件同步（avi） （Video File Synchronization (avi)）
    WMFeaturePaymentCode,            // 收款码 （Collection code）
    WMFeatureWatchFaceMarket,        // 表盘市场 （Dial market）
    WMFeatureNotificationExpansion,  // 通知列表是否全部展开 （Whether the notification list is fully expanded）
    WMFeatureCallBluetooth,          // 通话蓝牙 （Talking bluetooth）
    WMFeatureShowCallBluetoothOff,   // 显示关闭通话蓝牙 （Displays Bluetooth off call）
    WMFeatureEmergencyContacts,      // 紧急联系人 （Emergency contact）
    WMFeatureSyncFavContacts,        // 同步收藏联系人 （Synchronize favorites contacts）
    WMFeatureQuickReply,             // 快捷回复 （Quick reply）
    WMFeatureStepGoal,               // 步数目标 （Step goal）
    WMFeatureCalorieGoal,            // 卡路里目标 （Calorie target）
    WMFeatureExerciseDurationGoal,   // 活动时长目标 （Activity duration objective）
    WMFeatureSedentaryReminder,      // 久坐提醒 （Sedentary reminder）
    WMFeatureDrinkWaterReminder,     // 喝水提醒 （Drink water reminder）
    WMFeatureHandWashingReminder,    // 洗手提醒 （Hand-washing reminder）
    WMFeatureAutoHeartRateMonitoring,// 心率自动检测 （Automatic heart rate detection）
    WMFeatureREMSleepTracking,       // REM快速眼动  （REM rapid eye movement）
    WMFeatureMultipleSportModes,     // 是否支持多种运动 （Whether to support multiple sports）
    WMFeatureFixedSportTypes,        // 显示固定运动类型 （Displays fixed motion types）
    WMFeatureAutoSportRecognitionStart, // 运动自识别开始 （Motion begins with self-recognition）
    WMFeatureAutoSportRecognitionEnd,   // 运动自识别结束 （The motion self-recognition ends）
    WMFeatureAlarmLabel,             // 闹钟标签 （Alarm label）
    WMFeatureAlarmNote,              // 闹钟备注 （Alarm clock note）
    WMFeatureWorldClock,             // 世界时钟 （World clock）
    WMFeatureAppSwitchDeviceLanguage,// app切换设备语言 （app switches device language）
    WMFeatureWidgets,                // 小部件 （widget）
    WMFeatureAppAdjustsDeviceVolume, // App调整设备音量 （The App adjusts the volume of the device）
    WMFeatureQuietHeartRateAlert,    // 安静心率过高提醒 （Quiet heart rate alert）
    WMFeatureExerciseHeartRateAlert, // 运动心率过高提醒 （Exercise heart rate is too high alert）
    WMFeatureDailyHeartRateAlert,    // 日常心率过高提醒 （Daily heart rate alerts）
    WMFeatureContinuousBloodOxygen,  // 连续血氧 （Continuous oxygen）
    WMFeatureBluetoothDisconnectionAlert, // 蓝牙断连提醒设置 （Bluetooth disconnection reminder setting）
    WMFeatureCallBluetoothBLENameMatching, // 通话蓝牙与BLE是否同名 （Whether call Bluetooth has the same name as BLE）
    WMFeatureEventReminder,          // 事件提醒 （Event reminder）
    WMFeatureScreenOnReminder,       // 亮屏提醒 （Light up reminder）
    WMFeatureRestartDevice,          // 重启设备 （Restart the device）
    
    WMFeatureNavigation = 64,        // 导航 （Navigation）
    WMFeatureCompass = 65,            // 指南针 （Compass）
    WMFeatureMusilin = 66            // 穆斯林 （musilin）
};


// 特性列表 （Feature list）
@interface WMFeatureSet : NSObject
- (instancetype)initWithData:(NSData *)data;
// 是否支持该功能 （Whether the function is supported）
- (BOOL)isFeatureEnabled:(WMFeature)feature;
@end


// 手表特性 （Watch characteristics）
@interface WMFeatureSetModel : NSObject
// 特性清单版本 （Feature list version）
@property (nonatomic, assign) NSInteger feature_version;
// 特性清单开关 （Characteristic list switch）
@property (strong, nonatomic) WMFeatureSet *feature_mask;
// 支持的最大联系人个数 （Maximum number of contacts supported）
@property (nonatomic, assign) NSInteger max_contacts;
// 侧按钮个数 （Number of side buttons）
@property (nonatomic, assign) NSInteger side_button_count;
// 固定运动个数 （Fixed number of movements）
@property (nonatomic, assign) NSInteger fixed_sport_count;
// 可变运动个数 （Variable number of motions）
@property (nonatomic, assign) NSInteger variable_sport_count;
@end


@interface WMDeviceBaseInfo : NSObject
/// 设备型号 （Equipment type）
@property (nonatomic, copy) NSString * _Nullable model;
/// 设备MAC地址 （Device MAC address）
@property (nonatomic, copy) NSString * _Nullable macAddress;
/// 设备版本 （Device version）
@property (nonatomic, copy) NSString * _Nullable version;
/// 设备ID （Device ID）
@property (nonatomic, copy) NSString * _Nullable deviceId;
/// 蓝牙名称 （Bluetooth name）
@property (nonatomic, copy) NSString * _Nullable bluetoothName;
/// 设备名称 （Device name）
@property (nonatomic, copy) NSString * _Nullable deviceName;
/// 其他参数 （Other parameters）
@property (nonatomic, strong) NSDictionary * _Nullable otherInfo;
@end


@interface WMDeviceBatteryModel : NSObject
/// 设备电量百分比0~100 （Device power percentage 0 to 100）
@property (nonatomic, assign) NSInteger battery;
/// 设备是否充电 （Whether the device is charged）
@property (nonatomic, assign) BOOL isCharging;
@end


/// 设备信息 （Device information）
@interface WMDeviceInfoModel : NSObject
/// 设备电量 （Equipment power）
@property (nonatomic, strong) RACSignal<WMDeviceBatteryModel *> *battery;
@property (nonatomic, assign, readonly) WMDeviceBatteryModel *batteryValue;
@property (nonatomic, strong, nullable) WMFeatureSetModel *featureSetModel;

/// 主动获取设备信息 （Proactively obtain device information）
- (RACSignal<WMDeviceBaseInfo *> *)wm_getBaseinfo;
/// 主动获取电量 （Active power acquisition）
- (RACSignal<WMDeviceBatteryModel *> *)wm_getBattery;
/// 主动获取特性 （Active acquisition characteristic）
- (RACSignal<WMFeatureSetModel *> *)wm_getFeatureSet;
@end

NS_ASSUME_NONNULL_END
