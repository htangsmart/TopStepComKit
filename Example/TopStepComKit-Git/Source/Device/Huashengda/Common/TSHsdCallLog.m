//
//  TSHsdCallLog.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdCallLog.h"

NSNotificationName const TSHsdCallLogDidChangeNotification = @"TSHsdCallLogDidChangeNotification";

static const NSUInteger kTSHsdCallLogMaxCount = 200;

@implementation TSHsdCallLogEntry

- (NSTimeInterval)durationMs {
    if (!self.finishedAt || !self.startedAt) { return 0; }
    return [self.finishedAt timeIntervalSinceDate:self.startedAt] * 1000.0;
}

@end

@interface TSHsdCallLog ()
@property (nonatomic, strong) NSMutableArray<TSHsdCallLogEntry *> *storage;
@property (nonatomic, assign) BOOL lastCallFailed;
@end

@implementation TSHsdCallLog

+ (instancetype)shared {
    static TSHsdCallLog *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TSHsdCallLog alloc] init];
        instance.storage = [NSMutableArray array];
    });
    return instance;
}

- (NSArray<TSHsdCallLogEntry *> *)entries {
    return [self.storage copy];
}

- (TSHsdCallLogEntry *)begin:(NSString *)method params:(nullable NSString *)params {
    TSHsdCallLogEntry *entry = [[TSHsdCallLogEntry alloc] init];
    entry.method = method ?: @"";
    entry.params = params ?: @"";
    entry.startedAt = [NSDate date];
    [self.storage insertObject:entry atIndex:0];
    if (self.storage.count > kTSHsdCallLogMaxCount) { [self.storage removeLastObject]; }
    [self ts_notify];
    return entry;
}

- (void)finish:(TSHsdCallLogEntry *)entry success:(BOOL)success error:(nullable NSError *)error result:(nullable NSString *)result {
    if (!entry) { return; }
    entry.finished = YES;
    entry.finishedAt = [NSDate date];
    entry.success = success;
    entry.error = error;
    entry.result = result;
    self.lastCallFailed = !success;
    [self ts_notify];
}

- (void)clear {
    [self.storage removeAllObjects];
    self.lastCallFailed = NO;
    [self ts_notify];
}

- (void)ts_notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TSHsdCallLogDidChangeNotification object:self];
    });
}

@end
