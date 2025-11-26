//
//  UIViewController+NavigationBarHeight.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/8/15.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NavigationBarHeight)

/**
 获取导航条总高度（包含状态栏 + 导航栏本身）
 
 @return 导航条总高度，若导航栏隐藏则返回 0
 */
- (CGFloat)ts_navigationBarTotalHeight;

@end

NS_ASSUME_NONNULL_END
