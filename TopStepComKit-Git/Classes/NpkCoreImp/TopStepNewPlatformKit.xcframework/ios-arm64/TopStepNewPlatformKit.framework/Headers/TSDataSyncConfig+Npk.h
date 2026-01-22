//
//  TSDataSyncConfig+Npk.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSDataSyncConfig (Npk)


- (NSTimeInterval)startSyncNpkTimeWithOption:(TSDataSyncOption)dataOption;

- (NSTimeInterval)endSyncNpkTime;

@end

NS_ASSUME_NONNULL_END
