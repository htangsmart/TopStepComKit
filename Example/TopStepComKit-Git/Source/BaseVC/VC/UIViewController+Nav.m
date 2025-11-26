//
//  UIViewController+Nav.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/8/15.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "UIViewController+Nav.h"

@implementation UIViewController (Nav)

- (CGFloat)ts_navigationBarTotalHeight {
    // 1. 检查导航控制器是否存在且导航栏未隐藏
    if (!self.navigationController || self.navigationController.navigationBar.hidden) {
        return 0;
    }
    
    // 2. 获取状态栏高度（适配 iOS 13+ 与旧版本）
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        // iOS 13+ 从窗口的安全区域获取（更准确，兼容多场景）
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        statusBarHeight = window.safeAreaInsets.top;
    } else {
        // iOS 12 及以下直接获取状态栏 frame
        statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    
    // 3. 获取导航栏本身的高度
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    // 4. 处理特殊情况：导航栏尚未完成布局导致高度为 0 的情况
    if (navBarHeight <= 0) {
        // 手动计算默认高度（普通模式 44pt，大标题模式 96pt）
        if (self.navigationController.navigationBar.prefersLargeTitles) {
            navBarHeight = 96;
        } else {
            navBarHeight = 44;
        }
    }
    
    // 5. 总高度 = 状态栏高度 + 导航栏高度
    return statusBarHeight + navBarHeight;
}


@end



