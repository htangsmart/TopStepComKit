//
//  TSBloodOxygenVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBloodOxygenVC.h"

@interface TSBloodOxygenVC ()

@end

@implementation TSBloodOxygenVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步血氧数据"],

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
    [[[TopStepComKit sharedInstance] bloodOxygen] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSBOValueModel *> * _Nullable hrValues, NSError * _Nullable error) {
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
    [[[TopStepComKit sharedInstance] bloodOxygen] getAutoMonitorConfigsCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
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
    TSHRAutoMonitorConfigs *config = [TSHRAutoMonitorConfigs new];
    config.isEnabled = YES;
    
    [[[TopStepComKit sharedInstance] bloodOxygen] setAutoMonitorWithConfigs:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"setAutoMonitorConfigs success: %d error: %@",isSuccess ,error.debugDescription);
    }];
}

- (void)startActivityMeasure{
    
    if (![[[TopStepComKit sharedInstance] bloodOxygen] isSupportActivityMeasureByUser]) {
        // 不支持
        return;
    }

    TSActivityMeasureParam *measureParam = [TSActivityMeasureParam new];
    measureParam.measureItem = TSMeasureItemBloodOxygen;
    measureParam.maxMeasureDuration = 30;
    measureParam.interval = 10;
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] bloodOxygen] startMeasureWithParam:measureParam dataBlock:^(NSArray<TSHealthValueModel *> * _Nonnull values) {
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

    [[[TopStepComKit sharedInstance] bloodOxygen] stopMeasureCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];

        TSLog(@"stopActivityMeasure success %d error %@",isSuccess,error.debugDescription);
    }];
}

@end
