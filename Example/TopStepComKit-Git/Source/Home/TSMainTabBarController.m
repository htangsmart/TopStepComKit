//
//  TSMainTabBarController.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMainTabBarController.h"

#import "TSAIAudioRecordSessionCoordinator.h"
#import "TSAIAudioRecordVC.h"
#import "TSHomeVC.h"
#import "TSMineVC.h"
#import "TSViewController.h"

@interface TSMainTabBarController ()

// App 恢复活跃后是否需要展示设备发起的 AI 录音页面
@property (nonatomic, assign) BOOL shouldPresentPendingAIAudioRecord;

@end

@implementation TSMainTabBarController

#pragma mark - 生命周期

/** 初始化主标签页并提前注册全局 AI 录音页面路由 */
- (instancetype)init {
    self = [super init];
    if (self) {
        [self ts_registerAIAudioRecordPresentationNotifications];
    }
    return self;
}

/** 初始化主标签页界面并重放待展示请求 */
- (void)viewDidLoad {
    [super viewDidLoad];

    [self ts_setupTabs];
    [self ts_setupAppearance];
    if (self.shouldPresentPendingAIAudioRecord) {
        [self ts_presentAIAudioRecordPageIfPossible];
    }
}

/** 移除全局通知监听 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有方法

/** 注册设备发起的 AI 录音页面展示通知 */
- (void)ts_registerAIAudioRecordPresentationNotifications {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(ts_handleAIAudioRecordPresentationRequest:)
               name:TSAIAudioRecordSessionDidRequestPresentationNotification
             object:[TSAIAudioRecordSessionCoordinator sharedInstance]];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(ts_handleApplicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
}

/** 处理设备发起的 AI 录音页面展示请求 */
- (void)ts_handleAIAudioRecordPresentationRequest:(NSNotification *)notification {
    [self ts_presentAIAudioRecordPageIfPossible];
}

/** App 恢复活跃后继续处理待展示的 AI 录音页面 */
- (void)ts_handleApplicationDidBecomeActive:(NSNotification *)notification {
    if (!self.shouldPresentPendingAIAudioRecord) {
        return;
    }
    [self ts_presentAIAudioRecordPageIfPossible];
}

/** 切换到设备标签并展示 AI 录音页面 */
- (void)ts_presentAIAudioRecordPageIfPossible {
    TSAIAudioRecordSessionState *sessionState =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    if (![sessionState isActive] ||
        sessionState.source != TSAIAudioRecordSessionSourceDevice) {
        self.shouldPresentPendingAIAudioRecord = NO;
        TSLog(@"[TSMainTabBarController] ignore stale device AI audio recording presentation");
        return;
    }
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        self.shouldPresentPendingAIAudioRecord = YES;
        TSLog(@"[TSMainTabBarController] defer device AI audio recording presentation: app inactive");
        return;
    }
    if (![self isViewLoaded]) {
        self.shouldPresentPendingAIAudioRecord = YES;
        TSLog(@"[TSMainTabBarController] defer device AI audio recording presentation: tabs not loaded");
        return;
    }

    UINavigationController *deviceNavigationController = [self ts_deviceNavigationController];
    if (deviceNavigationController == nil) {
        self.shouldPresentPendingAIAudioRecord = YES;
        TSLog(@"[TSMainTabBarController] defer device AI audio recording presentation: device tab unavailable");
        return;
    }

    self.shouldPresentPendingAIAudioRecord = NO;
    self.selectedViewController = deviceNavigationController;
    UIViewController *topViewController = deviceNavigationController.topViewController;
    if ([topViewController isKindOfClass:[TSAIAudioRecordVC class]]) {
        TSLog(@"[TSMainTabBarController] device AI audio recording page already visible");
        return;
    }
    for (UIViewController *viewController in deviceNavigationController.viewControllers) {
        if ([viewController isKindOfClass:[TSAIAudioRecordVC class]]) {
            [deviceNavigationController popToViewController:viewController animated:YES];
            TSLog(@"[TSMainTabBarController] restored device AI audio recording page");
            return;
        }
    }
    TSAIAudioRecordVC *audioRecordVC = [[TSAIAudioRecordVC alloc] init];
    [deviceNavigationController pushViewController:audioRecordVC animated:YES];
    TSLog(@"[TSMainTabBarController] presented device AI audio recording page");
}

/** 返回设备标签对应的导航控制器 */
- (nullable UINavigationController *)ts_deviceNavigationController {
    for (UIViewController *viewController in self.viewControllers) {
        if (![viewController isKindOfClass:[UINavigationController class]]) {
            continue;
        }
        UINavigationController *navigationController =
            (UINavigationController *)viewController;
        UIViewController *rootViewController = navigationController.viewControllers.firstObject;
        if ([rootViewController isKindOfClass:[TSViewController class]]) {
            return navigationController;
        }
    }
    return nil;
}

/**
 * 配置三个 tab：首页 + 设备 + 我的
 */
- (void)ts_setupTabs {
    // 首页
    TSHomeVC *homeVC = [[TSHomeVC alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TSLocalizedString(@"tab.home")
                                                       image:[self ts_tabIconNamed:@"house"]
                                               selectedImage:[self ts_tabIconNamed:@"house.fill"]];

    // 设备页（原 TSViewController）
    TSViewController *deviceVC = [[TSViewController alloc] init];
    UINavigationController *deviceNav = [[UINavigationController alloc] initWithRootViewController:deviceVC];
    deviceNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TSLocalizedString(@"tab.device")
                                                         image:[self ts_tabIconNamed:@"applewatch"]
                                                 selectedImage:[self ts_tabIconNamed:@"applewatch"]];

    // 我的页
    TSMineVC *mineVC = [[TSMineVC alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TSLocalizedString(@"tab.mine")
                                                       image:[self ts_tabIconNamed:@"person"]
                                               selectedImage:[self ts_tabIconNamed:@"person.fill"]];

    self.viewControllers = @[homeNav, deviceNav, mineNav];
}

/**
 * 配置 TabBar 外观
 */
- (void)ts_setupAppearance {
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];

        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    } else {
        self.tabBar.barTintColor = [UIColor whiteColor];
    }
}

/**
 * 获取 SF Symbol 图标（iOS 13+）或返回 nil
 */
- (UIImage *)ts_tabIconNamed:(NSString *)symbolName {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24
                                                                                              weight:UIImageSymbolWeightRegular
                                                                                               scale:UIImageSymbolScaleMedium];
        return [UIImage systemImageNamed:symbolName withConfiguration:config];
    }
    return nil;
}

@end
