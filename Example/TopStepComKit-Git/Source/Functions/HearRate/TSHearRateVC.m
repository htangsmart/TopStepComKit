//
//  TSHearRateVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSHearRateVC.h"

@interface TSHearRateVC ()

@end

@implementation TSHearRateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步心率数据"],
        [TSValueModel valueWithName:@"同步静息心率数据"],

        [TSValueModel valueWithName:@"获取自动监测设置"],
        [TSValueModel valueWithName:@"设置自动监测设置"],
        
        [TSValueModel valueWithName:@"开始自动测量"],
        [TSValueModel valueWithName:@"结束自动测量"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncHRValue];
    } else if (indexPath.row == 1) {
        [self syncRestingHRValue];
    } else if (indexPath.row == 2) {
        [self queryAutoMonitorConfigs];
    }  else if (indexPath.row == 3) {
        [self setAutoMonitorConfigs];
    }  else if (indexPath.row == 4) {
        [self startActivityMeasure];
    }  else {
        [self stopActivityMeasure];
    }
}

- (void)syncHRValue{

    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate] syncRawDataFromStartTime:0 completion:^(NSArray<TSHRValueItem *> * _Nullable hrValues, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncHRValue error is %@",error.debugDescription);
            return;
        }
        for (TSHRValueItem *hrValue in hrValues) {
            TSLog(@"syncHRValue hrValue is : %@",hrValue.debugDescription);
        }
    }];
}

- (void)syncRestingHRValue{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate] syncRawRestingHeartRateDataFromStartTime:0 completion:^(NSArray<TSHRValueItem *> * _Nullable restingHRItems, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncRestingHRValue error is %@",error.debugDescription);
            return;
        }
        for (TSHRValueItem *hrValue in restingHRItems) {
            TSLog(@"syncRestingHRValue hrValue is : %@",hrValue.debugDescription);
        }
    }];
}

- (void)queryAutoMonitorConfigs{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] heartRate] fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorHRConfigs * _Nullable configuration, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        if (error) {
            TSLog(@"queryAutoMonitorConfigs error is %@",error.debugDescription);
            return;
        }
        TSLog(@"queryAutoMonitorConfigs configuration is : %@",configuration.debugDescription);
    }];
}

- (void)setAutoMonitorConfigs{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    TSAutoMonitorHRConfigs *config = [TSAutoMonitorHRConfigs new];
    config.schedule.enabled = YES;
    
    [[[TopStepComKit sharedInstance] heartRate] pushAutoMonitorConfigs:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"setAutoMonitorConfigs success: %d error: %@",isSuccess ,error.debugDescription);
    }];
}

- (void)startActivityMeasure{
    
    if (![[[TopStepComKit sharedInstance] heartRate] isSupportActivityMeasureByUser]) {
        // 不支持
        return;
    }

    TSActivityMeasureParam *measureParam = [TSActivityMeasureParam new];
    measureParam.measureType = TSMeasureTypeHeartRate;
    measureParam.maxMeasureDuration = 30;
    measureParam.interval = 10;
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    
    [[[TopStepComKit sharedInstance] heartRate] startMeasureWithParam:measureParam startHandler:^(BOOL success, NSError * _Nullable error) {
        
    } dataHandler:^(TSHRValueItem * _Nullable data, NSError * _Nullable error) {
        TSLog(@"startActivityMeasure vale is %d",data.debugDescription);
    } endHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"startActivityMeasure completion success %d error %@",isSuccess,error.debugDescription);
    }];

}

- (void)stopActivityMeasure{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] heartRate] stopMeasureCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        TSLog(@"stopActivityMeasure success %d error %@",isSuccess,error.debugDescription);
    }];
}

@end
