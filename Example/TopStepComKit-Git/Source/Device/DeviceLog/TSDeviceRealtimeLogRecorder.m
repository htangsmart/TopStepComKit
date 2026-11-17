#import "TSDeviceRealtimeLogRecorder.h"

#import <UIKit/UIKit.h>

#import <TopStepToolKit/TSLogPrinter.h>

#import "TSDeviceRealtimeLogStore.h"

NSNotificationName const TSDeviceRealtimeLogRecorderDidChangeNotification = @"TSDeviceRealtimeLogRecorderDidChange";

@interface TSDeviceRealtimeLogRecorder ()
@property (nonatomic, assign, readwrite) TSPeripheralRealtimeLogTypes selectedTypes;
@property (nonatomic, strong, readwrite, nullable) NSError *lastError;
@property (nonatomic, strong, nullable) id<TSPeripheralLogInterface> peripheralLog;
@property (nonatomic, strong, nullable) NSUUID *recordingIdentifier;
@property (nonatomic, assign) BOOL restartAfterStop;
@property (nonatomic, assign) BOOL stopCompletionPending;
// 统计供页面定时读取，每个数据包都不触发界面更新。
@property (atomic, assign, readwrite) uint64_t receivedBytes;
@property (atomic, assign, readwrite) NSUInteger savedFileCount;
@property (nonatomic, assign, readwrite) TSPeripheralRealtimeLogTypes captureTypes;
@property (nonatomic, assign, readwrite) BOOL hasCaptureResult;
@property (nonatomic, assign) NSTimeInterval startedAt;
@property (nonatomic, assign) NSTimeInterval finishedDuration;
@end

@implementation TSDeviceRealtimeLogRecorder

#pragma mark - 生命周期

// 应用进入后台时停止，即使实时日志页面已退出。
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

// 解除对应用状态的观察。
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

// 同一个抓取器为每次进入的日志页提供状态。
+ (instancetype)sharedRecorder {
    static TSDeviceRealtimeLogRecorder *recorder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [[TSDeviceRealtimeLogRecorder alloc] init];
    });
    return recorder;
}

// 冻结 SDK 实例与当前写入标识，供跨页面的回调使用。
- (void)startWithPeripheralLog:(id<TSPeripheralLogInterface>)peripheralLog
                        types:(TSPeripheralRealtimeLogTypes)types {
    if (self.recordingIdentifier || ![peripheralLog respondsToSelector:@selector(realtimeLogState)] ||
        [peripheralLog realtimeLogState] != TSPeripheralRealtimeLogStateIdle ||
        UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        return;
    }

    NSUUID *recordingIdentifier = [NSUUID UUID];
    self.recordingIdentifier = recordingIdentifier;
    self.peripheralLog = peripheralLog;
    self.lastError = nil;
    self.captureTypes = types;
    self.receivedBytes = 0;
    self.savedFileCount = 0;
    self.startedAt = 0;
    self.finishedDuration = 0;
    self.hasCaptureResult = NO;
    TSLogInfo(@"[RealtimeLog][Demo] start_requested recording=%@ types=0x%lX",
              recordingIdentifier.UUIDString, (unsigned long)types);
    TSDeviceRealtimeLogStore *store = [TSDeviceRealtimeLogStore sharedStore];
    __weak typeof(self) weakSelf = self;
    __block NSError *writeError = nil;
    [peripheralLog startRealtimeLogWithTypes:types dataHandler:^(NSString *deviceIdentifier, NSData *data) {
        if (writeError) {
            return;
        }
        NSError *error = nil;
        BOOL createdFile = NO;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL firstPacket = strongSelf.receivedBytes == 0 && data.length > 0;
        strongSelf.receivedBytes += data.length;
        if (firstPacket) {
            TSLogInfo(@"[RealtimeLog][Demo] first_packet recording=%@ bytes=%lu",
                      recordingIdentifier.UUIDString, (unsigned long)data.length);
        }
        if ([store appendData:data deviceIdentifier:deviceIdentifier recording:recordingIdentifier
                  createdFile:&createdFile error:&error]) {
            if (createdFile) {
                strongSelf.savedFileCount += 1;
            }
        } else {
            writeError = error;
            TSLogWarning(@"[RealtimeLog][Demo] write_failed recording=%@ packet_bytes=%lu error=%@/%ld",
                         recordingIdentifier.UUIDString, (unsigned long)data.length,
                         error.domain ?: @"none", (long)error.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf.recordingIdentifier isEqual:recordingIdentifier]) {
                    [strongSelf stopRecording];
                }
            });
        }
    } eventHandler:^(NSString *deviceIdentifier, TSPeripheralRealtimeLogEvent event, NSError *error) {
        if (event == TSPeripheralRealtimeLogEventStarted) {
            TSLogInfo(@"[RealtimeLog][Demo] started recording=%@", recordingIdentifier.UUIDString);
        } else {
            [store closeRecording:recordingIdentifier];
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSError *resultError = writeError ?: error;
            TSLogInfo(@"[RealtimeLog][Demo] finished recording=%@ result=%@ received_bytes=%llu files=%lu error=%@/%ld",
                      recordingIdentifier.UUIDString, resultError ? @"failed" : @"stopped",
                      (unsigned long long)strongSelf.receivedBytes, (unsigned long)strongSelf.savedFileCount,
                      resultError.domain ?: @"none", (long)resultError.code);
        }
        NSError *resultError = writeError ?: error;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleEvent:event recording:recordingIdentifier error:resultError];
        });
    }];
    [self notifyChange];
}

// 改类型需要等待原抓取停止成功，导航过程仍由同一抓取器处理。
- (void)updateSelectedTypes:(TSPeripheralRealtimeLogTypes)types
              peripheralLog:(id<TSPeripheralLogInterface>)peripheralLog {
    if (![peripheralLog respondsToSelector:@selector(realtimeLogState)]) {
        return;
    }
    TSPeripheralRealtimeLogState state = [peripheralLog realtimeLogState];
    if (self.selectedTypes == types || (self.peripheralLog && self.peripheralLog != peripheralLog) ||
        (state != TSPeripheralRealtimeLogStateIdle && state != TSPeripheralRealtimeLogStateRunning)) {
        return;
    }
    self.selectedTypes = types;
    if (state == TSPeripheralRealtimeLogStateRunning && self.recordingIdentifier) {
        self.restartAfterStop = YES;
        [self requestStop];
    } else {
        [self notifyChange];
    }
}

// 显式停止和应用退后台都会撤销计划的重开。
- (void)stopRecording {
    self.restartAfterStop = NO;
    [self requestStop];
}

// 手动刷新可以清除旧错误。
- (void)clearError {
    self.lastError = nil;
}

// 运行期间使用单调时钟，停止后保留最后一次抓取时长。
- (NSTimeInterval)elapsedDuration {
    return self.startedAt > 0 ? NSProcessInfo.processInfo.systemUptime - self.startedAt : self.finishedDuration;
}

#pragma mark - 私有方法

// 原终态先关闭文件，显式停止仍等 SDK 释放占用后再结算。
- (void)handleEvent:(TSPeripheralRealtimeLogEvent)event recording:(NSUUID *)recordingIdentifier
              error:(nullable NSError *)error {
    if (![self.recordingIdentifier isEqual:recordingIdentifier]) {
        return;
    }
    if (event == TSPeripheralRealtimeLogEventStarted) {
        if (!self.stopCompletionPending) {
            self.startedAt = NSProcessInfo.processInfo.systemUptime;
        }
        [self notifyChange];
        return;
    }
    [self freezeDuration];
    if (error) {
        self.lastError = error;
        self.restartAfterStop = NO;
    }
    if (!self.stopCompletionPending) {
        id<TSPeripheralLogInterface> peripheralLog = self.peripheralLog;
        [self releaseCapture];
        [self notifyAfterSDKReleaseForPeripheralLog:peripheralLog];
    } else {
        [self notifyChange];
    }
}

// 停止绑定原 SDK 实例，页面退出和重进不会改变目标。
- (void)requestStop {
    id<TSPeripheralLogInterface> peripheralLog = self.peripheralLog;
    TSPeripheralRealtimeLogState state = [peripheralLog realtimeLogState];
    if (self.stopCompletionPending ||
        (state != TSPeripheralRealtimeLogStateStarting && state != TSPeripheralRealtimeLogStateRunning)) {
        return;
    }

    self.stopCompletionPending = YES;
    [self freezeDuration];
    NSUUID *recordingIdentifier = self.recordingIdentifier;
    TSLogInfo(@"[RealtimeLog][Demo] stop_requested recording=%@ restart=%d",
              recordingIdentifier.UUIDString, self.restartAfterStop);
    __weak typeof(self) weakSelf = self;
    [peripheralLog stopRealtimeLogWithCompletion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf.recordingIdentifier isEqual:recordingIdentifier]) {
            return;
        }
        BOOL shouldRestart = success && strongSelf.restartAfterStop && !strongSelf.lastError &&
                             UIApplication.sharedApplication.applicationState != UIApplicationStateBackground;
        TSLogInfo(@"[RealtimeLog][Demo] stop_completed recording=%@ success=%d restart=%d error=%@/%ld",
                  recordingIdentifier.UUIDString, success, shouldRestart, error.domain ?: @"none", (long)error.code);
        if (error && !strongSelf.lastError) {
            strongSelf.lastError = error;
        }
        [strongSelf releaseCapture];
        if (shouldRestart) {
            [strongSelf startWithPeripheralLog:peripheralLog types:strongSelf.selectedTypes];
        } else {
            [strongSelf notifyChange];
        }
    }];
    [self notifyChange];
}

// 指定抓取结束后释放原 SDK 实例。
- (void)releaseCapture {
    self.hasCaptureResult = YES;
    self.recordingIdentifier = nil;
    self.peripheralLog = nil;
    self.restartAfterStop = NO;
    self.stopCompletionPending = NO;
}

// 停止阶段冻结时长，以便页面重进时保留结果。
- (void)freezeDuration {
    self.finishedDuration = self.elapsedDuration;
    self.startedAt = 0;
}

// 断连等 SDK 主动收尾没有停止回调，等 SDK 释放占用后刷新一次。
- (void)notifyAfterSDKReleaseForPeripheralLog:(id<TSPeripheralLogInterface>)peripheralLog {
    if (self.recordingIdentifier) {
        return;
    }
    if ([peripheralLog realtimeLogState] != TSPeripheralRealtimeLogStateStopping) {
        [self notifyChange];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [weakSelf notifyAfterSDKReleaseForPeripheralLog:peripheralLog];
    });
}

// 主线程广播状态，供当前页面更新显示。
- (void)notifyChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:TSDeviceRealtimeLogRecorderDidChangeNotification object:self];
}

#pragma mark - 应用状态回调

// 模拟与原生都沿用仅在应用前台抓取的规则。
- (void)didEnterBackground:(NSNotification *)notification {
    [self stopRecording];
}

@end
