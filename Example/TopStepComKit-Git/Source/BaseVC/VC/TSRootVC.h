//
//  TSRootVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// ─── Localization ───────────────────────────────────────────────────────────
#define TSLocalizedString(key) NSLocalizedString(key, nil)
// ───────────────────────────────────────────────────────────────────────────

// ─── Design System ─────────────────────────────────────────────────────────
// Colors
#define TSColor_Background      [UIColor colorWithRed:242/255.f green:242/255.f blue:247/255.f alpha:1.f]
#define TSColor_Card            [UIColor whiteColor]
#define TSColor_Primary         [UIColor colorWithRed:0/255.f   green:122/255.f blue:255/255.f alpha:1.f]
#define TSColor_TextPrimary     [UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f]
#define TSColor_TextSecondary   [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f]
#define TSColor_Separator       [UIColor colorWithRed:229/255.f green:229/255.f blue:234/255.f alpha:1.f]
#define TSColor_Success         [UIColor colorWithRed:52/255.f  green:199/255.f blue:89/255.f  alpha:1.f]
#define TSColor_Danger          [UIColor colorWithRed:255/255.f green:59/255.f  blue:48/255.f  alpha:1.f]
#define TSColor_Warning         [UIColor colorWithRed:255/255.f green:149/255.f blue:0/255.f   alpha:1.f]
#define TSColor_Purple          [UIColor colorWithRed:175/255.f green:82/255.f  blue:222/255.f alpha:1.f]
#define TSColor_Teal            [UIColor colorWithRed:48/255.f  green:176/255.f blue:199/255.f alpha:1.f]
#define TSColor_Indigo          [UIColor colorWithRed:88/255.f  green:86/255.f  blue:214/255.f alpha:1.f]
#define TSColor_Pink            [UIColor colorWithRed:255/255.f green:45/255.f  blue:85/255.f  alpha:1.f]
#define TSColor_Gray            [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f]

// Spacing
#define TSSpacing_XS    4.f
#define TSSpacing_SM    8.f
#define TSSpacing_MD    16.f
#define TSSpacing_LG    24.f
#define TSSpacing_XL    32.f

// Corner Radius
#define TSRadius_SM     8.f
#define TSRadius_MD     12.f
#define TSRadius_LG     16.f

// Typography
#define TSFont_H1       [UIFont systemFontOfSize:20.f weight:UIFontWeightBold]
#define TSFont_H2       [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]
#define TSFont_Body     [UIFont systemFontOfSize:15.f weight:UIFontWeightRegular]
#define TSFont_Caption  [UIFont systemFontOfSize:12.f weight:UIFontWeightRegular]
// ───────────────────────────────────────────────────────────────────────────


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
