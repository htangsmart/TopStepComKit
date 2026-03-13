//
//  TSHRDayChartView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSHRValueItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Chart display type
 * @chinese 图表显示类型
 */
typedef NS_ENUM(NSInteger, TSHRChartType) {
    /**
     * @brief Bar chart - 24 hourly bars
     * @chinese 柱状图 - 24小时柱子
     */
    TSHRChartTypeBar,
    /**
     * @brief Line chart - time-based polyline
     * @chinese 折线图 - 基于时间的折线
     */
    TSHRChartTypeLine
};

/**
 * @brief Heart rate day chart view
 * @chinese 心率日视图图表
 *
 * @discussion
 * [EN]: Displays heart rate data with time as X-axis (24 hours) and BPM as Y-axis.
 * Bar chart shows per-hour average; line chart plots each data point at its exact time position.
 *
 * [CN]: 以时间为横轴（24小时）、心率值为纵轴展示心率数据。
 * 柱状图展示每小时均值；折线图按数据点的精确时间位置绘制。
 */
@interface TSHRDayChartView : UIView

/**
 * @brief Current chart display type
 * @chinese 当前图表显示类型
 */
@property (nonatomic, assign) TSHRChartType chartType;

/**
 * @brief Configure chart with heart rate items for a given day
 * @chinese 用指定日期的心率数据配置图表
 *
 * @param items
 * EN: Array of TSHRValueItem, each with startTime and hrValue
 * CN: TSHRValueItem 数组，每项包含 startTime 和 hrValue
 *
 * @param date
 * EN: The date being displayed, used to compute 24-hour axis range
 * CN: 当前展示的日期，用于计算24小时轴范围
 */
- (void)configureWithItems:(NSArray<TSHRValueItem *> *)items date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
