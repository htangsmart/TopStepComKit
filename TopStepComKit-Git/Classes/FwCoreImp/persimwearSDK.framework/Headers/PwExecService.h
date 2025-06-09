//
//  PwExecService.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/15.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwUtils.h"
#import "PwCrypto.h"
#import "PyLpc.h"
// #import "PwCocoaLumberjack.h"

@interface PwExecService : NSObject

+(PwPromise * _Nonnull)execPyLpc:(NSString * _Nonnull)serviceName values:(NSDictionary<NSString * ,id> * _Nonnull)values;

+(PwPromise * _Nonnull)execPyLpc:(NSString * _Nonnull)serviceName values:(NSDictionary<NSString * ,id> * _Nonnull)values module:(NSString *)module cb:(PwWearCallback _Nonnull )cb;


@end
