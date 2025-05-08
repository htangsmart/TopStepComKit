//
//  TSSportInterface.h
//  TopStepCRPKit
//
//  Created by 磐石 on 2025/4/16.
//

#import "TSKitBaseInterface.h"
#import "TSSportModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport activity data management interface
 * @chinese 运动活动数据管理接口
 *
 * @discussion
 * [EN]: This interface provides methods for synchronizing sport activity data from the device,
 * including detailed metrics, heart rate data, and activity summaries for various sport types.
 * [CN]: 该接口提供从设备同步运动活动数据的方法，包括详细指标、心率数据和各种运动类型的活动摘要。
 */
@protocol TSSportInterface <TSKitBaseInterface>


/**
 * @brief Synchronize sport history data within a specified time range
 * @chinese 同步指定时间范围内的运动历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param endTime
 * [EN]: End time for data synchronization (timestamp)
 * [CN]: 数据同步的结束时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized sport activity data or error
 * [CN]: 包含同步的运动活动数据或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error))completion;

/**
 * @brief Synchronize sport history data from a specified start time until now
 * @chinese 从指定开始时间同步至今的运动历史数据
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp)
 * [CN]: 数据同步的开始时间（时间戳）
 *
 * @param completion
 * [EN]: Completion block with synchronized sport activity data or error
 * [CN]: 包含同步的运动活动数据或错误的完成回调块
 */
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
