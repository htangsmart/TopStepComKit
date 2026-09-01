//
//  TSDeviceCoordinator.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import <Foundation/Foundation.h>

#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Default user identifier shared by all Demo device connections
 * @chinese Demo 所有设备连接流程共用的默认用户标识
 */
FOUNDATION_EXTERN NSString * const TSDemoDefaultUserIdentifier;

FOUNDATION_EXTERN NSErrorDomain const TSDeviceCoordinatorErrorDomain;
FOUNDATION_EXTERN NSNotificationName const TSDeviceConnectionSnapshotDidChangeNotification;
FOUNDATION_EXTERN NSNotificationName const TSDeviceBindingDidClearNotification;
FOUNDATION_EXTERN NSString * const TSDeviceConnectionSnapshotUserInfoKey;

/**
 * @brief Device coordinator error codes
 * @chinese 设备协调器错误码
 */
typedef NS_ENUM(NSInteger, TSDeviceCoordinatorErrorCode) {
    TSDeviceCoordinatorErrorSDKNotReady = 3101,
    TSDeviceCoordinatorErrorBindingConflict,
    TSDeviceCoordinatorErrorOperationInProgress,
    TSDeviceCoordinatorErrorBindingMissing,
    TSDeviceCoordinatorErrorProviderUnavailable,
    TSDeviceCoordinatorErrorOperationCancelled,
    TSDeviceCoordinatorErrorConnectionFailed,
    TSDeviceCoordinatorErrorDeviceNotConnected = 3109,
};

/**
 * @brief Demo-owned SDK initialization state
 * @chinese Demo 自有的 SDK 初始化状态
 */
typedef NS_ENUM(NSInteger, TSDemoSDKState) {
    TSDemoSDKStateIdle = 0,
    TSDemoSDKStateInitializing,
    TSDemoSDKStateReady,
    TSDemoSDKStateFailed,
};

/**
 * @brief Immutable device connection snapshot for UI rendering
 * @chinese 供页面渲染的不可变设备连接快照
 */
@interface TSDeviceConnectionSnapshot : NSObject <NSCopying>

/**
 * @brief Create an immutable device connection snapshot
 * @chinese 创建不可变设备连接快照
 *
 * @param sdkState EN: Demo-owned SDK state. CN: Demo 自有 SDK 状态。
 * @param activeSDKType EN: SDK type selected for this process. CN: 当前进程选定的 SDK 类型。
 * @param connectionState EN: Raw BLE state. CN: BLE 原始状态。
 * @param peripheral EN: Current peripheral. CN: 当前外设。
 * @param error EN: Latest error. CN: 最近一次错误。
 * @param hasBinding EN: Whether binding exists. CN: 是否存在绑定。
 * @param sessionReady EN: Whether session preparation completed. CN: 会话准备是否完成。
 * @param connectionGeneration EN: Successful session generation. CN: 成功会话代次。
 * @return EN: Immutable device snapshot. CN: 不可变设备快照。
 */
+ (instancetype)snapshotWithSDKState:(TSDemoSDKState)sdkState
                       activeSDKType:(TSSDKType)activeSDKType
                     connectionState:(TSBleConnectionState)connectionState
                          peripheral:(nullable TSPeripheral *)peripheral
                               error:(nullable NSError *)error
                          hasBinding:(BOOL)hasBinding
                        sessionReady:(BOOL)sessionReady
                connectionGeneration:(NSUInteger)connectionGeneration;

/** @brief Demo-owned SDK initialization state @chinese Demo 自有的 SDK 初始化状态 */
@property (nonatomic, assign, readonly) TSDemoSDKState sdkState;

/** @brief SDK type selected for this process @chinese 当前进程选定的 SDK 类型 */
@property (nonatomic, assign, readonly) TSSDKType activeSDKType;

/** @brief Raw BLE connection state @chinese 原始 BLE 连接状态 */
@property (nonatomic, assign, readonly) TSBleConnectionState connectionState;

/** @brief Connected peripheral @chinese 当前连接设备 */
@property (nonatomic, strong, readonly, nullable) TSPeripheral *peripheral;

/** @brief Latest SDK or connection error @chinese 最近一次 SDK 或连接错误 */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/** @brief Whether a persisted binding exists @chinese 是否存在持久化绑定记录 */
@property (nonatomic, assign, readonly) BOOL hasBinding;

/** @brief Whether post-connect preparation completed @chinese 连接后准备流程是否完成 */
@property (nonatomic, assign, readonly) BOOL sessionReady;

/** @brief Successful connection session generation @chinese 成功连接会话代次 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Whether device business operations are ready
 * @chinese 设备业务操作是否已就绪
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

/**
 * @brief Whether SDK or BLE is transitioning
 * @chinese SDK 或 BLE 是否处于过渡状态
 */
@property (nonatomic, assign, readonly, getter=isTransitioning) BOOL transitioning;

@end

/**
 * @brief Single owner of SDK initialization, BLE connection listener and binding state
 * @chinese SDK 初始化、BLE 连接监听与绑定状态的唯一协调器
 */
@interface TSDeviceCoordinator : NSObject <NSCopying, NSMutableCopying>

/**
 * @brief Return the shared coordinator
 * @chinese 返回共享协调器
 *
 * @return EN: Shared coordinator. CN: 共享协调器。
 */
+ (instancetype)sharedInstance;

/** @brief Latest immutable connection snapshot @chinese 最新不可变连接快照 */
@property (nonatomic, strong, readonly) TSDeviceConnectionSnapshot *snapshot;

/**
 * @brief Start and initialize the preferred SDK for this process
 * @chinese 启动并初始化当前进程的首选 SDK
 */
- (void)start;

/**
 * @brief Return SDK types safe for the current Demo
 * @chinese 返回当前 Demo 可安全使用的 SDK 类型
 *
 * @return EN: Available SDK types. CN: 可用的 SDK 类型。
 */
- (NSArray<NSNumber *> *)availableSDKTypes;

/**
 * @brief Return whether a binding record exists
 * @chinese 返回是否存在绑定记录
 *
 * @return EN: YES when a valid binding exists. CN: 存在有效绑定时返回 YES。
 */
- (BOOL)hasBinding;

/**
 * @brief Return the bound SDK type
 * @chinese 返回绑定记录对应的 SDK 类型
 *
 * @return EN: Bound SDK type, or unknown when absent. CN: 绑定的 SDK 类型；无绑定时返回未知类型。
 */
- (TSSDKType)boundSDKType;

/**
 * @brief Return the preferred SDK type for launch or scanning
 * @chinese 返回启动或扫描优先使用的 SDK 类型
 *
 * @return EN: Preferred available SDK type. CN: 首选的可用 SDK 类型。
 */
- (TSSDKType)preferredSDKType;

/**
 * @brief Initialize or switch to the requested SDK type
 * @chinese 初始化或立即切换到指定 SDK 类型
 *
 * @param sdkType EN: Target SDK type. CN: 目标 SDK 类型。
 * @param completion EN: Initialization result. CN: 初始化结果。
 */
- (void)initializeSDKType:(TSSDKType)sdkType completion:(TSCompletionBlock)completion;

/**
 * @brief Start scanning through the active connector
 * @chinese 通过活动连接器开始扫描
 *
 * @param param EN: Scan parameters. CN: 扫描参数。
 * @param discoverPeripheral EN: Peripheral discovery callback. CN: 外设发现回调。
 * @param completion EN: Scan completion callback. CN: 扫描结束回调。
 */
- (void)startScanWithParam:(TSPeripheralScanParam *)param
        discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                completion:(TSScanCompletionBlock)completion;

/**
 * @brief Stop the active scan
 * @chinese 停止当前扫描
 */
- (void)stopScan;

/**
 * @brief Connect a peripheral through the active connector
 * @chinese 通过活动连接器连接设备
 *
 * @param peripheral EN: Target peripheral. CN: 目标外设。
 * @param param EN: Connection parameters. CN: 连接参数。
 * @param completion EN: Session-ready result. CN: 会话就绪结果。
 */
- (void)connectPeripheral:(TSPeripheral *)peripheral
                    param:(TSPeripheralConnectParam *)param
               completion:(TSCompletionBlock)completion;

/**
 * @brief Reconnect the persisted binding
 * @chinese 重连持久化绑定设备
 *
 * @param completion EN: Reconnection result. CN: 重连结果。
 */
- (void)reconnectWithCompletion:(nullable TSCompletionBlock)completion;

/**
 * @brief Disconnect while preserving binding
 * @chinese 断开连接并保留绑定
 *
 * @param completion EN: Disconnection result. CN: 断开结果。
 */
- (void)disconnectWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Unbind a connected device and remove local binding
 * @chinese 解绑已连接设备并删除本地绑定
 *
 * @param completion EN: Unbind result. CN: 解绑结果。
 */
- (void)unbindWithCompletion:(TSCompletionBlock)completion;

/**
 * @brief Forget an offline local binding without changing device-side state
 * @chinese 忘记离线本地绑定，不改变设备端状态
 */
- (void)clearLocalBinding;

@end

NS_ASSUME_NONNULL_END
