//
//  TSDataSyncConfig+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/12/3.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDataSyncConfig (Fit)

- (NSTimeInterval)startFitSyncTimeWithOption:(TSDataSyncOption)dataOption;

- (NSTimeInterval)endFitSyncTime;

@end

NS_ASSUME_NONNULL_END
