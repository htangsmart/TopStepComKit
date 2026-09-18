//
//  TSAIBudsManager+Private.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/14.
//

#import "TSAIBudsManager.h"

#import "../Runtime/TSAIBudsRuntimeCoordinator+Internal.h"
#import "TSAINetworkStatusProvider.h"

@class TSStarBurstDevice;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Private state shared by the AIBuds manager implementation units
 * @chinese AIBuds Manager 各实现单元共享的私有状态
 */
@interface TSAIBudsManager ()

/** @brief Current manager configuration @chinese 当前管理器配置 */
@property (nonatomic, strong, readwrite, nullable) TSAIBudsConfiguration *configuration;
/** @brief Weak Context device bridge @chinese Context 设备桥接器弱引用 */
@property (nonatomic, weak, readwrite, nullable) id<TSAIDeviceBridge> deviceBridge;
/** @brief Whether the manager is configured @chinese 管理器是否已配置 */
@property (nonatomic, assign, readwrite) BOOL isConfigured;
/** @brief Whether the manager is attached to Runtime @chinese 是否已接入全局 Runtime */
@property (nonatomic, assign, readwrite) BOOL isInitialized;
/** @brief Current authorization state @chinese 当前鉴权状态 */
@property (nonatomic, assign, readwrite) TSAIAuthorizationState authorizationState;
/** @brief Current Context vendor @chinese 当前 Context 厂商 */
@property (nonatomic, assign) TSAIBudsVendorType activeVendor;
/** @brief Current vendor device object @chinese 当前厂商设备对象 */
@property (nonatomic, strong, nullable) id currentDevice;
/** @brief Current device identifier @chinese 当前设备标识 */
@property (nonatomic, copy, nullable) NSString *deviceIdentifier;
/** @brief Lifecycle generation for stale callbacks @chinese 用于隔离迟到回调的生命周期代次 */
@property (nonatomic, assign) NSUInteger lifecycleGeneration;
/** @brief Serial manager lifecycle queue @chinese Manager 生命周期串行队列 */
@property (nonatomic, strong) dispatch_queue_t lifecycleQueue;
/** @brief Process-wide Runtime coordinator @chinese 进程级 Runtime 协调器 */
@property (nonatomic, strong) TSAIBudsRuntimeCoordinator *runtimeCoordinator;
/** @brief Authentication lifecycle generation @chinese 鉴权请求生命周期代次 */
@property (nonatomic, assign) NSUInteger authenticationGeneration;
/** @brief Authentication vendor @chinese 鉴权请求厂商 */
@property (nonatomic, assign) TSAIBudsVendorType authenticationVendor;
/** @brief Authentication device identifier @chinese 鉴权请求设备标识 */
@property (nonatomic, copy, nullable) NSString *authenticationIdentifier;
/** @brief Authentication request token @chinese 底层鉴权请求令牌 */
@property (nonatomic, copy, nullable) NSString *authenticationRequestToken;
/** @brief Whether App authentication is running @chinese App 鉴权是否正在执行 */
@property (nonatomic, assign) BOOL authenticationInFlight;
/** @brief Whether device authentication is prepared @chinese 设备侧鉴权是否准备完成 */
@property (nonatomic, assign) BOOL authenticationPrepared;
/** @brief Whether current device info is stored in Runtime @chinese Runtime 是否已保存当前设备信息 */
@property (nonatomic, assign) BOOL authenticationDeviceInfoPrepared;
/** @brief Whether vendor authentication environment is ready @chinese 厂商鉴权环境是否准备完成 */
@property (nonatomic, assign) BOOL authenticationEnvironmentPrepared;
/** @brief Whether authentication has a terminal result @chinese 当前鉴权是否已有终态 */
@property (nonatomic, assign) BOOL authenticationTerminal;
/** @brief Terminal authentication success flag @chinese 鉴权终态成功标记 */
@property (nonatomic, assign) BOOL authenticationSuccess;
/** @brief Terminal authentication error @chinese 鉴权终态错误 */
@property (nonatomic, strong, nullable) NSError *authenticationError;
/** @brief App authentication waiters @chinese App 鉴权等待回调 */
@property (nonatomic, strong) NSMutableArray *authenticationWaiters;
/** @brief Context network source @chinese Context 共用网络源 */
@property (nonatomic, strong, nullable) id<TSAINetworkStatusProvider> networkStatusProvider;
/** @brief Network observation token @chinese 当前网络观察令牌 */
@property (nonatomic, strong, nullable) id networkObservationToken;
/** @brief Runtime completion observation @chinese 底层请求结束观察令牌 */
@property (nonatomic, strong, nullable) id runtimeAuthenticationObservation;
/** @brief Identity of the active environment subscription @chinese 当前环境订阅身份 */
@property (nonatomic, copy, nullable) NSString *mltObservationIdentifier;
/** @brief Last observed network status @chinese 最近收到的网络状态 */
@property (nonatomic, assign) TSAINetworkStatus observedNetworkStatus;
/** @brief Current MltCloud device metadata @chinese 当前 MltCloud 设备信息，不是等待请求 */
@property (nonatomic, strong, nullable) AIBudsAIDeviceInfoModel *mltDeviceInfo;
/** @brief Owner of the current metadata @chinese 当前设备信息所属标识 */
@property (nonatomic, copy, nullable) NSString *mltDeviceIdentifier;
/** @brief Single MltCloud caller completion @chinese 单个 MltCloud 调用的回调 */
@property (nonatomic, copy, nullable) TSAICompletionBlock mltAuthenticationCompletion;
/** @brief Last physical request identifier @chinese 最近一次底层鉴权请求标识 */
@property (nonatomic, copy, nullable) NSString *mltLastRequestToken;
/** @brief Configuration of the current request @chinese 当前请求使用的认证配置 */
@property (nonatomic, copy, nullable) NSString *mltRequestConfigurationIdentity;
/** @brief Configuration of the last verified success @chinese 最近已确认成功所属配置 */
@property (nonatomic, copy, nullable) NSString *mltAuthorizedConfigurationIdentity;
/** @brief Single request deadline @chinese 单次请求截止计时器 */
@property (nonatomic, strong, nullable) dispatch_source_t mltAuthenticationTimeout;
/** @brief Retry timer within the current round @chinese 当前有限轮次中的重试计时器 */
@property (nonatomic, strong, nullable) dispatch_source_t mltAuthenticationRetry;
/** @brief Attempts in the current round @chinese 当前轮次实际发起次数 */
@property (nonatomic, assign) NSUInteger mltAuthenticationAttemptCount;
/** @brief Whether a bounded retry round is active @chinese 是否处于有限重试轮次 */
@property (nonatomic, assign) BOOL mltAuthenticationRoundActive;
/** @brief Whether vendor received this connection @chinese 是否已通知厂商当前连接 */
@property (nonatomic, assign) BOOL mltConnectionNotified;
/** @brief Current preparation encountered an occupied Runtime @chinese 当前准备确实遇到底层请求占用 */
@property (nonatomic, assign) BOOL mltAuthenticationBlockedByRuntime;
/** @brief Whether the authentication callback reports DeviceNotRegistered @chinese 本次鉴权回调是否明确返回设备未注册 */
@property (nonatomic, assign) BOOL mltAuthenticationFailureRequiresReport;

/**
 * @brief Bind a device identity and data receiver
 * @chinese 绑定设备身份与数据接收回调
 * @param identifier EN: Device identifier. CN: 设备标识。
 * @param dataReceiver EN: Bridge data receiver. CN: 桥接数据接收回调。
 */
- (void)bindDeviceIdentifier:(NSString *)identifier
                dataReceiver:(nullable TSAIBudsDataReceiver)dataReceiver;
/**
 * @brief Return or create the current vendor device
 * @chinese 返回或创建当前厂商设备对象
 * @param identifier EN: Device identifier. CN: 设备标识。
 * @return EN: Vendor device object. CN: 厂商设备对象。
 */
- (nullable id)currentDeviceWithIdentifier:(NSString *)identifier;
/**
 * @brief Prepare the vendor authentication environment
 * @chinese 准备厂商鉴权环境
 * @param vendor EN: Target vendor. CN: 目标厂商。
 * @param identifier EN: Device identifier. CN: 设备标识。
 */
- (void)prepareAuthenticationEnvironmentForVendor:(TSAIBudsVendorType)vendor
                                        identifier:(NSString *)identifier;
/** @brief Return the StarBurst device @chinese 返回 StarBurst 设备对象 */
- (nullable TSStarBurstDevice *)currentStarBurstDevice;
/** @brief Clear device bindings @chinese 清理设备级绑定 */
- (void)clearDeviceBinding;
/** @brief Clear the current device under state lock @chinese 在状态锁内清理当前设备 */
- (void)clearCurrentDeviceLocked;
/**
 * @brief Clear Context bindings
 * @chinese 清理 Context 级绑定
 * @param shouldClearStateHandler EN: Whether to clear state callback. CN: 是否清理状态回调。
 */
- (void)clearContextBindingsClearingStateHandler:(BOOL)shouldClearStateHandler;
/** @brief Clear failed initialization bindings @chinese 清理初始化失败后的绑定 */
- (void)clearInitializationBindings;
/**
 * @brief Update authorization state
 * @chinese 更新鉴权状态
 * @param authorizationState EN: New state. CN: 新状态。
 */
- (void)updateAuthorizationState:(TSAIAuthorizationState)authorizationState;
/** @brief Return lifecycle generation @chinese 返回生命周期代次 */
- (NSUInteger)currentLifecycleGeneration;
/**
 * @brief Execute synchronously on the lifecycle queue
 * @chinese 在生命周期队列同步执行
 * @param block EN: Operation block. CN: 操作 Block。
 */
- (void)executeSynchronouslyOnLifecycleQueue:(dispatch_block_t)block;
/** @brief Whether execution is on the lifecycle queue @chinese 当前是否位于生命周期队列 */
- (BOOL)isExecutingOnLifecycleQueue;

@end

/**
 * @brief Network-aware MltCloud authentication implementation
 * @chinese MltCloud 网络感知鉴权实现，与设备侧握手分别处理
 */
@interface TSAIBudsManager (MltCloudAuthentication)

/** @brief Start observing the active environment @chinese 观察当前激活环境 */
- (void)startMltCloudEnvironmentObservation;
/** @brief Stop this manager's observations @chinese 停止当前管理器的观察 */
- (void)stopMltCloudEnvironmentObservation;
/**
 * @brief Authenticate with current device metadata
 * @chinese 根据当前设备信息执行 MltCloud 鉴权
 * @param deviceInfo EN: Device metadata. CN: 设备信息。
 * @param completion EN: Single attempt result. CN: 本次尝试结果。
 */
- (void)authenticateMltCloudWithDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                              completion:(nullable TSAICompletionBlock)completion;
/** @brief Check current facts after an environment event @chinese 环境变化后检查当前事实 */
- (void)ensureMltCloudAuthentication;
/**
 * @brief Clear the logical request without invoking callbacks or changing authorization state
 * @chinese 清理逻辑请求，不执行外部回调或改变鉴权状态
 * @return EN: Detached completion to deliver after lifecycle changes. CN: 生命周期变更完成后需要结束的唯一回调。
 */
- (nullable TSAICompletionBlock)clearMltAuthenticationRequest;
/**
 * @brief End current logical attempt without removing reusable authorization
 * @chinese 结束当前逻辑请求，不删除可复用成功授权
 * @param error EN: Cancellation or network error. CN: 取消或网络错误。
 */
- (void)cancelMltCloudAuthenticationWithError:(NSError *)error;
/** @brief Build stable configuration identity @chinese 生成不含连接代次的稳定配置身份 */
- (NSString *)mltAuthenticationConfigurationIdentity;

@end

/**
 * @brief Private authentication implementation of the AIBuds manager
 * @chinese AIBuds Manager 的私有鉴权实现
 */
@interface TSAIBudsManager (Authentication)

/**
 * @brief Perform Context authentication
 * @chinese 执行 Context 鉴权
 * @param deviceInfo EN: Device information. CN: 设备信息。
 * @param completion EN: Acceptance or result callback. CN: 受理或结果回调。
 */
- (void)performAuthenticationWithDeviceInfo:(AIBudsAIDeviceInfoModel *)deviceInfo
                                  completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Handle device-initiated authorization result
 * @chinese 处理设备侧鉴权结果
 * @param success EN: Result flag. CN: 结果标记。
 * @param error EN: Vendor error. CN: 厂商错误。
 * @param lifecycleGeneration EN: Captured generation. CN: 捕获的代次。
 * @param vendor EN: Captured vendor. CN: 捕获的厂商。
 * @param identifier EN: Captured device identifier. CN: 捕获的设备标识。
 */
- (void)handleAuthorizationResult:(BOOL)success
                            error:(nullable NSError *)error
              lifecycleGeneration:(NSUInteger)lifecycleGeneration
                            vendor:(TSAIBudsVendorType)vendor
                        identifier:(NSString *)identifier;
/**
 * @brief Handle App-initiated authorization result
 * @chinese 处理 App 侧鉴权结果
 * @param success EN: Result flag. CN: 结果标记。
 * @param error EN: Vendor error. CN: 厂商错误。
 * @param requestToken EN: Request token. CN: 请求令牌。
 * @param lifecycleGeneration EN: Captured generation. CN: 捕获的代次。
 * @param vendor EN: Captured vendor. CN: 捕获的厂商。
 * @param identifier EN: Captured device identifier. CN: 捕获的设备标识。
 */
- (void)handleAppAuthenticationResult:(BOOL)success
                                error:(nullable NSError *)error
                         requestToken:(NSString *)requestToken
                  lifecycleGeneration:(NSUInteger)lifecycleGeneration
                               vendor:(TSAIBudsVendorType)vendor
                           identifier:(NSString *)identifier;
/**
 * @brief Replay or join authentication for the same identity
 * @chinese 回放或合并同一身份的鉴权请求
 * @param lifecycleGeneration EN: Current generation. CN: 当前代次。
 * @param vendor EN: Current vendor. CN: 当前厂商。
 * @param identifier EN: Device identifier. CN: 设备标识。
 * @param completion EN: Caller completion. CN: 调用方回调。
 * @return EN: YES when handled. CN: 已处理时返回 YES。
 */
- (BOOL)replayOrJoinAuthenticationForGeneration:(NSUInteger)lifecycleGeneration
                                          vendor:(TSAIBudsVendorType)vendor
                                      identifier:(NSString *)identifier
                                      completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Finish a synchronous authentication mode
 * @chinese 完成无需等待 SDK 回调的鉴权模式
 * @param authenticationMode EN: Resolved mode. CN: 已解析模式。
 * @param vendor EN: Current vendor. CN: 当前厂商。
 */
- (void)finishSynchronousAuthenticationMode:
            (TSAIBudsRuntimeAuthenticationMode)authenticationMode
                                         vendor:(TSAIBudsVendorType)vendor;
/**
 * @brief Normalize an authentication error
 * @chinese 规范化鉴权错误
 * @param error EN: Vendor error. CN: 厂商错误。
 * @param success EN: Result flag. CN: 结果标记。
 * @return EN: Normalized error. CN: 规范化错误。
 */
- (nullable NSError *)resolvedAuthenticationError:(nullable NSError *)error
                                           success:(BOOL)success;
/**
 * @brief Whether the request identity matches
 * @chinese 鉴权请求身份是否匹配
 * @param lifecycleGeneration EN: Generation. CN: 代次。
 * @param vendor EN: Vendor. CN: 厂商。
 * @param identifier EN: Device identifier. CN: 设备标识。
 * @return EN: Match result. CN: 匹配结果。
 */
- (BOOL)authenticationRequestMatchesGeneration:(NSUInteger)lifecycleGeneration
                                         vendor:(TSAIBudsVendorType)vendor
                                     identifier:(NSString *)identifier;
/** @brief Clear authentication state @chinese 清理鉴权请求状态 */
- (NSArray *)clearAuthenticationRequestLocked;
/**
 * @brief Finish authentication waiters
 * @chinese 结束鉴权等待者
 * @param waiters EN: Completion blocks. CN: 回调 Block 列表。
 * @param success EN: Result flag. CN: 结果标记。
 * @param error EN: Result error. CN: 结果错误。
 */
- (void)finishAuthenticationWaiters:(NSArray *)waiters
                             success:(BOOL)success
                               error:(nullable NSError *)error;
/** @brief Create a superseded error @chinese 创建连接代次失效错误 */
- (NSError *)authenticationSupersededError;

@end

NS_ASSUME_NONNULL_END
