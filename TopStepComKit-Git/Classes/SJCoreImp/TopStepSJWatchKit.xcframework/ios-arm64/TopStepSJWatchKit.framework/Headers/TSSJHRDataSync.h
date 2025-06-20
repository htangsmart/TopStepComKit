//
//  TSSJHRDataSync.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/19.
//

#import "TSSJBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSJHRDataSync : TSSJBaseDataSync

+ (void)syncHistoryRestingHeartRateCompletion:(void (^)(NSArray<TSHRValueModel *> * _Nullable models, NSError * _Nullable error))completion ;


@end

NS_ASSUME_NONNULL_END
