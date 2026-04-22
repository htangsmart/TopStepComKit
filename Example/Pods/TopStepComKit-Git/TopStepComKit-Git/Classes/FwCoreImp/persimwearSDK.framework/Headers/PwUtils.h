//
//  PwUtils.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/15.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwWearCallbackHelper.h"
// #import "PwCocoaLumberjack.h"

@interface PwUtils : NSObject

+(void)setInitStatus: (BOOL)status;

+(BOOL)getInitStatus;

+(void)outputBunildInfo;

+(NSDictionary<NSString *, id> * _Nonnull)generateError:(NSInteger)code errMsg:(NSString * _Nonnull)errMsg;

+(NSDictionary<NSString *, id> * _Nonnull)coverDictToString: (NSDictionary<NSString *, id> *)input;

+(NSDictionary<NSString *, id> * _Nonnull)coverStringToDict:(NSString *_Nonnull)input;

+(NSString * _Nonnull)getBundlePath;

+(void)setBundlePath: (NSString * _Nonnull)bundlePath;

+(NSDictionary<NSString *, id> * _Nullable)getVersion;

@end
