//
//  WMWidgetModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMWidgetType) {
    WMWidgetTypeWidgetMusic = 1, // 音乐 （MUSICIANS）
    WMWidgetTypeWidgetActivityRecord, // 活动记录（日常活动） （Activity record (daily activities)）
    WMWidgetTypeWidgetHeartRate, // 心率 （Heart rate）
    WMWidgetTypeWidgetBloodOxygen, // 血氧 （Blood oxygen）
    WMWidgetTypeWidgetBreathTrain, // 呼吸训练 （Breathing training）
    WMWidgetTypeWidgetSport, // 运动 （movement）
    WMWidgetTypeWidgetSportRecord, // 运动记录 （movement record）
    WMWidgetTypeWidgetNotifyMsg, // 消息 （message）
    WMWidgetTypeWidgetAlarm, // 闹钟 （Alarm clock）
    WMWidgetTypeWidgetPhone, // 电话 （telephone）
    WMWidgetTypeWidgetSleep, // 睡眠 （Sleep）
    WMWidgetTypeWidgetWeather, // 天气 （weather）
    WMWidgetTypeWidgetFindPhone, // 寻找手机 （Find the phone）
    WMWidgetTypeWidgetCalculator, // 计算器 （The Reckoner）
    WMWidgetTypeWidgetRemoteCamera, // 遥控相机 （Remote control camera）
    WMWidgetTypeWidgetStopWatch, // 秒表 （Second watch）
    WMWidgetTypeWidgetTimer, // 计时器(倒计时) （Timer (countdown)）
    WMWidgetTypeWidgetFlashLight, // 手电筒 （Flashlight）
    WMWidgetTypeWidgetSetting, // 设置 （Settings）
};

@interface WMWidgetModel : NSObject

/// 数组元素为 WMWidgetType （The array element is WMWidgetType）
@property (nonatomic, strong) NSArray<NSNumber *> *widgets;

@end

NS_ASSUME_NONNULL_END
