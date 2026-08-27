//
//  TSSceneDelegate.m
//  TopStepComKit
//
//  Created by Codex on 2026/8/26.
//  Copyright (c) 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSSceneDelegate.h"

#import "TSAppDelegate.h"

@implementation TSSceneDelegate

#pragma mark - UISceneDelegate

/**
 * 连接场景时创建窗口并配置初始界面
 */
- (void)scene:(UIScene *)scene
        willConnectToSession:(UISceneSession *)session
        options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window = window;

    TSAppDelegate *appDelegate = (TSAppDelegate *)UIApplication.sharedApplication.delegate;
    [appDelegate configureInitialInterfaceWithWindow:window];
}

@end
