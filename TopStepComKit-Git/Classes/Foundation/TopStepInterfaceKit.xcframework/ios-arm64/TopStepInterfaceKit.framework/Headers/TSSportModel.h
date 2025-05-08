//
//  TSSportModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>

#import "TSHRValueModel.h"
#import "TSSportItemModel.h"
#import "TSSportSummaryModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport activity model containing detailed metrics and measurements
 * @chinese 运动活动模型，包含详细的指标和测量数据
 *
 * @discussion
 * [EN]: This model represents a complete sport activity session, including:
 * - Basic activity information (type, duration, timestamps)
 * - Performance metrics (distance, steps, calories)
 * - Heart rate data (min, max, average, zones)
 * - Pace and speed measurements
 * - Detailed activity items and heart rate records
 *
 * [CN]: 此模型表示完整的运动活动会话，包括：
 * - 基本活动信息（类型、持续时间、时间戳）
 * - 性能指标（距离、步数、卡路里）
 * - 心率数据（最小值、最大值、平均值、区间）
 * - 配速和速度测量
 * - 详细的活动项目和心率记录
 */
@interface TSSportModel : NSObject

/**
 * @brief Sport activity summary data
 * @chinese 运动活动总结数据
 *
 * @discussion
 * [EN]: Contains the summary information of the sport activity, including:
 * - Overall statistics and achievements
 * - Performance metrics summary
 * - Heart rate zone distribution
 *
 * [CN]: 包含运动活动的总结信息，包括：
 * - 整体统计和成就
 * - 性能指标总结
 * - 心率区间分布
 */
@property (nonatomic, strong) TSSportSummaryModel *summary;

/**
 * @brief Sport activity detail items
 * @chinese 运动活动详细数据项
 *
 * @discussion
 * [EN]: An array of TSSportModel objects containing detailed metrics and measurements
 * recorded during the sport activity. Each item represents a specific time point or segment
 * during the activity and includes:
 * - Basic metrics (distance, steps, calories, pace)
 * - Swimming metrics (style, laps, strokes, SWOLF)
 * - Jump rope metrics (counts, breaks, consecutive jumps)
 * - Elliptical metrics (counts, frequencies)
 * - Rowing metrics (counts, frequencies)
 *
 * [CN]: TSSportModel对象数组，包含运动活动期间记录的详细指标和测量值。
 * 每个项目代表活动期间的特定时间点或片段，包括：
 * - 基本指标（距离、步数、卡路里、配速）
 * - 游泳指标（泳姿、趟数、划水次数、SWOLF值）
 * - 跳绳指标（跳绳次数、中断次数、连续跳绳次数）
 * - 椭圆机指标（计数、频率）
 * - 划船机指标（计数、频率）
 */
@property (nonatomic, strong) NSArray<TSSportItemModel *> *sportItems;

/**
 * @brief Heart rate data array for sport activity
 * @chinese 运动活动的心率数据数组
 *
 * @discussion
 * [EN]: An array of TSHRValueModel objects containing heart rate measurements recorded during
 * the sport activity. Each item represents a heart rate data point at a specific time,
 * providing continuous heart rate monitoring throughout the activity.
 * The data includes:
 * - Timestamp of the measurement
 * - Heart rate value in BPM (Beats Per Minute)
 * - Current heart rate zone
 *
 * [CN]: TSHRValueModel对象数组，包含运动活动期间记录的心率测量值。
 * 每个项目代表特定时间点的心率数据，提供整个活动过程中的连续心率监测。
 * 数据包括：
 * - 测量时间戳
 * - 心率值（每分钟心跳次数）
 * - 当前心率区间
 */
@property (nonatomic, strong) NSArray<TSHRValueModel *> *heartRateItems;

@end

NS_ASSUME_NONNULL_END
