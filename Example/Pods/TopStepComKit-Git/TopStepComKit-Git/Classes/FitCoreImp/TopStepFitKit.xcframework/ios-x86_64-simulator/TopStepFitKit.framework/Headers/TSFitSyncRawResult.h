//
//  TSFitSyncRawResult.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>

@class FitCloudManualSyncRecordObject;
@class FitCloudRestingHRValue;
@class FitCloudDailyHRVDataModel;
@class TSActivityDailyModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Raw result from device data synchronization
 * @chinese 设备数据同步的原始结果
 *
 * 封装所有数据源的同步结果，后续新增数据源只需加属性，completion 签名不变。
 */
@interface TSFitSyncRawResult : NSObject

/**
 * @brief Records from manualSyncDataWithOption
 * @chinese manualSyncDataWithOption 返回的全量同步记录
 */
@property (nonatomic, copy, nullable) NSArray<FitCloudManualSyncRecordObject *> *records;

/**
 * @brief Resting heart rate values from queryRestingHRWithCompletion
 * @chinese queryRestingHRWithCompletion 返回的静息心率数据
 */
@property (nonatomic, copy, nullable) NSArray<FitCloudRestingHRValue *> *restingHRValues;

/**
 * @brief Daily HRV aggregated data from fetchDailyHRVDataWithCompletion
 * @chinese fetchDailyHRVDataWithCompletion 返回的 HRV 日级聚合数据（基线 / 上下限 / 状态）
 *
 * @discussion 由于 manualSync 仅返回 HRV 样本明细，无基线，必须通过独立 API 获取。
 */
@property (nonatomic, copy, nullable) NSArray<FitCloudDailyHRVDataModel *> *dailyHRVDataArray;

/**
 * @brief Today's aggregated activity model fetched in parallel with manualSync
 * @chinese 与 manualSync 并发拉取的当日活动聚合数据
 *
 * @discussion 仅当请求范围包含当天（isEndTimeInToday 为 YES）时填充。
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
