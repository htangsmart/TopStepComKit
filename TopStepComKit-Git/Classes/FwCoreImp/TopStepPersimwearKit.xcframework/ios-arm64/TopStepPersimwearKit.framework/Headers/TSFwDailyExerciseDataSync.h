//
//  TSFwDailyExerciseDataSync.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSFwBaseDataSync.h"
#import "TSFwHealthData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwDailyExerciseDataSync : TSFwBaseDataSync

+ (void)syncTodayDailyExerciseDataCompletion:(void (^)(TSActivityDailyModel * _Nullable, NSError * _Nullable))completion;

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
 * @brief Query daily activity data from database
 * @chinese 从数据库查询日常活动数据
 */
+ (void)queryDataFromDBWithConfig:(TSDataSyncConfig *)config completion:(void (^)(NSArray<TSHealthValueModel *> *_Nullable, NSError *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
