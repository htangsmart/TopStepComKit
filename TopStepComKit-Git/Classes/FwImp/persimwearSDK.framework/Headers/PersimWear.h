//
//  PersimWear.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/15.
//



#import "py_urpc.h"
#import "py_lpc.h"
#import "PwWearCallbackHelper.h"
#import "PwPromise.h"
#import "PwAppManager.h"
#import "PwWearMessage.h"
#import "PwFiles.h"
#import "PwSystemStorage.h"
#import "PwAppManager.h"
#import "PwDialManager.h"
#import "PwDcm.h"
#import "PwEnv.h"
#import "PwFirmware.h"
#import "PwSettings.h"
#import "PwTsdb.h"
#import "PwWearSystem.h"
#import "PwContacts.h"
#import "PwUtils.h"
#import "PwWearService.h"
#import "PwExecService.h"
#import "PwLogService.h"
#import "PwSpeed.h"



typedef void(^WearInitCallback) (NSInteger code, NSString * _Nonnull err_msg);

typedef BOOL(^ServiceInitCallback) (NSInteger code, NSString * _Nonnull msg);

@interface PersimWear : NSObject

+(void) initSdkWithLincese: (NSString *_Nonnull) lincese cb:(WearInitCallback _Nonnull )cb;

+(void) setWriteCallbackWithCb: (PwWriteBluetooth _Nonnull)cb;

+(void) readBluetoothWithDataBytes:(NSData *_Nonnull)dataBytes;

+(PwPromise * _Nonnull) connectDeviceBySocket:(NSString * _Nonnull)ipHost ipPort:(NSString * _Nonnull)ipPort;

+(void) listenServiceStatusWithCb: (ServiceInitCallback _Nonnull)cb;

+(PwPromise * _Nonnull) noticeBluetoothConnectStatusChangedWithStatus: (BOOL) status mtu:(NSInteger)mtu;

+(PwPromise * _Nonnull)updateMtu: (NSInteger)mtu;

+(void)setSyncLocationCallbackWithLocation: (id<LocationProtocol>)location;

+(void) releaseSDK;

+(NSDictionary<NSString *, id> * _Nullable)getVersion;


@end

//
//#if pwa
//
////#define MRLogError(frmt, ...) ((void)0)
////#define MRLogWarn(frmt, ...) ((void)0)
////#define PWLogInfo(frmt, ...) ((void)0)
////#define MRLogDebug(frmt, ...) ((void)0)
////#define MRLogVerbose(frmt, ...) ((void)0)
////#define pwa 10
//
//
//
//#else
//
////#ifndef MR_LOGGING_CONTEXT
////#define MR_LOGGING_CONTEXT 0
////#endif
//
//
//
//#if __has_include("CocoaLumberjack.h") || __has_include("CocoaLumberjack/CocoaLumberjack.h")
//    
//    #define pwa 200000
//    
//#else
//    
//    #define pwa 300
//                                             \
//        
//#endif
//
//#endif
