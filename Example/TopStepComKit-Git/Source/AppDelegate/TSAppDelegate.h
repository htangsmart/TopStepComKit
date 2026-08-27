//
//  TSAppDelegate.h
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

/**
 * @brief Configure the initial interface for the specified application window
 * @chinese 为指定应用窗口配置初始界面
 *
 * @param window
 * EN: Window associated with the connected scene
 * CN: 与已连接场景关联的窗口
 */
- (void)configureInitialInterfaceWithWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
