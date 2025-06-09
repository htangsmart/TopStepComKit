//
//  PwDialManager.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwWearCallbackHelper.h"
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwDialManager : NSObject

+(void)dialInstallWithLocalPath: (NSString * _Nonnull)localPath remotePath:(NSString * _Nonnull)remotePath dialAlias:(NSString * _Nonnull)dialId cb:(PwWearCallback _Nonnull)cb;

+(void)dialInstallWithLocalPath: (NSString * _Nonnull)localPath remotePath:(NSString * _Nonnull)remotePath cb:(PwWearCallback _Nonnull)cb;

+(PwPromise * _Nonnull)syncDialInfo;

+(PwPromise * _Nonnull)syncCurrentDial;

+(PwPromise * _Nonnull)dialApplyWithDialIdAlias:(NSString * _Nonnull)dialID;

+(PwPromise * _Nonnull)dialUninstallWithDialIdAlias:(NSString * _Nonnull)dialID;

+(PwPromise * _Nonnull)dialHideWithDialIdAlias:(NSString * _Nonnull)dialId;

+(PwPromise * _Nonnull)dialUnhideWithDialIdAlias:(NSString * _Nonnull)dialId;

+(PwPromise * _Nonnull)setDialOrderInfoWithDials: (NSArray<NSString  *> * _Nonnull)dials;

@end
