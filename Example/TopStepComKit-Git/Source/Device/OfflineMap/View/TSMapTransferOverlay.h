//
//  TSMapTransferOverlay.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Determinate progress overlay for download / push
 * @chinese 下载/推送共用的确定态进度覆盖层
 *
 * @discussion
 * [EN]: A full-screen modal overlay showing a circular progress ring, a percentage label and a one-line
 *       hint. It intercepts all touches while visible so the underlying page cannot be operated during a
 *       download or push. Shared by both the offline-map download flow and the push flow.
 * [CN]: 全屏模态覆盖层，展示环形进度、百分比文案与一行提示。展示期间拦截所有触摸，使下方页面在下载或
 *       推送过程中不可操作。离线地图下载流程与推送流程共用。
 */
@interface TSMapTransferOverlay : UIView

/**
 * @brief Show the overlay over a view with a title and hint
 * @chinese 在视图上展示覆盖层，附标题与提示
 *
 * @param view
 * EN: The container view to present within
 * CN: 承载覆盖层的容器视图
 *
 * @param title
 * EN: The overlay title, e.g. "正在下载地图"
 * CN: 覆盖层标题，例如「正在下载地图」
 *
 * @param hint
 * EN: A one-line hint below the progress, e.g. "下载过程不可取消"
 * CN: 进度下方的一行提示，例如「下载过程不可取消」
 */
- (void)showInView:(UIView *)view title:(NSString *)title hint:(NSString *)hint;

/**
 * @brief Update the current progress
 * @chinese 更新当前进度
 *
 * @param progress
 * EN: Progress value in range 0-100
 * CN: 进度值，范围 0-100
 */
- (void)updateProgress:(NSInteger)progress;

/**
 * @brief Update the overlay title (e.g. switching from download stage to push stage)
 * @chinese 更新覆盖层标题（例如从下载阶段切换到推送阶段）
 *
 * @param title
 * EN: The new title
 * CN: 新标题
 *
 * @param hint
 * EN: The new hint
 * CN: 新提示
 */
- (void)updateTitle:(NSString *)title hint:(NSString *)hint;

/**
 * @brief Dismiss the overlay
 * @chinese 关闭覆盖层
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
