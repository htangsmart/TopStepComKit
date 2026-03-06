//
//  TSSportCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSportModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Table view cell for displaying sport activity summary
 * @chinese 用于显示运动活动摘要的表格视图单元格
 *
 * @discussion
 * [EN]: A custom table view cell that displays a sport activity summary in a card-based layout.
 * The cell includes:
 * - Sport type icon and name
 * - Activity time range
 * - Core metrics (duration, distance, calories)
 * - Secondary metrics (heart rate, pace)
 * - Color-coded left bar indicating sport type
 *
 * [CN]: 自定义表格视图单元格，以卡片式布局显示运动活动摘要。
 * 单元格包括：
 * - 运动类型图标和名称
 * - 活动时间范围
 * - 核心指标（时长、距离、卡路里）
 * - 次要指标（心率、配速）
 * - 表示运动类型的彩色左侧竖条
 */
@interface TSSportCell : UITableViewCell

/**
 * @brief Configure the cell with sport activity data
 * @chinese 使用运动活动数据配置单元格
 *
 * @param sport Sport activity model containing all activity information
 *
 * @discussion
 * [EN]: Configures the cell to display the provided sport activity data.
 * The cell will automatically format and display all relevant metrics.
 *
 * [CN]: 配置单元格以显示提供的运动活动数据。
 * 单元格将自动格式化并显示所有相关指标。
 */
- (void)configureWithSport:(TSSportModel *)sport;

@end

NS_ASSUME_NONNULL_END
