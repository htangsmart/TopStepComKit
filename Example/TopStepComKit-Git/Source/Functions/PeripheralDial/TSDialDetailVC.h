//
//  TSDialDetailVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face detail view controller
 * @chinese 表盘详情页
 *
 * @discussion
 * [EN]: Displays a full-screen preview of a watch face. Shows a button at the
 *       bottom that is disabled (labeled "当前表盘") if this is the active dial,
 *       or enabled (labeled "设置为当前表盘") otherwise.
 *
 * [CN]: 展示表盘大图预览。底部按钮：若为当前表盘则置灰显示"当前表盘"，
 *       否则可点击"设置为当前表盘"调用切换接口。
 */
@interface TSDialDetailVC : TSBaseVC

/**
 * @brief Initialize with a dial model and its current state
 * @chinese 使用表盘模型及当前状态初始化
 *
 * @param dial
 * EN: The watch face model to display
 * CN: 要展示的表盘模型
 *
 * @param isCurrent
 * EN: YES if this dial is currently active on the device
 * CN: YES 表示该表盘是设备当前正在使用的表盘
 */
- (instancetype)initWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent;

/**
 * @brief Callback triggered after a successful dial switch
 * @chinese 切换表盘成功后的回调
 *
 * @discussion
 * [EN]: Called with the newly activated dial's ID after a successful switch.
 *       Used by the parent list page to refresh the highlighted state.
 * [CN]: 切换成功后传回新的 dialId，供列表页刷新高亮状态。
 */
@property (nonatomic, copy, nullable) void(^onDialSwitched)(NSString *newDialId);

@end

NS_ASSUME_NONNULL_END
