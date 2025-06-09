//
//  PwFiles.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//


#import "PwWearCallbackHelper.h"
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwFiles : NSObject


+(void)pushWithLocalPath: (NSString * _Nonnull)localPath remotePath:(NSString * _Nonnull)remotePath isSync:(BOOL)isSync continueWrite :(BOOL)continueWrite cb:(PwWearCallback _Nonnull )cb;

+(void)pushWithLocalPath: (NSString * _Nonnull)localPath remotePath:(NSString * _Nonnull)remotePath isSync:(BOOL)isSync cb:(PwWearCallback _Nonnull )cb;

+(void)pullWithLocalPath: (NSString * _Nonnull)localPath remotePath:(NSString * _Nonnull)remotePath isSync:(BOOL)isSync cb:(PwWearCallback _Nonnull )cb;

+(PwPromise * _Nonnull)deleteFileWithRemotePath: (NSString * _Nonnull)remotePath;

@end
