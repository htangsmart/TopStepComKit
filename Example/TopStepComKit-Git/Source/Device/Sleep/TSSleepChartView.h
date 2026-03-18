//
//  TSSleepChartView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSleepDetailItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep stage timeline chart view
 * @chinese 睡眠阶段时间轴图表视图
 *
 * @discussion
 * [EN]: Displays sleep stages (Deep, Light, REM, Awake) as colored blocks on a 24-hour timeline.
 * Timeline runs from 20:00 to 20:00 next day, matching sleep day boundary.
 *
 * [CN]: 在24小时时间轴上用彩色色块展示睡眠阶段（深睡、浅睡、REM、清醒）。
 * 时间轴从20:00到次日20:00，符合睡眠日边界。
 */
@interface TSSleepChartView : UIView

/**
 * @brief Configure chart with sleep detail items for a given day
 * @chinese 用指定日期的睡眠详情数据配置图表
 *
 * @param items
 * EN: Array of TSSleepDetailItem, each with stage, startTime, endTime
 * CN: TSSleepDetailItem 数组，每项包含 stage、startTime、endTime
 *
 * @param date
 * EN: The date being displayed (sleep day starts at 20:00)
 * CN: 当前展示的日期（睡眠日从20:00开始）
 */
- (void)configureWithItems:(NSArray<TSSleepDetailItem *> *)items date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
