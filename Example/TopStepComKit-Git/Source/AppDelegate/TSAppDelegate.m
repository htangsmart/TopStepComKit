//
//  TSAppDelegate.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppDelegate.h"

#import <Network/Network.h>

#import <TopStepComKit/TopStepComKit.h>
#import <TopStepAIKit/TopStepAIKitAdapter.h>
@import AIBudsFoundation;

#import "TSMainTabBarController.h"
#import "TSDeviceScanVC.h"
#import "TSDeviceCoordinator.h"
#import "TSAppLanguageManager.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIAudioRecordSessionCoordinator.h"

// 开屏最短展示时长（秒），避免 SDK 初始化过快导致开屏一闪而过
static const NSTimeInterval kTSLaunchMinimumDisplayDuration = 1.0;
// 公网访问探测地址，用实际请求触发系统无线数据授权
static NSString * const kTSNetworkAccessProbeURLString = @"https://fitcloud.hetangsmart.com";
// Demo 未接入 Flywear 的服务端能力路由，设备未建议厂商时默认使用 StarBurst
static const TSAIBudsVendorType kTSDemoDefaultAIVendor = TSAIBudsVendorTypeStarBurst;
// AI 最终鉴权失败后的最大重试次数
static const NSUInteger kTSAIAuthenticationMaximumRetryCount = 3;
// AI 鉴权重试基础延迟，后续按 2、4、8 秒递增
static const NSTimeInterval kTSAIAuthenticationRetryBaseDelay = 2.0;

@interface TSAppDelegate ()

// 应用主 TabBar 控制器
@property (nonatomic, strong) TSMainTabBarController *mainTabBarController;
// 初始启动的真实目标（主界面或扫描页），最短展示时长与其就绪后再切换
@property (nonatomic, strong) UIViewController *pendingInitialRoot;
// 开屏最短展示时长是否已到
@property (nonatomic, assign) BOOL minimumDisplayElapsed;
// 公网访问授权探测会话
@property (nonatomic, strong) NSURLSession *networkAccessProbeSession;
// 公网访问授权探测任务
@property (nonatomic, strong) NSURLSessionDataTask *networkAccessProbeTask;
// 公网访问授权探测开始时间
@property (nonatomic, strong) NSDate *networkAccessProbeStartDate;
// 公网访问授权探测是否已完成
@property (nonatomic, assign) BOOL hasCompletedNetworkAccessProbe;
// 公网访问当前是否可用
@property (nonatomic, assign) BOOL isPublicNetworkAccessAvailable;
// 是否应在公网访问就绪后启动 AI
@property (nonatomic, assign) BOOL shouldStartAIWhenNetworkReady;
// 系统网络路径监听器，仅用于诊断实际联网路径
@property (nonatomic, strong) nw_path_monitor_t networkPathMonitor;
// 最近一次系统网络路径快照
@property (nonatomic, strong) nw_path_t latestNetworkPath;
// AI Context 是否正在激活
@property (nonatomic, assign) BOOL isAIContextActivating;
// AI 流程执行期间收到新的连接事件时，待当前步骤结束后重新处理
@property (nonatomic, assign) BOOL shouldPrepareAIWhenReady;
// AI 鉴权请求是否正在执行
@property (nonatomic, assign) BOOL isAIAuthenticationInProgress;
// 当前激活 Context 对应的 AI 厂商
@property (nonatomic, assign) TSAIBudsVendorType activeAIVendor;
// 当前激活 Context 的唯一标识
@property (nonatomic, copy) NSString *activeAIContextIdentifier;
// 当前连接流程的 AI 鉴权代次，用于废弃旧设备的延迟任务
@property (nonatomic, assign) NSUInteger aiAuthenticationGeneration;
// 当前连接流程已安排的 AI 鉴权重试次数
@property (nonatomic, assign) NSUInteger aiAuthenticationRetryCount;
// 是否已有 AI 鉴权重试等待执行
@property (nonatomic, assign) BOOL isAIAuthenticationRetryScheduled;
// 最近一次 AI 鉴权请求对应的设备 MAC
@property (nonatomic, copy) NSString *aiAuthenticationRequestedMacAddress;
// 已完成最终 AI 鉴权的设备 MAC
@property (nonatomic, copy) NSString *authenticatedAIMacAddress;
// 最近处理的设备连接会话代次，避免同一快照重复启动 AI
@property (nonatomic, assign) NSUInteger handledConnectionGeneration;
// 是否曾进入设备就绪态，用于断连时释放会话层监听
@property (nonatomic, assign) BOOL hadReadyDeviceSession;

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TSAppLanguageManager applyStoredLanguageIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceSnapshotChanged:)
                                                 name:TSDeviceConnectionSnapshotDidChangeNotification
                                               object:[TSDeviceCoordinator sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceBindingCleared:)
                                                 name:TSDeviceBindingDidClearNotification
                                               object:nil];
    [[TSDeviceCoordinator sharedInstance] start];
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

/**
 * 配置场景窗口与初始根控制器
 */
- (void)configureInitialInterfaceWithWindow:(UIWindow *)window {
    self.window = window;
    self.window.backgroundColor = [UIColor whiteColor];
    self.mainTabBarController = [[TSMainTabBarController alloc] init];
    self.pendingInitialRoot = nil;
    self.minimumDisplayElapsed = NO;
    [self checkDeviceBindingStatus];
    [self.window makeKeyAndVisible];
    [self ts_startNetworkPathMonitoring];
    [self ts_requestPublicNetworkAccessIfNeeded];
}

/**
 * 启动系统网络路径监听，区分无网络与目标地址不可达
 */
- (void)ts_startNetworkPathMonitoring {
    if (self.networkPathMonitor) {
        return;
    }

    nw_path_monitor_t pathMonitor = nw_path_monitor_create();
    self.networkPathMonitor = pathMonitor;
    __weak typeof(self) weakSelf = self;
    nw_path_monitor_set_update_handler(pathMonitor, ^(nw_path_t path) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.latestNetworkPath = path;
            TSLog(@"[TSAppDelegate][NetworkPath] 状态变化: %@",
                  [strongSelf ts_networkPathDescription:path]);
        });
    });
    dispatch_queue_t monitorQueue = dispatch_queue_create("com.topstep.example.network-path-monitor",
                                                           DISPATCH_QUEUE_SERIAL);
    nw_path_monitor_set_queue(pathMonitor, monitorQueue);
    nw_path_monitor_start(pathMonitor);
    TSLog(@"[TSAppDelegate][NetworkPath] 开始监听系统网络路径");
}

/**
 * 生成不含敏感信息的系统网络路径诊断描述
 */
- (NSString *)ts_networkPathDescription:(nw_path_t)path {
    if (!path) {
        return @"status=unknown, reason=unknown, interfaces=unknown, expensive=unknown, constrained=unknown";
    }

    NSString *statusDescription = @"invalid";
    switch (nw_path_get_status(path)) {
        case nw_path_status_satisfied:
            statusDescription = @"satisfied";
            break;
        case nw_path_status_unsatisfied:
            statusDescription = @"unsatisfied";
            break;
        case nw_path_status_satisfiable:
            statusDescription = @"satisfiable";
            break;
        case nw_path_status_invalid:
            break;
    }

    NSString *unsatisfiedReason = @"notAvailable";
    if (@available(iOS 14.2, *)) {
        switch (nw_path_get_unsatisfied_reason(path)) {
            case nw_path_unsatisfied_reason_cellular_denied:
                unsatisfiedReason = @"cellularDenied";
                break;
            case nw_path_unsatisfied_reason_wifi_denied:
                unsatisfiedReason = @"wifiDenied";
                break;
            case nw_path_unsatisfied_reason_local_network_denied:
                unsatisfiedReason = @"localNetworkDenied";
                break;
            case nw_path_unsatisfied_reason_not_available:
                break;
            default:
                unsatisfiedReason = @"other";
                break;
        }
    }

    NSMutableArray<NSString *> *interfaces = [NSMutableArray array];
    if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
        [interfaces addObject:@"wifi"];
    }
    if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
        [interfaces addObject:@"cellular"];
    }
    if (nw_path_uses_interface_type(path, nw_interface_type_wired)) {
        [interfaces addObject:@"wired"];
    }
    if (nw_path_uses_interface_type(path, nw_interface_type_loopback)) {
        [interfaces addObject:@"loopback"];
    }
    if (nw_path_uses_interface_type(path, nw_interface_type_other)) {
        [interfaces addObject:@"other"];
    }
    NSString *interfaceDescription = @"none";
    if (interfaces.count > 0) {
        interfaceDescription = [interfaces componentsJoinedByString:@","];
    }
    BOOL isConstrained = NO;
    if (@available(iOS 13.0, *)) {
        isConstrained = nw_path_is_constrained(path);
    }
    return [NSString stringWithFormat:@"status=%@, reason=%@, interfaces=%@, expensive=%d, constrained=%d",
            statusDescription,
            unsatisfiedReason,
            interfaceDescription,
            nw_path_is_expensive(path),
            isConstrained];
}

/**
 * 通过一次轻量公网请求触发系统无线数据授权
 */
- (void)ts_requestPublicNetworkAccessIfNeeded {
    if (self.networkAccessProbeTask || self.hasCompletedNetworkAccessProbe) {
        TSLog(@"[TSAppDelegate][NetworkProbe] 跳过探测: taskRunning=%d, completed=%d, available=%d, path={%@}",
              self.networkAccessProbeTask != nil,
              self.hasCompletedNetworkAccessProbe,
              self.isPublicNetworkAccessAvailable,
              [self ts_networkPathDescription:self.latestNetworkPath]);
        return;
    }

    NSURL *probeURL = [NSURL URLWithString:kTSNetworkAccessProbeURLString];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.timeoutIntervalForRequest = 10.0;
    configuration.timeoutIntervalForResource = 15.0;
    configuration.waitsForConnectivity = YES;
    self.networkAccessProbeSession = [NSURLSession sessionWithConfiguration:configuration];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:probeURL];
    request.HTTPMethod = @"HEAD";
    NSDate *probeStartDate = [NSDate date];
    self.networkAccessProbeStartDate = probeStartDate;
    TSLog(@"[TSAppDelegate][NetworkProbe] 开始探测: method=%@, url=%@, requestTimeout=%.0fs, "
          "resourceTimeout=%.0fs, waitsForConnectivity=%d, path={%@}",
          request.HTTPMethod,
          probeURL.absoluteString,
          configuration.timeoutIntervalForRequest,
          configuration.timeoutIntervalForResource,
          configuration.waitsForConnectivity,
          [self ts_networkPathDescription:self.latestNetworkPath]);
    __weak typeof(self) weakSelf = self;
    self.networkAccessProbeTask = [self.networkAccessProbeSession
        dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:probeStartDate];
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL wasWaitingToStartAI = strongSelf.shouldStartAIWhenNetworkReady;
                BOOL shouldStartAI = !error && wasWaitingToStartAI;
                NSHTTPURLResponse *httpResponse = nil;
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    httpResponse = (NSHTTPURLResponse *)response;
                }
                NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
                TSLog(@"[TSAppDelegate][NetworkProbe] 探测完成: success=%d, elapsed=%.3fs, httpStatus=%ld, "
                      "responseURL=%@, errorDomain=%@, errorCode=%ld, underlyingDomain=%@, "
                      "underlyingCode=%ld, pendingAI=%d, path={%@}",
                      error == nil,
                      elapsedTime,
                      (long)httpResponse.statusCode,
                      response.URL.absoluteString,
                      error.domain,
                      (long)error.code,
                      underlyingError.domain,
                      (long)underlyingError.code,
                      wasWaitingToStartAI,
                      [strongSelf ts_networkPathDescription:strongSelf.latestNetworkPath]);
                strongSelf.hasCompletedNetworkAccessProbe = YES;
                strongSelf.isPublicNetworkAccessAvailable = !error;
                strongSelf.shouldStartAIWhenNetworkReady = NO;
                if (error) {
                    TSLog(@"[TSAppDelegate][NetworkProbe] 探测错误详情: %@", error);
                } else {
                    TSLog(@"[TSAppDelegate][NetworkProbe] 公网访问授权探测成功");
                }
                [strongSelf.networkAccessProbeSession finishTasksAndInvalidate];
                strongSelf.networkAccessProbeTask = nil;
                strongSelf.networkAccessProbeSession = nil;
                strongSelf.networkAccessProbeStartDate = nil;
                TSLog(@"[TSAppDelegate][NetworkProbe] 门禁决策: shouldStartAI=%d, completed=%d, available=%d",
                      shouldStartAI,
                      strongSelf.hasCompletedNetworkAccessProbe,
                      strongSelf.isPublicNetworkAccessAvailable);
                if (shouldStartAI) {
                    [strongSelf ts_startAIForConnectedDevice];
                }
            });
        }];
    [self.networkAccessProbeTask resume];
}

/**
 * 检查设备绑定状态
 */
- (void)checkDeviceBindingStatus {
    // 检查 UserDefaults 中是否有历史绑定设备记录
    BOOL hasBoundDevice = [[TSDeviceCoordinator sharedInstance] hasBinding];
    
    // 始终先展示静态开屏，并保证最短展示时长，避免开屏一闪而过
    self.window.rootViewController = [self ts_makeLaunchSplashVC];
    [self ts_startMinimumDisplayTimer];
    
    if (hasBoundDevice) {
        // 有历史绑定设备：SDK 初始化是异步的，就绪后再切主界面
        [self ts_initSDKThenShowMain];
    } else {
        // 没有绑定过设备，目标为扫描页
        self.pendingInitialRoot = [self ts_makeScanNav];
        [self ts_deliverInitialRootIfReady];
    }
}

/**
 * 启动开屏最短展示计时，到点后尝试交付真实首屏
 */
- (void)ts_startMinimumDisplayTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSLaunchMinimumDisplayDuration * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        weakSelf.minimumDisplayElapsed = YES;
        [weakSelf ts_deliverInitialRootIfReady];
    });
}

/**
 * 用上次保存的 SDK 类型初始化 SDK，成功后进主界面；失败则回退扫描页
 */
- (void)ts_initSDKThenShowMain {
    TSSDKType sdkType = [[TSDeviceCoordinator sharedInstance] preferredSDKType];
    if (sdkType == eTSSDKTypeUnknow) {
        self.pendingInitialRoot = [self ts_makeScanNav];
        [self ts_deliverInitialRootIfReady];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[TSDeviceCoordinator sharedInstance] initializeSDKType:sdkType completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (isSuccess) {
                [strongSelf ts_synchronizeSavedConnectionUserIdentifier];
                strongSelf.pendingInitialRoot = strongSelf.mainTabBarController;
                [strongSelf ts_deliverInitialRootIfReady];
            } else {
                TSLog(@"[TSAppDelegate] SDK 初始化失败(SDKType=%ld): %@，回退扫描页", (long)sdkType, error);
                strongSelf.pendingInitialRoot = [strongSelf ts_makeScanNav];
                [strongSelf ts_deliverInitialRootIfReady];
            }
        });
    }];
}

/**
 * 显示主界面（带 TabBar）
 */
- (void)showMainInterface {
    self.window.rootViewController = self.mainTabBarController;
}

/**
 * 显示设备扫描页（无 TabBar）
 */
- (void)showDeviceScanInterface {
    self.window.rootViewController = [self ts_makeScanNav];
}

/**
 * 构建扫描页导航控制器
 */
- (UINavigationController *)ts_makeScanNav {
    TSDeviceScanVC *scanVC = [[TSDeviceScanVC alloc] init];
    return [[UINavigationController alloc] initWithRootViewController:scanVC];
}

/**
 * 构建静态开屏（仅展示 launch_bg，与 LaunchScreen.storyboard 首帧一致）
 */
- (UIViewController *)ts_makeLaunchSplashVC {
    UIViewController *splashVC = [[UIViewController alloc] init];
    splashVC.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:splashVC.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"launch_bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [splashVC.view addSubview:backgroundImageView];
    
    return splashVC;
}

/**
 * 最短展示时长与真实首屏均就绪后，交叉溶解切换（仅初始启动用一次）
 */
- (void)ts_deliverInitialRootIfReady {
    if (!self.minimumDisplayElapsed) return;
    if (!self.pendingInitialRoot) return;
    
    UIViewController *destination = self.pendingInitialRoot;
    self.pendingInitialRoot = nil;
    [self ts_transitionRootTo:destination];
}

/**
 * 交叉溶解切换 window 根控制器
 */
- (void)ts_transitionRootTo:(UIViewController *)destination {
    if (!destination) return;
    
    [UIView transitionWithView:self.window
                      duration:0.35
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        self.window.rootViewController = destination;
    }
                    completion:nil];
}

/**
 * 为当前设备开启新的 AI 准备流程
 */
- (void)ts_startAIForConnectedDevice {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    NSString *connectedMac = [self ts_normalizedMacAddress:snapshot.peripheral.systemInfo.mac];
    TSLog(@"[TSAppDelegate][AIFlow] 收到启动请求: ready=%d, connectionGeneration=%lu, "
          "handledGeneration=%lu, sdkType=%ld, mac=%@, probeCompleted=%d, networkAvailable=%d, "
          "probeRunning=%d, pendingNetworkStart=%d, path={%@}",
          snapshot.isReady,
          (unsigned long)snapshot.connectionGeneration,
          (unsigned long)self.handledConnectionGeneration,
          (long)snapshot.activeSDKType,
          connectedMac,
          self.hasCompletedNetworkAccessProbe,
          self.isPublicNetworkAccessAvailable,
          self.networkAccessProbeTask != nil,
          self.shouldStartAIWhenNetworkReady,
          [self ts_networkPathDescription:self.latestNetworkPath]);
    if (!self.hasCompletedNetworkAccessProbe) {
        self.shouldStartAIWhenNetworkReady = YES;
        TSLog(@"[TSAppDelegate][AIFlow][NetworkGate] 等待公网探测结果: mac=%@, connectionGeneration=%lu",
              connectedMac,
              (unsigned long)snapshot.connectionGeneration);
        return;
    }
    if (!self.isPublicNetworkAccessAvailable) {
        TSLog(@"[TSAppDelegate][AIFlow][NetworkGate] 初始化被拦截: probeCompleted=%d, "
              "networkAvailable=%d, path={%@}",
              self.hasCompletedNetworkAccessProbe,
              self.isPublicNetworkAccessAvailable,
              [self ts_networkPathDescription:self.latestNetworkPath]);
        return;
    }

    TSLog(@"[TSAppDelegate][AIFlow][NetworkGate] 门禁通过，开始准备 AI");
    TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
    [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
    [[TSAIAudioRecordSessionCoordinator sharedInstance] unbindContext:activeContext];
    self.aiAuthenticationGeneration += 1;
    self.aiAuthenticationRetryCount = 0;
    self.isAIAuthenticationRetryScheduled = NO;
    self.aiAuthenticationRequestedMacAddress = nil;
    self.authenticatedAIMacAddress = nil;
    [self ts_prepareAIForConnectedDevice];
}

/**
 * 连接成功后按设备平台与设备建议的厂商准备 AI Context
 */
- (void)ts_prepareAIForConnectedDevice {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheral *peripheral = snapshot.peripheral;
    if (!peripheral) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：当前没有已连接设备");
        return;
    }
    
    TSSDKType sdkType = snapshot.activeSDKType;
    NSString *platformIdentifier = [self ts_aiPlatformIdentifierForSDKType:sdkType];
    TSAIBudsVendorType vendor = [self ts_aiVendorForPeripheral:peripheral];
    TSLog(@"[TSAppDelegate][AIFlow] 准备 Context: ready=%d, connectionGeneration=%lu, sdkType=%ld, "
          "platform=%@, vendor=%ld, mac=%@, contextActivating=%d, authenticationInProgress=%d",
          snapshot.isReady,
          (unsigned long)snapshot.connectionGeneration,
          (long)sdkType,
          platformIdentifier,
          (long)vendor,
          [self ts_normalizedMacAddress:peripheral.systemInfo.mac],
          self.isAIContextActivating,
          self.isAIAuthenticationInProgress);
    if (platformIdentifier.length == 0 || vendor == TSAIBudsVendorTypeNone) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：平台或设备 AI 厂商不支持");
        return;
    }
    
    id<TSAIDeviceBridge> deviceBridge = [[TSAIDeviceBridgeRegistry sharedRegistry]
                                         createDeviceBridgeForPlatformIdentifier:platformIdentifier];
    if (!deviceBridge) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：当前平台未集成 DeviceBridge");
        return;
    }
    
    TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
    BOOL isExpectedContext = activeContext.state == TSAIContextStateActive &&
    [activeContext.platformIdentifier isEqualToString:platformIdentifier] &&
    [activeContext.contextIdentifier isEqualToString:self.activeAIContextIdentifier] &&
    self.activeAIVendor == vendor;
    TSLog(@"[TSAppDelegate][AIFlow] Context 检查: state=%ld, authorizationState=%ld, "
          "expected=%d, activeVendor=%ld",
          (long)activeContext.state,
          (long)activeContext.authorizationState,
          isExpectedContext,
          (long)self.activeAIVendor);
    if (isExpectedContext) {
        [[TSAIAudioRecordSessionCoordinator sharedInstance]
         bindActiveContext:activeContext];
        NSString *connectedMac = [self ts_normalizedMacAddress:peripheral.systemInfo.mac];
        BOOL isAuthenticatedDevice = activeContext.authorizationState == TSAIAuthorizationStateAuthenticated &&
        [connectedMac isEqualToString:self.authenticatedAIMacAddress];
        if (isAuthenticatedDevice) {
            [[TSAIChatDeviceSessionCoordinator sharedInstance]
             bindAuthenticatedContext:activeContext];
            TSLog(@"[TSAppDelegate] AI 已完成最终鉴权，无需重复请求");
            return;
        }
        [self ts_authenticatePeripheral:peripheral withContext:activeContext];
        return;
    }
    if (self.isAIContextActivating) {
        self.shouldPrepareAIWhenReady = YES;
        TSLog(@"[TSAppDelegate][AIFlow] Context 正在激活，本次准备请求已排队");
        return;
    }
    
    [self ts_activateAIContextForPeripheral:peripheral
                         platformIdentifier:platformIdentifier
                                     vendor:vendor];
}

/**
 * 按当前设备路由激活 AI Context，成功后立即鉴权
 */
- (void)ts_activateAIContextForPeripheral:(TSPeripheral *)peripheral
                       platformIdentifier:(NSString *)platformIdentifier
                                   vendor:(TSAIBudsVendorType)vendor {
    TSAIBudsConfiguration *budsConfiguration =
    [TSAIBudsConfiguration configurationWithPreferredVendor:vendor];
    TSAIContextConfiguration *contextConfiguration =
    [TSAIContextConfiguration configurationWithPlatformIdentifier:platformIdentifier
                                                     providerType:TSAIProviderTypeAIBuds
                                            providerConfiguration:budsConfiguration];
    self.isAIContextActivating = YES;
    TSLog(@"[TSAppDelegate][AIFlow] 开始激活 Context: platform=%@, vendor=%ld, mac=%@",
          platformIdentifier,
          (long)vendor,
          [self ts_normalizedMacAddress:peripheral.systemInfo.mac]);
    
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance] activateContextWithConfiguration:contextConfiguration
                                                    completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.isAIContextActivating = NO;
            if (!success) {
                TSLog(@"[TSAppDelegate][AIFlow] Context 激活失败: errorDomain=%@, errorCode=%ld, error=%@",
                      error.domain,
                      (long)error.code,
                      error);
                if (strongSelf.shouldPrepareAIWhenReady) {
                    strongSelf.shouldPrepareAIWhenReady = NO;
                    [strongSelf ts_prepareAIForConnectedDevice];
                }
                return;
            }
            
            TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
            if (activeContext.state != TSAIContextStateActive) {
                TSLog(@"[TSAppDelegate] AI Context 激活后状态不可用");
                return;
            }
            strongSelf.activeAIContextIdentifier = activeContext.contextIdentifier;
            strongSelf.activeAIVendor = vendor;
            [[TSAIAudioRecordSessionCoordinator sharedInstance]
             bindActiveContext:activeContext];
            [strongSelf ts_registerAuthorizationStateObserverForContext:activeContext];
            TSLog(@"[TSAppDelegate][AIFlow] Context 激活成功: state=%ld, authorizationState=%ld, vendor=%ld",
                  (long)activeContext.state,
                  (long)activeContext.authorizationState,
                  (long)vendor);
            if (strongSelf.shouldPrepareAIWhenReady) {
                strongSelf.shouldPrepareAIWhenReady = NO;
                [strongSelf ts_prepareAIForConnectedDevice];
            } else {
                [strongSelf ts_authenticatePeripheral:peripheral withContext:activeContext];
            }
        });
    }];
}

/**
 * 监听 AI Context 的最终鉴权状态
 */
- (void)ts_registerAuthorizationStateObserverForContext:(TSAIContext *)context {
    NSString *contextIdentifier = context.contextIdentifier;
    __weak typeof(self) weakSelf = self;
    __weak TSAIContext *weakContext = context;
    [context registerAuthorizationStateDidChange:^(TSAIAuthorizationState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            TSAIContext *observedContext = weakContext;
            TSAIContext *currentContext = [TSAIKit sharedInstance].activeContext;
            if (!strongSelf || !observedContext ||
                ![currentContext.contextIdentifier isEqualToString:contextIdentifier]) {
                return;
            }
            [strongSelf ts_handleAuthorizationState:state context:observedContext];
        });
    }];
}

/**
 * 处理 AI Context 的最终鉴权状态
 */
- (void)ts_handleAuthorizationState:(TSAIAuthorizationState)state context:(TSAIContext *)context {
    TSLog(@"[TSAppDelegate][AIAuth] 状态变化: state=%ld, contextState=%ld, authGeneration=%lu, "
          "retryCount=%lu, requestedMac=%@",
          (long)state,
          (long)context.state,
          (unsigned long)self.aiAuthenticationGeneration,
          (unsigned long)self.aiAuthenticationRetryCount,
          self.aiAuthenticationRequestedMacAddress);
    switch (state) {
        case TSAIAuthorizationStateAuthenticated:
            self.authenticatedAIMacAddress = self.aiAuthenticationRequestedMacAddress;
            self.aiAuthenticationRetryCount = 0;
            self.isAIAuthenticationRetryScheduled = NO;
            self.aiAuthenticationGeneration += 1;
            [[TSAIChatDeviceSessionCoordinator sharedInstance]
             bindAuthenticatedContext:context];
            [[TSAIAudioRecordSessionCoordinator sharedInstance]
             bindActiveContext:context];
            TSLog(@"[TSAppDelegate] AI 最终鉴权成功");
            break;
        case TSAIAuthorizationStateAuthenticating:
            TSLog(@"[TSAppDelegate] AI 正在鉴权");
            break;
        case TSAIAuthorizationStateFailed:
            [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:context];
            TSLog(@"[TSAppDelegate] AI 最终鉴权失败，准备重试");
            [self ts_scheduleAIAuthenticationRetryForContext:context];
            break;
        case TSAIAuthorizationStateDisconnected:
            [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:context];
            TSLog(@"[TSAppDelegate] AI 鉴权连接已断开，准备重试");
            [self ts_scheduleAIAuthenticationRetryForContext:context];
            break;
        case TSAIAuthorizationStateUnknown:
            TSLog(@"[TSAppDelegate] AI 鉴权状态未知");
            break;
    }
}

/**
 * 按递增延迟重试 AI 鉴权，等待网络恢复
 */
- (void)ts_scheduleAIAuthenticationRetryForContext:(TSAIContext *)context {
    if (self.aiAuthenticationRequestedMacAddress.length == 0 ||
        self.isAIAuthenticationRetryScheduled) {
        TSLog(@"[TSAppDelegate][AIAuth] 跳过安排重试: requestedMac=%@, retryScheduled=%d",
              self.aiAuthenticationRequestedMacAddress,
              self.isAIAuthenticationRetryScheduled);
        return;
    }
    if (self.aiAuthenticationRetryCount >= kTSAIAuthenticationMaximumRetryCount) {
        TSLog(@"[TSAppDelegate] AI 鉴权已重试 %lu 次仍失败，请检查网络后重新连接设备",
              (unsigned long)kTSAIAuthenticationMaximumRetryCount);
        return;
    }
    
    self.aiAuthenticationRetryCount += 1;
    self.isAIAuthenticationRetryScheduled = YES;
    NSUInteger retryNumber = self.aiAuthenticationRetryCount;
    NSUInteger authenticationGeneration = self.aiAuthenticationGeneration;
    NSString *contextIdentifier = context.contextIdentifier;
    NSTimeInterval delay = kTSAIAuthenticationRetryBaseDelay * (1UL << (retryNumber - 1));
    TSLog(@"[TSAppDelegate] AI 鉴权将在 %.0f 秒后进行第 %lu 次重试",
          delay, (unsigned long)retryNumber);
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.aiAuthenticationGeneration != authenticationGeneration) return;
        strongSelf.isAIAuthenticationRetryScheduled = NO;
        
        TSAIContext *currentContext = [TSAIKit sharedInstance].activeContext;
        TSPeripheral *currentPeripheral = [TSDeviceCoordinator sharedInstance].snapshot.peripheral;
        NSString *currentMac = [strongSelf ts_normalizedMacAddress:currentPeripheral.systemInfo.mac];
        BOOL isCurrentDevice = currentPeripheral &&
        [currentMac isEqualToString:strongSelf.aiAuthenticationRequestedMacAddress];
        BOOL isCurrentContext = [currentContext.contextIdentifier isEqualToString:contextIdentifier];
        if (!isCurrentDevice || !isCurrentContext ||
            currentContext.authorizationState == TSAIAuthorizationStateAuthenticated) {
            TSLog(@"[TSAppDelegate][AIAuth] 取消过期重试: currentDevice=%d, currentContext=%d, "
                  "authorizationState=%ld",
                  isCurrentDevice,
                  isCurrentContext,
                  (long)currentContext.authorizationState);
            return;
        }
        [strongSelf ts_authenticatePeripheral:currentPeripheral withContext:currentContext];
    });
}

/**
 * 使用当前连接设备信息向激活的 AI Context 发起鉴权
 */
- (void)ts_authenticatePeripheral:(TSPeripheral *)peripheral withContext:(TSAIContext *)context {
    TSLog(@"[TSAppDelegate][AIAuth] 收到鉴权请求: mac=%@, contextState=%ld, authorizationState=%ld, "
          "inProgress=%d, authGeneration=%lu, retryCount=%lu",
          [self ts_normalizedMacAddress:peripheral.systemInfo.mac],
          (long)context.state,
          (long)context.authorizationState,
          self.isAIAuthenticationInProgress,
          (unsigned long)self.aiAuthenticationGeneration,
          (unsigned long)self.aiAuthenticationRetryCount);
    if (self.isAIAuthenticationInProgress) {
        self.shouldPrepareAIWhenReady = YES;
        TSLog(@"[TSAppDelegate][AIAuth] 已有鉴权请求执行中，本次请求已排队");
        return;
    }
    
    TSPeripheral *connectedPeripheral = [TSDeviceCoordinator sharedInstance].snapshot.peripheral;
    NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    NSString *requestedMac = [self ts_normalizedMacAddress:
                              peripheral.systemInfo.mac.length > 0 ? peripheral.systemInfo.mac : savedMac];
    NSString *connectedMac = [self ts_normalizedMacAddress:
                              connectedPeripheral.systemInfo.mac.length > 0 ? connectedPeripheral.systemInfo.mac : savedMac];
    if (!connectedPeripheral || (requestedMac.length > 0 && ![requestedMac isEqualToString:connectedMac])) {
        TSLog(@"[TSAppDelegate] AI 鉴权跳过：连接设备已经变化");
        return;
    }
    
    AIBudsAIDeviceInfoModel *deviceInfo = [self ts_aiDeviceInfoWithPeripheral:connectedPeripheral];
    NSString *contextIdentifier = context.contextIdentifier;
    self.aiAuthenticationRequestedMacAddress = requestedMac;
    self.isAIAuthenticationInProgress = YES;
    TSLog(@"[TSAppDelegate][AIAuth] 发起鉴权: requestedMac=%@, connectedMac=%@, contextState=%ld, "
          "authorizationState=%ld",
          requestedMac,
          connectedMac,
          (long)context.state,
          (long)context.authorizationState);
    
    __weak typeof(self) weakSelf = self;
    [context authenticateWithDeviceInfo:deviceInfo completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.isAIAuthenticationInProgress = NO;
            
            TSAIContext *currentContext = [TSAIKit sharedInstance].activeContext;
            TSPeripheral *currentPeripheral = [TSDeviceCoordinator sharedInstance].snapshot.peripheral;
            NSString *currentPeripheralMac = currentPeripheral.systemInfo.mac.length > 0 ?
            currentPeripheral.systemInfo.mac : savedMac;
            NSString *currentMac = [strongSelf ts_normalizedMacAddress:currentPeripheralMac];
            BOOL isCurrentRequest = [currentContext.contextIdentifier isEqualToString:contextIdentifier] &&
            (requestedMac.length == 0 || [requestedMac isEqualToString:currentMac]);
            if (isCurrentRequest) {
                if (success) {
                    TSLog(@"[TSAppDelegate][AIAuth] 鉴权请求已受理: currentRequest=%d, currentMac=%@, "
                          "authorizationState=%ld",
                          isCurrentRequest,
                          currentMac,
                          (long)currentContext.authorizationState);
                } else {
                    TSLog(@"[TSAppDelegate][AIAuth] 鉴权请求失败: errorDomain=%@, errorCode=%ld, error=%@",
                          error.domain,
                          (long)error.code,
                          error);
                    [strongSelf ts_scheduleAIAuthenticationRetryForContext:currentContext];
                }
            } else {
                TSLog(@"[TSAppDelegate] 忽略已失效的 AI 鉴权结果");
            }
            
            if (strongSelf.shouldPrepareAIWhenReady) {
                strongSelf.shouldPrepareAIWhenReady = NO;
                [strongSelf ts_prepareAIForConnectedDevice];
            }
        });
    }];
}

/**
 * 根据设备 SDK 类型返回 AI DeviceBridge 平台标识
 */
- (NSString *)ts_aiPlatformIdentifierForSDKType:(TSSDKType)sdkType {
    switch (sdkType) {
        case eTSSDKTypeFIT:
            return TSAIPlatformIdentifierFit;
        case eTSSDKTypeFW:
            return TSAIPlatformIdentifierPersimwear;
        case eTSSDKTypeTPB:
            return TSAIPlatformIdentifierNewPlatform;
        default:
            return nil;
    }
}

/**
 * 将设备上报的首选 AI 厂商转换为 AIBuds Context 厂商
 */
- (TSAIBudsVendorType)ts_aiVendorForPeripheral:(TSPeripheral *)peripheral {
    switch (peripheral.capability.aiAbility.preferredAIVendor) {
        case TSAIVendorStarBurst:
            return TSAIBudsVendorTypeStarBurst;
        case TSAIVendorMltCloud:
            return TSAIBudsVendorTypeMltCloud;
        default:
            return kTSDemoDefaultAIVendor;
    }
}

/**
 * 从当前设备的连接记录恢复蓝牙与 AI 共用的用户标识
 */
- (void)ts_synchronizeSavedConnectionUserIdentifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserIdentifier = [defaults objectForKey:@"kUserId"];
    if (![savedUserIdentifier isEqualToString:TSDemoDefaultUserIdentifier]) {
        [defaults setObject:TSDemoDefaultUserIdentifier forKey:@"kUserId"];
        [defaults synchronize];
        TSLog(@"[TSAppDelegate] 已同步蓝牙连接与 AI 鉴权的用户标识");
    }
}

/**
 * 归一化 MAC 地址，供连接身份校验
 */
- (NSString *)ts_normalizedMacAddress:(NSString *)macAddress {
    NSString *normalizedMac = [macAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    normalizedMac = [normalizedMac stringByReplacingOccurrencesOfString:@":" withString:@""];
    normalizedMac = [normalizedMac stringByReplacingOccurrencesOfString:@"-" withString:@""];
    normalizedMac = [normalizedMac stringByReplacingOccurrencesOfString:@" " withString:@""];
    return normalizedMac.uppercaseString;
}

/**
 * 使用当前外设信息构建 AIBuds 鉴权设备模型
 */
- (AIBudsAIDeviceInfoModel *)ts_aiDeviceInfoWithPeripheral:(TSPeripheral *)peripheral {
    NSString *macAddress = peripheral.systemInfo.mac;
    if (macAddress.length == 0) {
        macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    }
    NSString *deviceName = peripheral.systemInfo.bleName;
    if (deviceName.length == 0) {
        deviceName = peripheral.systemInfo.peripheral.name;
    }
    if (deviceName.length == 0) {
        deviceName = peripheral.projectInfo.model;
    }
    if (deviceName.length == 0) {
        deviceName = macAddress;
    }
    if (deviceName.length == 0) {
        deviceName = @"TopStep Device";
    }
    return [[AIBudsAIDeviceInfoModel alloc] initWithProduct:AIBudsDeviceProductWatch
                                                       name:deviceName
                                              bluetoothName:peripheral.systemInfo.bleName
                                                 macAddress:macAddress
                                                      model:peripheral.projectInfo.model
                                         formatedProjNumber:peripheral.projectInfo.projectId
                                    formatedFirmwareVersion:peripheral.projectInfo.firmVersion
                                                     userID:TSDemoDefaultUserIdentifier
                                             additionalInfo:nil];
}

/** 处理统一设备连接快照 */
- (void)handleDeviceSnapshotChanged:(NSNotification *)notification {
    TSDeviceConnectionSnapshot *snapshot = notification.userInfo[TSDeviceConnectionSnapshotUserInfoKey];
    if (!snapshot) {
        TSLog(@"[TSAppDelegate][ConnectionSnapshot] 通知缺少连接快照");
        return;
    }
    TSLog(@"[TSAppDelegate][ConnectionSnapshot] 状态变化: ready=%d, connectionGeneration=%lu, "
          "handledGeneration=%lu, sdkType=%ld, hasPeripheral=%d, mac=%@, hadReadySession=%d",
          snapshot.isReady,
          (unsigned long)snapshot.connectionGeneration,
          (unsigned long)self.handledConnectionGeneration,
          (long)snapshot.activeSDKType,
          snapshot.peripheral != nil,
          [self ts_normalizedMacAddress:snapshot.peripheral.systemInfo.mac],
          self.hadReadyDeviceSession);
    if (snapshot.isReady &&
        snapshot.connectionGeneration != self.handledConnectionGeneration) {
        self.handledConnectionGeneration = snapshot.connectionGeneration;
        self.hadReadyDeviceSession = YES;
        TSLog(@"[TSAppDelegate][ConnectionSnapshot] 消费就绪代次并启动 AI: connectionGeneration=%lu",
              (unsigned long)snapshot.connectionGeneration);
        [self ts_startAIForConnectedDevice];

        if (self.pendingInitialRoot || !self.minimumDisplayElapsed) {
            self.pendingInitialRoot = self.mainTabBarController;
            [self ts_deliverInitialRootIfReady];
        } else if (self.window.rootViewController != self.mainTabBarController) {
            [self showMainInterface];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self triggerHomeRefresh];
        });
        return;
    }
    if (snapshot.isReady) {
        TSLog(@"[TSAppDelegate][ConnectionSnapshot] 忽略重复就绪快照: connectionGeneration=%lu",
              (unsigned long)snapshot.connectionGeneration);
    }
    if (!snapshot.isReady && self.hadReadyDeviceSession) {
        self.hadReadyDeviceSession = NO;
        TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
        TSLog(@"[TSAppDelegate][ConnectionSnapshot] 设备退出就绪态，解绑 AI 会话: "
              "connectionGeneration=%lu, contextState=%ld, authorizationState=%ld",
              (unsigned long)snapshot.connectionGeneration,
              (long)activeContext.state,
              (long)activeContext.authorizationState);
        [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
        [[TSAIAudioRecordSessionCoordinator sharedInstance] unbindContext:activeContext];
    }
}

/** 处理绑定记录清除 */
- (void)handleDeviceBindingCleared:(NSNotification *)notification {
    TSLog(@"[TSAppDelegate][ConnectionSnapshot] 设备绑定已清除，重置连接代次");
    self.handledConnectionGeneration = 0;
    self.hadReadyDeviceSession = NO;
    [self showDeviceScanInterface];
}

/**
 * 触发首页下拉刷新
 */
- (void)triggerHomeRefresh {
    if (![self.mainTabBarController.viewControllers.firstObject isKindOfClass:[UINavigationController class]]) return;
    
    UINavigationController *homeNav = (UINavigationController *)self.mainTabBarController.viewControllers.firstObject;
    UIViewController *homeVC = homeNav.topViewController;
    
    if (![homeVC respondsToSelector:@selector(ts_handleRefresh)]) return;
    
    // 显示刷新动画
    UIRefreshControl *refreshControl = [homeVC valueForKey:@"refreshControl"];
    if (refreshControl && refreshControl.superview && !refreshControl.isRefreshing) {
        [refreshControl beginRefreshing];
        UIScrollView *scrollView = (UIScrollView *)refreshControl.superview;
        CGPoint offset = scrollView.contentOffset;
        offset.y = -refreshControl.frame.size.height;
        [scrollView setContentOffset:offset animated:YES];
    }
    
    // 触发数据刷新
    [homeVC performSelector:@selector(ts_handleRefresh)];
}

- (void)dealloc {
    if (self.networkPathMonitor) {
        nw_path_monitor_cancel(self.networkPathMonitor);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    TSLog(@"[TSAppDelegate][Lifecycle] applicationWillResignActive: probeRunning=%d, probeCompleted=%d, "
          "pendingAI=%d",
          self.networkAccessProbeTask != nil,
          self.hasCompletedNetworkAccessProbe,
          self.shouldStartAIWhenNetworkReady);
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    TSLog(@"[TSAppDelegate][Lifecycle] applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    TSLog(@"[TSAppDelegate][Lifecycle] applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    NSTimeInterval probeElapsedTime = 0;
    if (self.networkAccessProbeStartDate) {
        probeElapsedTime = -[self.networkAccessProbeStartDate timeIntervalSinceNow];
    }
    TSLog(@"[TSAppDelegate][Lifecycle] applicationDidBecomeActive: ready=%d, connectionGeneration=%lu, "
          "handledGeneration=%lu, probeRunning=%d, probeElapsed=%.3fs, probeCompleted=%d, "
          "networkAvailable=%d, pendingAI=%d, path={%@}",
          snapshot.isReady,
          (unsigned long)snapshot.connectionGeneration,
          (unsigned long)self.handledConnectionGeneration,
          self.networkAccessProbeTask != nil,
          probeElapsedTime,
          self.hasCompletedNetworkAccessProbe,
          self.isPublicNetworkAccessAvailable,
          self.shouldStartAIWhenNetworkReady,
          [self ts_networkPathDescription:self.latestNetworkPath]);
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    TSLog(@"[TSAppDelegate][Lifecycle] applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
