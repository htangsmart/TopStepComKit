//
//  TSValueModel.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TSKitType) {
    eTSKitDefault,
    eTSKitLog,
    eTSKitBle,
    eTSKitPeripheralInfo,
    eTSKitHR,
    eTSKitBP,
    eTSKitBO,
    eTSKitStress,
    eTSKitSleep,
    eTSKitTemp,
    eTSKitECG,
    eTSKitSport,
    eTSKitDailyActivity,
    eTSKitDataSync,
    eTSKitFind,
    eTSKitTakePhoto,
    eTSKitContact,
    eTSKitAlarmClock,
    eTSKitExerciseGoal,
    eTSKitLanguage,
    eTSKitUserInfo,
    eTSKitMessage,
    eTSKitFileOTA,
    eTSKitWeather,
    eTSKitPeripheralDial,
    eTSKitRemoteControl,
    eTSKitUnit,
    eTSKitSetting,
    eTSKitBattery,
    eTSKitTime,
    eTSKitReminder,
    eTSKitAutoMonitor,
    eTSKitActivityMeasure,
    eTSKitWorldClock,
};

NS_ASSUME_NONNULL_BEGIN

@interface TSValueModel : NSObject

@property (nonatomic, strong) NSString *valueName;
@property (nonatomic, assign) TSKitType kitType;
@property (nonatomic, strong, nullable) NSString *vcName;

// 现代卡片 UI 扩展属性
@property (nonatomic, strong, nullable) NSString *iconName;    // SF Symbol 名称
@property (nonatomic, strong, nullable) NSString *subtitle;    // 功能副标题说明
@property (nonatomic, strong, nullable) UIColor  *iconColor;   // 图标背景色

+ (instancetype)valueWithName:(NSString *)valueName;

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType;

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType vcName:(NSString *)vcName;

+ (instancetype)valueWithName:(NSString *)valueName
                      kitType:(TSKitType)kitType
                       vcName:(NSString *)vcName
                     iconName:(nullable NSString *)iconName
                    iconColor:(nullable UIColor *)iconColor
                     subtitle:(nullable NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
