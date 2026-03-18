//
//  TSRootVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Root view controller for all view controllers in the app
 * @chinese 应用中所有视图控制器的根基类
 *
 * @discussion
 * [EN]: All view controllers should inherit from this class.
 *       By default, hides the tab bar when pushed.
 *       Tab bar root view controllers (TSHomeVC, TSViewController, TSMineVC)
 *       should override init to set hidesBottomBarWhenPushed = NO.
 * [CN]: 所有视图控制器都应继承此类。
 *       默认情况下，push 时隐藏 TabBar。
 *       TabBar 根视图控制器（TSHomeVC、TSViewController、TSMineVC）
 *       应重写 init 方法设置 hidesBottomBarWhenPushed = NO。
 */
@interface TSRootVC : UIViewController

@end

NS_ASSUME_NONNULL_END
