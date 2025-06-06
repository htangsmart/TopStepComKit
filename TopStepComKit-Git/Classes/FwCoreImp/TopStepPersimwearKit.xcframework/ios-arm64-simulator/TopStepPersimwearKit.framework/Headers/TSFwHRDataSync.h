//
//  TSFwHRDataSync.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSFwBaseDataSync.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwHRDataSync : TSFwBaseDataSync

+ (void)syncRestingHeartRateCompletion:(void (^)(NSArray<TSHRValueModel *> *_Nonnull, NSError *_Nullable))completion ;

@end

NS_ASSUME_NONNULL_END
