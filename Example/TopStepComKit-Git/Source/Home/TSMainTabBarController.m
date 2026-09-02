//
//  TSMainTabBarController.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMainTabBarController.h"

#import "TSAIChatVC.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIAudioRecordVC.h"
#import "TSAIAudioRecordSessionCoordinator.h"
#import "TSHomeVC.h"
#import "TSMineVC.h"
#import "TSViewController.h"

typedef NS_ENUM(NSUInteger, TSMainTabIndex) {
    TSMainTabIndexHome = 0,
    TSMainTabIndexDevice,
    TSMainTabIndexMine,
};

@interface TSMainTabBarController ()

// 是否有待展示的设备发起 AI 对话页面
@property (nonatomic, assign) BOOL hasPendingAIChatPresentation;
// 是否有待展示的设备发起 AI 录音页面
@property (nonatomic, assign) BOOL hasPendingAIAudioRecordPresentation;

@end

@implementation TSMainTabBarController

#pragma mark - 生命周期

/** 初始化并尽早监听进程级 AI 页面请求 */
- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(ts_handleAIChatPresentationRequest:)
                                   name:TSAIChatDeviceSessionDidRequestPresentationNotification
                                 object:[TSAIChatDeviceSessionCoordinator sharedInstance]];
        [notificationCenter addObserver:self
                               selector:@selector(ts_handleAIAudioRecordPresentationRequest:)
                                   name:TSAIAudioRecordSessionDidRequestPresentationNotification
                                 object:[TSAIAudioRecordSessionCoordinator sharedInstance]];
        [notificationCenter addObserver:self
                               selector:@selector(ts_handleApplicationDidBecomeActive:)
                                   name:UIApplicationDidBecomeActiveNotification
                                 object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self ts_setupTabs];
    [self ts_setupAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self ts_presentPendingAIChatIfPossible];
    [self ts_presentPendingAIAudioRecordIfPossible];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有方法

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

/** 记录设备发起的 AI 对话页面请求，并在当前可展示时立即执行 */
- (void)ts_handleAIChatPresentationRequest:(NSNotification *)notification {
    self.hasPendingAIAudioRecordPresentation = NO;
    self.hasPendingAIChatPresentation = YES;
    TSAIChatDeviceSessionCoordinator *coordinator =
        [TSAIChatDeviceSessionCoordinator sharedInstance];
    TSLog(@"[TSMainTabBarController][AIChatRoute] 收到请求: "
          "currentTab=%lu, appState=%@, phase=%ld, hasTask=%d",
          (unsigned long)self.selectedIndex,
          [self ts_applicationStateDescription],
          (long)coordinator.phase,
          coordinator.currentTaskId.length > 0);
    [self ts_presentPendingAIChatIfPossible];
}

/** 记录设备发起的录音页面请求，并在当前可展示时立即执行 */
- (void)ts_handleAIAudioRecordPresentationRequest:(NSNotification *)notification {
    TSAIAudioRecordSessionState *state =
        notification.userInfo[TSAIAudioRecordSessionStateUserInfoKey];
    self.hasPendingAIChatPresentation = NO;
    self.hasPendingAIAudioRecordPresentation = YES;
    TSLog(@"[TSMainTabBarController][AIAudioRecordRoute] 收到请求: "
          "currentTab=%lu, appState=%@, phase=%ld, generation=%lu",
          (unsigned long)self.selectedIndex,
          [self ts_applicationStateDescription],
          (long)state.phase,
          (unsigned long)state.generation);
    [self ts_presentPendingAIAudioRecordIfPossible];
}

/** App 回到前台后继续处理待展示的 AI 页面 */
- (void)ts_handleApplicationDidBecomeActive:(NSNotification *)notification {
    [self ts_presentPendingAIChatIfPossible];
    [self ts_presentPendingAIAudioRecordIfPossible];
}

/** 将设备 Tab 的导航栈切换到 AI 对话页面 */
- (void)ts_presentPendingAIChatIfPossible {
    if (!self.hasPendingAIChatPresentation) {
        return;
    }
    if ([self ts_routeDevicePageOfClass:[TSAIChatVC class] routeName:@"AIChatRoute"]) {
        self.hasPendingAIChatPresentation = NO;
    }
}

/** 将设备 Tab 的导航栈切换到 AI 录音页面 */
- (void)ts_presentPendingAIAudioRecordIfPossible {
    if (!self.hasPendingAIAudioRecordPresentation) {
        return;
    }
    if ([self ts_routeDevicePageOfClass:[TSAIAudioRecordVC class]
                              routeName:@"AIAudioRecordRoute"]) {
        self.hasPendingAIAudioRecordPresentation = NO;
    }
}

/** 在具备展示条件时切换到设备 Tab，并打开指定页面 */
- (BOOL)ts_routeDevicePageOfClass:(Class)pageClass routeName:(NSString *)routeName {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        TSLog(@"[TSMainTabBarController][%@] 延迟展示: appState=%@",
              routeName,
              [self ts_applicationStateDescription]);
        return NO;
    }
    if (!self.isViewLoaded || !self.view.window) {
        TSLog(@"[TSMainTabBarController][%@] 延迟展示: 主界面尚不可见", routeName);
        return NO;
    }

    UINavigationController *deviceNavigationController = [self ts_deviceNavigationController];
    if (!deviceNavigationController) {
        TSLog(@"[TSMainTabBarController][%@] 展示失败: 设备导航栈不可用", routeName);
        return NO;
    }

    NSUInteger previousTabIndex = self.selectedIndex;
    UIViewController *previousTopViewController = deviceNavigationController.topViewController;
    UIViewController *presentedViewController = deviceNavigationController.presentedViewController;
    self.selectedIndex = TSMainTabIndexDevice;

    NSString *routeAction = @"push";
    BOOL didRoute = NO;
    if ([previousTopViewController isKindOfClass:pageClass]) {
        routeAction = @"alreadyVisible";
        didRoute = YES;
    } else {
        for (UIViewController *viewController in deviceNavigationController.viewControllers) {
            if ([viewController isKindOfClass:pageClass]) {
                routeAction = @"pop";
                [deviceNavigationController popToViewController:viewController animated:YES];
                didRoute = deviceNavigationController.topViewController == viewController;
                break;
            }
        }
        if (!didRoute) {
            UIViewController *destinationViewController = [[pageClass alloc] init];
            [deviceNavigationController pushViewController:destinationViewController animated:YES];
            didRoute = deviceNavigationController.topViewController == destinationViewController;
        }
    }
    TSLog(@"[TSMainTabBarController][%@] 路由完成: "
          "fromTab=%lu, currentTab=%lu, appState=%@, previousTop=%@, "
          "presented=%@, action=%@, success=%d",
          routeName,
          (unsigned long)previousTabIndex,
          (unsigned long)self.selectedIndex,
          [self ts_applicationStateDescription],
          NSStringFromClass(previousTopViewController.class),
          presentedViewController ? NSStringFromClass(presentedViewController.class) : @"none",
          routeAction,
          didRoute);
    return didRoute;
}

/** 返回设备 Tab 的导航控制器 */
- (UINavigationController *)ts_deviceNavigationController {
    if (self.viewControllers.count <= TSMainTabIndexDevice) {
        return nil;
    }
    UIViewController *viewController = self.viewControllers[TSMainTabIndexDevice];
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    return (UINavigationController *)viewController;
}

/** 返回便于日志阅读的 App 状态 */
- (NSString *)ts_applicationStateDescription {
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
            return @"active";
        case UIApplicationStateInactive:
            return @"inactive";
        case UIApplicationStateBackground:
            return @"background";
    }
    return @"unknown";
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
