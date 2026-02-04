//
//  TSWindow.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/31.
//

#import "TSWindow.h"

@implementation TSWindow

#pragma mark - Public Methods

/**
 获取当前显示的顶层视图控制器
 
 @return 当前显示的顶层视图控制器，如果获取失败返回 nil
 @discussion 该方法会递归查找当前显示的最顶层控制器，包括处理导航控制器、标签控制器、分屏控制器等各种情况
 */
+ (UIViewController *)windowTopVC {
    UIViewController *rootVC = [self currentWindowRootViewController];
    return [self topViewControllerFrom:rootVC];
}

/**
 获取指定视图所在的视图控制器
 
 @param view 需要查找的视图
 @return 该视图所在的视图控制器，如果未找到返回 nil
 @discussion 该方法通过响应链向上查找，直到找到视图所属的视图控制器
 */
+ (UIViewController *)viewSuperVC:(UIView *)view {
    if (!view) {
        return nil;
    }
    return [self findViewControllerFromView:view];
}

#pragma mark - Private Methods

/**
 获取当前窗口的根视图控制器
 
 @return 当前窗口的根视图控制器，如果获取失败返回 nil
 @discussion 该方法会优先使用 Scene 方式获取窗口，如果失败则回退到传统方式
 */
+ (UIViewController *)currentWindowRootViewController {
    UIWindow *window = [self findKeyWindow];
    return window.rootViewController;
}

/**
 查找当前的 KeyWindow
 
 @return 当前的 KeyWindow，如果未找到返回 nil
 @discussion 该方法会按照以下顺序查找：
 1. iOS 13+ Scene 方式
 2. 传统 keyWindow 方式
 3. 遍历所有窗口
 */
+ (UIWindow *)findKeyWindow {
    UIWindow *window = [self findKeyWindowInScene];
    
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    if (!window) {
        window = [self findKeyWindowInWindows];
    }
    
    return window;
}

/**
 在 Scene 中查找 KeyWindow（iOS 13+）
 
 @return 找到的 KeyWindow，如果未找到返回 nil
 */
+ (UIWindow *)findKeyWindowInScene API_AVAILABLE(ios(13.0)) {
    NSSet<UIScene *> *scenes = [[UIApplication sharedApplication] connectedScenes];
    for (UIScene *scene in scenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return nil;
}

/**
 在应用的所有窗口中查找 KeyWindow
 
 @return 找到的 KeyWindow，如果未找到返回第一个窗口
 */
+ (UIWindow *)findKeyWindowInWindows {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return windows.firstObject;
}

/**
 递归查找顶层视图控制器
 
 @param viewController 开始查找的视图控制器
 @return 找到的顶层视图控制器
 @discussion 该方法会处理以下情况：
 1. 导航控制器
 2. 标签控制器
 3. 分屏控制器
 4. 模态视图控制器
 5. 子视图控制器
 */
+ (UIViewController *)topViewControllerFrom:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }
    
    // 处理导航控制器
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self topViewControllerFrom:[(UINavigationController *)viewController visibleViewController]];
    }
    
    // 处理标签控制器
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self topViewControllerFrom:[(UITabBarController *)viewController selectedViewController]];
    }
    
    // 处理分屏控制器
    if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitVC = (UISplitViewController *)viewController;
        if (splitVC.viewControllers.count > 0) {
            return [self topViewControllerFrom:splitVC.viewControllers.lastObject];
        }
        return splitVC;
    }
    
    // 处理模态视图控制器
    if (viewController.presentedViewController) {
        // 特殊处理 UIAlertController
        if ([viewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
            return viewController;
        }
        return [self topViewControllerFrom:viewController.presentedViewController];
    }
    
    // 处理子视图控制器
    if (viewController.childViewControllers.count > 0) {
        return [self topViewControllerFrom:viewController.childViewControllers.lastObject];
    }
    
    return viewController;
}


/**
 通过响应链查找视图所属的视图控制器
 
 @param view 需要查找的视图
 @return 找到的视图控制器，如果未找到返回 nil
 @discussion 该方法通过以下顺序查找视图控制器：
 1. 检查视图是否直接属于某个视图控制器
 2. 通过响应链向上查找
 3. 检查父视图是否属于某个视图控制器
 */
+ (UIViewController *)findViewControllerFromView:(UIView *)view {
    if (!view) {
        return nil;
    }
    
    // 1. 首先检查当前视图的 nextResponder
    UIResponder *nextResponder = view.nextResponder;
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)nextResponder;
    }
    
    // 2. 遍历响应链
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    
    // 3. 如果还没找到，尝试通过父视图查找
    UIView *parentView = view.superview;
    while (parentView) {
        UIResponder *parentResponder = parentView.nextResponder;
        if ([parentResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)parentResponder;
        }
        parentView = parentView.superview;
    }
    
    // 4. 如果视图是 window 的子视图，尝试获取 window 的根视图控制器
    if (view.window) {
        UIViewController *rootVC = view.window.rootViewController;
        if (rootVC) {
            return [self topViewControllerFrom:rootVC];
        }
    }
    
    return nil;
}

@end
