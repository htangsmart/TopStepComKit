//
//  TSAppDelegate.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppDelegate.h"

#import <TopStepComKit/TopStepComKit.h>
#import <TopStepAIKit/TopStepAIKit.h>
#if __has_include(<TopStepAIKit/TopStepAIKitAdapter.h>)
#import <TopStepAIKit/TopStepAIKitAdapter.h>
@import AIBudsFoundation;
#define TS_DEMO_HAS_AIBUDS 1
#else
#define TS_DEMO_HAS_AIBUDS 0
#endif
#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
#import <TopStepAIKit/TSAIYanJie.h>
#endif
@import Network;

#import "TSMainTabBarController.h"
#import "TSDeviceScanVC.h"
#import "TSDeviceCoordinator.h"
#import "TSHRAlertCoordinator.h"
#import "TSAppLanguageManager.h"
#import "TSAIChatDeviceSessionCoordinator.h"
#import "TSAIAudioRecordSessionCoordinator.h"
#import "TSAIQADeviceSessionCoordinator.h"
#import "UIViewController+TSToast.h"

// 开屏最短展示时长（秒），避免 SDK 初始化过快导致开屏一闪而过
static const NSTimeInterval kTSLaunchMinimumDisplayDuration = 1.0;
// 公网访问探测地址，用实际请求触发系统无线数据授权
static NSString * const kTSNetworkAccessProbeURLString = @"https://fitcloud.hetangsmart.com";
// 公网探测失败后的最大退避重试次数
static const NSUInteger kTSNetworkAccessProbeMaximumRetryCount = 4;
// 公网探测退避重试基础延迟，后续按 3、6、12、24 秒递增
static const NSTimeInterval kTSNetworkAccessProbeRetryBaseDelay = 3.0;
// AI 最终鉴权失败后的最大重试次数
static const NSUInteger kTSAIAuthenticationMaximumRetryCount = 3;
// AI 鉴权重试基础延迟，后续按 2、4、8 秒递增
static const NSTimeInterval kTSAIAuthenticationRetryBaseDelay = 2.0;
// AI 曾暂缓/重试、之后终于就绪时的全局提示文案
static NSString * const kTSAIReadyAfterRetryToastMessage = @"AI 服务已就绪，现在可以使用 AI 功能了";

NSNotificationName const TSAIProviderSelectionDidChangeNotification = @"TSAIProviderSelectionDidChangeNotification";

typedef NS_ENUM(NSInteger, TSDemoAISelectionErrorCode) {
    TSDemoAISelectionErrorInvalidConfiguration = 51000,
    TSDemoAISelectionErrorBusy = 51001,
    TSDemoAISelectionErrorCleanupPending = 51002
};

// 仅描述本地选择状态，不记录SDK凭证或原始错误文本。
static NSError *TSDemoAISelectionError(TSDemoAISelectionErrorCode code, NSString *description) {
    return [NSError errorWithDomain:@"TSDemoAISelectionErrorDomain" code:code
        userInfo:@{NSLocalizedDescriptionKey : description}];
}

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
// 公网访问授权探测是否已完成
@property (nonatomic, assign) BOOL hasCompletedNetworkAccessProbe;
// 公网访问当前是否可用
@property (nonatomic, assign) BOOL isPublicNetworkAccessAvailable;
// 是否应在公网访问就绪后启动 AI
@property (nonatomic, assign) BOOL shouldStartAIWhenNetworkReady;
// 公网探测失败后已安排的退避重试次数
@property (nonatomic, assign) NSUInteger networkAccessProbeRetryCount;
// 公网探测退避重试代次，用于作废挂起的重试任务
@property (nonatomic, assign) NSUInteger networkAccessProbeRetryGeneration;
// 是否已有公网探测退避重试等待执行
@property (nonatomic, assign) BOOL isNetworkAccessProbeRetryScheduled;
// AI 准备流程是否曾暂缓或重试过，就绪后需要全局 Toast 告知用户
@property (nonatomic, assign) BOOL shouldNotifyWhenAIReady;
// AI Context 是否正在激活
@property (nonatomic, assign) BOOL isAIContextActivating;
// AI 流程执行期间收到新的连接事件时，待当前步骤结束后重新处理
@property (nonatomic, assign) BOOL shouldPrepareAIWhenReady;
// AI 鉴权请求是否正在执行
@property (nonatomic, assign) BOOL isAIAuthenticationInProgress;
// 精确隔离旧AIBuds鉴权回调，不用授权状态代次替代请求归属。
@property (nonatomic, copy, nullable) NSString *activeAIAuthenticationRequestIdentifier;
// 当前激活 Context 对应的 AI 厂商
@property (nonatomic, assign) NSInteger activeAIVendor;
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
// 网络路径监听，网络恢复后重新探测公网并续做 AI 鉴权
@property (nonatomic, strong) nw_path_monitor_t networkPathMonitor;
// 最近一次网络路径是否可用
@property (nonatomic, assign) BOOL isNetworkPathSatisfied;
// 岩界选择与凭证只存在进程内，断连不切回设备推荐。
@property (nonatomic, copy, nullable) id explicitYanJieConfiguration;
// 用户切换与异步激活隔离，旧回调不能重新绑定旧厂商。
@property (nonatomic, assign) NSUInteger aiSelectionGeneration;
@property (nonatomic, assign) BOOL isAISelectionTransitioning;
@property (nonatomic, assign) BOOL requiresAISelectionCleanup;
@property (nonatomic, assign) NSUInteger explicitAIConnectionGeneration;
@property (nonatomic, copy, readwrite) NSString *aiProviderSelectionStatus;

@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.aiProviderSelectionStatus = @"设备推荐的AIBuds自动选择";
    [TSAppLanguageManager applyStoredLanguageIfNeeded];
    [[TSHRAlertCoordinator sharedInstance] start];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceSnapshotChanged:)
                                                 name:TSDeviceConnectionSnapshotDidChangeNotification
                                               object:[TSDeviceCoordinator sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceBindingCleared:)
                                                 name:TSDeviceBindingDidClearNotification
                                               object:nil];
    // 工程使用 Scene，AppDelegate 的 applicationDidBecomeActive: 不会回调，改用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [self ts_startNetworkPathMonitor];
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
    [self ts_requestPublicNetworkAccessIfNeeded];
}

/**
 * 用户进入 AI 功能但 AI 尚未就绪时，立即重走探测 / 激活 / 鉴权流程
 */
- (void)retryAIPreparationIfNeeded {
    if (self.requiresAISelectionCleanup) {
        [self ts_changeAISelection:self.explicitYanJieConfiguration completion:^(BOOL success, NSError *error) {
            TSLog(@"[TSAppDelegate] AI清理重试结果=%d code=%ld", success, (long)error.code);
        }];
        return;
    }
    TSLog(@"[TSAppDelegate] 用户进入 AI 功能，检查 AI 准备流程是否需要重试");
    // 用户已经因 AI 未就绪被挡过一次，就绪后要主动告知
    self.shouldNotifyWhenAIReady = YES;
    [self ts_resumeAIIfNeeded];
}

#pragma mark - 公开方法

// 不透明快照避免默认beta15编译依赖新版SDK类型。
- (id)yanJieConfigurationSnapshot { return [self.explicitYanJieConfiguration copy]; }

// 配置不是鉴权；实际授权仍由正常Context激活完成。
- (BOOL)usesExplicitYanJieConfiguration { return self.explicitYanJieConfiguration != nil; }

// 保存选择前先校验已安装产品及本地配置，不启动厂商业务。
- (void)selectYanJieConfiguration:(id)configuration completion:(void (^)(BOOL, NSError *))completion {
#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
    NSError *error = [configuration isKindOfClass:TSAIYanJieConfiguration.class]
        ? [configuration validationError] : TSDemoAISelectionError(TSDemoAISelectionErrorInvalidConfiguration, @"请选择有效的岩界配置");
    if (error == nil) {
        NSSet *installed = [TSAIYanJieConfiguration installedModuleTypes];
        if (![[configuration enabledModules] isSubsetOfSet:installed]) {
            error = TSDemoAISelectionError(TSDemoAISelectionErrorInvalidConfiguration, @"所选岩界模块未安装");
        }
    }
    if (error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, error); });
        return;
    }
    [self ts_changeAISelection:[configuration copy] completion:completion];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(NO, TSDemoAISelectionError(TSDemoAISelectionErrorInvalidConfiguration, @"当前SDK未包含岩界，请先安装显式岩界发布产品"));
    });
#endif
}

// 独立岩界包没有AIBuds，只有包含该产品时才允许恢复自动选择。
- (void)selectAutomaticAIProviderWithCompletion:(void (^)(BOOL, NSError *))completion {
#if TS_DEMO_HAS_AIBUDS
    [self ts_changeAISelection:nil completion:completion];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(NO, TSDemoAISelectionError(TSDemoAISelectionErrorInvalidConfiguration, @"当前为岩界独立产品，切回自动AIBuds需安装共存产品"));
    });
#endif
}

#pragma mark - 私有方法

// 清理失败保留用户目标选择，通过同一路径重试deactivate，不越过待清理Context。
- (void)ts_changeAISelection:(id)configuration completion:(void (^)(BOOL, NSError *))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isAISelectionTransitioning) {
            completion(NO, TSDemoAISelectionError(TSDemoAISelectionErrorBusy, @"AI厂商正在切换，请稍后重试"));
            return;
        }
        self.isAISelectionTransitioning = YES;
        self.aiSelectionGeneration += 1;
        self.aiAuthenticationGeneration += 1;
        self.isAIAuthenticationRetryScheduled = NO;
        self.isAIAuthenticationInProgress = NO;
        self.activeAIAuthenticationRequestIdentifier = nil;
        self.explicitYanJieConfiguration = configuration;
        self.activeAIContextIdentifier = nil;
        self.authenticatedAIMacAddress = nil;
        TSAIContext *context = [TSAIKit sharedInstance].activeContext;
        [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:context];
        [[TSAIQADeviceSessionCoordinator sharedInstance] unbindContext:context];
        [[TSAIAudioRecordSessionCoordinator sharedInstance] unbindContext:context];
        [self ts_updateAISelectionStatus:@"正在停用原AI Context"];
        [[TSAIKit sharedInstance] deactivateActiveContextWithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isAISelectionTransitioning = NO;
                self.isAIContextActivating = NO;
                self.requiresAISelectionCleanup = !success;
                if (!success) {
                    [self ts_updateAISelectionStatus:@"原Context清理失败，已保留目标方案；请再次点击刚才的选择操作重试"];
                    completion(NO, TSDemoAISelectionError(TSDemoAISelectionErrorCleanupPending, @"Context清理失败，请重试，不能直接切换新会话"));
                    return;
                }
                [self ts_updateAISelectionStatus:self.usesExplicitYanJieConfiguration
                    ? @"已选择岩界，等待真实设备连接及授权" : @"已恢复设备推荐的AIBuds自动选择"];
                completion(YES, nil);
                TSDeviceConnectionSnapshot *snapshot = TSDeviceCoordinator.sharedInstance.snapshot;
                if (snapshot.isReady && snapshot.peripheral != nil) { [self ts_startAIForConnectedDevice]; }
            });
        }];
    });
}

// UI只收到安全阶段，不传播原始SDK错误描述。
- (void)ts_updateAISelectionStatus:(NSString *)status {
    self.aiProviderSelectionStatus = status;
    [NSNotificationCenter.defaultCenter postNotificationName:TSAIProviderSelectionDidChangeNotification object:self];
}

/**
 * 通过一次轻量公网请求触发系统无线数据授权
 */
- (void)ts_requestPublicNetworkAccessIfNeeded {
    if (self.networkAccessProbeTask || self.hasCompletedNetworkAccessProbe) {
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
    __weak typeof(self) weakSelf = self;
    self.networkAccessProbeTask = [self.networkAccessProbeSession
        dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.networkAccessProbeSession finishTasksAndInvalidate];
                strongSelf.networkAccessProbeTask = nil;
                strongSelf.networkAccessProbeSession = nil;
                strongSelf.isPublicNetworkAccessAvailable = !error;
                if (error) {
                    // 失败不标记完成、不清 shouldStartAIWhenNetworkReady；
                    // AI 等待中则按退避策略自动重探，网络恢复/回前台/设备就绪/用户进入 AI 功能时也会重探
                    strongSelf.hasCompletedNetworkAccessProbe = NO;
                    TSLog(@"[TSAppDelegate] 公网访问授权探测失败: %@", error.localizedDescription);
                    if (strongSelf.shouldStartAIWhenNetworkReady) {
                        TSLog(@"[TSAppDelegate] AI 初始化暂缓：公网访问不可用，按退避策略重试探测");
                        strongSelf.shouldNotifyWhenAIReady = YES;
                        [strongSelf ts_scheduleNetworkAccessProbeRetry];
                    }
                    return;
                }
                [strongSelf ts_resetNetworkAccessProbeRetry];
                strongSelf.hasCompletedNetworkAccessProbe = YES;
                TSLog(@"[TSAppDelegate] 公网访问授权探测完成");
                if (strongSelf.shouldStartAIWhenNetworkReady) {
                    strongSelf.shouldStartAIWhenNetworkReady = NO;
                    [strongSelf ts_startAIForConnectedDevice];
                }
            });
        }];
    [self.networkAccessProbeTask resume];
}

/**
 * 公网探测失败后按递增延迟（3/6/12/24 秒）重新探测，超过上限则只等外部事件触发
 */
- (void)ts_scheduleNetworkAccessProbeRetry {
    if (self.isNetworkAccessProbeRetryScheduled) {
        return;
    }
    if (self.networkAccessProbeRetryCount >= kTSNetworkAccessProbeMaximumRetryCount) {
        TSLog(@"[TSAppDelegate] 公网探测已重试 %lu 次仍失败，等待网络恢复、App 回到前台或再次进入 AI 功能后重试",
              (unsigned long)kTSNetworkAccessProbeMaximumRetryCount);
        return;
    }

    self.networkAccessProbeRetryCount += 1;
    self.isNetworkAccessProbeRetryScheduled = YES;
    NSUInteger retryNumber = self.networkAccessProbeRetryCount;
    NSUInteger retryGeneration = self.networkAccessProbeRetryGeneration;
    NSTimeInterval delay = kTSNetworkAccessProbeRetryBaseDelay * (1UL << (retryNumber - 1));
    TSLog(@"[TSAppDelegate] 公网探测将在 %.0f 秒后进行第 %lu 次重试", delay, (unsigned long)retryNumber);

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.networkAccessProbeRetryGeneration != retryGeneration) return;
        strongSelf.isNetworkAccessProbeRetryScheduled = NO;
        if (strongSelf.hasCompletedNetworkAccessProbe || !strongSelf.shouldStartAIWhenNetworkReady) return;
        TSLog(@"[TSAppDelegate] 公网探测第 %lu 次重试开始", (unsigned long)retryNumber);
        [strongSelf ts_requestPublicNetworkAccessIfNeeded];
    });
}

/**
 * 重置公网探测退避状态并作废挂起的重试任务（探测成功或外部事件触发重探时调用）
 */
- (void)ts_resetNetworkAccessProbeRetry {
    self.networkAccessProbeRetryGeneration += 1;
    self.networkAccessProbeRetryCount = 0;
    self.isNetworkAccessProbeRetryScheduled = NO;
}

/**
 * AI 曾暂缓/重试、现在终于就绪：在全局 window 上 Toast 告知用户（首次一次性成功不提示）
 */
- (void)ts_notifyAIReadyAfterRetryIfNeeded {
    if (!self.shouldNotifyWhenAIReady) return;
    self.shouldNotifyWhenAIReady = NO;
    TSLog(@"[TSAppDelegate] AI 在暂缓/重试后已就绪，提示用户");
    [UIViewController ts_showGlobalToast:kTSAIReadyAfterRetryToastMessage];
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
    self.activeAIAuthenticationRequestIdentifier = nil;
    self.isAIAuthenticationInProgress = NO;
    if (!self.hasCompletedNetworkAccessProbe) {
        self.shouldStartAIWhenNetworkReady = YES;
        TSLog(@"[TSAppDelegate] AI 初始化等待公网访问授权结果");
        // 新的设备就绪事件：重置退避计数后重新发起探测；探测进行中则直接复用
        [self ts_resetNetworkAccessProbeRetry];
        [self ts_requestPublicNetworkAccessIfNeeded];
        return;
    }

    TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
    [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
    [[TSAIQADeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
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
    if (self.isAISelectionTransitioning || self.requiresAISelectionCleanup) { return; }
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheral *peripheral = snapshot.peripheral;
    if (!peripheral) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：当前没有已连接设备");
        return;
    }
    
    TSSDKType sdkType = snapshot.activeSDKType;
    NSString *platformIdentifier = [self ts_aiPlatformIdentifierForSDKType:sdkType];
#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
    if (self.usesExplicitYanJieConfiguration) {
        if (!snapshot.isReady) {
            [self ts_updateAISelectionStatus:@"已保留岩界选择，等待真实设备连接就绪"];
            return;
        }
        [self ts_prepareExplicitYanJieForSnapshot:snapshot platformIdentifier:platformIdentifier];
        return;
    }
#endif
#if TS_DEMO_HAS_AIBUDS
    TSAIBudsVendorType vendor = [self ts_aiVendorForPeripheral:peripheral];
    if (vendor == TSAIBudsVendorTypeNone) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：设备未上报有效 AI 方案");
        return;
    }
    if (platformIdentifier.length == 0) {
        TSLog(@"[TSAppDelegate] AI 初始化跳过：当前平台不支持");
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
            [[TSAIQADeviceSessionCoordinator sharedInstance]
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
#else
    [self ts_updateAISelectionStatus:@"当前产品未安装AIBuds，请进入AI方案配置后显式选择岩界"];
#endif
}

#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
// 岩界由真实平台注册Bridge和独立配置激活，不读取设备推荐厂商枚举。
- (void)ts_prepareExplicitYanJieForSnapshot:(TSDeviceConnectionSnapshot *)snapshot
                       platformIdentifier:(NSString *)platformIdentifier {
    if (platformIdentifier.length == 0 ||
        [[TSAIDeviceBridgeRegistry sharedRegistry] createDeviceBridgeForPlatformIdentifier:platformIdentifier] == nil) {
        [self ts_updateAISelectionStatus:@"当前平台没有真实AI Bridge，不能激活岩界"];
        return;
    }
    TSAIContext *current = [TSAIKit sharedInstance].activeContext;
    BOOL expected = current.state == TSAIContextStateActive &&
        [current.contextIdentifier isEqualToString:self.activeAIContextIdentifier] &&
        [current.platformIdentifier isEqualToString:platformIdentifier] &&
        self.explicitAIConnectionGeneration == snapshot.connectionGeneration;
    if (expected && current.authorizationState == TSAIAuthorizationStateAuthenticated) {
        [self ts_handleAuthorizationState:current.authorizationState context:current];
        return;
    }
    if (self.isAIContextActivating) { self.shouldPrepareAIWhenReady = YES; return; }
    NSUInteger selectionGeneration = self.aiSelectionGeneration;
    NSUInteger connectionGeneration = snapshot.connectionGeneration;
    TSAIContextConfiguration *configuration = [TSAIContextConfiguration
        configurationWithPlatformIdentifier:platformIdentifier providerType:TSAIProviderTypeAIYanJie
        providerConfiguration:[self.explicitYanJieConfiguration copy]];
    self.isAIContextActivating = YES;
    [self ts_updateAISelectionStatus:@"岩界正在执行所有启用模块的真实授权"];
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance] activateContextWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil || strongSelf.aiSelectionGeneration != selectionGeneration) { return; }
            strongSelf.isAIContextActivating = NO;
            TSDeviceConnectionSnapshot *latest = TSDeviceCoordinator.sharedInstance.snapshot;
            if (!success) {
                strongSelf.requiresAISelectionCleanup = YES;
                [strongSelf ts_updateAISelectionStatus:[NSString stringWithFormat:
                    @"岩界激活失败（code=%ld），保留配置，可应用/重试", (long)error.code]];
                return;
            }
            if (!latest.isReady || latest.connectionGeneration != connectionGeneration) {
                [strongSelf ts_updateAISelectionStatus:@"连接已改变，等待当前设备重新激活岩界"];
                if (latest.isReady) { [strongSelf ts_prepareAIForConnectedDevice]; }
                return;
            }
            TSAIContext *active = [TSAIKit sharedInstance].activeContext;
            if (active.state != TSAIContextStateActive) {
                [strongSelf ts_updateAISelectionStatus:@"岩界未发布有效Context，请应用/重试"];
                return;
            }
            strongSelf.activeAIContextIdentifier = active.contextIdentifier;
            strongSelf.explicitAIConnectionGeneration = connectionGeneration;
            strongSelf.aiAuthenticationRequestedMacAddress = [strongSelf ts_normalizedMacAddress:latest.peripheral.systemInfo.mac];
            [strongSelf ts_registerAuthorizationStateObserverForContext:active];
            // initialize已原子授权，按实际状态绑定；不再调用AIBuds设备鉴权。
            [strongSelf ts_handleAuthorizationState:active.authorizationState context:active];
            if (strongSelf.shouldPrepareAIWhenReady) {
                strongSelf.shouldPrepareAIWhenReady = NO;
                [strongSelf ts_prepareAIForConnectedDevice];
            }
        });
    }];
}
#endif

#if TS_DEMO_HAS_AIBUDS
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
    NSUInteger selectionGeneration = self.aiSelectionGeneration;
    
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance] activateContextWithConfiguration:contextConfiguration
                                                    completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.aiSelectionGeneration != selectionGeneration) return;
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
#endif

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
    if (self.isAISelectionTransitioning) { return; }
    if (self.usesExplicitYanJieConfiguration) {
        [self ts_updateAISelectionStatus:state == TSAIAuthorizationStateAuthenticated
            ? @"岩界真实授权已完成，可在现有业务页使用已支持能力"
            : @"岩界授权尚未就绪或已失效，请应用/重试；不会回退自动厂商"];
    }
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
            [[TSAIQADeviceSessionCoordinator sharedInstance]
             bindAuthenticatedContext:context];
            TSLog(@"[TSAppDelegate] AI 最终鉴权成功");
            [self ts_notifyAIReadyAfterRetryIfNeeded];
            break;
        case TSAIAuthorizationStateAuthenticating:
            TSLog(@"[TSAppDelegate] AI 正在鉴权");
            break;
        case TSAIAuthorizationStateFailed:
            [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:context];
            [[TSAIQADeviceSessionCoordinator sharedInstance] unbindContext:context];
            TSLog(@"[TSAppDelegate] AI 最终鉴权失败，准备重试");
            [self ts_scheduleAIAuthenticationRetryForContext:context];
            break;
        case TSAIAuthorizationStateDisconnected:
            [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:context];
            [[TSAIQADeviceSessionCoordinator sharedInstance] unbindContext:context];
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
    if (self.usesExplicitYanJieConfiguration || self.isAISelectionTransitioning) { return; }
    if (self.aiAuthenticationRequestedMacAddress.length == 0 ||
        self.isAIAuthenticationRetryScheduled) {
        return;
    }
    if (self.aiAuthenticationRetryCount >= kTSAIAuthenticationMaximumRetryCount) {
        TSLog(@"[TSAppDelegate] AI 鉴权已重试 %lu 次仍失败，等待网络恢复或 App 回到前台后自动重试",
              (unsigned long)kTSAIAuthenticationMaximumRetryCount);
        return;
    }
    
    self.aiAuthenticationRetryCount += 1;
    self.isAIAuthenticationRetryScheduled = YES;
    self.shouldNotifyWhenAIReady = YES;
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
            return;
        }
        [strongSelf ts_authenticatePeripheral:currentPeripheral withContext:currentContext];
    });
}

/**
 * 使用当前连接设备信息向激活的 AI Context 发起鉴权
 */
- (void)ts_authenticatePeripheral:(TSPeripheral *)peripheral withContext:(TSAIContext *)context {
    if (self.usesExplicitYanJieConfiguration || self.isAISelectionTransitioning) { return; }
#if TS_DEMO_HAS_AIBUDS
    if (self.isAIAuthenticationInProgress) {
        self.shouldPrepareAIWhenReady = YES;
        return;
    }
    
    TSDeviceConnectionSnapshot *requestedSnapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheral *connectedPeripheral = requestedSnapshot.peripheral;
    NSString *savedMac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    NSString *requestedMac = [self ts_normalizedMacAddress:
                              peripheral.systemInfo.mac.length > 0 ? peripheral.systemInfo.mac : savedMac];
    NSString *connectedMac = [self ts_normalizedMacAddress:
                              connectedPeripheral.systemInfo.mac.length > 0 ? connectedPeripheral.systemInfo.mac : savedMac];
    if (!requestedSnapshot.isReady || !connectedPeripheral ||
        (requestedMac.length > 0 && ![requestedMac isEqualToString:connectedMac])) {
        TSLog(@"[TSAppDelegate] AI 鉴权跳过：连接设备已经变化");
        return;
    }
    
    AIBudsAIDeviceInfoModel *deviceInfo = [self ts_aiDeviceInfoWithPeripheral:connectedPeripheral];
    NSString *contextIdentifier = context.contextIdentifier;
    NSString *requestIdentifier = NSUUID.UUID.UUIDString;
    NSUInteger selectionGeneration = self.aiSelectionGeneration;
    NSUInteger connectionGeneration = requestedSnapshot.connectionGeneration;
    self.aiAuthenticationRequestedMacAddress = requestedMac;
    self.activeAIAuthenticationRequestIdentifier = requestIdentifier;
    self.isAIAuthenticationInProgress = YES;
    
    __weak typeof(self) weakSelf = self;
    [context authenticateWithDeviceInfo:deviceInfo completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.aiSelectionGeneration != selectionGeneration ||
                ![strongSelf.activeAIAuthenticationRequestIdentifier isEqualToString:requestIdentifier]) { return; }
            
            TSAIContext *currentContext = [TSAIKit sharedInstance].activeContext;
            TSDeviceConnectionSnapshot *currentSnapshot = [TSDeviceCoordinator sharedInstance].snapshot;
            TSPeripheral *currentPeripheral = currentSnapshot.peripheral;
            NSString *currentPeripheralMac = currentPeripheral.systemInfo.mac.length > 0 ?
            currentPeripheral.systemInfo.mac : savedMac;
            NSString *currentMac = [strongSelf ts_normalizedMacAddress:currentPeripheralMac];
            BOOL isCurrentRequest = currentSnapshot.isReady && currentPeripheral != nil &&
            currentSnapshot.connectionGeneration == connectionGeneration &&
            [currentContext.contextIdentifier isEqualToString:contextIdentifier] &&
            (requestedMac.length == 0 || [requestedMac isEqualToString:currentMac]);
            if (!isCurrentRequest) {
                TSLog(@"[TSAppDelegate] 忽略已失效的 AI 鉴权结果");
                return;
            }
            strongSelf.activeAIAuthenticationRequestIdentifier = nil;
            strongSelf.isAIAuthenticationInProgress = NO;
            if (success) {
                TSLog(@"[TSAppDelegate] AI 鉴权请求已受理，等待最终鉴权状态");
            } else {
                TSLog(@"[TSAppDelegate] AI 鉴权请求失败 code=%ld", (long)error.code);
                [strongSelf ts_scheduleAIAuthenticationRetryForContext:currentContext];
            }
            
            if (strongSelf.shouldPrepareAIWhenReady) {
                strongSelf.shouldPrepareAIWhenReady = NO;
                [strongSelf ts_prepareAIForConnectedDevice];
            }
        });
    }];
#endif
}

/**
 * 启动网络路径监听，网络由不可用恢复为可用时重新探测公网并续做 AI 鉴权
 */
- (void)ts_startNetworkPathMonitor {
    if (self.networkPathMonitor) return;
    
    nw_path_monitor_t monitor = nw_path_monitor_create();
    nw_path_monitor_set_queue(monitor, dispatch_get_main_queue());
    __weak typeof(self) weakSelf = self;
    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        BOOL isSatisfied = nw_path_get_status(path) == nw_path_status_satisfied;
        BOOL didBecomeReachable = isSatisfied && !strongSelf.isNetworkPathSatisfied;
        strongSelf.isNetworkPathSatisfied = isSatisfied;
        if (didBecomeReachable) {
            TSLog(@"[TSAppDelegate] 网络已恢复可用，检查 AI 鉴权状态");
            [strongSelf ts_resumeAIIfNeeded];
        }
    });
    nw_path_monitor_start(monitor);
    self.networkPathMonitor = monitor;
}

/**
 * 网络恢复或 App 回到前台时，若设备已就绪但 AI 尚未完成最终鉴权，则重新走探测/鉴权流程
 */
- (void)ts_resumeAIIfNeeded {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheral *peripheral = snapshot.peripheral;
    if (!snapshot.isReady || !peripheral) return;
    
    TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
    NSString *connectedMac = [self ts_normalizedMacAddress:peripheral.systemInfo.mac];
    BOOL isAuthenticated = activeContext.state == TSAIContextStateActive &&
    activeContext.authorizationState == TSAIAuthorizationStateAuthenticated &&
    [connectedMac isEqualToString:self.authenticatedAIMacAddress];
    if (isAuthenticated) return;
    
    if (!self.hasCompletedNetworkAccessProbe) {
        // 探测尚未成功：外部事件触发，重置退避计数后立即重探，成功后自动启动 AI
        self.shouldStartAIWhenNetworkReady = YES;
        [self ts_resetNetworkAccessProbeRetry];
        [self ts_requestPublicNetworkAccessIfNeeded];
        return;
    }
    
    // 探测已成功：作废挂起的退避重试，重置计数后立即重新鉴权
    self.aiAuthenticationGeneration += 1;
    self.aiAuthenticationRetryCount = 0;
    self.isAIAuthenticationRetryScheduled = NO;
    TSLog(@"[TSAppDelegate] 重新发起 AI 鉴权");
    [self ts_prepareAIForConnectedDevice];
}

/** App 回到前台时检查 AI 鉴权是否需要续做 */
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    [self ts_resumeAIIfNeeded];
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
 * 将设备上报的首选 AI 厂商转换为 AIBuds Context 厂商，未知方案不使用兜底
 */
- (NSInteger)ts_aiVendorForPeripheral:(TSPeripheral *)peripheral {
#if TS_DEMO_HAS_AIBUDS
    switch (peripheral.capability.aiAbility.preferredAIVendor) {
        case TSAIVendorStarBurst:
            return TSAIBudsVendorTypeStarBurst;
        case TSAIVendorMltCloud:
            return TSAIBudsVendorTypeMltCloud;
        default:
            return TSAIBudsVendorTypeNone;
    }
#else
    return NSNotFound;
#endif
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
#if TS_DEMO_HAS_AIBUDS
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
#endif

/** 处理统一设备连接快照 */
- (void)handleDeviceSnapshotChanged:(NSNotification *)notification {
    TSDeviceConnectionSnapshot *snapshot = notification.userInfo[TSDeviceConnectionSnapshotUserInfoKey];
    if (!snapshot) {
        return;
    }
    if (snapshot.isReady &&
        snapshot.connectionGeneration != self.handledConnectionGeneration) {
        self.handledConnectionGeneration = snapshot.connectionGeneration;
        self.hadReadyDeviceSession = YES;
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
    if (!snapshot.isReady && self.hadReadyDeviceSession) {
        self.hadReadyDeviceSession = NO;
        TSAIContext *activeContext = [TSAIKit sharedInstance].activeContext;
        [[TSAIChatDeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
        [[TSAIQADeviceSessionCoordinator sharedInstance] unbindContext:activeContext];
        [[TSAIAudioRecordSessionCoordinator sharedInstance] unbindContext:activeContext];
    }
}

/** 处理绑定记录清除 */
- (void)handleDeviceBindingCleared:(NSNotification *)notification {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.networkPathMonitor) {
        nw_path_monitor_cancel(self.networkPathMonitor);
        self.networkPathMonitor = nil;
    }
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
