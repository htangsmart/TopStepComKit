//
//  TSMainTabBarController.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Main tab bar controller with Home and Device tabs
 * @chinese 主 TabBar 控制器，包含首页和设备两个标签
 *
 * @discussion
 * [EN]: Root view controller of the app, managing two tabs:
 *       - Home (首页): Health data cards with pull-to-refresh sync
 *       - Device (设备): Device management and settings
 * [CN]: 应用的根视图控制器，管理两个标签页：
 *       - 首页：健康数据卡片，支持下拉刷新同步
 *       - 设备：设备管理和设置
 */
@interface TSMainTabBarController : UITabBarController

@end

NS_ASSUME_NONNULL_END
