//
//  TSAlarmEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSAlarmEditorVC;

@protocol TSAlarmEditorDelegate <NSObject>
- (void)alarmEditor:(TSAlarmEditorVC *)editor didSaveAlarm:(TSAlarmClockModel *)alarm;
- (void)alarmEditorDidCancel:(TSAlarmEditorVC *)editor;
@end

@interface TSAlarmEditorVC : UIViewController

@property (nonatomic, weak) id<TSAlarmEditorDelegate> delegate;
@property (nonatomic, strong, nullable) TSAlarmClockModel *alarm; // nil = 新建

@end

NS_ASSUME_NONNULL_END
