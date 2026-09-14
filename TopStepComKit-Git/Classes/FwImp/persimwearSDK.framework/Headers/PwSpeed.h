//
//  PwSpeed.h
//  persimwearSDK
//
//  Created by rtt on 2023/9/21.
//

#ifndef PwSpeed_h
#define PwSpeed_h
#import "PwExecService.h"
#import "PwWearCallbackHelper.h"

@interface PwSpeed : NSObject

+(void) test:(NSString *) timer_str cb:(PwWearCallback _Nonnull)cb;
@end

#endif /* PwSpeed_h */
