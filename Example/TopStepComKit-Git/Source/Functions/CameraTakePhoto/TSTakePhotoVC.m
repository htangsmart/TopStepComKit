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
    
    [[[TopStepComKit sharedInstance] camera] registerAppCameraeControledByDevice:^(TSCameraAction action) {
        switch (action) {
            case TSCameraActionEnterCamera:
                TSLogInfo(@"[Camera] 设备已进入拍照模式");
                self.isInCameraMode = YES;
                [TSToast showText:@"设备已进入拍照模式" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionExitCamera:
                TSLogInfo(@"[Camera] 设备已退出拍照模式");
                self.isInCameraMode = NO;
                [TSToast showText:@"设备已退出拍照模式" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionTakePhoto:
                TSLogInfo(@"[Camera] 设备触发拍照");
                [TSToast showText:@"设备触发拍照" onView:self.view dismissAfterDelay:1.0f];
                // 这里可以添加实际的拍照逻辑，比如保存照片到相册
                [self handleDeviceTakePhoto];
                break;
                
            case TSCameraActionSwitchBackCamera:
                TSLogInfo(@"[Camera] 设备切换到后置摄像头");
                [TSToast showText:@"设备已切换到后置摄像头" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionSwitchFrontCamera:
                TSLogInfo(@"[Camera] 设备切换到前置摄像头");
                [TSToast showText:@"设备已切换到前置摄像头" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionFlashOff:
                TSLogInfo(@"[Camera] 设备关闭闪光灯");
                [TSToast showText:@"设备已关闭闪光灯" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionFlashAuto:
                TSLogInfo(@"[Camera] 设备设置闪光灯自动模式");
                [TSToast showText:@"设备已设置闪光灯自动模式" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            case TSCameraActionFlashOn:
                TSLogInfo(@"[Camera] 设备开启闪光灯");
                [TSToast showText:@"设备已开启闪光灯" onView:self.view dismissAfterDelay:1.0f];
                break;
                
            default:
                TSLogWarning(@"[Camera] 收到未知的相机动作: %ld", (long)action);
                [TSToast showText:[NSString stringWithFormat:@"收到未知动作: %ld", (long)action] onView:self.view dismissAfterDelay:1.0f];
                break;
        }
    }];
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"进入拍照"],
        [TSValueModel valueWithName:@"退出拍照"]
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
    
    [[[TopStepComKit sharedInstance] camera] controlCameraWithAction:TSCameraActionEnterCamera completion:^(BOOL isSuccess, NSError * _Nullable error) {
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
    
    [[[TopStepComKit sharedInstance] camera] controlCameraWithAction:TSCameraActionExitCamera completion:^(BOOL isSuccess, NSError * _Nullable error) {
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


/**
 * 处理设备触发的拍照
 * 当设备主动触发拍照时，App可以在这里处理相关逻辑
 */
- (void)handleDeviceTakePhoto {
    TSLogInfo(@"[Camera] 开始处理设备触发的拍照");
    
    // 这里可以添加实际的拍照处理逻辑，比如：
    // 1. 调用系统相机拍照
    // 2. 保存照片到相册
    // 3. 上传照片到服务器
    // 4. 显示拍照结果
    
    // 示例：显示拍照成功提示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TSToast showText:@"拍照完成！" onView:self.view dismissAfterDelay:2.0f];
    });
    
    // 可以在这里添加震动反馈
    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    TSLogInfo(@"[Camera] 设备触发的拍照处理完成");
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
