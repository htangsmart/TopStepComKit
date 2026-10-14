//
//  TSNpkBaseDataSync.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/7.
//

#import "TSNpkKitBase.h"
#import "TSDataSyncConfig+Npk.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSNpkBaseDataSync : TSNpkKitBase

+ (void)queryDataFromDBWithConfig:(TSDataSyncConfig *)config completion:(void(^)(NSArray<TSHealthValueModel *> * _Nullable results,NSError *_Nullable error))completion;

+ (void)insertDataToDBWithValues:(TSMetaHealthData *_Nonnull)healthValue completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
