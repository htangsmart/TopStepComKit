//
//  PwLogService.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/19.
//


#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwExecService.h"
// #import "PwCocoaLumberjack.h"

typedef void (^WearLogCallback)(NSString * _Nonnull logStr);

@interface PwLogService : NSObject


+(void)exportLog:(PwWearCallback)cb;

+(void)exportLog:(NSString * _Nonnull)filePath cb:(PwWearCallback)cb;

+(void)exportLog:(NSString * _Nonnull)filePath needCleanFile:(BOOL)needCleanFile cb:(PwWearCallback)cb;

+(void)exportWearDeviceLog:(NSString * _Nonnull)filePath needCleanFile:(BOOL)needCleanFile cb:(PwWearCallback)cb;

+(void) setLogCallbackWithCb:(WearLogCallback _Nonnull)cb;

+(void) setLogCallback: (PWLogFlag)level cb:(WearLogCallback _Nonnull)cb;

-(void)execLogCallback:(PWLogMessage * _Nonnull)logMessage;

@end

@interface PersimWearLogger : PWAbstractLogger <PWLogger>

@property (nonatomic, strong) PwLogService * _Nonnull _pwLogService;

@end
