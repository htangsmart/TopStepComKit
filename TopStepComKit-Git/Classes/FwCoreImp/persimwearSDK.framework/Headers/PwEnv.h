//
//  PwEnv.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import "PwPromise.h"
#import "PwExecService.h"

@interface PwEnv : NSObject

+(PwPromise *)getWithKeys: (NSArray<NSString *> *)keys;

@end
