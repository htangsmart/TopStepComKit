//
//  PwWearService.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/16.
//

#import <Foundation/Foundation.h>
#import "PwWearCallbackHelper.h"
#import "pybridge.h"
#import "PyUrpc.h"
#import "PyLpc.h"
#import "PwContacts.h"
#import "PwCrypto.h"
// #import "PwCocoaLumberjack.h"

@interface PwWearService : NSObject

+(int)initService;

+(void)registerPyLpcCommonCallback: (PwWearCallback _Nonnull )commonCallback;

+(void)registerWriteCallback:(PwWriteBluetooth _Nonnull )writeCallback;

+(void)releaseSDK;

@end

