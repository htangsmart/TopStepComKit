//
//  TSAIAudioSessionIdleWaiter.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIAudioSessionIdleWaiter.h"

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepComKit/TopStepComKit.h>

/// 等待 SDK 空闲的最长时间（秒）：SDK 拆除通常不超过约 1.1 秒
static const NSTimeInterval kTSAIAudioSessionIdleWaitTimeout = 3.0;

@interface TSAIAudioSessionIdleWaiter ()

// 调用方名称（日志用）
@property (nonatomic, copy) NSString *label;
// 回调
@property (nonatomic, copy, nullable) void (^handler)(BOOL timedOut);
// 空闲通知的观察者
@property (nonatomic, strong, nullable) id<NSObject> observer;
// 开始等待的时刻（systemUptime）
@property (nonatomic, assign) NSTimeInterval beganUptime;
// 是否已回调或已取消
@property (nonatomic, assign) BOOL finished;

@end

@implementation TSAIAudioSessionIdleWaiter

#pragma mark - 生命周期

/** 以调用方名称与回调创建 */
- (instancetype)initWithLabel:(NSString *)label handler:(void (^)(BOOL timedOut))handler {
    self = [super init];
    if (self) {
        _label = [label copy];
        _handler = [handler copy];
        _beganUptime = NSProcessInfo.processInfo.systemUptime;
    }
    return self;
}

/** 移除仍在的观察者 */
- (void)dealloc {
    if (_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    }
}

#pragma mark - 公开方法

/** SDK 是否空闲：没有活动 Context 或 SDK 不支持该查询时视为空闲 */
+ (BOOL)isAudioSessionIdle {
    id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
    if (!audioRouting || ![audioRouting respondsToSelector:@selector(isAudioSessionIdle)]) {
        return YES;
    }
    return audioRouting.isAudioSessionIdle;
}

/** 开始等待 SDK 空闲 */
+ (instancetype)waitForIdleWithLabel:(NSString *)label handler:(void (^)(BOOL timedOut))handler {
    TSAIAudioSessionIdleWaiter *waiter = [[self alloc] initWithLabel:label handler:handler];
    [waiter beginWaiting];
    return waiter;
}

/** 取消等待 */
- (void)cancel {
    if (self.finished) {
        return;
    }
    self.finished = YES;
    self.handler = nil;
    [self removeIdleObserver];
    TSLog(@"[TSAIAudioSessionIdleWaiter] %@: wait cancelled after %.0f ms", self.label, [self waitedMilliseconds]);
}

#pragma mark - 私有方法

/** 监听空闲通知并设超时；登记之后已经空闲（通知早于登记）时，下一轮主线程回调 */
- (void)beginWaiting {
    TSLog(@"[TSAIAudioSessionIdleWaiter] %@: waiting for the SDK audio session teardown", self.label);
    // block 持有等待者：回调或取消之前保持存活
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:TSAIAudioSessionDidBecomeIdleNotification
                                                                      object:nil
                                                                       queue:[NSOperationQueue mainQueue]
                                                                  usingBlock:^(NSNotification *notification) {
        [self finishWithTimedOut:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIAudioSessionIdleWaitTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self finishWithTimedOut:YES];
    });
    if ([self.class isAudioSessionIdle]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishWithTimedOut:NO];
        });
    }
}

/** 结束等待并回调（只一次） */
- (void)finishWithTimedOut:(BOOL)timedOut {
    if (self.finished) {
        return;
    }
    self.finished = YES;
    [self removeIdleObserver];
    void (^handler)(BOOL) = self.handler;
    self.handler = nil;
    if (timedOut) {
        TSLog(@"[TSAIAudioSessionIdleWaiter] %@: SDK still busy after %.0f ms, continuing anyway",
              self.label, [self waitedMilliseconds]);
    } else {
        TSLog(@"[TSAIAudioSessionIdleWaiter] %@: SDK idle after %.0f ms", self.label, [self waitedMilliseconds]);
    }
    if (handler) {
        handler(timedOut);
    }
}

/** 移除空闲通知观察者 */
- (void)removeIdleObserver {
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
        self.observer = nil;
    }
}

/** 已等待的毫秒数 */
- (double)waitedMilliseconds {
    return (NSProcessInfo.processInfo.systemUptime - self.beganUptime) * 1000.0;
}

@end
