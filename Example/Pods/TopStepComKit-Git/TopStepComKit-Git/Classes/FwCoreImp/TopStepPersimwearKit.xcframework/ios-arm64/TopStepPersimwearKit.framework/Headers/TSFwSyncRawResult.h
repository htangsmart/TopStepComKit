//
//  TSFwSyncRawResult.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/05/09.
//

#import <Foundation/Foundation.h>

@class TSActivityDailyModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Raw result from Fw device data synchronization
 * @chinese Fw 设备数据同步的原始结果
 *
 * @discussion 封装 manualSync 之外的并发数据源结果，后续新增数据源只需加属性。
 */
@interface TSFwSyncRawResult : NSObject

/**
 * @brief Today's aggregated activity model fetched separately from main sync
 * @chinese 与主同步独立拉取的当日活动聚合数据
 *
 * @discussion 仅当 granularity=Day、options 含 DailyActivity、且时间范围包含当天时填充。
 *             用于阶段3合并到 DB 聚合结果，避免阶段3再发一次蓝牙请求引发跨0点 race。
 */
@property (nonatomic, strong, nullable) TSActivityDailyModel *todayActivityModel;

/**
 * @brief Anchor "today 00:00:00" captured at sync entry
 * @chinese 同步入口时刻锁定的"目标当天 0 点"时间戳
 *
 * @discussion 0 表示未启用当日合并；非 0 时作为 dayModels 匹配 key，
 *             保证整个异步管道里"今天"的语义一致，不受跨0点影响。
 */
@property (nonatomic, assign) NSTimeInterval anchorDayStart;

@end

NS_ASSUME_NONNULL_END
