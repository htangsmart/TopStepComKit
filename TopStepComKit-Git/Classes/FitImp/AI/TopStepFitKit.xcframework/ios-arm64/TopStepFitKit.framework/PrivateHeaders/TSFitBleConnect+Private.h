//
//  TSFitBleConnect+Private.h
//  TopStepFitKit
//

#import "TSFitBleConnect.h"

@class TSFitBleScanSession;

NS_ASSUME_NONNULL_BEGIN

/** @brief Login fallback phases. @chinese 登录转重绑的互斥阶段。 */
typedef NS_ENUM(NSUInteger, TSFitBleFallbackPhase) {
    /** @brief No fallback. @chinese 没有登录转重绑任务。 */
    TSFitBleFallbackPhaseNone,
    /** @brief Await identity confirmation. @chinese 等待身份失效通知确认。 */
    TSFitBleFallbackPhaseAwaitingIdentity,
    /** @brief Await old connection exit. @chinese 已确认失效，等待旧连接退出。 */
    TSFitBleFallbackPhaseWaitingForDisconnect,
    /** @brief Await a new binding opportunity. @chinese 等待蓝牙、保护时间、扫描或收尾完成。 */
    TSFitBleFallbackPhaseWaitingForPeripheral,
    /** @brief Binding attempt in progress. @chinese 本层已经发起本轮绑定。 */
    TSFitBleFallbackPhaseBinding,
};

/** @brief Physical disconnect phases. @chinese 物理断开的互斥处理阶段。 */
typedef NS_ENUM(NSUInteger, TSFitBleDisconnectPhase) {
    /** @brief No pending disconnect. @chinese 没有等待物理断开。 */
    TSFitBleDisconnectPhaseNone,
    /** @brief Switch connections. @chinese 退出旧连接后继续当前连接请求。 */
    TSFitBleDisconnectPhaseSwitchingConnection,
    /** @brief Drain old connection events. @chinese 失败或主动断开后，等待旧连接通知排空。 */
    TSFitBleDisconnectPhaseCleaningUp,
};

/** @brief Shared internal connection state. @chinese 主实现及通知适配共享的私有声明。 */
@interface TSFitBleConnect ()

/** @brief Target peripheral. @chinese 当前目标外设。 */
@property (nonatomic, strong, nullable) TSPeripheral *currentPeripheral;
/** @brief Connection parameters. @chinese 当前连接参数。 */
@property (nonatomic, strong, nullable) TSPeripheralConnectParam *connectParam;
/** @brief Request completion and identity. @chinese 本次请求回调，兼作独立请求身份。 */
@property (nonatomic, copy, nullable) TSCompletionBlock connectCompletionBlock;
/** @brief Persistent state listener. @chinese 持续连接状态监听。 */
@property (nonatomic, copy, nullable) TSBleConnectionStateBlock connectionStateDidChangedBlock;
/** @brief Last reported state. @chinese 最近一次对外上报的状态。 */
@property (nonatomic, assign) TSBleConnectionState currentConnectionState;
/** @brief Diagnostic start time. @chinese 仅用于诊断耗时的开始时间。 */
@property (nonatomic, assign) NSTimeInterval connectionDiagnosticStartTime;

/** @brief Fallback phase. @chinese 登录转重绑阶段，代替三个可矛盾的布尔量。 */
@property (nonatomic, assign) TSFitBleFallbackPhase fallbackPhase;
/** @brief Binding synchronization cleanup. @chinese 完整绑定后需清理同步游标，也标记本轮绑定。 */
@property (nonatomic, assign) BOOL shouldClearSyncCursorAfterBind;
/** @brief Recovery timer. @chinese 首次保护等待或扫描续轮的定时任务。 */
@property (nonatomic, strong, nullable) NSTimer *fallbackBindTimer;
/** @brief Initial recovery deadline. @chinese 首次保护等待截止时间，蓝牙恢复时保留。 */
@property (nonatomic, assign) NSTimeInterval fallbackBindReadyTime;

/** @brief Pending disconnect phase. @chinese 统一管理内部切换与失败收尾门禁。 */
@property (nonatomic, assign) TSFitBleDisconnectPhase disconnectPhase;
/** @brief Cleanup peripheral identity. @chinese 正在收尾的外设 UUID。 */
@property (nonatomic, strong, nullable) NSUUID *failedConnectionIdentifier;
/** @brief Cleanup generation. @chinese 防止旧收尾回调影响新一轮连接的序号。 */
@property (nonatomic, assign) NSUInteger failedConnectionCleanupIdentifier;
/** @brief User disconnect intent. @chinese 用户主动断开标记。 */
@property (nonatomic, assign) BOOL isUserDisconnect;
/** @brief User unbind intent. @chinese 用户主动解绑标记。 */
@property (nonatomic, assign) BOOL isUserUnbinding;
/** @brief User disconnect completion. @chinese 主动断开完成回调。 */
@property (nonatomic, copy, nullable) TSCompletionBlock userDisconnectCompletionBlock;

/** @brief Bluetooth readiness intent. @chinese 等待蓝牙就绪的意图，可独立于 timer 存在。 */
@property (nonatomic, assign) BOOL waitingForBluetoothReady;
/** @brief Initial readiness timeout. @chinese 初始蓝牙就绪等待任务。 */
@property (nonatomic, strong, nullable) NSTimer *bluetoothReadyTimer;
/** @brief Scan readiness replay used. @chinese 扫描未就绪后是否已重放一次。 */
@property (nonatomic, assign) BOOL hasReplayedScanAfterBluetoothReady;

/** @brief Scan lifecycle owner. @chinese 独立管理扫描、过滤、去重及结束回调。 */
@property (nonatomic, strong) TSFitBleScanSession *scanSession;

/** @brief Cancellable info result receiver. @chinese 可取消的设备信息结果接收任务。 */
@property (nonatomic, copy, nullable) dispatch_block_t peripheralInfoCompletion;
/** @brief Device info completed. @chinese 当前连接的设备信息查询已完成。 */
@property (nonatomic, assign) BOOL hasLoadedPeripheralInfo;
/** @brief Physical peripheral snapshot. @chinese SDK 当前物理外设快照。 */
@property (nonatomic, strong, nullable) CBPeripheral *sdkConnectedPeripheral;
/** @brief Latest physical RSSI. @chinese 物理连接最近一次 RSSI。 */
@property (nonatomic, strong, nullable) NSNumber *sdkConnectedPeripheralRSSI;
/** @brief File transfer ownership. @chinese OTA 文件传输占用标记。 */
@property (nonatomic, assign) BOOL isFileTransfering;

@end

/** @brief Internal event routing. @chinese 主实现与通知分类之间的内部事件入口。 */
@interface TSFitBleConnect (ConnectionInternal)

/** @brief Route the current request. @chinese 按当前事实选择连接路径。 */
- (void)continueCurrentConnectionRequest;
/** @brief Begin confirmed fallback. @chinese 启动已确认身份失效的重绑恢复。 */
- (void)beginRebinding;
/** @brief Resume confirmed fallback. @chinese 推进当前重绑恢复阶段。 */
- (void)continueRebinding;
/** @brief Schedule initial protection. @chinese 按原截止时间安排首次保护等待。 */
- (void)scheduleInitialRebind;
/** @brief Query active recovery. @chinese 判断是否已确认进入重绑。 @return Recovery is active / 是否正在恢复。 */
- (BOOL)isRebinding;
/** @brief Advance central state. @chinese 处理蓝牙中心状态变化。 */
- (void)handleBluetoothStateChange;
/** @brief Route physical disconnection. @chinese 按当前收尾状态和用户意图处理物理断开。 */
- (void)handlePhysicalDisconnect;
/** @brief Advance binding result. @chinese 根据绑定结果推进恢复或失败。 @param success Success / 是否成功。 @param error Error / 底层错误。 */
- (void)handleBindingResult:(BOOL)success error:(nullable NSError *)error;
/** @brief Resolve central state error. @chinese 映射蓝牙中心错误。 @param state State / 中心状态。 @return Mapped error / 统一错误。 */
- (NSError *)errorForBluetoothCentralState:(FITCLOUDBLECENTRALSTATE)state;
/** @brief Apply a connection transition. @chinese 主线程内编排状态迁移、收尾及请求回调。 @param state State / 目标状态。 @param error Error / 变化原因。 */
- (void)transitionConnectionToState:(TSBleConnectionState)state error:(nullable NSError *)error;
/** @brief Fail and clean up a connection. @chinese 设置收尾门禁后结束失败连接。 @param error Error / 失败原因。 */
- (void)failCurrentConnectionWithError:(NSError *)error;
/** @brief Load info after preparation. @chinese 在底层准备完成后推进设备信息查询。 */
- (void)loadPeripheralInfoIfNeeded;
/** @brief Query SDK readiness. @chinese 判断底层认证及准备是否完成。 @return SDK is ready / 底层是否就绪。 */
- (BOOL)isSDKConnectionReady;
/** @brief Match the physical target. @chinese 检查当前物理连接是否属于目标设备。 @return Match / 是否匹配。 */
- (BOOL)isSDKConnectedToTarget;
/** @brief Update the target from SDK data. @chinese 将 SDK 快照补充到当前目标。 */
- (void)updateCurrentPeripheralFromSDK;
/** @brief Clear the physical snapshot. @chinese 清理物理连接及设备信息就绪快照。 */
- (void)clearSDKConnectedPeripheralSnapshot;
/** @brief Publish AI state. @chinese 发布对应连接状态的 AI 事件。 @param state State / 连接状态。 */
- (void)publishAIEventForConnectionState:(TSBleConnectionState)state;
/** @brief Log connection facts. @chinese 记录连接诊断快照。 @param event Event / 事件。 @param error Error / 错误。 */
- (void)logConnectionEvent:(NSString *)event error:(nullable NSError *)error;

@end

/** @brief Connection notification adapter. @chinese 统一管理通知订阅、分发与连接状态发布。 */
@interface TSFitBleConnect (ConnectionNotifications)

/** @brief Register a state listener. @chinese 注册持续连接状态监听。 @param completion Listener / 状态回调，传 nil 取消监听。 */
- (void)registerConnectionStateDidChanged:(nullable TSBleConnectionStateBlock)completion;
/** @brief Register SDK notifications. @chinese 注册当前连接器接收的 SDK 通知。 */
- (void)registerConnectionNotifications;
/** @brief Remove notification observers. @chinese 移除当前连接器持有的通知观察者。 */
- (void)removeConnectionNotifications;
/** @brief Deliver a transition on the main thread. @chinese 将状态变化投递到主线程状态迁移入口。 @param state State / 目标状态。 @param error Error / 变化原因。 */
- (void)dispatchConnectionState:(TSBleConnectionState)state error:(nullable NSError *)error;
/** @brief Publish an applied state. @chinese 向监听者发布主类已经完成迁移的状态。 @param state State / 当前状态。 @param error Error / 变化原因。 */
- (void)publishConnectionState:(TSBleConnectionState)state error:(nullable NSError *)error;
/** @brief Publish transport reset. @chinese 连接建立或断开时发布传输上下文重置通知。 @param state State / 连接状态。 */
- (void)publishTransportResetForConnectionState:(TSBleConnectionState)state;

@end

NS_ASSUME_NONNULL_END
