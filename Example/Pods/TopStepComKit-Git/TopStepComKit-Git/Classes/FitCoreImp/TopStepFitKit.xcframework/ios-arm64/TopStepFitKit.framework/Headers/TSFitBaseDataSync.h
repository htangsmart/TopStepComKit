//
//  TSFitBaseDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <TopStepFitKit/TSFitKitBase.h>
#import <TopStepFitKit/TopStepFitKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "TSFitComDataStorage.h"
#import "TSDataSyncConfig+Fit.h"
NS_ASSUME_NONNULL_BEGIN



@interface TSFitBaseDataSync : TSFitKitBase



+ (void)queryDataFromDBWithConfig:(TSDataSyncConfig *)config completion:(nonnull void (^)(NSArray<TSHealthValueModel *> * _Nullable, NSError * _Nullable))completion;


/**
 * @brief Insert data into the database from a FitCloudManualSyncRecordObject.
 * @chinese 从FitCloudManualSyncRecordObject插入数据到数据库。
 * 
 * @param record
 * EN: The record object containing data to be inserted.
 * CN: 包含要插入数据的记录对象。
 * 
 * @param completion
 * EN: The completion block that returns the success status and an error if any.
 * CN: 完成块，返回成功状态和可能的错误。
 */
+ (void)insertDataIntoDBWithRecord:(FitCloudManualSyncRecordObject *)record 
                        completion:(void (^)(BOOL isSuccess, NSError *_Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
