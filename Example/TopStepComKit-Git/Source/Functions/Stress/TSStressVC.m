//
//  TSStressVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSStressVC.h"

@interface TSStressVC ()

@end

@implementation TSStressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步压力数据"],

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
    [[[TopStepComKit sharedInstance] stress] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSStressValueModel *> * _Nullable hrValues, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        if (error) {
            TSLog(@"syncValue error is %@",error.debugDescription);
            return;
        }
        for (TSHRValueModel *hrValue in hrValues) {
            TSLog(@"syncValue hrValue is : %@",hrValue.debugDescription);
        }
    }];
}


- (void)queryAutoMonitorConfigs{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] stress] getAutoMonitorConfigsCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
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
    TSBPAutoMonitorConfigs *config = [TSBPAutoMonitorConfigs new];
    config.isEnabled = YES;
    
    [[[TopStepComKit sharedInstance] stress] setAutoMonitorWithConfigs:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"setAutoMonitorConfigs success: %d error: %@",isSuccess ,error.debugDescription);
    }];
}

- (void)startActivityMeasure{
    
    if (![[[TopStepComKit sharedInstance] stress] isSupportActivityMeasureByUser]) {
        // 不支持
        return;
    }

    TSActivityMeasureParam *measureParam = [TSActivityMeasureParam new];
    measureParam.measureItem = TSMeasureItemBloodOxygen;
    measureParam.maxMeasureDuration = 30;
    measureParam.interval = 10;
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] stress] startMeasureWithParam:measureParam dataBlock:^(NSArray<TSHealthValueModel *> * _Nonnull values) {
        for (TSHealthValueModel *value in values) {
            TSLog(@"startActivityMeasure vale is %d",value.debugDescription);
        }
    } completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"startActivityMeasure completion success %d error %@",isSuccess,error.debugDescription);
    }];
}

- (void)stopActivityMeasure{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] stress] stopMeasureCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        TSLog(@"stopActivityMeasure success %d error %@",isSuccess,error.debugDescription);
    }];
}


@end
