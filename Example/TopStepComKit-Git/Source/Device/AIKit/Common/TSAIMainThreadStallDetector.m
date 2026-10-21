//
//  TSAIMainThreadStallDetector.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIMainThreadStallDetector.h"

#import <UIKit/UIKit.h>

#import <TopStepComKit/TopStepComKit.h>

#if DEBUG

/// 卡顿阈值（秒）
static const NSTimeInterval kTSAIMainStallThreshold = 0.1;
/// 探测间隔（秒）
static const NSTimeInterval kTSAIMainStallPingInterval = 0.05;

@interface TSAIMainThreadStallDetector ()

// 探测队列（以下状态除标记外都只在该队列上访问）
@property (nonatomic, strong) dispatch_queue_t queue;
// 探测定时器
@property (nonatomic, strong, nullable) dispatch_source_t timer;
// 启动方计数
@property (nonatomic, assign) NSUInteger ownerCount;
// 是否有探测还没在主线程执行
@property (nonatomic, assign) BOOL pingInFlight;
// 探测代次：前后台切换时作废在途探测，避免把挂起时间当成卡顿
@property (nonatomic, assign) NSUInteger generation;
// App 是否处于活跃状态
@property (nonatomic, assign) BOOL appActive;
// 最近一次标记（主线程）
@property (nonatomic, copy, nullable) NSString *context;
// 最近一次标记的时刻（主线程，systemUptime）
@property (nonatomic, assign) NSTimeInterval contextUptime;

@end

#endif

@implementation TSAIMainThreadStallDetector

#pragma mark - 公开方法

/** 开始监测（引用计数） */
+ (void)startMonitoringForOwner:(NSString *)owner {
#if DEBUG
    TSAIMainThreadStallDetector *detector = [self sharedDetector];
    NSString *ownerName = [owner copy];
    dispatch_async(detector.queue, ^{
        detector.ownerCount += 1;
        if (detector.timer) {
            return;
        }
        [detector startTimer];
        TSLog(@"[mainStall] monitoring started by %@ (threshold %.0f ms)", ownerName, kTSAIMainStallThreshold * 1000.0);
    });
#endif
}

/** 停止监测：最后一个启动方停止后关闭定时器 */
+ (void)stopMonitoringForOwner:(NSString *)owner {
#if DEBUG
    TSAIMainThreadStallDetector *detector = [self sharedDetector];
    NSString *ownerName = [owner copy];
    dispatch_async(detector.queue, ^{
        if (detector.ownerCount == 0) {
            return;
        }
        detector.ownerCount -= 1;
        if (detector.ownerCount > 0 || !detector.timer) {
            return;
        }
        dispatch_source_cancel(detector.timer);
        detector.timer = nil;
        detector.generation += 1;
        detector.pingInFlight = NO;
        TSLog(@"[mainStall] monitoring stopped by %@", ownerName);
    });
#endif
}

/** 记录主线程接下来要做的事（主线程） */
+ (void)markContext:(NSString *)context {
#if DEBUG
    if (![NSThread isMainThread]) {
        return;
    }
    TSAIMainThreadStallDetector *detector = [self sharedDetector];
    detector.context = context;
    detector.contextUptime = NSProcessInfo.processInfo.systemUptime;
#endif
}

#if DEBUG

#pragma mark - 私有方法

/** 共享探测器 */
+ (instancetype)sharedDetector {
    static TSAIMainThreadStallDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[super allocWithZone:NULL] initPrivate];
    });
    return detector;
}

/** 初始化：探测队列与前后台监听 */
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.topstep.demo.main-stall-detector", DISPATCH_QUEUE_SERIAL);
        _appActive = YES;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onAppWillResignActive)
                       name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(onAppDidBecomeActive)
                       name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

/** 启动探测定时器（探测队列） */
- (void)startTimer {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    uint64_t interval = (uint64_t)(kTSAIMainStallPingInterval * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)interval), interval, interval / 5);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf sendPing];
    });
    self.timer = timer;
    dispatch_resume(timer);
}

/** 向主队列投递一次探测；上一次还没执行时不再投递（卡顿进行中，执行时一并测出时长） */
- (void)sendPing {
    if (self.pingInFlight || !self.appActive) {
        return;
    }
    self.pingInFlight = YES;
    NSUInteger generation = self.generation;
    NSTimeInterval sentUptime = NSProcessInfo.processInfo.systemUptime;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval ranUptime = NSProcessInfo.processInfo.systemUptime;
        NSString *context = self.context;
        NSTimeInterval contextUptime = self.contextUptime;
        dispatch_async(self.queue, ^{
            if (generation != self.generation) {
                return;
            }
            self.pingInFlight = NO;
            NSTimeInterval blocked = ranUptime - sentUptime;
            if (blocked <= kTSAIMainStallThreshold) {
                return;
            }
            NSString *contextText = context.length > 0
                ? [NSString stringWithFormat:@"%@, %.0f ms before", context, (ranUptime - contextUptime) * 1000.0]
                : @"-";
            TSLog(@"[mainStall] main thread blocked %.0f ms (context=%@)", blocked * 1000.0, contextText);
        });
    });
}

#pragma mark - 通知

/** 将要失去活跃：暂停探测，作废在途探测 */
- (void)onAppWillResignActive {
    dispatch_async(self.queue, ^{
        self.appActive = NO;
        self.generation += 1;
        self.pingInFlight = NO;
    });
}

/** 回到活跃：恢复探测，作废挂起期间的探测 */
- (void)onAppDidBecomeActive {
    dispatch_async(self.queue, ^{
        self.appActive = YES;
        self.generation += 1;
        self.pingInFlight = NO;
    });
}

#endif

@end
