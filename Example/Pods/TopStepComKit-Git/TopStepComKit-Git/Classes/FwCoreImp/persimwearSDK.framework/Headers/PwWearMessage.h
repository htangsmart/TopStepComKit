//
//  PwWearMessage.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
#import "PwPromise.h"
#import "PwWearCallbackHelper.h"
#import "PwExecService.h"

typedef void(^DataChannelCallback) (NSInteger channel, NSData * _Nonnull bytes);

@interface PwWearMessage : NSObject

+(PwPromise * _Nonnull) syncLocationWithAppId:(NSString * _Nonnull)appId longitude:(float)longitude latitude:(float)latitude;

+(PwPromise * _Nonnull)sendMsgWithAppid:(NSString * _Nonnull)appid msg:(NSString * _Nonnull)msg;

+(void)registerReceiveMessageWithCb:(PwWearCallback _Nonnull)cb;

+(void)unRegisterReceive;

+(PwPromise * _Nonnull)pingWithAppid: (NSString * _Nonnull)appid;

+(PwPromise * _Nonnull)appIsInstalledWithAppid:(NSString * _Nonnull)appid;

+(PwPromise * _Nonnull)sendDataChannel: (NSInteger )channel bytes:(NSData * _Nonnull)bytes;

+(void)registerDataChannelReceive: (NSInteger)channle cb:(DataChannelCallback _Nonnull)cb;

+(void)unRegisterDataChannelReceive: (NSInteger) channel;

@end
