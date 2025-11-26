//
//  TSPeripheralFindVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralFindVC.h"

@interface TSPeripheralFindVC ()

@property (nonatomic,strong) UIAlertController *alert ;

@end

@implementation TSPeripheralFindVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerCallBack];
    
}

- (void)registerCallBack{
    // 外设查找手机
    
    [[[TopStepComKit sharedInstance] peripheralFind] registerPeripheralFindPhone:^{
        TSLog(@"PeripheralFindPhone");
        // 检查 alert 是否已经在展示中，避免重复展示
        if (!self.presentedViewController) {
            [self presentViewController:self.alert animated:YES completion:nil];
        } else {
            TSLog(@"Alert already presented, skipping presentation");
        }
    }];

    // 外设结束查找手机
    [[[TopStepComKit sharedInstance] peripheralFind] registerPeripheralStopFindPhone:^{
        TSLog(@"PeripheralStopFindPhone");
        // 检查 alert 是否已经在展示中，只有在展示状态才需要关闭
        if (self.presentedViewController == self.alert) {
            [self.alert dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [[[TopStepComKit sharedInstance] peripheralFind]registerPeripheralHasBeenFound:^{
        [TSToast showText:@"设备已经被找到" onView:self.view dismissAfterDelay:1.5f];
    }];
}


- (UIAlertController *)alert{
    if (!_alert) {
        _alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                    message:@"设备正在查找手机"
                                                             preferredStyle:UIAlertControllerStyleAlert];

       [_alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction * _Nonnull action) {
           [self notifyPeripheralThatPhoneHasBeenFound];
       }]];

    }
    return _alert;
}

- (NSArray *)sourceArray{
    return @[
        [TSValueModel valueWithName:@"iPhone开始查找设备"],
        [TSValueModel valueWithName:@"iPhone结束查找设备"],
        [TSValueModel valueWithName:@"iPhone已经被找到"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self beginFindPeripheral];
    }else if (indexPath.row == 1){
        [self stopFindPeripheral];
    }else{
        [self notifyPeripheralThatPhoneHasBeenFound];
    }
}

- (void)beginFindPeripheral{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] peripheralFind] beginFindPeripheral:^(BOOL isSuccess, NSError *error) {
        TSLog(@"beginFindPeripheralCompletion %d error:%@",isSuccess,error);
    }];
}

- (void)stopFindPeripheral{
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] peripheralFind] stopFindPeripheral:^(BOOL isSuccess, NSError *error) {
        TSLog(@"stopFindPeripheralCompletion %d error:%@",isSuccess,error);
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast showText:@"结束查找" onView:strongSelf.view dismissAfterDelay:1.5f];
    }];
}

- (void)notifyPeripheralThatPhoneHasBeenFound{
    [[[TopStepComKit sharedInstance] peripheralFind] notifyPeripheralPhoneHasBeenFound:^(BOOL isSuccess, NSError *error) {
        TSLog(@"notifyPeripheralPhoneHasBeenFoundCompletion %d error:%@",isSuccess,error);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
