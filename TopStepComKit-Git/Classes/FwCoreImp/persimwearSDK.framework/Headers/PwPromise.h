//
//  PwPromise.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/11.
//
#import <Foundation/Foundation.h>
#import "PwUtils.h"
#import "PwLog.h"

typedef BOOL (^ResolveBlock)(NSDictionary<NSString *, id> * _Nonnull result);
typedef BOOL (^RejectBlock)(NSDictionary<NSString *, id> * _Nonnull error);

@interface PwPromise : NSObject

- (instancetype _Nonnull )_initWithExecutor:(void (^_Nonnull)(RejectBlock _Nonnull resolve, RejectBlock _Nonnull reject))executor;
+ (instancetype _Nonnull )initWithExecutor:(void (^_Nonnull)(RejectBlock _Nonnull resolve, RejectBlock _Nonnull reject))executor;
- (void)callbackOnSuccess:(BOOL (^_Nonnull)(NSDictionary<NSString *, id> * _Nonnull))onSuccess onError:(BOOL (^_Nonnull)(NSDictionary<NSString *, id> * _Nonnull))onError;
- (PwPromise *_Nonnull)then:(BOOL (^_Nonnull)(NSDictionary<NSString *, id> * _Nonnull))onSuccess;
- (PwPromise *_Nonnull)error:(BOOL (^_Nonnull)(NSDictionary<NSString *, id> * _Nonnull))onError;
+ (PwPromise *_Nonnull)resolve:(NSDictionary<NSString *, id> * _Nonnull)result;
+ (PwPromise *_Nonnull)reject:(NSDictionary<NSString *, id> * _Nonnull)result;

@end



@interface PromiseStatus : NSObject
@property (class, readonly, strong) NSString * _Nonnull PENDING;
@property (class, readonly, strong) NSString * _Nonnull RESOLVED;
@property (class, readonly, strong) NSString * _Nonnull REJECTED;
@end
