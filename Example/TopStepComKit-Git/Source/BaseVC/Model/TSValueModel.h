//
//  TSValueModel.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TSKitType) {
    eTSKitDefault,
    eTSKitLog,
    eTSKitBle,
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

};

NS_ASSUME_NONNULL_BEGIN

@interface TSValueModel : NSObject

@property (nonatomic,strong) NSString * valueName;

@property (nonatomic,assign) TSKitType kitType;

@property (nonatomic,strong) NSString * vcName;

+ (instancetype)valueWithName:(NSString *)valueName ;

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType;

+ (instancetype)valueWithName:(NSString *)valueName kitType:(TSKitType)kitType vcName:(NSString *)vcName;

@end

NS_ASSUME_NONNULL_END
