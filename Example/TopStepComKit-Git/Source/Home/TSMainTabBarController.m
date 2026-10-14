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
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIChatVC.h"
#import "TSAIQADeviceSessionCoordinator.h"
#import "TSAIQuestionAnswerVC.h"
#import "TSHomeVC.h"
#import "TSMineVC.h"
#import "TSViewController.h"

@interface TSMainTabBarController ()

// App 恢复活跃后是否需要展示设备发起的 AI 录音页面
@property (nonatomic, assign) BOOL shouldPresentPendingAIAudioRecord;
// App 恢复活跃后是否需要展示设备发起的 AI 畅聊页面
@property (nonatomic, assign) BOOL shouldPresentPendingAIChat;

@end

@implementation TSMainTabBarController

#pragma mark - 生命周期

/** 初始化主标签页并提前注册全局 AI 页面路由（设备标签页懒加载，不能由它监听） */
- (instancetype)init {
    self = [super init];
    if (self) {
        [self ts_registerDeviceAIPresentationNotifications];
    }
    return self;
}

/** 初始化主标签页界面并重放待展示请求 */
- (void)viewDidLoad {
    [super viewDidLoad];

    [self ts_setupTabs];
    [self ts_setupAppearance];
    [self ts_presentPendingDeviceAIPagesIfNeeded];
}

/** 移除全局通知监听 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有方法 - 设备发起的 AI 页面路由

/** 注册设备发起的 AI 录音 / AI 畅聊 / AI 问答页面展示通知 */
- (void)ts_registerDeviceAIPresentationNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(ts_handleAIAudioRecordPresentationRequest:)
                   name:TSAIAudioRecordSessionDidRequestPresentationNotification
                 object:[TSAIAudioRecordSessionCoordinator sharedInstance]];
    [center addObserver:self
               selector:@selector(ts_handleAIChatPresentationRequest:)
                   name:TSAIChatDeviceSessionDidRequestPresentationNotification
                 object:[TSAIChatDeviceSessionCoordinator sharedInstance]];
    [center addObserver:self
               selector:@selector(ts_handleAIQuestionAnswerPresentationRequest:)
                   name:TSAIQADeviceSessionDidRequestPresentationNotification
                 object:[TSAIQADeviceSessionCoordinator sharedInstance]];
    [center addObserver:self
               selector:@selector(ts_handleApplicationDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

/** App 恢复活跃后继续处理待展示的页面 */
- (void)ts_handleApplicationDidBecomeActive:(NSNotification *)notification {
    [self ts_presentPendingDeviceAIPagesIfNeeded];
}

/** 重放被延后的设备发起页面 */
- (void)ts_presentPendingDeviceAIPagesIfNeeded {
    if (self.shouldPresentPendingAIAudioRecord) {
        [self ts_presentAIAudioRecordPageIfPossible];
    }
    if (self.shouldPresentPendingAIChat) {
        [self ts_presentAIChatPageIfPossible];
    }
}

/** 处理设备发起的 AI 录音页面展示请求 */
- (void)ts_handleAIAudioRecordPresentationRequest:(NSNotification *)notification {
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
    UINavigationController *deviceNavigationController =
        [self ts_deviceNavigationControllerForPresentation:@"AI audio recording"];
    if (deviceNavigationController == nil) {
        self.shouldPresentPendingAIAudioRecord = YES;
        return;
    }

    self.shouldPresentPendingAIAudioRecord = NO;
    self.selectedViewController = deviceNavigationController;
    UIViewController *topViewController = deviceNavigationController.topViewController;
    if ([topViewController isKindOfClass:[TSAIAudioRecordVC class]]) {
        TSLog(@"[TSMainTabBarController] device AI audio recording page already visible");
        return;
    }
    UIViewController *existing = [self ts_viewControllerOfClass:[TSAIAudioRecordVC class]
                                         inNavigationController:deviceNavigationController];
    if (existing) {
        [deviceNavigationController popToViewController:existing animated:YES];
        TSLog(@"[TSMainTabBarController] restored device AI audio recording page");
        return;
    }
    TSAIAudioRecordVC *audioRecordVC = [[TSAIAudioRecordVC alloc] init];
    [deviceNavigationController pushViewController:audioRecordVC animated:YES];
    TSLog(@"[TSMainTabBarController] presented device AI audio recording page");
}

/** 处理设备发起的 AI 畅聊页面展示请求（双端激活后由协调器发出） */
- (void)ts_handleAIChatPresentationRequest:(NSNotification *)notification {
    [self ts_presentAIChatPageIfPossible];
}

/** 切换到设备标签并展示 AI 对话页；页面按协调器的设备会话自动进入「AI 畅聊」 */
- (void)ts_presentAIChatPageIfPossible {
    if (![self ts_isDeviceAIChatPresentable]) {
        self.shouldPresentPendingAIChat = NO;
        TSLog(@"[TSMainTabBarController] ignore stale device AI chat presentation");
        return;
    }
    UINavigationController *deviceNavigationController =
        [self ts_deviceNavigationControllerForPresentation:@"AI chat"];
    if (deviceNavigationController == nil) {
        self.shouldPresentPendingAIChat = YES;
        return;
    }

    self.shouldPresentPendingAIChat = NO;
    self.selectedViewController = deviceNavigationController;
    UIViewController *presentedViewController = self.presentedViewController;
    // 弹层会挡住压栈的页面：先收起再展示；AI 对话页自己已在收起时不重复 dismiss（重复调用 UIKit 会丢弃 completion）
    if (presentedViewController && !presentedViewController.isBeingDismissed) {
        TSLog(@"[TSMainTabBarController] dismiss %@ before presenting device AI chat page",
              NSStringFromClass([presentedViewController class]));
        __weak typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            [weakSelf ts_showAIChatPageInNavigationController:deviceNavigationController];
        }];
        return;
    }
    [self ts_showAIChatPageInNavigationController:deviceNavigationController];
}

/** 把 AI 对话页带到导航栈顶：已在栈中则回到它，否则压入新页面 */
- (void)ts_showAIChatPageInNavigationController:(UINavigationController *)navigationController {
    if (![self ts_isDeviceAIChatPresentable]) {
        TSLog(@"[TSMainTabBarController] device AI chat ended before presentation");
        return;
    }
    if ([navigationController.topViewController isKindOfClass:[TSAIChatVC class]]) {
        TSLog(@"[TSMainTabBarController] device AI chat page already visible");
        return;
    }
    UIViewController *existing = [self ts_viewControllerOfClass:[TSAIChatVC class]
                                         inNavigationController:navigationController];
    if (existing) {
        [navigationController popToViewController:existing animated:YES];
        TSLog(@"[TSMainTabBarController] restored device AI chat page");
        return;
    }
    TSAIChatVC *chatVC = [[TSAIChatVC alloc] init];
    [navigationController pushViewController:chatVC animated:YES];
    TSLog(@"[TSMainTabBarController] presented device AI chat page");
}

/** 设备发起的 AI 畅聊仍在进行（已双端激活、未被设备结束）时才需要展示页面 */
- (BOOL)ts_isDeviceAIChatPresentable {
    TSAIChatDeviceSessionCoordinator *coordinator = [TSAIChatDeviceSessionCoordinator sharedInstance];
    return coordinator.activeSessionDeviceInitiated &&
           coordinator.phase == TSAIChatDeviceSessionPhaseActive;
}

/** 处理设备发起新一轮 AI 问答：展示问答页面（设备语音模式）；App 未激活时不展示 */
- (void)ts_handleAIQuestionAnswerPresentationRequest:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive ||
        ![self isViewLoaded]) {
        return;
    }
    UINavigationController *deviceNavigationController = [self ts_deviceNavigationController];
    if (deviceNavigationController == nil) {
        return;
    }
    self.selectedViewController = deviceNavigationController;
    UIViewController *existing = [self ts_viewControllerOfClass:[TSAIQuestionAnswerVC class]
                                         inNavigationController:deviceNavigationController];
    if (existing) {
        [(TSAIQuestionAnswerVC *)existing switchToInputMode:TSAIQAInputModeWatch];
        if (deviceNavigationController.topViewController != existing) {
            [deviceNavigationController popToViewController:existing animated:YES];
        }
        return;
    }
    TSAIQuestionAnswerVC *questionAnswerVC =
        [[TSAIQuestionAnswerVC alloc] initWithInputMode:TSAIQAInputModeWatch];
    [deviceNavigationController pushViewController:questionAnswerVC animated:YES];
}

/** 设备发起的页面当前可展示时返回设备标签的导航控制器；App 未激活、标签未加载时返回 nil，由调用方延后 */
- (nullable UINavigationController *)ts_deviceNavigationControllerForPresentation:(NSString *)featureName {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        TSLog(@"[TSMainTabBarController] defer device %@ presentation: app inactive", featureName);
        return nil;
    }
    if (![self isViewLoaded]) {
        TSLog(@"[TSMainTabBarController] defer device %@ presentation: tabs not loaded", featureName);
        return nil;
    }
    UINavigationController *deviceNavigationController = [self ts_deviceNavigationController];
    if (deviceNavigationController == nil) {
        TSLog(@"[TSMainTabBarController] defer device %@ presentation: device tab unavailable", featureName);
    }
    return deviceNavigationController;
}

/** 返回导航栈中最靠近栈顶的指定类页面 */
- (nullable UIViewController *)ts_viewControllerOfClass:(Class)viewControllerClass
                                 inNavigationController:(UINavigationController *)navigationController {
    for (UIViewController *viewController in [navigationController.viewControllers reverseObjectEnumerator]) {
        if ([viewController isKindOfClass:viewControllerClass]) {
            return viewController;
        }
    }
    return nil;
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

#pragma mark - 私有方法 - 标签页

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
