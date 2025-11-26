//
//  TSFitHRDataSync.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSFitBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitHRDataSync : TSFitBaseDataSync


+ (void)syncHistoryRestingHeartRateCompletion:(void (^)(NSArray<TSHRValueItem *> * _Nonnull, NSError * _Nullable))completion;


+ (void)syncRawRestingHeartRateDataFromStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime completion:(nonnull void (^)(NSArray<TSHRValueItem *> * _Nullable, NSError * _Nullable))completion ;


+ (void)syncTodayRestingHeartRateDataWithCompletion:(nonnull void (^)(TSHRValueItem * _Nullable, NSError * _Nullable))completion ;
    


@end

NS_ASSUME_NONNULL_END
