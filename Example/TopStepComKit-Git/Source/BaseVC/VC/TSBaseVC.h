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
#import "TSEmptyView.h"
#import "TSLoadingHUD.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "UIViewController+Nav.h"


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

/**
 * @brief Shows a unified empty-state view above the table view.
 * @chinese 在表格视图上方显示统一空状态视图。
 *
 * @param title    主标题
 * @param subtitle 副标题，传 nil 则不显示
 */
- (void)showEmptyViewWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle;

/**
 * @brief Hides and removes the empty-state view.
 * @chinese 隐藏并移除空状态视图。
 */
- (void)hideEmptyView;

/**
 * @brief Shows the loading HUD over the current view.
 * @chinese 在当前视图上显示加载 HUD。
 */
- (void)showLoading;

/**
 * @brief Hides the loading HUD.
 * @chinese 隐藏加载 HUD。
 */
- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
