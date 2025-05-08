//
//  TSReminderVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSReminderVC.h"

@interface TSReminderVC ()

@end

@implementation TSReminderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提醒设置";
}

/**
 * 返回功能列表数组
 */
- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置提醒设置"],
        [TSValueModel valueWithName:@"获取提醒设置"],
    ];
}

/**
 * 表格点击事件处理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self setReminders];
    }else{
        [self getReminders];
    }
}

- (NSArray <TSRemindersModel *>*)reminders{
    TSRemindersModel *pointsRemind = [[TSRemindersModel alloc]init];
    pointsRemind.reminderId = @"1001";
    pointsRemind.reminderName = @"做作业提醒";
    pointsRemind.isEnabled = YES;
    pointsRemind.reminderType = ReminderTypeCustom;
    pointsRemind.timeType = ReminderTimeTypePoint;
    pointsRemind.timePoints = @[@(360),@(720)];
    pointsRemind.isNoDisturb = YES;
    pointsRemind.noDisturbStartTime = 720;
    pointsRemind.noDisturbStartTime = 780;
    pointsRemind.notes = @"这是一个时间点的提醒";
    
    
    TSRemindersModel *rangeRemind = [[TSRemindersModel alloc]init];
    rangeRemind.reminderId = @"1002";
    rangeRemind.reminderName = @"吃饭提醒";
    rangeRemind.isEnabled = YES;
    rangeRemind.reminderType = ReminderTypeCustom;
    rangeRemind.timeType = ReminderTimeTypePeriod;
    rangeRemind.startTime = 360;
    rangeRemind.endTime = 1200;

    rangeRemind.isNoDisturb = YES;
    rangeRemind.noDisturbStartTime = 720;
    rangeRemind.noDisturbStartTime = 780;
    rangeRemind.notes = @"这是一个时间段的提醒";

    return @[pointsRemind,rangeRemind];
}


- (void)setReminders {
    [TSToast showText:@"正在设置提醒..." onView:self.view dismissAfterDelay:1.0f];

    [[[TopStepComKit sharedInstance] reminder] setReminders:[self reminders] completion:^(BOOL isSuccess, NSError * _Nullable error) {
        
        if (isSuccess) {
            TSLog(@"设置成功");
        }else{
            TSLog(@"设置失败：%@",error.debugDescription);
        }
    }];
}


- (void)getReminders {
    
    [TSToast showText:@"正在获取提醒..." onView:self.view];
    
    [[[TopStepComKit sharedInstance] reminder] getAllRemindersWithCompletion:^(NSArray<TSRemindersModel *> * _Nonnull reminders, NSError * _Nonnull error) {
        [TSToast dismissLoadingOnView:self.view];
        if (reminders && reminders.count<=0) {
            [TSToast showText:@"没有获取到提醒..." onView:self.view dismissAfterDelay:1.0f];
            return;
        }
        for (TSRemindersModel *remind in reminders) {
            TSLog(@"remind is %@",remind.debugDescription);
        }
    }];
    
}

@end
