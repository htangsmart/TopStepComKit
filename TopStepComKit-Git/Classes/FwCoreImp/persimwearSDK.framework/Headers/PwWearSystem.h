//
//  PwWearSystem.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import "PwPromise.h"
#import "PwWearNotification.h"
#import "PwExecService.h"

@interface PwWearSystem : NSObject

+(PwPromise * _Nonnull) sendNoticeWithNotification:(PwWearNotification * _Nonnull)notification;

+(PwPromise * _Nonnull)syncSystemDataWithPhoneDbPath:(NSString * _Nonnull)phoneDbPath watchDbPath:(NSString * _Nonnull)watchDbPath values:(NSDictionary<NSString *, id> *)values;

+(PwPromise * _Nonnull)syncSystemTimeWithTimestamp: (NSInteger)timestamp timezone:(NSInteger)timezone DEPRECATED_MSG_ATTRIBUTE("Please use [PwWearSystem syncSystemTime:]");;

+(PwPromise * _Nonnull)syncSystemTime:(NSInteger)timestamp minuteOffset:(NSInteger)minuteOffset;

+(PwPromise * _Nonnull)syncDeviceInfo;

+(PwPromise * _Nonnull)togglePerformanceWithStatus:(BOOL)status;

+(PwPromise * _Nonnull)getDirSizeInfoWithPath:(NSString * _Nonnull)path;

+(PwPromise * _Nonnull)readDirAsync:(NSString * _Nonnull)path;

+(PwPromise * _Nonnull)openDevelopMode;

+(PwPromise * _Nonnull)closeDevelopMode;

@end
