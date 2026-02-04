//
//  TSConnectionHistory+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/14.
//

#import <TopStepToolKit/TopStepToolKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSConnectionHistory (Npk)

+ (instancetype)connectionHistoryWithPeripheral:(TSPeripheral *)peripheral
                                    operationType:(TSOperationType)operationType
                                         userID:(nonnull NSString *)userID;

@end

NS_ASSUME_NONNULL_END
