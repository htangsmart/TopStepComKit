//
//  TSAlarmEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSAlarmEditorVC;

@protocol TSAlarmEditorDelegate <NSObject>
- (void)alarmEditor:(TSAlarmEditorVC *)editor didSaveAlarm:(TSAlarmClockModel *)alarm;
- (void)alarmEditorDidCancel:(TSAlarmEditorVC *)editor;
@end

@interface TSAlarmEditorVC : TSRootVC

@property (nonatomic, weak) id<TSAlarmEditorDelegate> delegate;
@property (nonatomic, strong, nullable) TSAlarmClockModel *alarm; // nil = 新建

/// 设备是否支持闹钟类型（alarmClock.isSupportAlarmType）；YES 时显示「类型」行
@property (nonatomic, assign) BOOL typeSupported;
/// 设备支持的类型集合（fetchSupportedAlarmTypes: 的结果）；nil 表示未查询到，选择器视为全部可选
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *supportedTypes;

@end

NS_ASSUME_NONNULL_END
