//
//  TSUserInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSUserInfoVC.h"

@interface TSUserInfoVC ()


@end

@implementation TSUserInfoVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCallBack];
}



#pragma mark - Callback

- (void)registerCallBack {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] userInfo] registerUserInfoDidChangedBlock:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
        if (error) {
            TSLog(@"用户信息监听失败: %@", error.localizedDescription);
//            //[TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        if (userInfo) {
            TSLog(@"用户信息发生改变: %@", userInfo.debugDescription);
//            //[TSToast showText:@"用户信息已更新" onView:weakSelf.view dismissAfterDelay:1.0f];
        }
    }];
}

#pragma mark - TableView DataSource & Delegate

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置用户信息"],
        [TSValueModel valueWithName:@"获取用户信息"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self setUserInfo];
    } else if (indexPath.row == 1) {
        [self getUserInfo];
    }
}

#pragma mark - Private Methods


- (TSUserInfoModel *)userInfo {
    TSUserInfoModel *user = [[TSUserInfoModel alloc] init];
    user.name = @"张三";
    user.gender = TSUserGenderMale;
    user.age = 18;
    user.weight = 55;
    user.height = 166;
    return user;
}

#pragma mark - Network Methods

- (void)setUserInfo {
    TSUserInfoModel *userInfo = [self userInfo];
    
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] userInfo] setUserInfo:userInfo completion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            TSLog(@"设置用户信息失败: %@", error.localizedDescription);
//            //[TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"设置用户信息成功");
//        //[TSToast showText:@"设置用户信息成功" onView:weakSelf.view dismissAfterDelay:1.0f];
    }];
}

- (void)getUserInfo {
    
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] userInfo] getUserInfoWithCompletion:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
        
        if (error) {
            TSLog(@"获取用户信息失败: %@", error.localizedDescription);
//            //[TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        if (userInfo) {
            TSLog(@"获取用户信息成功: %@", userInfo.debugDescription);
//            //[TSToast showText:@"获取用户信息成功" onView:weakSelf.view dismissAfterDelay:1.0f];
        } else {
//            //[TSToast showText:@"未获取到用户信息" onView:weakSelf.view dismissAfterDelay:2.0f];
        }
    }];
}

@end
