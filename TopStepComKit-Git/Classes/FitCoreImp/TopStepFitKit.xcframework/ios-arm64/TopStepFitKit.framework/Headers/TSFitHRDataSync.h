//
//  TSFitHRDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSFitBaseDataSync.h"

@class FitCloudRestingHRValue;

NS_ASSUME_NONNULL_BEGIN

@interface TSFitHRDataSync : TSFitBaseDataSync


+ (void)syncHistoryRestingHeartRateCompletion:(void (^)(NSArray<TSHRValueItem *> * _Nonnull, NSError * _Nullable))completion;


+ (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime completion:(nonnull void (^)(NSArray<TSHRValueItem *> * _Nullable, NSError * _Nullable))completion ;


+ (void)syncTodayRestingHeartRateDataWithCompletion:(nonnull void (^)(TSHRValueItem * _Nullable, NSError * _Nullable))completion ;


/**
 * @brief Insert resting heart rate data into database
 * @chinese 将静息心率数据插入数据库
 *
 * @param values 静息心率原始数据
 * @param completion 完成回调
 */
+ (void)insertRestingHRIntoDBWithValues:(NSArray<FitCloudRestingHRValue *> *)values
                             completion:(void (^)(BOOL succeed, NSError * _Nullable error))completion;
    


@end

NS_ASSUME_NONNULL_END
