//
//  TSAlarmClockVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmClockVC.h"

@interface TSAlarmClockVC ()

@end

@implementation TSAlarmClockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self registerCallBack];
}

- (void)registerCallBack {
    [[[TopStepComKit sharedInstance] alarmClock] registerAlarmClocksDidChangedBlock:^(NSArray<TSAlarmClockModel *> *_Nonnull allAlarmClocks, NSError *_Nonnull error) {
        TSLog(@"闹钟变化回调: %@", allAlarmClocks);

        if (allAlarmClocks && allAlarmClocks.count > 0) {
            // 打印闹钟变化详情
            [self logAlarms:allAlarmClocks];
            [TSToast     showText:@"闹钟发生改变"
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            // 获取详细的错误信息
            NSString *errorMessage = error.localizedDescription;

            if (error.userInfo) {
            // 如果有详细的错误信息，优先使用
                if (error.userInfo[NSLocalizedDescriptionKey]) {
                    errorMessage = error.userInfo[NSLocalizedDescriptionKey];
                }

            // 打印完整的错误信息用于调试
                TSLog(@"闹钟监听错误: domain=%@, code=%ld, userInfo=%@",
                      error.domain,
                      (long)error.code,
                      error.userInfo);
            }

            [TSToast     showText:errorMessage
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置闹钟"],
        [TSValueModel valueWithName:@"获取所有闹钟"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self setAlarmClocks];
    } else {
        [self getAlarmClocks];
    }
}

- (NSArray <TSAlarmClockModel *> *)allAlarmClocks {
    // 闹钟标签数组
    NSArray *alarmLabels = @[@"起床", @"吃药", @"运动", @"喝水", @"午休",
                             @"开会", @"学习", @"遛狗", @"看书", @"睡觉"];

    NSMutableArray *alarms = [NSMutableArray arrayWithCapacity:5];

    // 生成5个随机闹钟
    for (NSInteger i = 0; i < 3; i++) {
        TSAlarmClockModel *alarm = [[TSAlarmClockModel alloc] init];

        // 设置闹钟ID (0-255)
        alarm.alarmId = i;

        // 随机设置闹钟标签
        NSInteger labelIndex = arc4random_uniform((uint32_t)alarmLabels.count);
        alarm.label = alarmLabels[labelIndex];

        // 随机设置时间 (0-23小时, 0-59分钟)
        NSInteger hour = arc4random_uniform(24);
        NSInteger minute = arc4random_uniform(60);
        [alarm setHour:hour minute:minute];

        // 随机设置重复选项
        TSAlarmRepeat repeatOptions = TSAlarmRepeatNone;

        // 33%的概率不重复
        // 33%的概率工作日重复
        // 33%的概率随机选择重复日期
        NSInteger repeatType = arc4random_uniform(3);

        switch (repeatType) {
            case 0:
                repeatOptions = TSAlarmRepeatNone;
                break;

            case 1:
                repeatOptions = TSAlarmRepeatWorkday;
                break;

            case 2: {
                // 随机选择1-7天重复
                for (int j = 0; j < 7; j++) {
                    if (arc4random_uniform(2)) { // 50%概率选中每一天
                        repeatOptions |= (1 << j);
                    }
                }

                // 如果一天都没选中，至少选中一天
                if (repeatOptions == TSAlarmRepeatNone) {
                    repeatOptions |= (1 << (arc4random_uniform(7)));
                }

                break;
            }
        }
        alarm.repeatOptions = repeatOptions;

        // 随机设置开关状态 (80%概率开启)
        alarm.isOn = (arc4random_uniform(100) < 80);

        // 随机设置是否支持稍后提醒 (50%概率支持)
        alarm.supportRemindLater = (arc4random_uniform(2) == 1);

        [alarms addObject:alarm];
    }

    return [alarms copy];
}

- (void)setAlarmClocks {
    [[[TopStepComKit sharedInstance] alarmClock] setAllAlarmClocks:[self allAlarmClocks]
                                                        completion:^(BOOL success, NSError *_Nullable error) {
        if (success) {
            TSLog(@"设置闹钟成功");
            [TSToast     showText:@"设置闹钟成功"
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            TSLog(@"设置闹钟失败: %@", error.localizedDescription);
            [TSToast     showText:[NSString stringWithFormat:@"设置闹钟失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (void)getAlarmClocks {
    [[[TopStepComKit sharedInstance] alarmClock] getAllAlarmClocksCompletion:^(NSArray<TSAlarmClockModel *> *_Nullable allAlarmClocks, NSError *_Nullable error) {
        if (allAlarmClocks) {
            [self logAlarms:allAlarmClocks];
            [TSToast     showText:[NSString stringWithFormat:@"获取闹钟成功: %lu个", (unsigned long)allAlarmClocks.count]
                           onView:self.view
                dismissAfterDelay:1.0f];
        } else {
            TSLog(@"获取闹钟失败: %@", error.localizedDescription);
            [TSToast     showText:[NSString stringWithFormat:@"获取闹钟失败: %@", error.localizedDescription]
                           onView:self.view
                dismissAfterDelay:1.0f];
        }
    }];
}

- (void)logAlarms:(NSArray *)allAlarmClocks {
    // 遍历打印每个闹钟的详细信息
    TSLog(@"获取闹钟成功，共%lu个闹钟:", (unsigned long)allAlarmClocks.count);
    [allAlarmClocks enumerateObjectsUsingBlock:^(TSAlarmClockModel *_Nonnull alarm, NSUInteger idx, BOOL *_Nonnull stop) {
        TSLog(@"闹钟%lu: ID=%d, 标签=%@, 时间=%ld:%ld, 重复=%d, 开启=%d",
              (unsigned long)idx,
              alarm.alarmId,
              alarm.label,
              (long)[alarm hour],
              (long)[alarm minute],
              alarm.repeatOptions,
              alarm.isOn);
    }];
}

@end
