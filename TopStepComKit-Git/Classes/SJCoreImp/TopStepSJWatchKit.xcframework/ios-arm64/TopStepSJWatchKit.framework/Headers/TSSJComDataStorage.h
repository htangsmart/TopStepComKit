//
//  TSSJPeripheralManger.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/2/26.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>



@interface TSSJComDataStorage : NSObject<TSComDataStorageInterface>

@property (nonatomic,strong) WMPeripheral * wmPeripheral;

@end

