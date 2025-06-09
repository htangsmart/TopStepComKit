//
//  PwFirmware.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//


#import <Foundation/Foundation.h>
#import "PwWearCallbackHelper.h"
#import "PwPromise.h"
#import "PwExecService.h"

@interface PwFirmware : NSObject

+(PwPromise * _Nonnull)getCurrentFirmwareVersion;

+(PwPromise * _Nonnull)getFirmWareUpgradeStatus;


+(PwPromise * _Nonnull)otaUpdateWithLocalPath: (NSString * _Nonnull)localPath cb:(PwWearCallback _Nonnull)cb;

+(PwPromise * _Nonnull)otaUpdateWithLocalPath: (NSString * _Nonnull)localPath retry:(NSInteger)retry cb:(PwWearCallback _Nonnull)cb;


+(PwPromise * _Nonnull)otaQuit;

@end

