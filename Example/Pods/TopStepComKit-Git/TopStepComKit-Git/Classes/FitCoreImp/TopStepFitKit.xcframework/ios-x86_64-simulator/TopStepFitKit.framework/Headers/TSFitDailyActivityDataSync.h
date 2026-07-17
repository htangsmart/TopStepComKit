//
//  TSFitDailyActivityDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSFitBaseDataSync.h"

@class TSFitSyncRawResult;

NS_ASSUME_NONNULL_BEGIN

@interface TSFitDailyActivityDataSync : TSFitBaseDataSync

+ (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel * _Nullable, NSError * _Nullable))completion ;

/**
 * @brief Whether stage1 should fetch today's aggregate in parallel for the given config
 * @chinese 阶段1 是否需要为该 config 并发拉取当日活动聚合
 *
 * @discussion 仅当 granularity = Day、options 含 DailyActivity、且时间范围包含当天时返回 YES。
 *             封装拉取条件，避免上层组合多个判断。
 */
+ (BOOL)needsParallelTodayFetchForConfig:(TSDataSyncConfig *)config;

/**
 * @brief Query daily activity from DB and merge today's aggregate from raw result if needed
 * @chinese 查询每日活动数据，必要时与 rawResult 中的当日聚合合并
 *
 * @param config Sync config / 同步配置
 * @param rawResult Stage1 raw result, providing today's model and anchorDayStart / 阶段1原始结果，含当日数据与 anchor
 * @param completion Result callback / 结果回调
 */
+ (void)queryDataFromDBWithConfig:(TSDataSyncConfig *)config
                         rawResult:(nullable TSFitSyncRawResult *)rawResult
                       completion:(void (^)(NSArray<TSHealthValueModel *> * _Nullable, NSError * _Nullable))completion;


@end

NS_ASSUME_NONNULL_END
