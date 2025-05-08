//
//  TSTakePhotoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTakePhotoVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

@interface TSTakePhotoVC ()

/** 记录当前是否在拍照模式 */
@property (nonatomic, assign) BOOL isInCameraMode;

@end

@implementation TSTakePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"远程拍照";
    self.isInCameraMode = NO;
    
    TSLogInfo(@"[Camera] 远程拍照页面已加载");
    [self registerCallBack];
}

- (void)registerCallBack {
    TSLogInfo(@"[Camera] 开始注册拍照相关回调");
    
    // 外设进入拍照
    [[[TopStepComKit sharedInstance] camera] registerPeripheralDidEnterCameraBlock:^{
        TSLogInfo(@"[Camera] 设备已进入拍照模式");
        self.isInCameraMode = YES;
        [TSToast showText:@"设备已进入拍照模式" onView:self.view dismissAfterDelay:1.0f];
    }];
    
    // 外设退出拍照
    [[[TopStepComKit sharedInstance] camera] registerPeripheralDidExitCameraBlock:^{
        TSLogInfo(@"[Camera] 设备已退出拍照模式");
        self.isInCameraMode = NO;
        [TSToast showText:@"设备已退出拍照模式" onView:self.view dismissAfterDelay:1.0f];
    }];
    
    // 外设执行了摇一摇
    [[[TopStepComKit sharedInstance] camera] registerPeripheralTakePhotoBlock:^{
        TSLogInfo(@"[Camera] 设备触发拍照");
        [TSToast showText:@"设备触发拍照" onView:self.view dismissAfterDelay:1.0f];
        // 这里可以添加实际的拍照逻辑
    }];
    
    TSLogInfo(@"[Camera] 拍照相关回调注册完成");
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"进入拍照"],
        [TSValueModel valueWithName:@"退出拍照"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self enterCamera];
    } else if (indexPath.row == 1) {
        [self exitCamera];
    }
}

/**
 * 进入拍照模式
 */
- (void)enterCamera {
    if (self.isInCameraMode) {
        TSLogWarning(@"[Camera] 设备已经在拍照模式中");
        [TSToast showText:@"设备已经在拍照模式中" onView:self.view dismissAfterDelay:1.0f];
        return;
    }
    
    TSLogInfo(@"[Camera] 正在请求设备进入拍照模式");
    [TSToast showText:@"正在进入拍照模式..." onView:self.view dismissAfterDelay:1.0f];
    
    [[[TopStepComKit sharedInstance] camera] notifyPeripheralEnterCameraWithCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            self.isInCameraMode = YES;
            TSLogInfo(@"[Camera] 设备成功进入拍照模式");
            [TSToast showText:@"已进入拍照模式" onView:self.view dismissAfterDelay:1.0f];
        } else {
            TSLogError(@"[Camera] 进入拍照模式失败: %@", error.localizedDescription);
            [TSToast showText:@"进入拍照模式失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

/**
 * 退出拍照模式
 */
- (void)exitCamera {
    if (!self.isInCameraMode) {
        TSLogWarning(@"[Camera] 设备当前不在拍照模式中");
        [TSToast showText:@"设备当前不在拍照模式中" onView:self.view dismissAfterDelay:1.0f];
        return;
    }
    
    TSLogInfo(@"[Camera] 正在请求设备退出拍照模式");
    [TSToast showText:@"正在退出拍照模式..." onView:self.view dismissAfterDelay:1.0f];
    
    [[[TopStepComKit sharedInstance] camera] notifyPeripheralExitCameraWithCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            self.isInCameraMode = NO;
            TSLogInfo(@"[Camera] 设备成功退出拍照模式");
            [TSToast showText:@"已退出拍照模式" onView:self.view dismissAfterDelay:1.0f];
        } else {
            TSLogError(@"[Camera] 退出拍照模式失败: %@", error.localizedDescription);
            [TSToast showText:@"退出拍照模式失败" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
}

- (void)dealloc {
    TSLogInfo(@"[Camera] 远程拍照页面已释放");
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
