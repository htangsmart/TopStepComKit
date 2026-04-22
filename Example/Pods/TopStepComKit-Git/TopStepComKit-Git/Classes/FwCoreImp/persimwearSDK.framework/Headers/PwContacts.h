//
//  PwContacts.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwContacts : NSObject

+(PwPromise *)syncWithValues:(NSDictionary<NSString *, id> *)values;

+(PwPromise *)sync:(NSArray<NSDictionary<NSString *,id> *> *)values;

@end
