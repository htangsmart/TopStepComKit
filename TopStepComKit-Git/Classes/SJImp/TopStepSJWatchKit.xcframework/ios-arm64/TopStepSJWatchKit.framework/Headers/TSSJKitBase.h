//
//  TSSJKitBase.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/1/9.
//

#import <Foundation/Foundation.h>
#import <SJWatchLib/SJWatchLib.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSSJComDataStorage.h"


NS_ASSUME_NONNULL_BEGIN

#define TSWMPeripheral [[TSSJComDataStorage sharedInstance] wmPeripheral]


@interface TSSJKitBase : NSObject<TSKitBaseInterface>

@property (nonatomic,weak) id delegate;

@property (nonatomic,strong) TSKitConfigOptions * kitOption ;

@end

NS_ASSUME_NONNULL_END
