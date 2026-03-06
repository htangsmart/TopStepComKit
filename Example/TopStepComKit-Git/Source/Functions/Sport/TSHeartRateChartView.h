//
//  TSHeartRateChartView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSportSummaryModel;
@class TSHRValueItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Chart display type
 * @chinese 图表显示类型
 */
typedef NS_ENUM(NSInteger, TSChartType) {
    /**
     * @brief Bar chart
     * @chinese 柱状图
     */
    TSChartTypeBar,
    /**
     * @brief Line chart
     * @chinese 曲线图
     */
    TSChartTypeLine
};

/**
 * @brief Heart rate chart view for displaying heart rate data visualization
 * @chinese 心率图表视图，用于显示心率数据可视化
 *
 * @discussion
 * [EN]: This view displays heart rate data in either bar chart or line chart format.
 * It supports switching between chart types and automatically samples data if there are too many points.
 *
 * [CN]: 此视图以柱状图或折线图格式显示心率数据。
 * 支持在图表类型之间切换，如果数据点过多会自动采样。
 */
@interface TSHeartRateChartView : UIView

/**
 * @brief Current chart display type
 * @chinese 当前图表显示类型
 *
 * @discussion
 * [EN]: The type of chart currently being displayed (bar or line).
 * Can be changed to switch between visualization styles.
 *
 * [CN]: 当前显示的图表类型（柱状图或折线图）。
 * 可以更改以在可视化样式之间切换。
 */
@property (nonatomic, assign) TSChartType chartType;

/**
 * @brief Configure the chart with sport summary and heart rate data
 * @chinese 使用运动摘要和心率数据配置图表
 *
 * @param summary Sport activity summary containing overall statistics
 * @param heartRateItems Array of heart rate measurements recorded during the activity
 *
 * @discussion
 * [EN]: Configures the chart view with sport summary data and detailed heart rate measurements.
 * The chart will display the heart rate values over time, with colors indicating different heart rate zones.
 *
 * [CN]: 使用运动摘要数据和详细的心率测量值配置图表视图。
 * 图表将显示随时间变化的心率值，颜色表示不同的心率区间。
 */
- (void)configureWithSummary:(TSSportSummaryModel *)summary heartRateItems:(NSArray<TSHRValueItem *> *)heartRateItems;

/**
 * @brief Switch between bar chart and line chart display
 * @chinese 在柱状图和折线图显示之间切换
 *
 * @discussion
 * [EN]: Toggles the chart type between bar and line visualization.
 * The chart will be redrawn with the new type.
 *
 * [CN]: 在柱状图和折线图可视化之间切换图表类型。
 * 图表将使用新类型重新绘制。
 */
- (void)switchChartType;

@end

NS_ASSUME_NONNULL_END
