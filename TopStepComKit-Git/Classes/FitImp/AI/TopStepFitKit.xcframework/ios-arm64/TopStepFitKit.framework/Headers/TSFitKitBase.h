//
//  TSFitKitBase.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/1/2.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSFitComDataStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitKitBase : NSObject<TSKitBaseInterface>


- (BOOL)checkBluetoothAvailability;

@end

NS_ASSUME_NONNULL_END
