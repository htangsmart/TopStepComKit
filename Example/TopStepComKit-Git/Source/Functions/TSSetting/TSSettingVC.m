//
//  TSSettingVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSettingVC.h"

@interface TSSettingVC ()

@end

@implementation TSSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"开关设置";
    [self registerCallBack];
}

- (void)registerCallBack {
    // 可以在这里添加其他回调注册
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"佩戴习惯设置-左手"],
        [TSValueModel valueWithName:@"佩戴习惯设置-右手"],
        [TSValueModel valueWithName:@"获取佩戴习惯"],

        [TSValueModel valueWithName:@"蓝牙断链提醒设置-打开"],
        [TSValueModel valueWithName:@"蓝牙断链提醒设置-关闭"],
        [TSValueModel valueWithName:@"获取蓝牙断链提醒设置"],

        [TSValueModel valueWithName:@"运动目标达标提醒-打开"],
        [TSValueModel valueWithName:@"运动目标达标提醒-关闭"],
        [TSValueModel valueWithName:@"获取运动目标达标提醒"],

        [TSValueModel valueWithName:@"抬腕亮屏设置-打开"],
        [TSValueModel valueWithName:@"抬腕亮屏设置-关闭"],
        [TSValueModel valueWithName:@"获取抬腕亮屏设置"],

        [TSValueModel valueWithName:@"来电响铃设置-打开"],
        [TSValueModel valueWithName:@"来电响铃设置-关闭"],
        [TSValueModel valueWithName:@"获取来电响铃设置"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        [self setHobbitLeft];
    } else if (indexPath.row == 1) {
        [self setHobbitRight];
    } else if (indexPath.row == 2) {
        [self getHobbit];
        
        
    } else if (indexPath.row == 3) {
        [self setDisBlutOpen];
    } else if (indexPath.row == 4) {
        [self setDisBlutClose];
    } else if (indexPath.row == 5) {
        [self getDisBlut];

        
    } else if (indexPath.row == 6) {
        [self setActivityGoalOpen];
    } else if (indexPath.row == 7) {
        [self setActivityGoalClose];
    } else if (indexPath.row == 8) {
        [self getActivityGoal];

        
    } else if (indexPath.row == 9) {
        [self setWWOpen];
    } else if (indexPath.row == 10) {
        [self setWWClose];
    } else if (indexPath.row == 11) {
        [self getWW];
        
        
    }else if (indexPath.row == 12) {
        [self setRingOepn];
    } else if (indexPath.row == 13) {
        [self setRingClose];
    } else if (indexPath.row == 14) {
        [self getRing];
    }
    
}


- (void)setHobbitLeft {

    [[[TopStepComKit sharedInstance] setting] setWearingHabit:TSWearingHabitLeft completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)setHobbitRight {
    [[[TopStepComKit sharedInstance] setting] setWearingHabit:TSWearingHabitRight completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)getHobbit {
    [[[TopStepComKit sharedInstance] setting] getCurrentWearingHabit:^(TSWearingHabit habit, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:[NSString stringWithFormat:@"获取佩戴习惯失败: %@", error.localizedDescription] onView:self.view dismissAfterDelay:1.0f];
        }else{
            [TSToast showText:[NSString stringWithFormat:@"获取佩戴习惯成功: %ld", (long)habit] onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}



- (void)setDisBlutOpen {
    [[[TopStepComKit sharedInstance] setting] setBluetoothDisconnectionVibration:YES completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)setDisBlutClose {
    [[[TopStepComKit sharedInstance] setting] setBluetoothDisconnectionVibration:NO completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];

}

- (void)getDisBlut {
    
    [[[TopStepComKit sharedInstance] setting]getBluetoothDisconnectionVibrationStatus:^(BOOL enabled, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:[NSString stringWithFormat:@"获取蓝牙断链提示失败: %@", error.localizedDescription] onView:self.view dismissAfterDelay:1.0f];
        }else{
            [TSToast showText:[NSString stringWithFormat:@"获取蓝牙断链提示成功: %ld", (long)enabled] onView:self.view dismissAfterDelay:1.0f];
        }

    }];
}


- (void)setActivityGoalOpen {
    [[[TopStepComKit sharedInstance] setting] setExerciseGoalReminder:YES completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)setActivityGoalClose {
    [[[TopStepComKit sharedInstance] setting] setExerciseGoalReminder:NO completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)getActivityGoal {
    [[[TopStepComKit sharedInstance] setting] getExerciseGoalReminderStatus:^(BOOL enabled, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:[NSString stringWithFormat:@"获取达标提醒失败: %@", error.localizedDescription] onView:self.view dismissAfterDelay:1.0f];
        }else{
            [TSToast showText:[NSString stringWithFormat:@"获取达标提醒成功: %ld", (long)enabled] onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}



- (void)setWWOpen {
    TSWristWakeUpModel *model = [TSWristWakeUpModel new];
    model.isEnable = YES;
    model.begin = 360;// 早6点
    model.end = 1200;// 20点
    [[[TopStepComKit sharedInstance] setting] setRaiseWristToWake:model completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)setWWClose {
    TSWristWakeUpModel *model = [TSWristWakeUpModel new];
    model.isEnable = NO;
    model.begin = 360;// 早6点
    model.end = 1200;// 20点
    [[[TopStepComKit sharedInstance] setting] setRaiseWristToWake:model completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)getWW {
    
    [[[TopStepComKit sharedInstance] setting] getRaiseWristToWakeStatus:^(TSWristWakeUpModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:[NSString stringWithFormat:@"获取抬腕提醒失败: %@", error.localizedDescription] onView:self.view dismissAfterDelay:1.0f];
        }else{
            [TSToast showText:[NSString stringWithFormat:@"获取抬腕提醒成功: %@", model.debugDescription] onView:self.view dismissAfterDelay:3.0f];
        }
    }];
}


- (void)setRingOepn {
    [[[TopStepComKit sharedInstance] setting] setCallRing:YES completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];

}

- (void)setRingClose {
    [[[TopStepComKit sharedInstance] setting] setCallRing:NO completion:^(BOOL success, NSError * _Nullable error) {
        [TSToast showText:success?@"设置成功":@"设置失败" onView:self.view dismissAfterDelay:1.0f];
    }];
}

- (void)getRing {
    
    
    [[[TopStepComKit sharedInstance] setting] getCallRingStatus:^(BOOL enabled, NSError * _Nullable error) {
        if (error) {
            [TSToast showText:[NSString stringWithFormat:@"获取来电提醒设置失败: %@", error.localizedDescription] onView:self.view dismissAfterDelay:1.0f];
        }else{
            [TSToast showText:[NSString stringWithFormat:@"获取来电提醒设置成功: %ld", (long)enabled] onView:self.view dismissAfterDelay:1.0f];
        }

    }];
}

@end
