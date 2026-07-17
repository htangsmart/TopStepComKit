//
//  PwDcm.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwDcm : NSObject

+(PwPromise *)setWithValues:(NSDictionary<NSString *, id> *) values poolName:(NSString * _Nonnull)poolName;

+(PwPromise *)getWithValues:(NSArray<NSString *> * _Nonnull)keys poolName:(NSString * _Nonnull)poolName;

@end
