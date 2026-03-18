//
//  TSAppDelegate.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSMainTabBarController.h"
#import "TSDeviceScanVC.h"
#import "TSAppLanguageManager.h"
#import <TopStepComKit/TopStepComKit.h>

@interface TSAppDelegate ()

@property (nonatomic, strong) TSMainTabBarController *mainTabBarController;

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TSAppLanguageManager applyStoredLanguageIfNeeded];

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen bounds: %@", NSStringFromCGRect(bounds));

    self.window = [[UIWindow alloc] initWithFrame:bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    // 创建 TabBar 控制器
    self.mainTabBarController = [[TSMainTabBarController alloc] init];

    // 检查是否有历史绑定设备
    [self checkDeviceBindingStatus];

    [self.window makeKeyAndVisible];

    // 注册设备绑定成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceBindSuccess)
                                                 name:@"TSDeviceBindSuccessNotification"
                                               object:nil];

    // 注册设备解绑通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceUnbind)
                                                 name:@"TSDeviceUnbindNotification"
                                               object:nil];

    // 注册设备重连成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceReconnected)
                                                 name:@"TSDeviceReconnectedNotification"
                                               object:nil];

    return YES;
}

/**
 * 检查设备绑定状态
 */
- (void)checkDeviceBindingStatus {
    // 检查 UserDefaults 中是否有历史绑定设备记录
    BOOL hasBoundDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"TSHasBoundDevice"];

    if (hasBoundDevice) {
        // 有历史绑定设备，直接进主界面
        // TSViewController 会负责初始化 SDK 和自动重连
        [self showMainInterface];
    } else {
        // 没有绑定过设备，显示扫描页
        [self showDeviceScanInterface];
    }
}

/**
 * 显示主界面（带 TabBar）
 */
- (void)showMainInterface {
    self.window.rootViewController = self.mainTabBarController;
}

/**
 * 显示设备扫描页（无 TabBar）
 */
- (void)showDeviceScanInterface {
    TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scanVC];
    self.window.rootViewController = navController;
}

/**
 * 处理设备绑定成功（首次绑定）
 */
- (void)handleDeviceBindSuccess {
    // 记录已绑定设备
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TSHasBoundDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 切换到主界面
    [self showMainInterface];

    // 延迟触发首页刷新（等待界面切换完成）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self triggerHomeRefresh];
    });
}

/**
 * 处理设备重连成功
 */
- (void)handleDeviceReconnected {
    [self triggerHomeRefresh];
}

/**
 * 触发首页下拉刷新
 */
- (void)triggerHomeRefresh {
    if (![self.mainTabBarController.viewControllers.firstObject isKindOfClass:[UINavigationController class]]) return;

    UINavigationController *homeNav = (UINavigationController *)self.mainTabBarController.viewControllers.firstObject;
    UIViewController *homeVC = homeNav.topViewController;

    if (![homeVC respondsToSelector:@selector(ts_handleRefresh)]) return;

    // 显示刷新动画
    UIRefreshControl *refreshControl = [homeVC valueForKey:@"refreshControl"];
    if (refreshControl && refreshControl.superview && !refreshControl.isRefreshing) {
        [refreshControl beginRefreshing];
        UIScrollView *scrollView = (UIScrollView *)refreshControl.superview;
        CGPoint offset = scrollView.contentOffset;
        offset.y = -refreshControl.frame.size.height;
        [scrollView setContentOffset:offset animated:YES];
    }

    // 触发数据刷新
    [homeVC performSelector:@selector(ts_handleRefresh)];
}

/**
 * 处理设备解绑
 */
- (void)handleDeviceUnbind {
    // 清除绑定标记
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TSHasBoundDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 切换到扫描页
    [self showDeviceScanInterface];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
