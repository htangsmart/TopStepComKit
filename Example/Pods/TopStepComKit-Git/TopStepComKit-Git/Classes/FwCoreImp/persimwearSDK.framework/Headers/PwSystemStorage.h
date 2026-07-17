//
//  PwSystemStorage.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//
#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwSystemStorage : NSObject

+(PwPromise *_Nonnull)setWithValues:(NSDictionary<NSString *, id> *_Nonnull) values;


+(PwPromise *_Nonnull)getWithKeys:(NSArray<NSString *> * _Nonnull)keys;

@end


