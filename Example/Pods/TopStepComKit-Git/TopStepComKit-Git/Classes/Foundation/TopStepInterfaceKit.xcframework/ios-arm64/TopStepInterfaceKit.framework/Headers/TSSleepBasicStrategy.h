//
//  TSSleepBasicStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSSleepStatisticsStrategy.h"
#import "TSSleepDailyModel.h"
#import "TSSleepSegment.h"
#import "TSSleepSummary.h"
#import "TSSleepDetailItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Basic sleep statistics strategy - Base class for all strategies
 * @chinese 基础睡眠统计策略 - 所有策略的基类
 *
 * @discussion
 * [EN]: Base class providing common methods for all sleep statistics strategies.
 * Subclasses can override processWithSleepDetailItems: to implement specific logic.
 *
 * [CN]: 为所有睡眠统计策略提供公共方法的基类。
 * 子类可以重写 processWithSleepDetailItems: 实现特定逻辑。
 */
@interface TSSleepBasicStrategy : NSObject <TSSleepStatisticsStrategy>

#pragma mark - Common Helper Methods (供子类使用的公共方法)

/**
 * @brief 移除数组末尾的清醒状态item
 * @chinese 移除数组末尾的清醒状态item
 */
- (void)removeTrailingAwakeItems:(NSMutableArray<TSSleepDetailItem *> *)items;

/**
 * @brief 分离夜间和日间睡眠数据
 * @chinese 分离夜间和日间睡眠数据
 *
 * @discussion
 * 将睡眠数据按照时间范围分离为夜间睡眠和日间睡眠：
 * 1. 初始化夜间睡眠数组和日间睡眠数组
 * 2. 遍历所有睡眠数据项，判断每个item是否在夜间时间范围内（startTime ~ endTime）
 * 3. 对于在夜间范围内的item：
 *    - 跳过开头的清醒状态，从第一个非清醒状态开始收集
 *    - 添加到夜间睡眠数组
 * 4. 对于不在夜间范围内的item：
 *    - 判断是否与夜间睡眠毗连（时间间隔<=1秒且都是非清醒状态）
 *    - 如果毗连，则归入夜间睡眠数组（处理跨时间边界的情况）
 *    - 否则归入日间睡眠数组
 * 5. 返回分离后的字典，包含"nightItems"和"daytimeItems"两个key
 *
 * @param items 待分离的睡眠数据数组
 * @param startTime 夜间睡眠开始时间（Unix时间戳）
 * @param endTime 夜间睡眠结束时间（Unix时间戳）
 * @return 包含"nightItems"和"daytimeItems"的字典
 */
- (NSDictionary *)separateNightAndDaytimeItems:(NSArray<TSSleepDetailItem *> *)items
                                  sleepStartTime:(NSTimeInterval)startTime
                                    sleepEndTime:(NSTimeInterval)endTime;

/**
 * @brief 判断item是否毗连夜间睡眠
 * @chinese 判断item是否毗连夜间睡眠
 */
- (BOOL)isAdjacentToNightSleep:(TSSleepDetailItem *)item
                     nightItems:(NSArray<TSSleepDetailItem *> *)nightItems;

/**
 * @brief 将睡眠数据分段（30分钟清醒分隔）
 * @chinese 将睡眠数据分段（30分钟清醒分隔）
 */
- (NSArray<NSArray<TSSleepDetailItem *> *> *)splitIntoSegments:(NSArray<TSSleepDetailItem *> *)items;

/**
 * @brief 从 TSSleepDetailItem 数组创建 TSSleepSegment 对象
 * @chinese 从 TSSleepDetailItem 数组创建 TSSleepSegment 对象
 */
- (nullable TSSleepSegment *)createSegmentFromItems:(NSArray<TSSleepDetailItem *> *)items
                                         periodType:(TSSleepPeriodType)periodType;

/**
 * @brief 根据时长过滤段
 * @chinese 根据时长过滤段
 */
- (void)filterSegmentsByDuration:(NSMutableArray<TSSleepSegment *> *)segments
                     minDuration:(NSTimeInterval)minDuration
                     maxDuration:(NSTimeInterval)maxDuration;

/**
 * @brief 创建睡眠统计汇总
 * @chinese 创建睡眠统计汇总
 */
- (nullable TSSleepSummary *)createSummaryFromItems:(NSArray<TSSleepDetailItem *> *)items;

@end

NS_ASSUME_NONNULL_END

