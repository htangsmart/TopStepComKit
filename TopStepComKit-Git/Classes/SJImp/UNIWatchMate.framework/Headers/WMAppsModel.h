//
//  WMAppsModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDialAppModel.h"
#import "WMFileAppModel.h"
#import "WMAlarmAppModel.h"
#import "WMContactsAppModel.h"
#import "WMWeatherForecastAppModel.h"
#import "WMConfigMotionAppModel.h"
#import "WMConfigHeartRateAppModel.h"
#import "WMFindAppModel.h"
#import "WMCameraAppModel.h"
#import "WMNavigationAppModel.h"
#import "WMMusilinAppModel.h"
#import "WMGlassesVideoModel.h"


NS_ASSUME_NONNULL_BEGIN

/// 设备应用 （Equipment application）
@interface WMAppsModel : NSObject

/// 表盘 （Dial plate）
@property (nonatomic, strong) WMDialAppModel *dialApp;
/// 文件传输 （File transfer）
@property (nonatomic, strong) WMFileAppModel *fileApp;
/// 闹钟 （Alarm clock）
@property (nonatomic, strong) WMAlarmAppModel *alarmApp;
/// 通讯录 （Address book）
@property (nonatomic, strong) WMContactsAppModel *contactsApp;
/// 天气预报 （Weather forecast）
@property (nonatomic, strong) WMWeatherForecastAppModel *weatherForecastApp;
/// 运动项目配置 （Allocation of sports items）
@property (nonatomic, strong) WMConfigMotionAppModel *configMotionApp;
/// 心率 （Heart rate）
@property (nonatomic, strong) WMConfigHeartRateAppModel *configHeartRateApp;
/// 查找 （Look up）
@property (nonatomic, strong) WMFindAppModel *findApp;
/// 相机 （Camera）
@property (nonatomic, strong) WMCameraAppModel *cameraApp;
/// 手表视频预览 （Watch Video Preview）
@property (nonatomic, strong) WMGlassesVideoModel *watchGlassesVideoApp;
/// 导航 （Navigation）
@property (nonatomic, strong) WMNavigationAppModel *navigationApp;

@property (nonatomic, strong) WMMusilinAppModel *musilinApp;
@end

NS_ASSUME_NONNULL_END
