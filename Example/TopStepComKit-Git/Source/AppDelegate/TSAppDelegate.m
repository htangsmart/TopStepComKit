//
//  TSAppDelegate.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppDelegate.h"

#import <TopStepComKit/TopStepComKit.h>
#import <TopStepAIKit/TopStepAIKitAdapter.h>
#import <TopStepToolKit/TSConnectedPeripheral.h>
@import AIBudsFoundation;

#import "TSMainTabBarController.h"
#import "TSDeviceScanVC.h"
#import "TSAppLanguageManager.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIAudioRecordSessionCoordinator.h"

// 开屏最短展示时长（秒），避免 SDK 初始化过快导致开屏一闪而过
static const NSTimeInterval kTSLaunchMinimumDisplayDuration = 1.0;
// Demo 未接入 Flywear 的服务端能力路由，设备未建议厂商时默认使用 StarBurst
static const TSAIBudsVendorType kTSDemoDefaultAIVendor = TSAIBudsVendorTypeStarBurst;
// Demo 未接入账号系统时使用的默认用户标识
static NSString * const kTSDemoDefaultUserIdentifier = @"fajlief";
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

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TSAppLanguageManager applyStoredLanguageIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceBindSuccess:)
                                                 name:@"TSDeviceBindSuccessNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceReconnected:)
                                                 name:@"TSDeviceReconnectedNotification"
                                               object:nil];
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
}

/**
 * 检查设备绑定状态
 */
- (void)checkDeviceBindingStatus {
    // 检查 UserDefaults 中是否有历史绑定设备记录
    BOOL hasBoundDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"TSHasBoundDevice"];
    
    // 始终先展示静态开屏，并保证最短展示时长，避免开屏一闪而过
    self.window.rootViewController = [self ts_makeLaunchSplashVC];
    [self ts_startMinimumDisplayTimer];
    
    if (hasBoundDevice) {
        // 有历史绑定设备：SDK 初始化是异步的，就绪后再切主界面
        [self ts_initSDKThenShowMain];
    } else {
        // 没有绑定过设备，目标为扫描页（扫描页内部会初始化 SDK）
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
    // 优先使用上次保存的 SDK 类型；未保存过时兜底为 eTSSDKTypeTPB
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TSSDKType sdkType;
    if ([defaults objectForKey:@"TSSavedSDKType"]) {
        sdkType = (TSSDKType)[defaults integerForKey:@"TSSavedSDKType"];
    } else {
        sdkType = eTSSDKTypeTPB;
    }
    
    TSKitConfigOptions *config = [TSKitConfigOptions configOptionWithSDKType:sdkType
                                                                     license:@"abcdef1234567890abcdef1234567890"];
    TSLogConfig *loginConfig = [[TSLogConfig alloc] init];
    loginConfig.enabled = YES;
    loginConfig.level = TopStepLogLevelDebug;
    config.logConfig = loginConfig;
    
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:config completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (isSuccess) {
                [strongSelf ts_synchronizeSavedConnectionUserIdentifier];
                strongSelf.pendingInitialRoot = strongSelf.mainTabBarController;
                [strongSelf ts_deliverInitialRootIfReady];
                // SDK 就绪后通知，让需要用 SDK 的 VC 发起自动重连等依赖 SDK 的动作
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSSDKDidInitializeNotification"
                                                                    object:@(sdkType)];
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
    TSPeripheral *peripheral = [TopStepComKit sharedInstance].connectedPeripheral;
    if (!peripheral) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：当前没有已连接设备");
        return;
    }
    
    TSSDKType sdkType = [TopStepComKit sharedInstance].kitOption.sdkType;
    NSString *platformIdentifier = [self ts_aiPlatformIdentifierForSDKType:sdkType];
    TSAIBudsVendorType vendor = [self ts_aiVendorForPeripheral:peripheral];
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
    
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance] activateContextWithConfiguration:contextConfiguration
                                                    completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.isAIContextActivating = NO;
            if (!success) {
                TSLog(@"[TSAppDelegate] AI Context 激活失败: %@", error.localizedDescription);
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
            TSLog(@"[TSAppDelegate] AI Context 激活成功");
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
        TSPeripheral *currentPeripheral = [TopStepComKit sharedInstance].connectedPeripheral;
        NSString *currentMac = [strongSelf ts_normalizedMacAddress:currentPeripheral.systemInfo.mac];
        BOOL isCurrentDevice = currentPeripheral &&
        [currentMac isEqualToString:strongSelf.aiAuthenticationRequestedMacAddress];
        BOOL isCurrentContext = [currentContext.contextIdentifier isEqualToString:contextIdentifier];
        if (!isCurrentDevice || !isCurrentContext ||
            currentContext.authorizationState == TSAIAuthorizationStateAuthenticated) {
            return;
        }
        [strongSelf ts_authenticatePeripheral:currentPeripheral withContext:currentContext];
    });
}

/**
 * 使用当前连接设备信息向激活的 AI Context 发起鉴权
 */
- (void)ts_authenticatePeripheral:(TSPeripheral *)peripheral withContext:(TSAIContext *)context {
    if (self.isAIAuthenticationInProgress) {
        self.shouldPrepareAIWhenReady = YES;
        return;
    }
    
    TSPeripheral *connectedPeripheral = [TopStepComKit sharedInstance].connectedPeripheral;
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
    
    __weak typeof(self) weakSelf = self;
    [context authenticateWithDeviceInfo:deviceInfo completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            strongSelf.isAIAuthenticationInProgress = NO;
            
            TSAIContext *currentContext = [TSAIKit sharedInstance].activeContext;
            TSPeripheral *currentPeripheral = [TopStepComKit sharedInstance].connectedPeripheral;
            NSString *currentPeripheralMac = currentPeripheral.systemInfo.mac.length > 0 ?
            currentPeripheral.systemInfo.mac : savedMac;
            NSString *currentMac = [strongSelf ts_normalizedMacAddress:currentPeripheralMac];
            BOOL isCurrentRequest = [currentContext.contextIdentifier isEqualToString:contextIdentifier] &&
            (requestedMac.length == 0 || [requestedMac isEqualToString:currentMac]);
            if (isCurrentRequest) {
                if (success) {
                    TSLog(@"[TSAppDelegate] AI 鉴权请求已受理，等待最终鉴权状态");
                } else {
                    TSLog(@"[TSAppDelegate] AI 鉴权请求失败: %@", error.localizedDescription);
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
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    [self ts_connectionUserIdentifierForMacAddress:macAddress];
}

/**
 * 获取当前连接身份的用户标识，优先采用设备最近一次绑定记录
 */
- (NSString *)ts_connectionUserIdentifierForMacAddress:(NSString *)macAddress {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedUserIdentifier = [defaults objectForKey:@"kUserId"];
    TSConnectedPeripheral *connectionRecord = nil;
    if (macAddress.length > 0) {
        connectionRecord = [TSConnectedPeripheral queryLatestConnectedPeripheralWithMacAddress:macAddress];
    }
    
    NSString *userIdentifier = connectionRecord.userID;
    if (userIdentifier.length == 0) {
        userIdentifier = savedUserIdentifier;
    }
    if (userIdentifier.length == 0) {
        userIdentifier = kTSDemoDefaultUserIdentifier;
    }
    if (![savedUserIdentifier isEqualToString:userIdentifier]) {
        [defaults setObject:userIdentifier forKey:@"kUserId"];
        [defaults synchronize];
        TSLog(@"[TSAppDelegate] 已同步蓝牙连接与 AI 鉴权的用户标识");
    }
    return userIdentifier;
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
    NSString *userIdentifier = [self ts_connectionUserIdentifierForMacAddress:macAddress];
    return [[AIBudsAIDeviceInfoModel alloc] initWithProduct:AIBudsDeviceProductWatch
                                                       name:deviceName
                                              bluetoothName:peripheral.systemInfo.bleName
                                                 macAddress:macAddress
                                                      model:peripheral.projectInfo.model
                                         formatedProjNumber:peripheral.projectInfo.projectId
                                    formatedFirmwareVersion:peripheral.projectInfo.firmVersion
                                                     userID:userIdentifier
                                             additionalInfo:nil];
}

/**
 * 处理设备绑定成功（首次绑定）
 */
- (void)handleDeviceBindSuccess:(NSNotification *)notification {
    // 记录已绑定设备
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TSHasBoundDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self ts_startAIForConnectedDevice];
    
    // 切换到主界面
    [self showMainInterface];
    
    // 延迟触发首页刷新（等待界面切换完成）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self triggerHomeRefresh];
    });
}

/**
 * 处理设备重连成功
 */
- (void)handleDeviceReconnected:(NSNotification *)notification {
    [self ts_startAIForConnectedDevice];
    [self triggerHomeRefresh];
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

/**
 * 处理设备解绑
 */
- (void)handleDeviceUnbind {
    // 清除绑定标记
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TSHasBoundDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 切换到扫描页
    [self showDeviceScanInterface];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
