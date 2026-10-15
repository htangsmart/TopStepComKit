//
//  TSAIEarbudsPickupAvailability.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/10/15.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIEarbudsPickupAvailability.h"

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "TSAIAudioRecordAppCapture.h"
#import "TSDeviceCoordinator.h"

const NSTimeInterval TSAIEarbudsReconnectGracePeriod = 5.0;

/// 多路事件合并为一次刷新的延迟
static const NSTimeInterval kTSAIEarbudsPickupRefreshDelay = 0.3;

#pragma mark - TSAIEarbudsPickupStatus

@interface TSAIEarbudsPickupStatus ()

// 选项状态
@property (nonatomic, assign, readwrite) TSAIEarbudsPickupState state;
// 蓝牙音频设备名称
@property (nonatomic, copy, readwrite, nullable) NSString *deviceName;

/** 创建状态快照 */
+ (instancetype)statusWithState:(TSAIEarbudsPickupState)state deviceName:(nullable NSString *)deviceName;

/** 私有初始化 */
- (instancetype)initPrivate;

@end

@implementation TSAIEarbudsPickupStatus

/** 创建状态快照 */
+ (instancetype)statusWithState:(TSAIEarbudsPickupState)state deviceName:(NSString *)deviceName {
    TSAIEarbudsPickupStatus *status = [[self alloc] initPrivate];
    status.state = state;
    status.deviceName = deviceName;
    return status;
}

/** 私有初始化 */
- (instancetype)initPrivate {
    return [super init];
}

/** 除充电仓不可用外均可点击 */
- (BOOL)isSelectable {
    return self.state != TSAIEarbudsPickupStateCaseRequired;
}

@end

#pragma mark - TSAIEarbudsPickupChangeObserver

/** 合并路由变化、回到前台、设备连接变化事件的监听令牌 */
@interface TSAIEarbudsPickupChangeObserver : NSObject

// 通知中心返回的监听对象
@property (nonatomic, strong) NSMutableArray<id<NSObject>> *notificationTokens;
// 合并后的回调
@property (nonatomic, copy, nullable) void (^handler)(void);
// 是否已安排一次合并回调
@property (nonatomic, assign) BOOL refreshScheduled;

/** 创建并开始监听 */
- (instancetype)initWithHandler:(void (^)(void))handler;

/** 移除全部监听并丢弃回调 */
- (void)invalidate;

@end

@implementation TSAIEarbudsPickupChangeObserver

/** 创建并开始监听 */
- (instancetype)initWithHandler:(void (^)(void))handler {
    self = [super init];
    if (self) {
        _handler = [handler copy];
        _notificationTokens = [NSMutableArray array];
        [self registerNotifications];
    }
    return self;
}

/** 释放时移除监听 */
- (void)dealloc {
    [self invalidate];
}

/** 注册路由变化、回到前台、设备连接变化通知 */
- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    __weak typeof(self) weakSelf = self;
    [self.notificationTokens addObject:[center addObserverForName:AVAudioSessionRouteChangeNotification
                                                            object:nil
                                                             queue:mainQueue
                                                        usingBlock:^(NSNotification *notification) {
        // 只关心设备接入/断开；类别切换（包括本类自身的探测）引起的变化忽略，避免自己触发自己
        NSUInteger reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
        if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable ||
            reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
            [weakSelf scheduleRefresh];
        }
    }]];
    [self.notificationTokens addObject:[center addObserverForName:UIApplicationDidBecomeActiveNotification
                                                            object:nil
                                                             queue:mainQueue
                                                        usingBlock:^(NSNotification *notification) {
        [weakSelf scheduleRefresh];
    }]];
    [self.notificationTokens addObject:[center addObserverForName:TSDeviceConnectionSnapshotDidChangeNotification
                                                            object:nil
                                                             queue:mainQueue
                                                        usingBlock:^(NSNotification *notification) {
        [weakSelf scheduleRefresh];
    }]];
}

/** 合并短时间内的多次事件为一次回调 */
- (void)scheduleRefresh {
    if (self.refreshScheduled || self.handler == nil) {
        return;
    }
    self.refreshScheduled = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSAIEarbudsPickupRefreshDelay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.refreshScheduled = NO;
        if (strongSelf.handler) {
            strongSelf.handler();
        }
    });
}

/** 移除全部监听并丢弃回调 */
- (void)invalidate {
    for (id<NSObject> token in self.notificationTokens) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
    }
    [self.notificationTokens removeAllObjects];
    self.handler = nil;
}

@end

#pragma mark - TSAIEarbudsPickupAvailability

@implementation TSAIEarbudsPickupAvailability

#pragma mark - 公开方法

/** 按充电仓、权限、蓝牙音频设备的优先级计算状态；权限被拒时仍检测设备，供调用方区分耳机是否已连接 */
+ (TSAIEarbudsPickupStatus *)statusWithCaseReady:(BOOL)caseReady allowsProbe:(BOOL)allowsProbe {
    TSAIEarbudsPickupState state = TSAIEarbudsPickupStateCaseRequired;
    NSString *deviceName = nil;
    if (caseReady) {
        deviceName = [self connectedBluetoothAudioDeviceNameAllowingProbe:allowsProbe];
        if ([TSAIAudioRecordAppCapture isRecordPermissionDenied]) {
            state = TSAIEarbudsPickupStatePermissionRequired;
        } else {
            state = deviceName != nil ? TSAIEarbudsPickupStateAvailable : TSAIEarbudsPickupStateEarbudsNotReady;
        }
    }
    TSLog(@"[TSAIEarbudsPickup] status: state=%ld, caseReady=%d, device=%@",
          (long)state, caseReady, deviceName ?: @"-");
    return [TSAIEarbudsPickupStatus statusWithState:state deviceName:deviceName];
}

/** 先无副作用查看当前路由；看不到且允许探测时临时切换类别再看 */
+ (NSString *)connectedBluetoothAudioDeviceNameAllowingProbe:(BOOL)allowsProbe {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    AVAudioSessionPortDescription *port = [self bluetoothAudioPortInSession:session];
    NSString *via = port != nil ? @"route" : @"none";
    // 是否允许探测由调用方按自身会话状态决定：采集或播放进行中切换类别会改变实际路由
    if (port == nil && allowsProbe) {
        port = [self probeBluetoothAudioPortInSession:session];
        via = port != nil ? @"probe" : @"none";
    }
    TSLog(@"[TSAIEarbudsPickup] bluetooth audio: device=%@, type=%@, via=%@, category=%@, outputs=%@, availableInputs=%@",
          port.portName ?: @"-", port.portType ?: @"-", via, session.category,
          [self descriptionForPorts:session.currentRoute.outputs],
          [self descriptionForPorts:session.availableInputs]);
    if (port == nil) {
        return nil;
    }
    return port.portName.length > 0 ? port.portName : port.portType;
}

/** 路由的输入或输出中是否有蓝牙音频端口 */
+ (BOOL)routeContainsBluetoothAudio:(AVAudioSessionRouteDescription *)route {
    for (AVAudioSessionPortDescription *port in route.outputs) {
        if ([self isBluetoothAudioPortType:port.portType]) {
            return YES;
        }
    }
    for (AVAudioSessionPortDescription *port in route.inputs) {
        if ([self isBluetoothAudioPortType:port.portType]) {
            return YES;
        }
    }
    return NO;
}

/** 创建合并事件的监听令牌 */
+ (id<NSObject>)addChangeObserverWithHandler:(void (^)(void))handler {
    return [[TSAIEarbudsPickupChangeObserver alloc] initWithHandler:handler];
}

/** 停止监听 */
+ (void)removeChangeObserver:(id<NSObject>)observer {
    if ([observer isKindOfClass:[TSAIEarbudsPickupChangeObserver class]]) {
        [(TSAIEarbudsPickupChangeObserver *)observer invalidate];
    }
}

/** 打开系统设置中的本 App 页面 */
+ (void)openAppSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - 私有方法

/** 无副作用：当前路由的输出、输入与可用输入中的蓝牙音频端口 */
+ (nullable AVAudioSessionPortDescription *)bluetoothAudioPortInSession:(AVAudioSession *)session {
    NSMutableArray<AVAudioSessionPortDescription *> *ports = [NSMutableArray array];
    [ports addObjectsFromArray:session.currentRoute.outputs ?: @[]];
    [ports addObjectsFromArray:session.currentRoute.inputs ?: @[]];
    [ports addObjectsFromArray:session.availableInputs ?: @[]];
    for (AVAudioSessionPortDescription *port in ports) {
        if ([self isBluetoothAudioPortType:port.portType]) {
            return port;
        }
    }
    return nil;
}

/**
 * 当前类别看不到蓝牙端口时（如录音类别未允许蓝牙）：
 * 临时切到播放类别看 A2DP 输出，再切到录音+蓝牙看 HFP 输入；全程不激活会话，最后恢复原类别
 */
+ (nullable AVAudioSessionPortDescription *)probeBluetoothAudioPortInSession:(AVAudioSession *)session {
    AVAudioSessionCategory previousCategory = session.category;
    AVAudioSessionMode previousMode = session.mode;
    AVAudioSessionCategoryOptions previousOptions = session.categoryOptions;
    AVAudioSessionPortDescription *port = nil;
    NSString *playbackOutputs = @"-";
    NSString *recordInputs = @"-";
    if ([session setCategory:AVAudioSessionCategoryPlayback
                        mode:AVAudioSessionModeDefault
                     options:0
                       error:nil]) {
        playbackOutputs = [self descriptionForPorts:session.currentRoute.outputs];
        port = [self bluetoothAudioPortInSession:session];
    }
    if (port == nil &&
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                        mode:AVAudioSessionModeDefault
                     options:AVAudioSessionCategoryOptionAllowBluetooth
                       error:nil]) {
        recordInputs = [self descriptionForPorts:session.availableInputs];
        port = [self bluetoothAudioPortInSession:session];
    }
    [session setCategory:previousCategory mode:previousMode options:previousOptions error:nil];
    TSLog(@"[TSAIEarbudsPickup] probe: playbackOutputs=%@, recordAvailableInputs=%@, found=%@",
          playbackOutputs, recordInputs, port.portName ?: @"-");
    return port;
}

/** 是否为蓝牙音频端口类型 */
+ (BOOL)isBluetoothAudioPortType:(AVAudioSessionPort)portType {
    return [portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
        [portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
        [portType isEqualToString:AVAudioSessionPortBluetoothLE];
}

/** 将端口列表格式化为「类型:名称」便于日志排查 */
+ (NSString *)descriptionForPorts:(NSArray<AVAudioSessionPortDescription *> *)ports {
    NSMutableArray<NSString *> *items = [NSMutableArray arrayWithCapacity:ports.count];
    for (AVAudioSessionPortDescription *port in ports) {
        [items addObject:[NSString stringWithFormat:@"%@:%@", port.portType, port.portName]];
    }
    return items.count > 0 ? [items componentsJoinedByString:@", "] : @"(none)";
}

@end
