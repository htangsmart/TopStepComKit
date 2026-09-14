//
//  TSPeripheral+SJ.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/26.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheral (SJ)

- (void)requestSJPeripheralInfoWithWmPeripheral:(WMPeripheral *)peripheral completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
