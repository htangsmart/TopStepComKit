//
//  TSFwComDataStorage.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <Foundation/Foundation.h>

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSFwComDataStorage : NSObject<TSComDataStorageInterface>


- (void)addConnectPeripheral:(TSPeripheral *)peripheral;

- (void)removeConnectPeripheral:(TSPeripheral *)peripheral;

- (NSArray<NSDictionary *> *)allPreConnectedPeripherals ;

- (BOOL)is850H;

@end

NS_ASSUME_NONNULL_END
