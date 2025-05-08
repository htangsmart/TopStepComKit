//
//  TSPeripheralDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralDialVC.h"

@interface TSPeripheralDialVC ()

@end

@implementation TSPeripheralDialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self registerCallBack];
}

- (void)registerCallBack {
    [[[TopStepComKit sharedInstance] dial] registerDialDidChangedBlock:^(TSDialModel * _Nonnull dial) {
        
    }];
    
    [[[TopStepComKit sharedInstance] dial] registerDialDidDeletedBlock:^(TSDialModel * _Nonnull dial) {
        
    }];
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取当前表盘"],
        [TSValueModel valueWithName:@"获取所有表盘"],
        [TSValueModel valueWithName:@"推送云端表盘"],
        [TSValueModel valueWithName:@"推送自定义表盘"],
        [TSValueModel valueWithName:@"删除云端表盘"],
        [TSValueModel valueWithName:@"删除自定义表盘"],
        [TSValueModel valueWithName:@"获取预留空间"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self getCurrentDial];
    } else if(indexPath.row == 1){
        [self getAllDials];
    } else if(indexPath.row == 2){
        [self pushCloudDial];
    } else if(indexPath.row == 3){
        [self pushCustomerDial];
    } else if(indexPath.row == 4){
        [self deleteCloudDial];
    } else if(indexPath.row == 5){
        [self deleteCustomDial];
    } else if(indexPath.row == 6){
        [self getRemainSpace];
    }else{
        [self switchDial];
    }
}
- (void)getCurrentDial {
    [[[TopStepComKit sharedInstance] dial] getCurrentDialWithCompletion:^(TSDialModel * _Nullable dial, NSError * _Nullable error) {
        
    }];
}

- (void)getAllDials {
    [[[TopStepComKit sharedInstance] dial] getAllDialsWithCompletion:^(NSArray<TSDialModel *> * _Nonnull dials, NSError * _Nullable error) {
        
    }];
}

- (void)pushCloudDial{
    TSFitDialModel *cloudDial = [TSFitDialModel new];
    
    [[[TopStepComKit sharedInstance] dial] pushCloudDial:cloudDial progressBlock:^(TSDialPushResult result, NSInteger progress) {
        
    } completion:^(TSDialPushResult result, NSError * _Nullable error) {
        
    }];
}
- (void)pushCustomerDial{
    
    TSFitDialModel *customeDial = [TSFitDialModel new];

    [[[TopStepComKit sharedInstance] dial] pushCustomDial:customeDial progressBlock:^(TSDialPushResult result, NSInteger progress) {
        
    } completion:^(TSDialPushResult result, NSError * _Nullable error) {
        
    }];
}

- (void)deleteCloudDial{
    TSFitDialModel *cloudDial = [TSFitDialModel new];
    [[[TopStepComKit sharedInstance] dial] deleteCloudDial:cloudDial completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

- (void)deleteCustomDial{
    
    TSFitDialModel *customeDial = [TSFitDialModel new];

    [[[TopStepComKit sharedInstance] dial] deleteCustomDial:customeDial completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
    
}

- (void)getRemainSpace{
    
    [[[TopStepComKit sharedInstance] dial] getWatchFaceRemainingStorageSpaceWithCompletion:^(NSInteger remainSpace, NSError * _Nullable error) {
        
    }];
}

- (void)switchDial{
    
    TSFitDialModel *dial = [TSFitDialModel new];

    [[[TopStepComKit sharedInstance] dial] switchToDial:dial completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

@end
