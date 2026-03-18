//
//  TSMainTabBarController.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMainTabBarController.h"
#import "TSHomeVC.h"
#import "TSViewController.h"
#import "TSMineVC.h"

@interface TSMainTabBarController ()

@end

@implementation TSMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self ts_setupTabs];
    [self ts_setupAppearance];
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
    // 强制加载 view，确保 SDK 初始化和自动重连在 App 启动时触发（不依赖用户切换到此 tab）
    [deviceVC loadViewIfNeeded];
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
