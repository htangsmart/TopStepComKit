//
//  TSDataSyncVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/28.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDataSyncVC.h"

@interface TSDataSyncVC ()

// 本次同步逐类型累积的简报，用于结束时汇总展示
@property (nonatomic, strong) NSMutableArray<NSString *> *syncProgressLogs;

@end

@implementation TSDataSyncVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerCallBack];
}

- (void)registerCallBack{
}

#pragma mark - Table

- (NSArray *)sourceArray{
    return @[
        [TSValueModel valueWithName:TSLocalizedString(@"data_sync.title")],
        [TSValueModel valueWithName:@"取消同步"],
        [TSValueModel valueWithName:TSLocalizedString(@"data_sync.resting_hr")],
        [TSValueModel valueWithName:TSLocalizedString(@"data_sync.today_activity")]
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self beginSyncData];
    }else if (indexPath.row == 1){
        [self cancelSyncData];
    }else if (indexPath.row == 2){
        [self beginSyncRestHR];
    }else{
        [self beginSyncDailyExercise];
    }
}

#pragma mark - Sync

- (void)beginSyncData{

    if ([[[TopStepComKit sharedInstance] dataSync] isSyncing]) {
        [self showAlertWithTitle:@"提示" message:@"正在同步中，请勿重复触发"];
        return;
    }

    self.syncProgressLogs = [NSMutableArray array];

    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    TSDataSyncConfig *config = [[TSDataSyncConfig alloc] init];
    config.granularity = TSDataGranularityDay;
    config.startTime = 1771776000;// 2026-02-23 00:00:00
    config.endTime = nowTime;
    config.options = TSDataSyncOptionAll;// 全部类型，也可指定任意具体类型

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] dataSync]
     syncDataWithConfig:config
     onHealthData:^(TSHealthData *typeData) {
        // 每类型完成回调一次（主线程）：区分成功 / 单类型失败
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *name = [strongSelf nameForOption:typeData.option];
        NSString *line = nil;
        if (typeData.fetchError) {
            line = [NSString stringWithFormat:@"✗ %@ 失败: %@", name, typeData.fetchError.localizedDescription];
        } else {
            line = [NSString stringWithFormat:@"✓ %@ 完成, %lu 条", name, (unsigned long)typeData.healthValues.count];
        }
        TSLog(@"[DataSyncVC] onHealthData %@", line);
        [strongSelf.syncProgressLogs addObject:line];
    }
     completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        // 整体结束：致命 error / 取消 / 正常
        __strong typeof(weakSelf) strongSelf = weakSelf;
        TSLog(@"[DataSyncVC] completion results=%lu error=%@", (unsigned long)results.count, error);
        NSString *detail = [strongSelf.syncProgressLogs componentsJoinedByString:@"\n"];
        if (error) {
            if (error.code == eTSErrorSyncCancelled) {
                [strongSelf showAlertWithTitle:@"已取消"
                                       message:[NSString stringWithFormat:@"已完成 %lu 类后取消\n%@",
                                                (unsigned long)results.count, detail]];
            } else {
                [strongSelf showAlertWithTitle:@"同步失败"
                                       message:[NSString stringWithFormat:@"%@\n已到达: %@",
                                                error.localizedDescription, detail]];
            }
        } else {
            [strongSelf showAlertWithTitle:@"同步完成"
                                   message:[NSString stringWithFormat:@"共 %lu 类\n%@",
                                            (unsigned long)results.count, detail]];
        }
    }];
}

- (void)cancelSyncData{
    if (![[[TopStepComKit sharedInstance] dataSync] isSyncing]) {
        [self showAlertWithTitle:@"提示" message:@"当前没有正在进行的同步"];
        return;
    }
    // 即时受理：立刻返回，真正结束由 completion(取消错误) 通知
    [[[TopStepComKit sharedInstance] dataSync] cancelSync];
    TSLog(@"[DataSyncVC] cancelSync called");
    [self showAlertWithTitle:@"取消中" message:@"已发起取消，等待安全点结束…"];
}

- (void)beginSyncRestHR{
    // 保留占位（原静息心率单独接口示例）
}

- (void)beginSyncDailyExercise{
    // 保留占位（原今日活动单独接口示例）
}

#pragma mark - Helper

// option → 可读名（仅用于演示打印）
- (NSString *)nameForOption:(TSDataSyncOption)option{
    switch (option) {
        case TSDataSyncOptionHeartRate:     return @"心率";
        case TSDataSyncOptionBloodOxygen:   return @"血氧";
        case TSDataSyncOptionBloodPressure: return @"血压";
        case TSDataSyncOptionStress:        return @"压力";
        case TSDataSyncOptionSleep:         return @"睡眠";
        case TSDataSyncOptionTemperature:   return @"体温";
        case TSDataSyncOptionECG:           return @"心电";
        case TSDataSyncOptionSport:         return @"运动";
        case TSDataSyncOptionDailyActivity: return @"日常活动";
        case TSDataSyncOptionHeartRateVar:  return @"心率变异性";
        default:                            return [NSString stringWithFormat:@"类型(0x%lx)", (unsigned long)option];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
