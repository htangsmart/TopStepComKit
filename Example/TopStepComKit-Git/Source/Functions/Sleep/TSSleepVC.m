//
//  TSSleepVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSSleepVC.h"

@interface TSSleepVC ()

@end

@implementation TSSleepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"同步睡眠数据"],

        [TSValueModel valueWithName:@"获取自动监测设置"],
        [TSValueModel valueWithName:@"设置自动监测设置"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncValue];
    } else if (indexPath.row == 1) {
        [self queryAutoMonitorConfigs];
    } else if (indexPath.row == 2) {
        [self setAutoMonitorConfigs];
    }
}

- (void)syncValue{

    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] sleep] syncHistoryDataFormStartTime:0 completion:^(NSArray<TSStressValueModel *> * _Nullable hrValues, NSError * _Nullable error) {
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
    
    [[[TopStepComKit sharedInstance] sleep] getAutoMonitorConfigsCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
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
    
    [[[TopStepComKit sharedInstance] sleep] setAutoMonitorWithConfigs:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"setAutoMonitorConfigs success: %d error: %@",isSuccess ,error.debugDescription);
    }];
}



@end
