//
//  TSSportDetailVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@class TSSportModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport activity detail view controller
 * @chinese 运动活动详情视图控制器
 *
 * @discussion
 * [EN]: Displays comprehensive information about a sport activity, including:
 * - Activity overview (type, date, time)
 * - Core metrics (distance, calories, pace, steps)
 * - Heart rate analysis with interactive charts
 * - Heart rate zone distribution
 * - Sport-specific data (e.g., swimming metrics)
 *
 * [CN]: 显示运动活动的综合信息，包括：
 * - 活动概览（类型、日期、时间）
 * - 核心指标（距离、卡路里、配速、步数）
 * - 带交互式图表的心率分析
 * - 心率区间分布
 * - 运动特定数据（例如游泳指标）
 */
@interface TSSportDetailVC : TSBaseVC

/**
 * @brief Initialize with sport activity model
 * @chinese 使用运动活动模型初始化
 *
 * @param sport Sport activity model containing all activity data
 * @return Initialized sport detail view controller instance
 *
 * @discussion
 * [EN]: Creates a new sport detail view controller with the provided sport activity data.
 * The view controller will display all available information from the sport model.
 *
 * [CN]: 使用提供的运动活动数据创建新的运动详情视图控制器。
 * 视图控制器将显示运动模型中的所有可用信息。
 */
- (instancetype)initWithSport:(TSSportModel *)sport;

@end

NS_ASSUME_NONNULL_END
