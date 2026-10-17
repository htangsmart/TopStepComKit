//
//  TSAIEarbudsMicrophoneUI.m
//  TopStepComKit-Git_Example
//
//  Created by Claude on 2026/10/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIEarbudsMicrophoneUI.h"

#import <UIKit/UIKit.h>

#import "TSDeviceCoordinator.h"

const NSTimeInterval TSAIEarbudsReconnectGracePeriod = 5.0;

/** 本地化文案（TSLocalizedString 定义在 TSRootVC.h，这里直接用 NSLocalizedString） */
static NSString *TSLocalizedStringValue(NSString *key) {
    return NSLocalizedString(key, nil);
}

#pragma mark - TSAIEarbudsMicrophoneObserver

/** 组合监听：持有多个通知令牌，失效时统一移除 */
@interface TSAIEarbudsMicrophoneObserver : NSObject

// 通知令牌
@property (nonatomic, strong) NSMutableArray<id<NSObject>> *tokens;

/** 移除全部通知 */
- (void)invalidate;

@end

@implementation TSAIEarbudsMicrophoneObserver

/** 初始化 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _tokens = [NSMutableArray array];
    }
    return self;
}

/** 释放时移除 */
- (void)dealloc {
    [self invalidate];
}

/** 移除全部通知 */
- (void)invalidate {
    for (id<NSObject> token in self.tokens) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
    }
    [self.tokens removeAllObjects];
}

@end

@implementation TSAIEarbudsMicrophoneUI

#pragma mark - 状态

/** 从当前 Context 读取状态 */
+ (nullable TSAIEarbudsMicrophoneStatus *)statusForFeature:(TSAIFeatureOptions)feature {
    id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
    return [audioRouting earbudsMicrophoneStatusForFeature:feature];
}

/** 可用或权限相关状态均可点击 */
+ (BOOL)isSelectableStatus:(nullable TSAIEarbudsMicrophoneStatus *)status {
    switch (status.state) {
        case TSAIEarbudsMicrophoneStateLikely:
        case TSAIEarbudsMicrophoneStateVerified:
        case TSAIEarbudsMicrophoneStatePermissionNotDetermined:
        case TSAIEarbudsMicrophoneStatePermissionDenied:
            return status != nil;
        case TSAIEarbudsMicrophoneStateUnsupported:
        case TSAIEarbudsMicrophoneStateCaseRequired:
        case TSAIEarbudsMicrophoneStateNotConnected:
        default:
            return NO;
    }
}

/** 不可用原因 */
+ (nullable NSString *)unavailableReasonForStatus:(nullable TSAIEarbudsMicrophoneStatus *)status {
    if (status == nil) {
        return TSLocalizedStringValue(@"ai_interpreter.setup_pickup_case_unavailable");
    }
    switch (status.state) {
        case TSAIEarbudsMicrophoneStateLikely:
        case TSAIEarbudsMicrophoneStateVerified:
        case TSAIEarbudsMicrophoneStatePermissionNotDetermined:
            return nil;
        case TSAIEarbudsMicrophoneStatePermissionDenied:
            return TSLocalizedStringValue(@"ai_conversation.mic_permission_denied");
        case TSAIEarbudsMicrophoneStateNotConnected:
            return TSLocalizedStringValue(@"ai_conversation.earbuds_not_ready");
        case TSAIEarbudsMicrophoneStateCaseRequired:
            return TSLocalizedStringValue(@"ai_interpreter.setup_pickup_case_unavailable");
        case TSAIEarbudsMicrophoneStateUnsupported:
        default:
            // 面向集成方：附带 SDK 的原因（功能、产品、Provider 或会话策略不支持）
            return status.reason.length > 0
                ? [NSString stringWithFormat:@"当前设备或功能不支持耳机收音（%@）", status.reason]
                : @"当前设备或功能不支持耳机收音";
    }
}

/** 标题后缀 */
+ (nullable NSString *)titleSuffixForStatus:(nullable TSAIEarbudsMicrophoneStatus *)status {
    switch (status.state) {
        case TSAIEarbudsMicrophoneStateLikely:
        case TSAIEarbudsMicrophoneStateVerified:
            return status.deviceName.length > 0 ? status.deviceName : nil;
        case TSAIEarbudsMicrophoneStatePermissionDenied:
            return @"需开启权限";
        case TSAIEarbudsMicrophoneStateNotConnected:
            return @"未连接";
        default:
            return nil;
    }
}

#pragma mark - 监听

/** 监听某功能的状态变化 */
+ (id<NSObject>)addStatusObserverForFeature:(TSAIFeatureOptions)feature
                                    handler:(void (^)(TSAIEarbudsMicrophoneStatus * _Nullable status))handler {
    TSAIEarbudsMicrophoneObserver *observer = [[TSAIEarbudsMicrophoneObserver alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [observer.tokens addObject:[center addObserverForName:TSAIEarbudsMicrophoneStatusDidChangeNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:^(NSNotification *notification) {
        NSNumber *featureValue = notification.userInfo[TSAIEarbudsMicrophoneFeatureKey];
        TSAIEarbudsMicrophoneStatus *status = notification.userInfo[TSAIEarbudsMicrophoneStatusKey];
        if (featureValue.unsignedIntegerValue != feature || status == nil) {
            return;
        }
        handler(status);
    }]];
    // Context 被替换或销毁时 SDK 不再发通知：设备连接变化、回到前台时主动重读
    void (^reload)(NSNotification *) = ^(NSNotification *notification) {
        handler([TSAIEarbudsMicrophoneUI statusForFeature:feature]);
    };
    [observer.tokens addObject:[center addObserverForName:TSDeviceConnectionSnapshotDidChangeNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:reload]];
    [observer.tokens addObject:[center addObserverForName:UIApplicationDidBecomeActiveNotification
                                                   object:nil
                                                    queue:mainQueue
                                               usingBlock:reload]];
    return observer;
}

/** 监听某功能运行中的耳机输入状态 */
+ (id<NSObject>)addInputObserverForFeature:(TSAIFeatureOptions)feature
                                   handler:(void (^)(TSAIEarbudsMicrophoneInputState,
                                                     NSString * _Nullable,
                                                     NSError * _Nullable))handler {
    return [[NSNotificationCenter defaultCenter]
        addObserverForName:TSAIEarbudsMicrophoneInputDidChangeNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *notification) {
        NSNumber *featureValue = notification.userInfo[TSAIEarbudsMicrophoneFeatureKey];
        NSNumber *stateValue = notification.userInfo[TSAIEarbudsMicrophoneStateKey];
        if (featureValue.unsignedIntegerValue != feature || stateValue == nil) {
            return;
        }
        handler((TSAIEarbudsMicrophoneInputState)stateValue.integerValue,
                notification.userInfo[TSAIEarbudsMicrophoneTaskIdKey],
                notification.userInfo[TSAIEarbudsMicrophoneErrorKey]);
    }];
}

/** 停止监听 */
+ (void)removeObserver:(nullable id<NSObject>)observer {
    if ([observer isKindOfClass:[TSAIEarbudsMicrophoneObserver class]]) {
        [(TSAIEarbudsMicrophoneObserver *)observer invalidate];
    } else if (observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

#pragma mark - 错误

/** 是否为 SDK 耳机麦克风错误 */
+ (BOOL)isEarbudsMicrophoneError:(nullable NSError *)error {
    return [error.domain isEqualToString:TSAIErrorDomain] &&
        (error.code == TSAIErrorCodeMicrophonePermissionDenied ||
         error.code == TSAIErrorCodeEarbudsMicrophoneUnavailable ||
         error.code == TSAIErrorCodeAudioInputLost);
}

/** 耳机麦克风错误提示 */
+ (NSString *)descriptionForEarbudsMicrophoneError:(nullable NSError *)error {
    if (![error.domain isEqualToString:TSAIErrorDomain]) {
        return error.localizedDescription ?: @"耳机麦克风不可用";
    }
    switch (error.code) {
        case TSAIErrorCodeMicrophonePermissionDenied:
            return TSLocalizedStringValue(@"ai_conversation.mic_permission_denied");
        case TSAIErrorCodeEarbudsMicrophoneUnavailable:
            return [self descriptionForEarbudsUnavailableError:error];
        case TSAIErrorCodeAudioInputLost:
            return [NSString stringWithFormat:@"耳机已断开，%.0f 秒内未重新连接", TSAIEarbudsReconnectGracePeriod];
        default:
            return error.localizedDescription ?: @"耳机麦克风不可用";
    }
}

/** 1022 按失败原因给出提示 */
+ (NSString *)descriptionForEarbudsUnavailableError:(NSError *)error {
    TSAIEarbudsMicrophoneFailureReason reason =
        [error.userInfo[TSAIErrorUserInfoEarbudsMicrophoneFailureReasonKey] integerValue];
    switch (reason) {
        case TSAIEarbudsMicrophoneFailureReasonOtherDeviceActive: {
            NSString *holder = error.userInfo[TSAIErrorUserInfoEarbudsMicrophoneRouteHolderNameKey];
            NSString *device = holder.length > 0 ? [NSString stringWithFormat:@"「%@」", holder] : @"";
            return [NSString stringWithFormat:@"手机把蓝牙通话音频交给了另一台蓝牙设备%@，没有切到耳机。"
                    @"请在系统「设置 - 蓝牙」中断开该设备（或关闭它的蓝牙通话）后重试", device];
        }
        case TSAIEarbudsMicrophoneFailureReasonForeignHeadset:
            return @"没有找到这副耳机的麦克风（手机上只有或同时连着其他蓝牙设备，如车载、手表，无法确认）。"
                   @"请确认耳机已取出佩戴并连接到手机，必要时在系统「设置 - 蓝牙」中断开其他设备后重试";
        case TSAIEarbudsMicrophoneFailureReasonPriority:
            return @"正在通话或其他 App 占用麦克风，暂时无法使用耳机麦克风";
        case TSAIEarbudsMicrophoneFailureReasonBackground:
            return @"App 在后台，系统不允许开始录音。请回到前台后重试";
        case TSAIEarbudsMicrophoneFailureReasonInterrupted:
            return @"启动时音频被系统打断（如来电、闹钟），请重试";
        case TSAIEarbudsMicrophoneFailureReasonNeverSeen:
        case TSAIEarbudsMicrophoneFailureReasonNotRouted:
        default:
            return @"无法使用耳机麦克风：请确认耳机已取出佩戴并连接到手机。耳机若只连了播放通道，可在系统「设置 - 蓝牙」中断开后重新连接";
    }
}

#pragma mark - 权限

/** 权限是否已被拒绝 */
+ (BOOL)isMicrophonePermissionDenied {
    return [TSAIKit microphonePermissionStatus] == TSAIMicrophonePermissionStatusDenied;
}

/** 请求权限 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completion {
    [TSAIKit requestMicrophonePermissionWithCompletion:^(TSAIMicrophonePermissionStatus status) {
        if (completion) {
            completion(status == TSAIMicrophonePermissionStatusGranted);
        }
    }];
}

/** 打开系统设置中的本 App 页面 */
+ (void)openAppSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end
