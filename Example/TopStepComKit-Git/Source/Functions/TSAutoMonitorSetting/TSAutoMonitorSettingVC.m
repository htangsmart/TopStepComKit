//
//  TSAutoMonitorSettingVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAutoMonitorSettingVC.h"

@interface TSAutoMonitorSettingVC ()

@end

@implementation TSAutoMonitorSettingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自动监测设置";
}

/**
 * 返回功能列表数组
 */
- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取心率设置"],
        [TSValueModel valueWithName:@"设置心率设置"],
        
        [TSValueModel valueWithName:@"获取血氧设置"],
        [TSValueModel valueWithName:@"设置血氧设置"],
        
        [TSValueModel valueWithName:@"获取压力设置"],
        [TSValueModel valueWithName:@"设置压力设置"],

    ];
}

/**
 * 表格点击事件处理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self getHRSettings];
    }else if(indexPath.row == 1){
        [self setHRSettings];
    }else if (indexPath.row == 2){
        [self getOxySettings];

    }else if (indexPath.row == 3){
        [self setOxySettings];

    }else if (indexPath.row == 4){
        [self getStressSettings];

    }else{
        [self setStressSettings];

    }
}



/**
 * 设置当前系统时间到设备
 */
- (void)getHRSettings {

    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate] getAutoMonitorConfigsCompletion:^(TSHRAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"获取心率设置失败: %@", error);
        } else {
            TSLog(@"获取心率设置成功: %@", configuration.debugDescription);
        }
    }];
}

- (TSHRAutoMonitorConfigs *)hrSettings {
    // 返回心率设置模型
    TSHRAutoMonitorConfigs *model = [[TSHRAutoMonitorConfigs alloc] init];
    model.isEnabled = YES; // 示例值
    model.startTime = 480; // 示例值，8 AM
    model.endTime = 1200; // 示例值，8 PM
    model.interval = 1; // 示例值，30分钟
    model.restHRWarnEnabled = YES; // 示例值
    model.restHeartRateMax = 100; // 示例值
    model.restHeartRateMin = 60; // 示例值
    model.exerciseHRWarnEnabled = YES; // 示例值
    model.exerciseHeartRateMax = 180; // 示例值
    model.exerciseHeartRateMin = 100; // 示例值
    return model;
}


- (void)setHRSettings {
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    
    [[[TopStepComKit sharedInstance] heartRate] setAutoMonitorWithConfigs:[self hrSettings] completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        if (isSuccess) {
            TSLog(@"设置心率设置成功");
        } else {
            TSLog(@"设置心率设置失败: %@", error);
        }
    }];
}

- (void)getOxySettings {
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] bloodOxygen] getAutoMonitorConfigsCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        if (error) {
            TSLog(@"获取血氧设置失败: %@", error);
        } else {
            TSLog(@"获取血氧设置成功: %@", configuration.debugDescription);
        }
    }];
}

- (TSAutoMonitorConfigs *)oxySettings {
    // 返回血氧设置模型
    TSAutoMonitorConfigs *model = [[TSAutoMonitorConfigs alloc] init];
    model.monitorType = eTSMonitorTypeBloodOxygen;
    model.isEnabled = YES; // 示例值
    model.startTime = 480; // 示例值，8 AM
    model.endTime = 1200; // 示例值，8 PM
    model.interval = 2; // 示例值，30分钟
    return model;
}

- (void)setOxySettings {
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    TSAutoMonitorConfigs *setting = [self oxySettings];
    [[[TopStepComKit sharedInstance] bloodOxygen] setAutoMonitorWithConfigs:setting completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        if (isSuccess) {
            TSLog(@"设置血氧设置成功");
            TSLog(@"获取血氧设置成功: %@", setting.debugDescription);
        } else {
            TSLog(@"设置血氧设置失败: %@", error);
        }
    }];
}

- (void)getStressSettings {
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    
    [[[TopStepComKit sharedInstance] stress] getAutoMonitorConfigsCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"获取压力设置失败: %@", error);
        } else {
            TSLog(@"获取压力设置成功: %@", configuration.debugDescription);
        }
    }];
}


- (TSAutoMonitorConfigs *)stressSettings {
    // 返回压力设置模型
    TSAutoMonitorConfigs *model = [[TSAutoMonitorConfigs alloc] init];
    model.monitorType = eTSMonitorTypeStress;
    model.isEnabled = YES; // 示例值
    model.startTime = 480; // 示例值，8 AM
    model.endTime = 1200; // 示例值，8 PM
    model.interval = 3; // 示例值，30分钟
    return model;
}

- (void)setStressSettings {
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] stress] setAutoMonitorWithConfigs:[self stressSettings] completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (isSuccess) {
            TSLog(@"设置压力设置成功");
        } else {
            TSLog(@"设置压力设置失败: %@", error);
        }
    }];
}


@end
