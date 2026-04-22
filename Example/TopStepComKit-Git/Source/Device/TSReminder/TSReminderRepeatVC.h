//
//  TSReminderRepeatVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSReminderRepeatVC : TSRootVC

@property (nonatomic, assign) TSRemindersRepeat selectedDays;
@property (nonatomic, copy) void(^onDaysChanged)(TSRemindersRepeat days);

@end

NS_ASSUME_NONNULL_END
