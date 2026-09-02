//
//  TSFwSyncContext.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//
//  文件说明:
//  Fw 数据同步责任链的共享上下文，贯穿整条 handler 链，承载一次同步的共享状态。
//  相比 Npk 版，额外携带 Fw 特有的今日活动聚合锚点与当日活动模型（原 TSFwSyncRawResult 职责）。

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepInterfaceKit/TSActivityDailyModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Shared context for one Fw data-sync run passed through the handler chain
 * @chinese 一次 Fw 数据同步的共享上下文，贯穿整条责任链
 */
@interface TSFwSyncContext : NSObject

/**
 * @brief Sync configuration
 * @chinese 本次同步配置
 */
@property (nonatomic, strong) TSDataSyncConfig *config;

/**
 * @brief Request end time used to advance lastSyncTime when a type returns empty data
 * @chinese 空数据类型推进 lastSyncTime 的目标时间（所有 option 共用同一个 endTime）
 */
@property (nonatomic, assign) NSTimeInterval requestEndTime;

/**
 * @brief Per-type completion callback (invoked on main thread), may be nil
 * @chinese 单类型完成回调（主线程触发），可为 nil
 */
@property (nonatomic, copy, nullable) TSDataSyncHealthDataBlock onHealthData;

/**
 * @brief Accumulated per-type results, used as the final completion snapshot
 * @chinese 逐类型累积的结果，作为最终 completion 的全量快照
 */
@property (nonatomic, strong) NSMutableArray<TSHealthData *> *results;

/**
 * @brief Returns whether a cancel has been requested (read at type boundaries)
 * @chinese 返回是否已请求取消（在类型边界读取）
 */
@property (nonatomic, copy) BOOL (^isCancelled)(void);

#pragma mark - Fw 特有（原 TSFwSyncRawResult 职责）

/**
 * @brief Day-start anchor locked at entry to keep "today" stable across the async pipeline
 * @chinese 入口锁定的今日 0 点锚点，保证异步管道里"今天"的语义不漂移
 */
@property (nonatomic, assign) NSTimeInterval anchorDayStart;

/**
 * @brief Today's aggregated activity fetched separately after DailyActivity, used in query stage
 * @chinese DailyActivity 后单独拉取的当日聚合活动，查库阶段使用
 */
@property (nonatomic, strong, nullable) TSActivityDailyModel *todayActivityModel;

@end

NS_ASSUME_NONNULL_END
