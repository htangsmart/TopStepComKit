//
//  TSConnectedPeripheral+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/1/22.
//

#import <TopStepToolKit/TopStepToolKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSConnectedPeripheral (Fw)

+ (instancetype _Nullable)connectedPeripheralWithFwPeripheral:(TSPeripheral *)peripheral
                                                 connectParam:(TSPeripheralConnectParam *)connectParam ;

@end

NS_ASSUME_NONNULL_END
