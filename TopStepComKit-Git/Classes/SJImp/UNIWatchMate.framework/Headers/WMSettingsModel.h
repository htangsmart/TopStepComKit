//
//  WMSettingsModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMSportGoalSettingModel.h"
#import "WMUnitInfoSettingModel.h"
#import "WMPersonalInfoSettingModel.h"
#import "WMLanguageSettingModel.h"
#import "WMReminderSettingModel.h"
#import "WMDateTimeSettingModel.h"
#import "WMSwitchsSettingModel.h"
#import "WMAppViewSettingModel.h"
#import "WMSleepSettingModel.h"
#import "WMMessageSettingModel.h"
#import "WMWidgetSettingModel.h"
#import "WMLocationSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 功能设置 （Function setting）
@interface WMSettingsModel : NSObject
/// 运动目标设置 （Moving goal setting）
@property (nonatomic, strong) WMSportGoalSettingModel *sportGoal;
/// 计量单位设置 （Unit setting）
@property (nonatomic, strong) WMUnitInfoSettingModel *unitInfo;
/// 个人信息设置 （Personal information setting）
@property (nonatomic, strong) WMPersonalInfoSettingModel *personalInfo;
/// 语言设置 （Language setting）
@property (nonatomic, strong) WMLanguageSettingModel *language;
/// 喝水提醒设置 （Drink water reminder Settings）
@property (nonatomic, strong) WMReminderSettingModel *waterReminder;
/// 久坐提醒设置 （Sedentary reminder Settings）
@property (nonatomic, strong) WMReminderSettingModel *sedentaryReminder;
/// 时间设置 （Time setting）
@property (nonatomic, strong) WMDateTimeSettingModel *dateTime;
/// 经纬度设置 （Time setting）
@property (nonatomic, strong) WMLocationSettingModel *location;
/// 开关设置 （Switch setting）
@property (nonatomic, strong) WMSwitchsSettingModel *switchs;
/// app视图设置 （app view Settings）
@property (nonatomic, strong) WMAppViewSettingModel *appView;
/// 睡眠设置 （Sleep setting）
@property (nonatomic, strong) WMSleepSettingModel *sleep;
/// 消息设置 （Message setting）
@property (nonatomic, strong) WMMessageSettingModel *message;
/// 组件设置 （Component setup）
@property (nonatomic, strong) WMWidgetSettingModel *widget;

@end

NS_ASSUME_NONNULL_END
