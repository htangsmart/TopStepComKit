//
//  TSNpkAppStatus.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSNpkAppStatus : TSNpkKitBase<TSAppStatusInterface>

- (void)startMonitoring ;

- (void)stopMonitoring ;

@end

NS_ASSUME_NONNULL_END
