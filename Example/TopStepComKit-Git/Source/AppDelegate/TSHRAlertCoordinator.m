//
//  TSHRAlertCoordinator.m
//  TopStepComKit_Example
//

#import "TSHRAlertCoordinator.h"

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

#import "TSDeviceCoordinator.h"

NSNotificationName const TSHRAlertCoordinatorDidUpdateNotification = @"TSHRAlertCoordinatorDidUpdateNotification";
static NSString * const kTSHRAlertNotificationPrefix = @"com.topstep.demo.hr-alert.";
static TSHRAlertCoordinator *heartRateAlertCoordinator;

@interface TSHRAlertCoordinator () <UNUserNotificationCenterDelegate>

// 主线程维护的页面快照
@property (nonatomic, assign, readwrite) TSHRAlertListenerStatus listenerStatus;
@property (nonatomic, strong, readwrite, nullable) TSHRAlertModel *latestAlert;
@property (nonatomic, strong, readwrite, nullable) NSError *listenerError;
// 保留旧接口，以便在 Provider 切换前主动注销
@property (nonatomic, strong, nullable) id<TSHeartRateInterface> heartRate;
// 注册代次用于作废已进入主队列的旧会话回调
@property (nonatomic, assign) NSUInteger registrationGeneration;
@property (nonatomic, assign) NSUInteger connectionGeneration;
@property (nonatomic, assign) TSSDKType activeSDKType;
@property (nonatomic, assign) BOOL hasDeviceSession;
@property (nonatomic, assign) BOOL started;
// 仅前台接收的告警进入弹窗队列
@property (nonatomic, strong) NSMutableArray<TSHRAlertModel *> *pendingAlerts;
@property (nonatomic, strong, nullable) UIAlertController *presentedAlert;
@property (nonatomic, strong, nullable) NSTimer *presentationRetryTimer;
// 系统权限查询防重入，不影响设备监听状态
@property (nonatomic, assign) BOOL isCheckingNotificationAuthorization;

@end

@implementation TSHRAlertCoordinator

#pragma mark - 生命周期

// 初始化仅包含内存状态，不主动访问 SDK
- (instancetype)init {
    self = [super init];
    if (self && !_pendingAlerts) {
        _pendingAlerts = [NSMutableArray array];
        _listenerStatus = TSHRAlertListenerStatusWaitingForDevice;
    }
    return self;
}

// 保持 App 内唯一监听所有者
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

// 移除观察和仅属于本协调器的定时器
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_presentationRetryTimer invalidate];
}

#pragma mark - 公开方法

// 返回 App 级协调器
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        heartRateAlertCoordinator = [[super allocWithZone:NULL] init];
    });
    return heartRateAlertCoordinator;
}

// 在 SDK 初始化前开始观察，监听本身等设备会话就绪再注册
- (void)start {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self start]; });
        return;
    }
    if (self.started) {
        return;
    }
    self.started = YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleDeviceSnapshotChanged:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:[TSDeviceCoordinator sharedInstance]];
    [center addObserver:self selector:@selector(handleBindingCleared:)
                   name:TSDeviceBindingDidClearNotification object:nil];
    [center addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification object:nil];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [self updateForDeviceSnapshot:[TSDeviceCoordinator sharedInstance].snapshot];
}

// 未知类型使用中性标题，不默认为过高
+ (NSString *)titleForAlert:(TSHRAlertModel *)alert {
    switch (alert.type) {
        case TSHRAlertTypeDynamicHigh:
        case TSHRAlertTypeStaticHigh:
            return NSLocalizedString(@"hr.alert.notification.high", nil);
        case TSHRAlertTypeDynamicLow:
        case TSHRAlertTypeStaticLow:
            return NSLocalizedString(@"hr.alert.notification.low", nil);
        default: return NSLocalizedString(@"hr.alert.notification.unknown", nil);
    }
}

// 告警方向始终来自设备，配置值仅用于展示
+ (NSString *)messageForAlert:(TSHRAlertModel *)alert {
    BOOL isDynamic = alert.type == TSHRAlertTypeDynamicHigh || alert.type == TSHRAlertTypeDynamicLow;
    BOOL isStatic = alert.type == TSHRAlertTypeStaticHigh || alert.type == TSHRAlertTypeStaticLow;
    BOOL isHigh = alert.type == TSHRAlertTypeDynamicHigh || alert.type == TSHRAlertTypeStaticHigh;
    BOOL isLow = alert.type == TSHRAlertTypeDynamicLow || alert.type == TSHRAlertTypeStaticLow;
    NSString *mode = NSLocalizedString(@"hr.alert.message.mode_unknown", nil);
    if (isDynamic) {
        mode = NSLocalizedString(@"hr.alert.message.mode_dynamic", nil);
    } else if (isStatic) {
        mode = NSLocalizedString(@"hr.alert.message.mode_static", nil);
    }
    NSString *fact = [NSString stringWithFormat:NSLocalizedString(@"hr.alert.message.device_format", nil),
                      (unsigned int)alert.hrValue, mode, [self titleForAlert:alert]];
    if (!alert.threshold || (!isHigh && !isLow)) {
        return fact;
    }
    BOOL matchesThreshold = isHigh ? alert.hrValue > alert.threshold.doubleValue :
                                    alert.hrValue < alert.threshold.doubleValue;
    if (!matchesThreshold) {
        NSString *limit = NSLocalizedString(isHigh ? @"hr.alert.message.upper" : @"hr.alert.message.lower", nil);
        return [fact stringByAppendingFormat:NSLocalizedString(@"hr.alert.message.config_format", nil),
                limit, alert.threshold];
    }
    NSString *message = [NSString stringWithFormat:
                        NSLocalizedString(isHigh ? @"hr.alert.message.high_format" : @"hr.alert.message.low_format", nil),
                        mode, (unsigned int)alert.hrValue, alert.threshold];
    if (isHigh) {
        message = [message stringByAppendingString:NSLocalizedString(
                   isDynamic ? @"hr.alert.message.dynamic_advice" :
                   @"hr.alert.message.static_advice", nil)];
    }
    return message;
}

#pragma mark - 私有方法

// 相同就绪会话不重复注册；先清理旧接口再绑定新接口
- (void)updateForDeviceSnapshot:(TSDeviceConnectionSnapshot *)snapshot {
    if (!snapshot.isReady || !snapshot.hasBinding) {
        [self resetDeviceSession];
        return;
    }
    if (self.hasDeviceSession && self.connectionGeneration == snapshot.connectionGeneration &&
        self.activeSDKType == snapshot.activeSDKType) {
        return;
    }
    [self resetDeviceSession];
    self.hasDeviceSession = YES;
    self.connectionGeneration = snapshot.connectionGeneration;
    self.activeSDKType = snapshot.activeSDKType;
    self.heartRate = [TopStepComKit sharedInstance].heartRate;
    BOOL supportsAlerts = [self.heartRate respondsToSelector:@selector(supportHeartRateAlertForType:)] &&
        ([self.heartRate supportHeartRateAlertForType:TSHRAlertTypeDynamicHigh] ||
         [self.heartRate supportHeartRateAlertForType:TSHRAlertTypeDynamicLow] ||
         [self.heartRate supportHeartRateAlertForType:TSHRAlertTypeStaticHigh] ||
         [self.heartRate supportHeartRateAlertForType:TSHRAlertTypeStaticLow]);
    if (!supportsAlerts || ![self.heartRate respondsToSelector:@selector(registerHeartRateAlertBlock:)]) {
        self.listenerStatus = TSHRAlertListenerStatusNotSupported;
        [self publishUpdate];
        return;
    }

    self.listenerStatus = TSHRAlertListenerStatusListening;
    NSUInteger generation = self.registrationGeneration;
    __weak typeof(self) weakSelf = self;
    [self.heartRate registerHeartRateAlertBlock:^(TSHRAlertModel *alert, NSError *error) {
        void (^deliver)(void) = ^{
            [weakSelf handleAlert:alert error:error generation:generation];
        };
        if ([NSThread isMainThread]) {
            deliver();
        } else {
            dispatch_async(dispatch_get_main_queue(), deliver);
        }
    }];
    [self publishUpdate];
    [self requestNotificationAuthorizationIfNeeded];
}

// 先废弃旧回调，再注销监听；已提交的系统通知仍是有效的历史提醒
- (void)resetDeviceSession {
    if (!self.hasDeviceSession && self.listenerStatus == TSHRAlertListenerStatusWaitingForDevice) {
        return;
    }
    self.registrationGeneration += 1;
    self.hasDeviceSession = NO;
    if ([self.heartRate respondsToSelector:@selector(registerHeartRateAlertBlock:)]) {
        [self.heartRate registerHeartRateAlertBlock:nil];
    }
    self.heartRate = nil;
    self.latestAlert = nil;
    self.listenerError = nil;
    self.listenerStatus = TSHRAlertListenerStatusWaitingForDevice;
    [self clearPendingPresentation];
    [self publishUpdate];
}

// 同时核对注册身份与设备会话，拒绝已排入主线程的旧设备事件
- (BOOL)isCurrentSessionForGeneration:(NSUInteger)generation {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    return self.hasDeviceSession && generation == self.registrationGeneration &&
        snapshot.isReady && snapshot.hasBinding && snapshot.connectionGeneration == self.connectionGeneration &&
        snapshot.activeSDKType == self.activeSDKType;
}

// 错误只更新调试状态；真实事件在同一主线程处理路径更新页面、通知和弹窗
- (void)handleAlert:(TSHRAlertModel *)alert error:(NSError *)error generation:(NSUInteger)generation {
    if (![self isCurrentSessionForGeneration:generation]) {
        return;
    }
    NSError *receivedError = error ?: [alert doesModelHasError];
    if (receivedError) {
        self.listenerError = receivedError;
        BOOL notSupported = [receivedError.domain isEqualToString:kTSErrorDomainHeartRateName] &&
                            receivedError.code == eTSErrorNotSupport;
        self.listenerStatus = notSupported ? TSHRAlertListenerStatusNotSupported : TSHRAlertListenerStatusFailed;
        TSLog(@"[TSHRAlertCoordinator] listener error: %@", receivedError.localizedDescription);
        [self publishUpdate];
        return;
    }
    if (!alert) {
        return;
    }
    self.listenerError = nil;
    self.listenerStatus = TSHRAlertListenerStatusListening;
    self.latestAlert = alert;
    [self publishUpdate];
    [self requestNotificationAuthorizationIfNeeded];
    [self submitLocalNotificationForAlert:alert];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self.pendingAlerts addObject:alert];
        [self presentNextAlertIfPossible];
    }
}

// 页面只订阅这份只读状态，不占用 SDK 的单个监听槽位
- (void)publishUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:TSHRAlertCoordinatorDidUpdateNotification object:self];
}

// 处理设备快照时读取最新状态，避免后台派发的过期快照重新注册
- (void)handleDeviceSnapshotChanged:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self handleDeviceSnapshotChanged:notification]; });
        return;
    }
    [self updateForDeviceSnapshot:[TSDeviceCoordinator sharedInstance].snapshot];
}

// 解绑立即清除当前会话及页面上的最近回调
- (void)handleBindingCleared:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self handleBindingCleared:notification]; });
        return;
    }
    [self resetDeviceSession];
}

// 回到前台仅继续尚未展示的前台事件，不重放后台收到的事件
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    [self requestNotificationAuthorizationIfNeeded];
    [self presentNextAlertIfPossible];
}

// 进入后台时保留最近回调，清除弹窗队列以免返回时重复提醒
- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    [self clearPendingPresentation];
}

// 仅支持告警且 App 活跃时请求通知权限，拒绝权限不关闭监听
- (void)requestNotificationAuthorizationIfNeeded {
    if (self.listenerStatus != TSHRAlertListenerStatusListening || self.isCheckingNotificationAuthorization ||
        [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    self.isCheckingNotificationAuthorization = YES;
    NSUInteger generation = self.registrationGeneration;
    __weak typeof(self) weakSelf = self;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.isCheckingNotificationAuthorization = NO;
            if (![strongSelf isCurrentSessionForGeneration:generation]) {
                [strongSelf requestNotificationAuthorizationIfNeeded];
                return;
            }
            if (strongSelf.listenerStatus != TSHRAlertListenerStatusListening ||
                [UIApplication sharedApplication].applicationState != UIApplicationStateActive ||
                settings.authorizationStatus != UNAuthorizationStatusNotDetermined) {
                return;
            }
            strongSelf.isCheckingNotificationAuthorization = YES;
            [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound
                                 completionHandler:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.isCheckingNotificationAuthorization = NO;
                    if (error) {
                        TSLog(@"[TSHRAlertCoordinator] notification authorization error: %@", error.localizedDescription);
                    }
                });
            }];
        });
    }];
}

// 每个真实设备回调生成独立通知，重复数值也不合并或覆盖
- (void)submitLocalNotificationForAlert:(TSHRAlertModel *)alert {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [[self class] titleForAlert:alert];
    content.body = [[self class] messageForAlert:alert];
    content.sound = [UNNotificationSound defaultSound];
    NSString *identifier = [kTSHRAlertNotificationPrefix stringByAppendingString:[NSUUID UUID].UUIDString];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request
                                                         withCompletionHandler:^(NSError *error) {
        if (error) {
            TSLog(@"[TSHRAlertCoordinator] notification submission error: %@", error.localizedDescription);
        }
    }];
}

// 查找活跃场景的当前页面，避免从已离屏的心率页展示
- (UIViewController *)visibleViewController {
    UIWindow *activeWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive ||
                ![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) {
                    activeWindow = window;
                    break;
                }
            }
            if (activeWindow) {
                break;
            }
        }
    } else {
        activeWindow = [UIApplication sharedApplication].keyWindow;
    }
    UIViewController *controller = activeWindow.rootViewController;
    while (controller) {
        if (controller.presentedViewController) {
            controller = controller.presentedViewController;
        } else if ([controller isKindOfClass:[UINavigationController class]]) {
            controller = ((UINavigationController *)controller).visibleViewController;
        } else if ([controller isKindOfClass:[UITabBarController class]]) {
            controller = ((UITabBarController *)controller).selectedViewController;
        } else {
            return controller;
        }
    }
    return nil;
}

// 连续告警依次展示，已有弹窗或页面转场时等待，不覆盖其它业务弹窗
- (void)presentNextAlertIfPossible {
    if (!self.pendingAlerts.count || [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    if (self.presentedAlert && !self.presentedAlert.presentingViewController && !self.presentedAlert.isBeingPresented) {
        self.presentedAlert = nil;
    }
    UIViewController *presenter = [self visibleViewController];
    if (self.presentedAlert || !presenter.viewIfLoaded.window || [presenter isKindOfClass:[UIAlertController class]] ||
        presenter.isBeingPresented || presenter.isBeingDismissed || presenter.transitionCoordinator) {
        [self schedulePresentationRetry];
        return;
    }
    TSHRAlertModel *event = self.pendingAlerts.firstObject;
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:[[self class] titleForAlert:event]
                                                                  message:[[self class] messageForAlert:event]
                                                           preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [dialog addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"hr.alert.notification.acknowledge", nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        weakSelf.presentedAlert = nil;
        [weakSelf schedulePresentationRetry];
    }]];
    self.presentedAlert = dialog;
    NSUInteger generation = self.registrationGeneration;
    __weak UIAlertController *weakDialog = dialog;
    [presenter presentViewController:dialog animated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf isCurrentSessionForGeneration:generation] ||
            [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [weakDialog dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        if (strongSelf.pendingAlerts.firstObject == event) {
            [strongSelf.pendingAlerts removeObjectAtIndex:0];
        }
    }];
    [self schedulePresentationRetry];
}

// 只在队列非空时等待 UIKit 空闲，外部代码收起弹窗后也能继续处理
- (void)schedulePresentationRetry {
    if (self.presentationRetryTimer || !self.pendingAlerts.count ||
        [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.presentationRetryTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:NO block:^(NSTimer *timer) {
        weakSelf.presentationRetryTimer = nil;
        [weakSelf presentNextAlertIfPossible];
    }];
}

// 仅收起本协调器的弹窗，不影响其它页面的模态展示
- (void)clearPendingPresentation {
    [self.pendingAlerts removeAllObjects];
    [self.presentationRetryTimer invalidate];
    self.presentationRetryTimer = nil;
    UIAlertController *dialog = self.presentedAlert;
    self.presentedAlert = nil;
    if (dialog.presentingViewController) {
        [dialog dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - UNUserNotificationCenterDelegate

// 前台也显示此功能提交的系统通知，与 App 弹窗消费同一回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
      willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    if (![notification.request.identifier hasPrefix:kTSHRAlertNotificationPrefix]) {
        completionHandler(0);
        return;
    }
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList |
                          UNNotificationPresentationOptionSound);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    }
}

@end
