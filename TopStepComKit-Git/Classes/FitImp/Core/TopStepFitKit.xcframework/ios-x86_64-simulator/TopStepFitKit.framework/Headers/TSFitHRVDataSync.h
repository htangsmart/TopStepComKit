//
//  TSFitHRVDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/05/29.
//

#import "TSFitBaseDataSync.h"

@class FitCloudDailyHRVDataModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief HRV (Heart Rate Variability) data sync component
 * @chinese 心率变异性 (HRV) 数据同步组件
 *
 * @discussion
 * [EN]: HRV data flows from two sources on the device side:
 *       1) `FitCloudHRVRecordObject` carried by manualSyncDataWithOption — sample details
 *       2) `fetchDailyHRVDataWithCompletion:` — daily baseline (lower/upper/center) + level
 *       Sample items go to TSHeartRateVarTable; daily aggregation goes to
 *       TSHeartRateVarDailyTable.
 * [CN]: HRV 数据在设备端有两条数据源：
 *       1) manualSync 携带的 `FitCloudHRVRecordObject` —— 样本明细
 *       2) `fetchDailyHRVDataWithCompletion:` —— 日级基线（lower/upper/center）+ level
 *       样本数据落 TSHeartRateVarTable；日级聚合落 TSHeartRateVarDailyTable。
 */
@interface TSFitHRVDataSync : TSFitBaseDataSync

#pragma mark - Daily HRV Fetch (parallel with manualSync)

/**
 * @brief Whether stage1 should fetch daily HRV in parallel for the given config
 * @chinese 阶段1 是否需要为该 config 并发拉取日级 HRV
 *
 * @discussion 仅当 options 含 HeartRateVar 时返回 YES。
 *             基线 / 上下限 / 状态在样本中没有，必须独立拉取。
 */
+ (BOOL)needsParallelDailyHRVFetchForConfig:(TSDataSyncConfig *)config;

/**
 * @brief Fetch daily HRV data via FitCloud independent API
 * @chinese 通过 FitCloud 独立接口拉取日级 HRV 数据
 *
 * @param completion Always called on the main queue.
 */
+ (void)syncDailyHRVCompletion:(void (^)(NSArray<FitCloudDailyHRVDataModel *> * _Nullable models, NSError * _Nullable error))completion;

#pragma mark - Persistence

/**
 * @brief Insert daily HRV models into TSHeartRateVarDailyTable (upsert by dayStartTime)
 * @chinese 将日级 HRV 模型 upsert 到 TSHeartRateVarDailyTable（以 dayStartTime 为唯一键）
 */
+ (void)insertDailyHRVIntoDBWithValues:(NSArray<FitCloudDailyHRVDataModel *> *)values
                            completion:(void (^)(BOOL succeed, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
