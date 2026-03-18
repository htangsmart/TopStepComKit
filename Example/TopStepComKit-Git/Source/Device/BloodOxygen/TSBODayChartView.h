//
//  TSBODayChartView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSBOValueItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Chart display type
 * @chinese 图表显示类型
 */
typedef NS_ENUM(NSInteger, TSBOChartType) {
    /**
     * @brief Bar chart - 24 hourly bars
     * @chinese 柱状图 - 24小时柱子
     */
    TSBOChartTypeBar,
    /**
     * @brief Line chart - time-based polyline
     * @chinese 折线图 - 基于时间的折线
     */
    TSBOChartTypeLine
};

/**
 * @brief Blood oxygen day chart view
 * @chinese 血氧日视图图表
 *
 * @discussion
 * [EN]: Displays blood oxygen data with time as X-axis (24 hours) and SpO2% as Y-axis.
 * Bar chart shows per-hour average; line chart plots each data point at its exact time position.
 *
 * [CN]: 以时间为横轴（24小时）、血氧值为纵轴展示血氧数据。
 * 柱状图展示每小时均值；折线图按数据点的精确时间位置绘制。
 */
@interface TSBODayChartView : UIView

/**
 * @brief Current chart display type
 * @chinese 当前图表显示类型
 */
@property (nonatomic, assign) TSBOChartType chartType;

/**
 * @brief Configure chart with blood oxygen items for a given day
 * @chinese 用指定日期的血氧数据配置图表
 *
 * @param items
 * EN: Array of TSBOValueItem, each with startTime and oxyValue
 * CN: TSBOValueItem 数组，每项包含 startTime 和 oxyValue
 *
 * @param date
 * EN: The date being displayed, used to compute 24-hour axis range
 * CN: 当前展示的日期，用于计算24小时轴范围
 */
- (void)configureWithItems:(NSArray<TSBOValueItem *> *)items date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
