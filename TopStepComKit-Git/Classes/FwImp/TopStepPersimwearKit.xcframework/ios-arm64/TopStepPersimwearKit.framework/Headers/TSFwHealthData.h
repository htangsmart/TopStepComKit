//
//  TSFwHealthData.h
//  TopStepPersimwearKit
//
//  Created on 2025/12/19.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Intermediate data structure for Fw data synchronization
 * @chinese Fw数据同步的中间数据结构
 *
 * @discussion
 * EN: This class is used to store raw data pulled from the device before inserting into database.
 *     Similar to TSMetaHealthData in NPK implementation.
 * CN: 此类用于存储从设备拉取的原始数据，在插入数据库之前使用。
 *     类似于NPK实现中的TSMetaHealthData。
 */
@interface TSFwHealthData : NSObject

/**
 * @brief Sync time (timestamp when data was pulled from device)
 * @chinese 同步时间（从设备拉取数据时的时间戳）
 */
@property (nonatomic, assign) NSTimeInterval syncTime;

/**
 * @brief Data type option
 * @chinese 数据类型选项
 */
@property (nonatomic, assign) TSDataSyncOption option;

/**
 * @brief Raw data array from device (e.g., NSArray<TSHRValueItem *>, NSArray<TSBOValueItem *>, etc.)
 * @chinese 从设备拉取的原始数据数组（例如：NSArray<TSHRValueItem *>、NSArray<TSBOValueItem *> 等）
 */
@property (nonatomic, strong, nullable) NSArray *datas;

/**
 * @brief Error if data sync failed
 * @chinese 数据同步失败时的错误信息
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 * @brief Create TSFwHealthData with option
 * @chinese 使用选项创建TSFwHealthData
 */
+ (TSFwHealthData *)healthDataWithOption:(TSDataSyncOption)dataOption;

/**
 * @brief Create TSFwHealthData with option and error
 * @chinese 使用选项和错误创建TSFwHealthData
 */
+ (TSFwHealthData *)healthDataWithOption:(TSDataSyncOption)dataOption error:(NSError *_Nullable)error;

/**
 * @brief Create TSFwHealthData with option, datas and error
 * @chinese 使用选项、数据和错误创建TSFwHealthData
 */
+ (TSFwHealthData *)healthDataWithOption:(TSDataSyncOption)dataOption datas:(NSArray *_Nullable)datas error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

