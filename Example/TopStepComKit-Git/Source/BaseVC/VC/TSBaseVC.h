//
//  TSBaseVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"
#import "TSTableViewCell.h"
#import "TSValueModel.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "UIViewController+Nav.h"

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

@interface TSBaseVC : TSRootVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *sourceTableview;
@property (nonatomic, strong) NSArray *sourceArray;

/**
 * @brief Initialize data, called before setupViews. Subclasses should override to set initial state.
 * @chinese 初始化数据，在 setupViews 之前调用。子类可重写以设置初始状态。
 */
- (void)initData;

/**
 * @brief Add and configure subviews. Subclasses should override to build custom view hierarchies.
 * @chinese 添加并配置子视图。子类可重写以构建自定义视图层级。
 */
- (void)setupViews;

/**
 * @brief Apply frame-based layout. Subclasses should override to position custom views.
 * @chinese 执行 Frame 布局。子类可重写以定位自定义视图。
 */
- (void)layoutViews;

/**
 * @brief Returns the display name for the cell at the given index path.
 * @chinese 返回指定 indexPath 的单元格展示名称。
 */
- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath;

/**
 * @brief Shows an alert dialog with the given message.
 * @chinese 显示包含指定内容的弹窗提示。
 */
- (void)showAlertWithMsg:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
