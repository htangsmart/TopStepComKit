//
//  PwWearCallbackHelper.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//

#import <Foundation/Foundation.h>
// #import "PwCocoaLumberjack.h"

typedef BOOL(^PwWearCallback)(NSString * _Nonnull module, NSString * _Nonnull event, NSDictionary<NSString *, id> * _Nonnull jsonMsg);
typedef NSInteger(^PwWriteBluetooth)(NSData * _Nonnull dataBytes);

@protocol LocationProtocol <NSObject>

- (void)startLocationWithAppId:(NSString * _Nonnull)appId;
- (void)stopLocationWithAppId:(NSString *_Nonnull)appId;

@end

@interface PwWearCallbackHelper : NSObject

@property (class, nonatomic, strong) NSMutableDictionary<NSString *, PwWearCallback> *staticCallbackList;
@property (class, nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, PwWearCallback> *> *dynamicCallbackList;

+ (void)addCallback:(NSString *_Nonnull)type callback:(PwWearCallback _Nonnull )callback;
+ (void)addDynamicCallback:(NSString *_Nonnull)module eventId:(NSString *_Nonnull)eventId callback:(PwWearCallback _Nonnull )callback;
+ (void)removeCallback:(NSString *_Nonnull)type;
+ (void)removeDynamicCallback:(NSString *_Nonnull)module eventId:(NSString *_Nonnull)eventId;
+ (BOOL)execCallback:(NSString *_Nonnull)module event:(NSString *_Nonnull)event jsonMsg:(NSDictionary<NSString *, id> *_Nonnull)jsonMsg;
+ (BOOL)execCallbackHelper:(NSString *_Nonnull)module event:(NSString *_Nonnull)event jsonMsg:(NSDictionary<NSString *, id> *_Nonnull)jsonMsg;

@end

@interface PwWearCallbackType : NSObject

@property (class, nonatomic, readonly) NSString * _Nonnull file_push;
@property (class, nonatomic, readonly) NSString * _Nonnull service_status;
@property (class, nonatomic, readonly) NSString * _Nonnull message;
@property (class, nonatomic, readonly) NSString * _Nonnull appIsInstalled;
@property (class, nonatomic, readonly) NSString * _Nonnull launchApp;
@property (class, nonatomic, readonly) NSString * _Nonnull device_status;
@property (class, nonatomic, readonly) NSString * _Nonnull ota_process;
@property (class, nonatomic, readonly) NSString * _Nonnull syncLocation;
@property (class, nonatomic, readonly) NSString * _Nonnull wearInit;
@property (class, nonatomic, readonly) NSString * _Nonnull serviceInit;
@property (class, nonatomic, readonly) NSString * _Nonnull user_app_install;
@property (class, nonatomic, readonly) NSString * _Nonnull user_dial_install;
@property (class, nonatomic, readonly) NSString * _Nonnull tsdb_query;
@property (class, nonatomic, readonly) NSString * _Nonnull log_export;
@property (class, nonatomic, readonly) NSString * _Nonnull device_log_export;
@property (class, nonatomic, readonly) NSString * _Nonnull data_channel;

@end

