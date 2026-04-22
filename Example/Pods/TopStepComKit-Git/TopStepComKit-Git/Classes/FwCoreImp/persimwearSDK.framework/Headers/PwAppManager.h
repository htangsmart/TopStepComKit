//
//  PwAppManager.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwWearCallbackHelper.h"
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwAppManager : NSObject

+(PwPromise *_Nonnull) appInstallWithLocalPath: (NSString * _Nonnull)localpath remotePath:(NSString * _Nonnull)remotePath isLaunch:(BOOL)isLaunch cb:(PwWearCallback _Nonnull )cb;

+(PwPromise *_Nonnull) syncAppInfo;

+(PwPromise *_Nonnull) appUninstallWithAppid: (NSString * _Nonnull)appId;

+(PwPromise * _Nonnull) launchWearAppWithUri: (NSString * _Nonnull)uri;

@end
