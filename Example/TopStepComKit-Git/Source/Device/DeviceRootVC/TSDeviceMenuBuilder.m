//
//  TSDeviceMenuBuilder.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import "TSDeviceMenuBuilder.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSDeviceCoordinator.h"
#import "TSRootVC.h"
#import "TSValueModel.h"

/** 创建单个设备菜单模型 */
static TSValueModel *TSDeviceMenuItem(NSString *title,
                                      TSKitType kitType,
                                      NSString *viewControllerName,
                                      NSString *iconName,
                                      UIColor *iconColor,
                                      NSString *subtitle,
                                      BOOL enabled) {
    TSValueModel *model = [TSValueModel valueWithName:title
                                              kitType:kitType
                                               vcName:viewControllerName
                                             iconName:iconName
                                            iconColor:iconColor
                                             subtitle:subtitle];
    model.enabled = enabled;
    return model;
}

@implementation TSDeviceMenuBuilder

#pragma mark - 公开方法

/** 根据连接快照构建全部设备菜单 */
+ (NSArray<NSArray<TSValueModel *> *> *)sectionDataWithSnapshot:(TSDeviceConnectionSnapshot *)snapshot {
    BOOL ready = snapshot.isReady;
    TSFeatureAbility *ability = snapshot.peripheral.capability.featureAbility;
    TopStepComKit *sdk = [TopStepComKit sharedInstance];

    NSArray<TSValueModel *> *featureItems = @[
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.health_measure"), eTSKitActivityMeasure,
                         @"TSActivityMeasureVC", @"heart.circle.fill", TSColor_Pink,
                         TSLocalizedString(@"device.menu.health_measure.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.ai_guidance"), eTSKitAI,
                         @"TSAIDailyGuidanceVC", @"sparkles", TSColor_Teal,
                         TSLocalizedString(@"device.menu.ai_guidance.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.find"), eTSKitFind,
                         @"TSPeripheralFindVC", @"location.fill", TSColor_Primary,
                         TSLocalizedString(@"device.menu.find.sub"), ready && ability.isSupportFindMyPhone),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.camera"), eTSKitTakePhoto,
                         @"TSTakePhotoVC", @"camera.fill", TSColor_Teal,
                         TSLocalizedString(@"device.menu.camera.sub"),
                         ready && (ability.isSupportShakeCamera || ability.isSupportCameraPreview)),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.contacts"), eTSKitContact,
                         @"TSContactVC", @"person.2.fill", TSColor_Primary,
                         TSLocalizedString(@"device.menu.contacts.sub"), ready && ability.isSupportContacts),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.alarm"), eTSKitAlarmClock,
                         @"TSAlarmClockVC", @"alarm.fill", TSColor_Warning,
                         TSLocalizedString(@"device.menu.alarm.sub"), ready && ability.isSupportAlarmClock),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.world_clock"), eTSKitWorldClock,
                         @"TSWorldClockVC", @"globe", TSColor_Teal,
                         TSLocalizedString(@"device.menu.world_clock.sub"), ready && ability.isSupportWorldClock),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.music"), eTSKitMusic,
                         @"TSMusicVC", @"music.note", TSColor_Primary,
                         TSLocalizedString(@"device.menu.music.sub"), ready && ability.isSupportMusic),
        TSDeviceMenuItem(@"Audio Recordings", eTSKitDefault, @"TSMediaFileVC", @"waveform", TSColor_Indigo,
                         @"List, download, and delete device recordings", ready && sdk.mediaFile.isSupport),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.equalizer"), eTSKitEqualizer,
                         @"TSEqualizerVC", @"slider.horizontal.3", TSColor_Purple,
                         TSLocalizedString(@"device.menu.equalizer.sub"), ready && ability.isSupportEqualizer),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.message"), eTSKitMessage,
                         @"TSMessageVC", @"bell.fill", TSColor_Danger,
                         TSLocalizedString(@"device.menu.message.sub"), ready && ability.isSupportAppNotifications),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.weather"), eTSKitWeather,
                         @"TSWeatherVC", @"cloud.sun.fill", TSColor_Primary,
                         TSLocalizedString(@"device.menu.weather.sub"), ready && ability.isSupportWeatherDisplay),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.dial"), eTSKitPeripheralDial,
                         @"TSPeripheralDialVC", @"clock.fill", TSColor_Indigo,
                         TSLocalizedString(@"device.menu.dial.sub"),
                         ready && (ability.isSupportFacePush || ability.isSupportCustomFace)),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.workout_push"), eTSKitWorkoutPush,
                         @"TSWorkoutPushVC", @"figure.run.circle.fill", TSColor_Success,
                         TSLocalizedString(@"device.menu.workout_push.sub"), ready && sdk.workout.isSupport),
        TSDeviceMenuItem(@"互联运动", eTSKitSport, @"TSCompanionWorkoutVC", @"figure.run", TSColor_Success,
                         @"App 与手表实时协同运动", ready && sdk.companionWorkout.isSupport),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.ota"), eTSKitFileOTA,
                         @"TSFileOTAVC", @"arrow.down.circle.fill", TSColor_Success,
                         TSLocalizedString(@"device.menu.ota.sub"), ready && ability.isSupportFirmwareUpgrade),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.glasses"), eTSKitActivityMeasure,
                         @"TSGlassesVC", @"eye.fill", TSColor_Teal,
                         TSLocalizedString(@"device.menu.glasses.sub"), NO),
    ];

    NSArray<TSValueModel *> *settingsItems = @[
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.user_info"), eTSKitUserInfo,
                         @"TSUserInfoVC", @"person.fill", TSColor_Primary,
                         TSLocalizedString(@"device.menu.user_info.sub"), ready && ability.isSupportUserInfoSettings),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.daily_goal"), eTSKitExerciseGoal,
                         @"TSDailyExerciseGoalVC", @"flag.fill", TSColor_Warning,
                         TSLocalizedString(@"device.menu.daily_goal.sub"), ready && ability.isSupportDailyActivity),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.language"), eTSKitLanguage,
                         @"TSLanguagesVC", @"globe", TSColor_Primary,
                         TSLocalizedString(@"device.menu.language.sub"), ready && ability.isSupportLanguage),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.unit"), eTSKitUnit,
                         @"TSUnitVC", @"textformat", TSColor_Gray,
                         TSLocalizedString(@"device.menu.unit.sub"), ready && ability.isSupportUnitSettings),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.setting"), eTSKitSetting,
                         @"TSSettingVC", @"gear", TSColor_Gray,
                         TSLocalizedString(@"device.menu.setting.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.time"), eTSKitTime,
                         @"TSTimeVC", @"clock.fill", TSColor_Primary,
                         TSLocalizedString(@"device.menu.time.sub"), ready && ability.isSupportTimeSettings),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.reminder"), eTSKitReminder,
                         @"TSReminderVC", @"bell.circle.fill", TSColor_Danger,
                         TSLocalizedString(@"device.menu.reminder.sub"), ready && ability.isSupportReminders),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.lock"), eTSKitPeripheralLock,
                         @"TSPeripheralLockVC", @"lock.fill", TSColor_Gray,
                         TSLocalizedString(@"device.menu.lock.sub"),
                         ready && (ability.isSupportGameLock || ability.isSupportScreenLock)),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.auto_monitor"), eTSKitAutoMonitor,
                         @"TSAutoMonitorSettingVC", @"chart.bar.fill", TSColor_Gray,
                         TSLocalizedString(@"device.menu.auto_monitor.sub"), ready && ability.isSupportHeartRate),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.battery"), eTSKitBattery,
                         @"TSBatteryVC", @"battery.100", TSColor_Success,
                         TSLocalizedString(@"device.menu.battery.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.device_info"), eTSKitPeripheralInfo,
                         @"TSPeripheralInfoVC", @"info.circle.fill", TSColor_Gray,
                         TSLocalizedString(@"device.menu.device_info.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.device_log"), eTSKitLog,
                         @"TSDeviceLogVC", @"doc.text.fill", TSColor_Indigo,
                         TSLocalizedString(@"device.menu.device_log.sub"), ready && ability.isSupportDeviceLog),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.ai_kit"), eTSKitAI,
                         @"TSAIKitRootVC", @"brain.head.profile", TSColor_Purple,
                         TSLocalizedString(@"device.menu.ai_kit.sub"), ready),
    ];

    NSArray<TSValueModel *> *dangerItems = @[
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.remote_control"), eTSKitRemoteControl,
                         @"TSRemoteControlVC", @"hand.raised.fill", TSColor_Purple,
                         TSLocalizedString(@"device.menu.remote_control.sub"), ready),
        TSDeviceMenuItem(TSLocalizedString(@"device.menu.unbind"), eTSKitDefault,
                         nil, @"trash.fill", TSColor_Danger,
                         TSLocalizedString(@"device.menu.unbind.sub"), ready || snapshot.hasBinding),
    ];

    return @[featureItems, settingsItems, dangerItems];
}

@end
