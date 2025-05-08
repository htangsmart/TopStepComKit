//
//  TSRemoteControlVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSRemoteControlVC.h"
#import <TopStepToolKit/TopStepToolKit.h>

@interface TSRemoteControlVC ()

@end

@implementation TSRemoteControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"远程控制";
    [self registerCallBack];
}

- (void)registerCallBack {
    // 可以在这里添加其他回调注册
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"关机"],
        [TSValueModel valueWithName:@"重启"],
        [TSValueModel valueWithName:@"恢复出厂设置"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self showAlertWithTitle:@"关机确认" 
                       message:@"确定要关闭设备吗？" 
                    completion:^{
            [self turnOff];
        }];
    } else if(indexPath.row == 1) {
        [self showAlertWithTitle:@"重启确认" 
                       message:@"确定要重启设备吗？" 
                    completion:^{
            [self reStart];
        }];
    } else {
        [self showAlertWithTitle:@"恢复出厂设置确认" 
                       message:@"恢复出厂设置将清除设备所有数据，确定要继续吗？" 
                    completion:^{
            [self reset];
        }];
    }
}

/**
 * 显示确认对话框
 */
- (void)showAlertWithTitle:(NSString *)title 
                  message:(NSString *)message 
               completion:(void(^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 关闭设备
 */
- (void)turnOff {
    [TSToast showText:@"正在关闭设备..." onView:self.view dismissAfterDelay:1.0f];
    
    [[[TopStepComKit sharedInstance] remoteControl] powerOffWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [TSToast showText:@"设备已关闭" onView:self.view dismissAfterDelay:1.0f];
        } else {
            [TSToast showText:@"关闭设备失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

/**
 * 重启设备
 */
- (void)reStart {
    
    [TSToast showText:@"正在重启设备..." onView:self.view dismissAfterDelay:1.0f];

    [[[TopStepComKit sharedInstance] remoteControl] restartDeviceWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [TSToast showText:@"设备已重启" onView:self.view dismissAfterDelay:1.0f];
        } else {
            [TSToast showText:@"重启设备失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

/**
 * 恢复出厂设置
 */
- (void)reset {
    
    [TSToast showText:@"正在恢复出厂设置..." onView:self.view dismissAfterDelay:1.0f];

    [[[TopStepComKit sharedInstance] remoteControl] resetToFactoryWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            [TSToast showText:@"设备已恢复出厂设置" onView:self.view dismissAfterDelay:1.0f];
        } else {
            [TSToast showText:@"恢复出厂设置失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

@end

