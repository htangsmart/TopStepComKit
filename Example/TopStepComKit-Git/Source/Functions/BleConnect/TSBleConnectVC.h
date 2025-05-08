//
//  TSBleConnectVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSBleConnectVCDelegate <NSObject>

- (void)connectSuccess:(TSPeripheral *)peripheral param:(TSPeripheralConnectParam *)connectParam;

- (void)unbindSuccess;

@end

@interface TSBleConnectVC : TSBaseVC

@property (nonatomic,weak) id<TSBleConnectVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
