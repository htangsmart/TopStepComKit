//
//  TSDataSyncInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//
//  文件说明:
//  数据同步管理协议，定义了设备健康数据同步的方法，包括心率、血氧、血压、压力、睡眠、体温、心电图、运动和日常活动等数据

#import <Foundation/Foundation.h>
#import "TSKitBaseInterface.h"
#import "TSHealthData.h"
#import "TSDataSyncConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Per-type sync completion callback
 * @chinese 单类型同步完成回调
 *
 * @param typeData
 * [EN]: The result of a single data type. Triggered once when that type finishes syncing.
 *       - On success: fetchError is nil, healthValues is valid (may be empty).
 *       - On failure: fetchError is non-nil, healthValues may be empty.
 *       Heart rate resting values are merged into the HeartRate TSHealthData and
 *       distinguished by valueType == Resting (single callback for HeartRate).
 * [CN]: 单个数据类型的结果，每种类型同步结束时触发一次。
 *       - 成功时：fetchError 为空，healthValues 有效（可能为空）。
 *       - 失败时：fetchError 非空，healthValues 可能为空。
 *       静息心率并入 HeartRate 的 TSHealthData，靠 valueType == Resting 区分（HeartRate 只回调一次）。
 */
typedef void(^TSDataSyncHealthDataBlock)(TSHealthData *typeData);

/**
 * @brief Data synchronization interface
 * @chinese 数据同步接口
 *
 * @discussion
 * [EN]: This protocol defines methods for synchronizing health data from the device.
 *       It provides a unified API using TSDataSyncConfig for flexible data synchronization.
 *       The interface supports:
 *       - Unified configuration-based synchronization
 *       - Multiple data types and granularities
 *       - Flexible time range specification
 *       - Automatic error handling and reporting
 *       - Simple sync-only operations
 *
 * [CN]: 该协议定义了从设备同步健康数据的方法。
 *       它提供了基于TSDataSyncConfig的统一API，支持灵活的数据同步。
 *       该接口支持：
 *       - 基于配置的统一同步
 *       - 多种数据类型和颗粒度
 *       - 灵活的时间范围指定
 *       - 自动错误处理和报告
 *       - 简单的纯同步操作
 */
@protocol TSDataSyncInterface <TSKitBaseInterface>


#pragma mark - Auto Sync from Last Time

/**
 * @brief Automatically synchronize daily data from last sync time
 * @chinese 从上次同步时间开始自动同步每日数据
 *
 * @param onHealthData
 * [EN]: Per-type callback, triggered once for each type when it finishes (on main thread).
 *       fetchError non-nil means that type failed. May be nil (equivalent to the old aggregated-only path).
 * [CN]: 单类型回调，每种类型完成时触发一次（主线程）。fetchError 非空即该类型失败。
 *       可为 nil（等价于旧的一次性聚合路径）。
 *
 * @param completion
 * [EN]: Completion handler providing per-type results and an optional fatal error.
 *       - results: Array of TSHealthData. Each element corresponds to one requested data type.
 *         · If that type succeeds (even with empty data), healthValues is set and fetchError is nil.
 *         · If that type fails, fetchError is populated and healthValues may be empty.
 *       - error: Non-nil only when a hard failure occurs and the operation cannot continue
 *         (e.g., config invalid, auth/network fatal, device busy/canceled). In this case,
 *         results may be nil or empty.
 * [CN]: 完成回调，返回每种类型的结果与可选的致命错误：
 *       - results: TSHealthData 数组。每个元素对应一种请求的数据类型。
 *         · 若该类型成功（即使无数据），healthValues 有效且 fetchError 为空；
 *         · 若该类型失败，在 fetchError 返回错误，healthValues 可能为空。
 *       - error: 仅在"无法继续"的致命错误时非空（如配置无效、鉴权/网络致命错误、设备繁忙/被取消）。
 *         此时 results 可能为 nil 或空。
 *
 * @discussion
 * [EN]: This method automatically synchronizes all types of daily aggregated data from the last sync time to current time.
 *       The SDK will automatically calculate the time range based on the last sync time stored in the database.
 *       Important notes:
 *       1. All data types are automatically synchronized (TSDataSyncOptionAll)
 *       2. Data granularity is automatically set to TSDataGranularityDay
 *       3. Time range is automatically calculated from last sync time to current time
 *       4. If last sync time is not found, SDK may use a default time (e.g., 7 days ago) or return an error
 *       5. The completion handler is called on the main thread
 *
 * [CN]: 此方法自动从上次同步时间到当前时间同步所有类型的每日聚合数据。
 *       SDK会自动根据数据库中存储的上次同步时间计算时间范围。
 *       重要说明：
 *       1. 自动同步所有数据类型（TSDataSyncOptionAll）
 *       2. 数据颗粒度自动设置为 TSDataGranularityDay
 *       3. 时间范围自动从上次同步时间计算到当前时间
 *       4. 如果找不到上次同步时间，SDK可能使用默认时间（如7天前）或返回错误
 *       5. 完成回调在主线程中调用
 */
- (void)syncDailyDataFromLastTime:(nullable TSDataSyncHealthDataBlock)onHealthData
                       completion:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;

/**
 * @brief Automatically synchronize raw data from last sync time
 * @chinese 从上次同步时间开始自动同步原始数据
 *
 * @param onHealthData
 * [EN]: Per-type callback, triggered once for each type when it finishes (on main thread).
 *       fetchError non-nil means that type failed. May be nil (equivalent to the old aggregated-only path).
 * [CN]: 单类型回调，每种类型完成时触发一次（主线程）。fetchError 非空即该类型失败。
 *       可为 nil（等价于旧的一次性聚合路径）。
 *
 * @param completion
 * [EN]: Completion handler providing per-type results and an optional fatal error.
 *       - results: Array of TSHealthData. Each element corresponds to one requested data type.
 *         · If that type succeeds (even with empty data), healthValues is set and fetchError is nil.
 *         · If that type fails, fetchError is populated and healthValues may be empty.
 *       - error: Non-nil only when a hard failure occurs and the operation cannot continue
 *         (e.g., config invalid, auth/network fatal, device busy/canceled). In this case,
 *         results may be nil or empty.
 * [CN]: 完成回调，返回每种类型的结果与可选的致命错误：
 *       - results: TSHealthData 数组。每个元素对应一种请求的数据类型。
 *         · 若该类型成功（即使无数据），healthValues 有效且 fetchError 为空；
 *         · 若该类型失败，在 fetchError 返回错误，healthValues 可能为空。
 *       - error: 仅在"无法继续"的致命错误时非空（如配置无效、鉴权/网络致命错误、设备繁忙/被取消）。
 *         此时 results 可能为 nil 或空。
 *
 * @discussion
 * [EN]: This method automatically synchronizes all types of raw data from the last sync time to current time.
 *       The SDK will automatically calculate the time range based on the last sync time stored in the database.
 *       Important notes:
 *       1. All data types are automatically synchronized (TSDataSyncOptionAll)
 *       2. Data granularity is automatically set to TSDataGranularityRaw
 *       3. Time range is automatically calculated from last sync time to current time
 *       4. If last sync time is not found, SDK may use a default time (e.g., 7 days ago) or return an error
 *       5. The completion handler is called on the main thread
 *       6. Raw data contains individual measurements, which may result in larger data volumes
 *
 * [CN]: 此方法自动从上次同步时间到当前时间同步所有类型的原始数据。
 *       SDK会自动根据数据库中存储的上次同步时间计算时间范围。
 *       重要说明：
 *       1. 自动同步所有数据类型（TSDataSyncOptionAll）
 *       2. 数据颗粒度自动设置为 TSDataGranularityRaw
 *       3. 时间范围自动从上次同步时间计算到当前时间
 *       4. 如果找不到上次同步时间，SDK可能使用默认时间（如7天前）或返回错误
 *       5. 完成回调在主线程中调用
 *       6. 原始数据包含单个测量值，可能导致数据量较大
 */
- (void)syncRawDataFromLastTime:(nullable TSDataSyncHealthDataBlock)onHealthData
                     completion:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;

#pragma mark - Configuration-based Synchronization

/**
 * @brief Synchronize health data using configuration
 * @chinese 使用配置同步健康数据
 *
 * @param config
 * [EN]: Configuration object containing all synchronization parameters,can not be nil
 * [CN]: 包含所有同步参数的配置对象,不能为空
 *
 * @param onHealthData
 * [EN]: Per-type callback, triggered once for each type when it finishes (on main thread).
 *       - On success: fetchError is nil, healthValues is valid (may be empty).
 *       - On failure (including mid-sync disconnect): fetchError is non-nil.
 *       Each requested type that passes capability filtering is guaranteed exactly one callback.
 *       May be nil (equivalent to the old aggregated-only path).
 * [CN]: 单类型回调，每种类型完成时触发一次（主线程）。
 *       - 成功时：fetchError 为空，healthValues 有效（可能为空）。
 *       - 失败时（含中途断连）：fetchError 非空。
 *       通过能力过滤的每种请求类型，保证有且仅有一次回调。
 *       可为 nil（等价于旧的一次性聚合路径）。
 *
 * @param completion
 * [EN]: Completion handler providing per-type results and an optional fatal error.
 *       - results: Array of TSHealthData. Each element corresponds to one requested data type.
 *         · If that type succeeds (even with empty data), healthValues is set and fetchError is nil.
 *         · If that type fails, fetchError is populated and healthValues may be empty.
 *       - error: Non-nil only when a hard failure occurs and the operation cannot continue
 *         (e.g., config invalid, auth/network fatal, device busy/canceled). In this case,
 *         results may be nil or empty.
 * [CN]: 完成回调，返回每种类型的结果与可选的致命错误：
 *       - results: TSHealthData 数组。每个元素对应一种请求的数据类型。
 *         · 若该类型成功（即使无数据），healthValues 有效且 fetchError 为空；
 *         · 若该类型失败，在 fetchError 返回错误，healthValues 可能为空。
 *       - error: 仅在“无法继续”的致命错误时非空（如配置无效、鉴权/网络致命错误、设备繁忙/被取消）。
 *         此时 results 可能为 nil 或空。
 *
 * @discussion
 * [EN]: This method synchronizes health data from the device using the provided configuration.
 *       The configuration determines data types, granularity, time range, and other parameters.
 *       Important notes:
 *       1. Configuration is validated before synchronization
 *       2. Multiple data types can be requested simultaneously
 *       3. Data granularity (raw or daily) is determined by configuration
 *       4. Time range is specified in configuration
 *       5. The completion handler is called on the main thread
 *       6. Configuration validation errors are returned in completion
 *
 * [CN]: 此方法使用提供的配置从设备同步健康数据。
 *       配置决定数据类型、颗粒度、时间范围和其他参数。
 *       重要说明：
 *       1. 同步前会验证配置
 *       2. 可以同时请求多个数据类型
 *       3. 数据颗粒度（原始或每日）由配置决定
 *       4. 时间范围在配置中指定
 *       5. 完成回调在主线程中调用
 *       6. 配置验证错误会在完成回调中返回
 */
- (void)syncDataWithConfig:(TSDataSyncConfig *_Nonnull)config
              onHealthData:(nullable TSDataSyncHealthDataBlock)onHealthData
                completion:(void (^)(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error))completion;


#pragma mark - Cancel

/**
 * @brief Cancel the ongoing data synchronization
 * @chinese 取消正在进行的数据同步
 *
 * @discussion
 * [EN]: Accepts the cancel request and returns immediately, so the App can refresh UI at once
 *       (e.g. show "cancelling") without blocking. Sync is not finished yet when this returns —
 *       the real end is delivered later via completion(error = eTSErrorSyncCancelled), at which
 *       point the App may do teardown (allow next sync / release the connection).
 *       If isSyncing == NO, this call is silently ignored.
 * [CN]: 受理取消请求并立即返回，App 可即时刷新 UI（如显示"取消中"），不阻塞。
 *       此方法返回时同步尚未结束——真正的结束稍后通过 completion(error = eTSErrorSyncCancelled)
 *       通知，届时 App 才可做收尾（允许下次同步 / 释放连接）。
 *       若 isSyncing == NO，此调用被静默忽略。
 */
- (void)cancelSync;


#pragma mark - Status Checking

/**
 * @brief Check if data synchronization is currently in progress
 * @chinese 检查数据同步是否正在进行中
 *
 * @return
 * [EN]: YES if data synchronization is currently active, NO otherwise
 * [CN]: 如果数据同步正在进行中返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method checks whether any data synchronization operation is currently running.
 *       It can be used to:
 *       1. Prevent multiple simultaneous sync operations
 *       2. Update UI state based on sync status
 *       3. Show appropriate user feedback
 *       4. Handle sync state in application lifecycle
 *
 * [CN]: 此方法检查是否有数据同步操作正在运行。
 *       可用于：
 *       1. 防止多个同步操作同时进行
 *       2. 根据同步状态更新UI
 *       3. 显示适当的用户反馈
 *       4. 在应用程序生命周期中处理同步状态
 *
 * @note
 * [EN]: This method should be called from the main thread for UI updates.
 *       The return value reflects the current state at the time of the call.
 * [CN]: 此方法应在主线程中调用以更新UI。
 *       返回值反映调用时的当前状态。
 */
- (BOOL)isSyncing;


@end

NS_ASSUME_NONNULL_END
