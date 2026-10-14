//
//  TSBleMetaKit.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/15.
//

#import "TSBusinessBase.h"
#import "TSBleMetaKitOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBleMetaKit : TSBusinessBase

+ (void)initBleMetaKitWithOption:(TSBleMetaKitOption *)kitOption completion:(TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
