//
//  TSHRVValueItem+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/05/29.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudManualSyncRecordObject;
@class FitCloudDailyHRVDataModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bridge layer between FitCloud HRV objects and TSHRVValueItem / DB rows
 * @chinese FitCloud HRV 对象与 TSHRVValueItem / 数据库行的桥接层
 *
 * @discussion
 * [EN]: HRV data has two data sources on the device side:
 *       1) `FitCloudHRVRecordObject` from manualSync (sample-level details)
 *       2) `FitCloudDailyHRVDataModel` from fetchDailyHRVDataWithCompletion (per-day baseline + status)
 *       This category provides conversion helpers for both to/from DB rows.
 * [CN]: HRV 数据在设备端有两条数据源：
 *       1) manualSync 返回的 `FitCloudHRVRecordObject`（样本明细）
 *       2) fetchDailyHRVDataWithCompletion 返回的 `FitCloudDailyHRVDataModel`（日级基线 + 状态）
 *       本类目提供两者与数据库行之间的转换工具。
 */
@interface TSHRVValueItem (Fit)

#pragma mark - Sample Items (manualSync record)

/**
 * @brief Convert a FitCloudHRVRecordObject to DB-row dicts for TSHeartRateVarTable
 * @chinese 将 FitCloudHRVRecordObject 转换为 TSHeartRateVarTable 入库 dict 数组
 *
 * @param record
 * EN: HRV record returned by manualSyncDataWithOption.
 * CN: manualSync 返回的 HRV record。
 *
 * @return
 * EN: Array of dicts ready to be inserted, or empty array if record/items invalid.
 * CN: 可直接入库的 dict 数组；record 为空或 items 为空时返回空数组。
 */
+ (NSArray<NSDictionary *> *)hrvDictsWithFitCloudManualSyncRecord:(nullable FitCloudManualSyncRecordObject *)record;

#pragma mark - Daily Aggregation (fetchDailyHRVData)

/**
 * @brief Convert FitCloudDailyHRVDataModel array to DB-row dicts for TSHeartRateVarDailyTable
 * @chinese 将 FitCloudDailyHRVDataModel 数组转换为 TSHeartRateVarDailyTable 入库 dict 数组
 *
 * @param models
 * EN: Daily HRV models from fetchDailyHRVDataWithCompletion.
 * CN: fetchDailyHRVDataWithCompletion 回调返回的日级 HRV 数据模型。
 *
 * @return
 * EN: Array of dicts ready to be upserted; entries with invalid date are skipped.
 * CN: 可直接 upsert 的 dict 数组；日期无效的条目会被跳过。
 */
+ (NSArray<NSDictionary *> *)dailyHRVDictsWithFitCloudDailyHRVDataModels:(nullable NSArray<FitCloudDailyHRVDataModel *> *)models;

@end

NS_ASSUME_NONNULL_END
