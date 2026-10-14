//
//  TSMetaDataSync.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/30.
//

#import "TSBusinessBase.h"
#import "TSMetaHealthData.h"
#import "PbDataParam.pbobjc.h"
#import "PbSportDetail.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN


@interface TSMetaDataSync : TSBusinessBase

/**
 * @brief Start data synchronization within time range
 * @chinese 开始同步时间范围内的数据
 *
 * @param dataOptions
 * [EN]: The type of data to synchronize.
 * [CN]: 要同步的数据类型。
 *
 * @param startTime
 * [EN]: Start time for data synchronization (timestamp since 2000).
 * [CN]: 数据同步的开始时间（以2000年开始的时间戳）。
 *
 * @param endTime
 * [EN]: End time for data synchronization (timestamp since 2000).
 * [CN]: 数据同步的结束时间（以2000年开始的时间戳）。
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 *
 * @param completion
 * [EN]: Completion callback block that returns the synchronized data array.
 * [CN]: 完成回调块，返回同步的数据数组。
 *
 * @discussion
 * [EN]: Initiates data synchronization process for the specified data type within the given time range.
 *        The method will handle the complete sync flow including start command, data retrieval, and response processing.
 * [CN]: 启动指定数据类型在给定时间范围内的数据同步过程。
 *       该方法将处理完整的同步流程，包括开始命令、数据检索和响应处理。
 */
+ (void)startSyncData:(TSMetaDataOpetions)dataOptions
            startTime:(NSTimeInterval)startTime
              endTime:(NSTimeInterval)endTime
           macAddress:(NSString *)macAddress
           completion:(void(^)(NSArray<TSMetaHealthData *> *_Nullable syncDatas,NSError *_Nullable error))completion;

/**
 * @brief Start data synchronization from last sync time to now
 * @chinese 开始同步从上次同步时间到现在的数据
 *
 * @param dataOptions
 * [EN]: The type of data to synchronize (must be a single type, not a combination).
 * [CN]: 要同步的数据类型（必须是单个类型，不能是组合）。
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 *
 * @param completion
 * [EN]: Completion callback block that returns the synchronized data array.
 * [CN]: 完成回调块，返回同步的数据数组。
 *
 * @discussion
 * [EN]: Initiates data synchronization process for the specified data type from the last sync time to current time.
 *        The method will automatically retrieve the last sync time from storage using the MAC address.
 *        If no last sync time is found, it will use a default time (7 days ago) as the start time.
 *        The method will automatically set the end time to current time and handle the complete sync flow.
 * [CN]: 启动指定数据类型从上次同步时间到当前时间的数据同步过程。
 *       该方法会使用MAC地址自动从存储中获取上次同步时间。如果未找到上次同步时间，将使用默认时间（7天前）作为开始时间。
 *       该方法将自动设置结束时间为当前时间，并处理完整的同步流程。
 */
+ (void)startSyncDataFromLastTimeWithOptions:(TSMetaDataOpetions)dataOptions
                                 macAddress:(NSString *)macAddress
                                  completion:(void(^)(NSArray<TSMetaHealthData *> *_Nullable syncDatas,NSError *_Nullable error))completion;


@end


NS_ASSUME_NONNULL_END
