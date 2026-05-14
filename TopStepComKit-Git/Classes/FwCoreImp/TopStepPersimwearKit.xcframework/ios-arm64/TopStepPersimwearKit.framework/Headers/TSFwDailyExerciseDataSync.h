//
//  TSFwDailyExerciseDataSync.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSFwBaseDataSync.h"
#import "TSFwHealthData.h"

@class TSDataSyncConfig;
@class TSFwSyncRawResult;

NS_ASSUME_NONNULL_BEGIN

@interface TSFwDailyExerciseDataSync : TSFwBaseDataSync

/**
 * @brief Sync today's daily exercise data from device
 * @chinese 从设备同步当天的每日活动数据
 */
+ (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel * _Nullable, NSError * _Nullable))completion;

/**
 * @brief Whether stage1 should fetch today's aggregate for the given config
 * @chinese 阶段1 是否需要为该 config 拉取当日活动聚合
 *
 * @discussion 仅当 granularity = Day、options 含 DailyActivity、且时间范围包含当天时返回 YES。
 *             封装拉取条件，避免上层组合多个判断。
 */
+ (BOOL)needsParallelTodayFetchForConfig:(TSDataSyncConfig *)config;

/**
 * @brief DEPRECATED: 此方法已废弃，请使用新的数据同步流程
 * @chinese DEPRECATED: 此方法已废弃，请使用新的数据同步流程
 */
+ (void)queryDataWithStartTime:(NSTimeInterval)startTime
                       endTime:(NSTimeInterval)endTime
                    completion:(void (^)(BOOL, NSArray<TSHealthValueModel *> *_Nullable, NSError *_Nullable))completion DEPRECATED_MSG_ATTRIBUTE("此方法已废弃，请使用新的数据同步流程");

/**
 * @brief Insert daily activity data to database
 * @chinese 将日常活动数据插入数据库
 */
+ (void)insertDataToDBWithValues:(TSFwHealthData *)healthValue completion:(void (^)(BOOL succeed, NSError *error))completion;

/**
 * @brief Query daily activity from DB and merge today's aggregate from raw result if needed
 * @chinese 查询每日活动数据，必要时与 rawResult 中的当日聚合合并
 *
 * @param config Sync config / 同步配置
 * @param rawResult Stage1 raw result, providing today's model and anchorDayStart / 阶段1原始结果，含当日数据与 anchor
 * @param completion Result callback / 结果回调
 */
+ (void)queryDataFromDBWithConfig:(TSDataSyncConfig *)config
                        rawResult:(nullable TSFwSyncRawResult *)rawResult
                       completion:(void (^)(NSArray<TSHealthValueModel *> *_Nullable, NSError *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
