//
//  Tsdb.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwWearCallbackHelper.h"
#import "PwExecService.h"


@interface PwTsdb : NSObject

+(PwPromise * _Nonnull)queryCountWithDbPath:(NSString * _Nonnull)path fromTime:(NSInteger)fromTime toTime:(NSInteger)toTime;

+(PwPromise * _Nonnull)queryWithDbPath:(NSString * _Nonnull)dbPath fromTime:(NSInteger)fromTime toTime:(NSInteger)toTime startIndex:(NSInteger)startIndex count:(NSInteger)count cb:(PwWearCallback)cb;

+(PwPromise * _Nonnull)queryWithDbPath:(NSString * _Nonnull)dbPath fromTime:(NSInteger)fromTime toTime:(NSInteger)toTime cb:(PwWearCallback)cb;

@end
