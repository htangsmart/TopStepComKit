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

// 开屏最短展示时长（秒），避免 SDK 初始化过快导致开屏一闪而过
static const NSTimeInterval kTSLaunchMinimumDisplayDuration = 1.0;

@interface TSAppDelegate ()

@property (nonatomic, strong) TSMainTabBarController *mainTabBarController;
// 初始启动的真实目标（主界面或扫描页），最短展示时长与其就绪后再切换
@property (nonatomic, strong) UIViewController *pendingInitialRoot;
// 开屏最短展示时长是否已到
@property (nonatomic, assign) BOOL minimumDisplayElapsed;

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

    // 根据历史绑定状态决定初始首屏（绑定过则先展示静态开屏，等待 SDK 初始化）
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

    // 始终先展示静态开屏，并保证最短展示时长，避免开屏一闪而过
    self.window.rootViewController = [self ts_makeLaunchSplashVC];
    [self ts_startMinimumDisplayTimer];

    if (hasBoundDevice) {
        // 有历史绑定设备：SDK 初始化是异步的，就绪后再切主界面
        [self ts_initSDKThenShowMain];
    } else {
        // 没有绑定过设备，目标为扫描页（扫描页内部会初始化 SDK）
        self.pendingInitialRoot = [self ts_makeScanNav];
        [self ts_deliverInitialRootIfReady];
    }
}

/**
 * 启动开屏最短展示计时，到点后尝试交付真实首屏
 */
- (void)ts_startMinimumDisplayTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSLaunchMinimumDisplayDuration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        weakSelf.minimumDisplayElapsed = YES;
        [weakSelf ts_deliverInitialRootIfReady];
    });
}

/**
 * 用上次保存的 SDK 类型初始化 SDK，成功后进主界面；失败则回退扫描页
 */
- (void)ts_initSDKThenShowMain {
    // 优先使用上次保存的 SDK 类型；未保存过时兜底为 eTSSDKTypeTPB
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TSSDKType sdkType;
    if ([defaults objectForKey:@"TSSavedSDKType"]) {
        sdkType = (TSSDKType)[defaults integerForKey:@"TSSavedSDKType"];
    } else {
        sdkType = eTSSDKTypeTPB;
    }

    TSKitConfigOptions *config = [TSKitConfigOptions configOptionWithSDKType:sdkType
                                                                     license:@"abcdef1234567890abcdef1234567890"];

    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:config completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (isSuccess) {
                strongSelf.pendingInitialRoot = strongSelf.mainTabBarController;
                [strongSelf ts_deliverInitialRootIfReady];
                // SDK 就绪后通知，让需要用 SDK 的 VC 发起自动重连等依赖 SDK 的动作
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSSDKDidInitializeNotification" object:nil];
            } else {
                TSLog(@"[TSAppDelegate] SDK 初始化失败(SDKType=%ld): %@，回退扫描页", (long)sdkType, error);
                strongSelf.pendingInitialRoot = [strongSelf ts_makeScanNav];
                [strongSelf ts_deliverInitialRootIfReady];
            }
        });
    }];
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
    self.window.rootViewController = [self ts_makeScanNav];
}

/**
 * 构建扫描页导航控制器
 */
- (UINavigationController *)ts_makeScanNav {
    TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
    return [[UINavigationController alloc] initWithRootViewController:scanVC];
}

/**
 * 构建静态开屏（仅展示 launch_bg，与 LaunchScreen.storyboard 首帧一致）
 */
- (UIViewController *)ts_makeLaunchSplashVC {
    UIViewController *splashVC = [[UIViewController alloc] init];
    splashVC.view.backgroundColor = [UIColor whiteColor];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:splashVC.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"launch_bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [splashVC.view addSubview:backgroundImageView];

    return splashVC;
}

/**
 * 最短展示时长与真实首屏均就绪后，交叉溶解切换（仅初始启动用一次）
 */
- (void)ts_deliverInitialRootIfReady {
    if (!self.minimumDisplayElapsed) return;
    if (!self.pendingInitialRoot) return;

    UIViewController *destination = self.pendingInitialRoot;
    self.pendingInitialRoot = nil;
    [self ts_transitionRootTo:destination];
}

/**
 * 交叉溶解切换 window 根控制器
 */
- (void)ts_transitionRootTo:(UIViewController *)destination {
    if (!destination) return;

    [UIView transitionWithView:self.window
                      duration:0.35
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.window.rootViewController = destination;
                    }
                    completion:nil];
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
