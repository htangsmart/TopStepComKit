//
//  TSAIQADeviceActionBar.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIQADeviceStatusView.h"

@class TSAIQADeviceActionBar;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callbacks of the device mode action bar
 * @chinese 设备模式底部操作区的回调
 */
@protocol TSAIQADeviceActionBarDelegate <NSObject>

/**
 * @brief Primary start / stop button tapped
 * @chinese 点击了启停主按钮
 *
 * @param bar
 * EN: Source bar
 * CN: 来源操作区
 */
- (void)deviceActionBarDidTapPrimary:(TSAIQADeviceActionBar *)bar;

/**
 * @brief A side route button tapped
 * @chinese 点击了两侧的路由按钮
 *
 * @param bar
 * EN: Source bar
 * CN: 来源操作区
 *
 * @param kind
 * EN: Input or output
 * CN: 拾音或播放
 */
- (void)deviceActionBar:(TSAIQADeviceActionBar *)bar didTapRoute:(TSAIQARouteKind)kind;

@end

/**
 * @brief Bottom bar of the device mode: side route buttons, big start / stop button and caption
 * @chinese 设备模式底部操作区：两侧路由按钮、启停大按钮与说明文字
 */
@interface TSAIQADeviceActionBar : UIView

/**
 * @brief Interaction delegate
 * @chinese 交互代理
 */
@property (nonatomic, weak, nullable) id<TSAIQADeviceActionBarDelegate> delegate;

/**
 * @brief Whether the session is armed; switches the primary button to a stop button
 * @chinese 会话是否已就绪；为 YES 时主按钮变为停止
 */
@property (nonatomic, assign) BOOL armed;

/**
 * @brief Whether the primary button can be tapped
 * @chinese 主按钮是否可点击
 */
@property (nonatomic, assign) BOOL primaryEnabled;

/**
 * @brief Whether the primary button shows a spinner
 * @chinese 主按钮是否显示加载指示
 */
@property (nonatomic, assign) BOOL busy;

/**
 * @brief Input route title under the left button
 * @chinese 左侧按钮下的拾音路由标题
 */
@property (nonatomic, copy) NSString *inputRouteTitle;

/**
 * @brief Output route title under the right button
 * @chinese 右侧按钮下的播放路由标题
 */
@property (nonatomic, copy) NSString *outputRouteTitle;

/**
 * @brief Caption under the primary button
 * @chinese 主按钮下方的说明
 */
@property (nonatomic, copy, nullable) NSString *caption;

/**
 * @brief Height excluding the safe-area inset
 * @chinese 不含安全区的高度
 *
 * @return
 * EN: Height in points
 * CN: 高度（pt）
 */
+ (CGFloat)contentHeight;

@end

NS_ASSUME_NONNULL_END
