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

// ─── Adaptive Color Helper ──────────────────────────────────────────────────
/// 深色模式自适应颜色，iOS 13+ 动态适配，iOS 12 退回亮色
static inline UIColor *TSAdaptiveColor(UIColor *light, UIColor *dark) {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
            return tc.userInterfaceStyle == UIUserInterfaceStyleDark ? dark : light;
        }];
    }
    return light;
}
// ───────────────────────────────────────────────────────────────────────────

// ─── Design System ─────────────────────────────────────────────────────────
// Colors — iOS 13+ 自动适配深色模式；iOS 12 使用亮色值
#define TSColor_Background    TSAdaptiveColor([UIColor colorWithRed:242/255.f green:242/255.f blue:247/255.f alpha:1.f], [UIColor colorWithRed:0/255.f   green:0/255.f   blue:0/255.f   alpha:1.f])
#define TSColor_Card          TSAdaptiveColor([UIColor whiteColor],                                                       [UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f])
#define TSColor_Primary       TSAdaptiveColor([UIColor colorWithRed:0/255.f   green:122/255.f blue:255/255.f alpha:1.f],  [UIColor colorWithRed:10/255.f  green:132/255.f blue:255/255.f alpha:1.f])
#define TSColor_TextPrimary   TSAdaptiveColor([UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f],  [UIColor whiteColor])
#define TSColor_TextSecondary TSAdaptiveColor([UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f],  [UIColor colorWithRed:152/255.f green:152/255.f blue:157/255.f alpha:1.f])
#define TSColor_Separator     TSAdaptiveColor([UIColor colorWithRed:229/255.f green:229/255.f blue:234/255.f alpha:1.f],  [UIColor colorWithRed:56/255.f  green:56/255.f  blue:58/255.f  alpha:1.f])
#define TSColor_Success       TSAdaptiveColor([UIColor colorWithRed:52/255.f  green:199/255.f blue:89/255.f  alpha:1.f],  [UIColor colorWithRed:48/255.f  green:209/255.f blue:88/255.f  alpha:1.f])
#define TSColor_Danger        TSAdaptiveColor([UIColor colorWithRed:255/255.f green:59/255.f  blue:48/255.f  alpha:1.f],  [UIColor colorWithRed:255/255.f green:69/255.f  blue:58/255.f  alpha:1.f])
#define TSColor_Warning       TSAdaptiveColor([UIColor colorWithRed:255/255.f green:149/255.f blue:0/255.f   alpha:1.f],  [UIColor colorWithRed:255/255.f green:159/255.f blue:10/255.f  alpha:1.f])
#define TSColor_Purple        TSAdaptiveColor([UIColor colorWithRed:175/255.f green:82/255.f  blue:222/255.f alpha:1.f],  [UIColor colorWithRed:191/255.f green:90/255.f  blue:242/255.f alpha:1.f])
#define TSColor_Teal          TSAdaptiveColor([UIColor colorWithRed:48/255.f  green:176/255.f blue:199/255.f alpha:1.f],  [UIColor colorWithRed:90/255.f  green:200/255.f blue:250/255.f alpha:1.f])
#define TSColor_Indigo        TSAdaptiveColor([UIColor colorWithRed:88/255.f  green:86/255.f  blue:214/255.f alpha:1.f],  [UIColor colorWithRed:94/255.f  green:92/255.f  blue:230/255.f alpha:1.f])
#define TSColor_Pink          TSAdaptiveColor([UIColor colorWithRed:255/255.f green:45/255.f  blue:85/255.f  alpha:1.f],  [UIColor colorWithRed:255/255.f green:55/255.f  blue:95/255.f  alpha:1.f])
#define TSColor_Gray          TSAdaptiveColor([UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f],  [UIColor colorWithRed:152/255.f green:152/255.f blue:157/255.f alpha:1.f])

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
