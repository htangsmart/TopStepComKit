#ifndef pybridge_h
#define pybridge_h

#include <stdio.h>
// #import "PwCocoaLumberjack.h"

@interface Bridge : NSObject

+(void) python_main;
+(void) python_start: (NSString * ) path;
+(void) python_end;
+(char *) python_call:(const char *) payload;
+(void) python_set_callback:(void *())Callback;

@end
#endif /* pybridge_h */
