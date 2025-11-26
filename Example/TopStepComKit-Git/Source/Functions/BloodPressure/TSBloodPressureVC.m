//
//  TSBloodPressureVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBloodPressureVC.h"

@interface TSBloodPressureVC ()

@end

@implementation TSBloodPressureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步血压数据"],

        [TSValueModel valueWithName:@"获取自动监测设置"],
        [TSValueModel valueWithName:@"设置自动监测设置"],
        
        [TSValueModel valueWithName:@"开始自动测量"],
        [TSValueModel valueWithName:@"结束自动测量"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncValue];
    } else if (indexPath.row == 1) {
        [self queryAutoMonitorConfigs];
    } else if (indexPath.row == 2) {
        [self setAutoMonitorConfigs];
    }  else if (indexPath.row == 3) {
        [self startActivityMeasure];
    }  else if (indexPath.row == 4) {
        [self stopActivityMeasure];
    }
}

- (void)syncValue{

    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodPressure] syncRawDataFromStartTime:0 completion:^(NSArray<TSBPValueItem *> * _Nullable hrValues, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncValue error is %@",error.debugDescription);
            return;
        }
        for (TSHRValueItem *hrValue in hrValues) {
            TSLog(@"syncValue hrValue is : %@",hrValue.debugDescription);
        }
    }];
}


- (void)queryAutoMonitorConfigs{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodPressure] fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorBPConfigs * _Nullable configuration, NSError * _Nullable error) {
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
    TSAutoMonitorBPConfigs *config = [TSAutoMonitorBPConfigs new];
    config.schedule.enabled = YES;
    
    [[[TopStepComKit sharedInstance] bloodPressure] pushAutoMonitorConfigs:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"setAutoMonitorConfigs success: %d error: %@",isSuccess ,error.debugDescription);
    }];
}

- (void)startActivityMeasure{
    
    if (![[[TopStepComKit sharedInstance] bloodPressure] isSupportActivityMeasureByUser]) {
        // 不支持
        return;
    }

    TSActivityMeasureParam *measureParam = [TSActivityMeasureParam new];
    measureParam.measureType = TSMeasureTypeBloodOxygen;
    measureParam.maxMeasureDuration = 30;
    measureParam.interval = 10;
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodPressure] startMeasureWithParam:measureParam startHandler:^(BOOL success, NSError * _Nullable error) {
        
    } dataHandler:^(TSBPValueItem * _Nullable data, NSError * _Nullable error) {
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

    [[[TopStepComKit sharedInstance] bloodPressure] stopMeasureCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        TSLog(@"stopActivityMeasure success %d error %@",isSuccess,error.debugDescription);
    }];
}


@end
