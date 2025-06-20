//
//  WMLog.h
//  WMWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMLogInfo : NSObject

@property (nonatomic, strong) RACSignal<NSString *> *log;

+ (WMLogInfo *)sharedInstance;

- (void)registerLevel:(NSString *)level;

- (NSString *)mateName;

@end

@interface WMLog : NSObject

@property (nonatomic, strong) RACSignal<NSString *> *log;

+ (instancetype)sharedInstance;

- (void)registerLogInfo:(WMLogInfo *)logInfo;

@end

NS_ASSUME_NONNULL_END
