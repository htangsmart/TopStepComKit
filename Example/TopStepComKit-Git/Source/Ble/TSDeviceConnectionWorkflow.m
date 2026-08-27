//
//  TSDeviceConnectionWorkflow.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/27.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDeviceConnectionWorkflow.h"

#import <TopStepComKit/TopStepComKit.h>

@implementation TSDeviceConnectionWorkflow

#pragma mark - 公开方法

/**
 * 按顺序执行连接成功后的设备准备操作
 */
+ (void)prepareConnectedDeviceWithCompletion:(void (^)(void))completion {
    id<TSTimeInterface> timeInterface = [TopStepComKit sharedInstance].time;
    if (!timeInterface) {
        TSLog(@"[TSDeviceConnectionWorkflow] 同步系统时间失败：时间接口不可用");
        [self ts_finishWithCompletion:completion];
        return;
    }

    [timeInterface setSystemTimeWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            TSLog(@"[TSDeviceConnectionWorkflow] 系统时间同步成功");
        } else {
            TSLog(@"[TSDeviceConnectionWorkflow] 系统时间同步失败: %@", error.localizedDescription);
        }
        [self ts_finishWithCompletion:completion];
    }];
}

#pragma mark - 私有方法

/**
 * 在主线程结束设备准备流程
 */
+ (void)ts_finishWithCompletion:(void (^)(void))completion {
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), completion);
}

@end
