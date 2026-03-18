//
//  TSHomeVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Home page view controller with health data cards
 * @chinese 首页视图控制器，展示健康数据卡片
 *
 * @discussion
 * [EN]: Displays activity rings at the top and a 2-column grid of health data cards.
 *       Pull-to-refresh triggers full data sync and updates all cards.
 *       Cards are grayed out when the device is disconnected or feature is unsupported.
 * [CN]: 顶部展示三环活动数据，下方显示 2 列方形健康卡片网格。
 *       下拉刷新触发全量数据同步并更新所有卡片。
 *       设备未连接或功能不支持时，卡片显示为灰色。
 */
@interface TSHomeVC : TSRootVC

@end

NS_ASSUME_NONNULL_END
