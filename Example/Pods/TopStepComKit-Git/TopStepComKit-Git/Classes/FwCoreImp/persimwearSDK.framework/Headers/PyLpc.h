//
//  PyLpc.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/12.
//

#import <Foundation/Foundation.h>
#import "PwUtils.h"

typedef BOOL (^PyLrpcOutputCallback)(NSString *module, NSString *event, NSString *msg);

@interface PyLpc : NSObject

+(NSString * _Nonnull)execNativePyJsonLpc: (NSString * _Nonnull)serviceName input:(NSString * _Nonnull)input;

+(NSDictionary<NSString *, id> * _Nonnull)execPyJsonLpc: (NSString * _Nonnull)service input:(NSDictionary<NSString *, id> * _Nonnull)input;

+(void)setPyJsonLpcCallback:(PyLrpcOutputCallback _Nonnull)outputCallBack;

@end
