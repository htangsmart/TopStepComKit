//
//  TSDeviceCoordinator.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import "TSDeviceCoordinator.h"

#import <TargetConditionals.h>

#import "TSDeviceBindingStore.h"
#import "TSDeviceConnectionWorkflow.h"

NSString * const TSDemoDefaultUserIdentifier = @"demo_user_001";
NSErrorDomain const TSDeviceCoordinatorErrorDomain = @"com.topstep.demo.device-coordinator";
NSNotificationName const TSDeviceConnectionSnapshotDidChangeNotification =
    @"TSDeviceConnectionSnapshotDidChangeNotification";
NSNotificationName const TSDeviceBindingDidClearNotification = @"TSDeviceBindingDidClearNotification";
NSString * const TSDeviceConnectionSnapshotUserInfoKey = @"TSDeviceConnectionSnapshotUserInfoKey";

static NSString * const kTSLastInitializedSDKTypeKey = @"TSLastInitializedSDKType";
static NSString * const kTSPreferredSDKTypeKey = @"TSPreferredSDKType";
static NSString * const kTSDemoSDKLicense = @"abcdef1234567890abcdef1234567890";

@interface TSDeviceCoordinator ()

/** 最近一次设备连接快照 */
@property (nonatomic, strong, readwrite) TSDeviceConnectionSnapshot *snapshot;
/** 绑定记录存储 */
@property (nonatomic, strong) TSDeviceBindingStore *bindingStore;
/** 当前进程的连接器 */
@property (nonatomic, strong, nullable) id<TSBleConnectInterface> connector;
/** 等待当前初始化完成的回调 */
@property (nonatomic, strong) NSMutableArray *initializationCompletions;
/** 当前连接请求设备 */
@property (nonatomic, strong, nullable) TSPeripheral *pendingPeripheral;
/** 当前连接请求参数 */
@property (nonatomic, strong, nullable) TSPeripheralConnectParam *pendingConnectParam;
/** 当前连接请求结果回调 */
@property (nonatomic, copy, nullable) TSCompletionBlock pendingConnectCompletion;
/** 是否有连接请求正在执行 */
@property (nonatomic, assign) BOOL connectionOperationInProgress;
/** 是否正在准备连接后会话 */
@property (nonatomic, assign) BOOL sessionPreparationInProgress;
/** 是否已启动首选 SDK 初始化 */
@property (nonatomic, assign) BOOL started;
/** 当前 SDK 初始化代次 */
@property (nonatomic, assign) NSUInteger sdkGeneration;
/** 当前连接请求代次 */
@property (nonatomic, assign) NSUInteger connectionOperationGeneration;
/** 当前连接状态代次 */
@property (nonatomic, assign) NSUInteger connectionStateGeneration;
/** 成功连接会话代次 */
@property (nonatomic, assign) NSUInteger connectionGeneration;
/** 已触发自动重连的 SDK 初始化代次 */
@property (nonatomic, assign) NSUInteger automaticReconnectGeneration;

- (void)handleInitializationResult:(BOOL)success
                             error:(nullable NSError *)error
                           sdkType:(TSSDKType)sdkType
                     sdkGeneration:(NSUInteger)sdkGeneration;
- (void)finishInitializationCompletions:(BOOL)success error:(nullable NSError *)error;
- (void)bindActiveConnectorForSDKGeneration:(NSUInteger)sdkGeneration;
- (void)handleConnectionState:(TSBleConnectionState)connectionState
                        error:(nullable NSError *)error
                sdkGeneration:(NSUInteger)sdkGeneration;
- (void)prepareConnectedSessionIfNeeded;
- (void)finishPendingConnection:(BOOL)success error:(nullable NSError *)error;
- (void)publishConnectionState:(TSBleConnectionState)connectionState
                    peripheral:(nullable TSPeripheral *)peripheral
                  sessionReady:(BOOL)sessionReady
                         error:(nullable NSError *)error;
- (void)postSnapshotDidChange;
- (TSDeviceConnectionSnapshot *)snapshotWithSDKState:(TSDemoSDKState)sdkState
                                       activeSDKType:(TSSDKType)activeSDKType
                                     connectionState:(TSBleConnectionState)connectionState
                                          peripheral:(nullable TSPeripheral *)peripheral
                                        sessionReady:(BOOL)sessionReady
                                               error:(nullable NSError *)error;
- (TSKitConfigOptions *)configOptionsForSDKType:(TSSDKType)sdkType;
- (NSError *)coordinatorErrorWithCode:(TSDeviceCoordinatorErrorCode)code
                          description:(NSString *)description;
- (void)complete:(nullable TSCompletionBlock)completion
         success:(BOOL)success
           error:(nullable NSError *)error;

@end

static TSDeviceCoordinator *deviceCoordinator = nil;

@implementation TSDeviceCoordinator

#pragma mark - 生命周期

/** 获取共享协调器 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceCoordinator = [[super allocWithZone:NULL] init];
    });
    return deviceCoordinator;
}

/** 保证 alloc 仍返回共享协调器 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

/** 保证复制仍返回共享协调器 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

/** 保证可变复制仍返回共享协调器 */
- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

/** 初始化协调器快照 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _bindingStore = [[TSDeviceBindingStore alloc] init];
        _initializationCompletions = [NSMutableArray array];
        _snapshot = [self snapshotWithSDKState:TSDemoSDKStateIdle
                                 activeSDKType:eTSSDKTypeUnknow
                               connectionState:eTSBleStateDisconnected
                                    peripheral:nil
                                  sessionReady:NO
                                         error:nil];
    }
    return self;
}

#pragma mark - 公开方法

/** 启动并初始化当前进程唯一的 SDK Provider */
- (void)start {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];
        });
        return;
    }
    if (self.started) {
        return;
    }
    self.started = YES;
    TSSDKType sdkType = [self preferredSDKType];
    [self initializeSDKType:sdkType completion:^(BOOL success, NSError *error) {
        if (!success) {
            TSLog(@"[TSDeviceCoordinator] 启动初始化失败: %@", error.localizedDescription);
        }
    }];
}

/** 返回当前 Demo 安全可用的 SDK 类型 */
- (NSArray<NSNumber *> *)availableSDKTypes {
#if TARGET_OS_SIMULATOR
    return @[@(eTSSDKTypeFIT)];
#else
    return @[@(eTSSDKTypeFIT), @(eTSSDKTypeFW), @(eTSSDKTypeTPB)];
#endif
}

/** 返回是否存在绑定记录 */
- (BOOL)hasBinding {
    return [self.bindingStore bindingRecord] != nil;
}

/** 返回绑定记录的 SDK 类型 */
- (TSSDKType)boundSDKType {
    return [self.bindingStore bindingRecord].sdkType;
}

/** 选择绑定类型、用户偏好、上次成功类型或首个可用类型 */
- (TSSDKType)preferredSDKType {
    NSArray<NSNumber *> *availableTypes = [self availableSDKTypes];
    TSDeviceBindingRecord *record = [self.bindingStore bindingRecord];
    if (record) {
        return record.sdkType;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kTSPreferredSDKTypeKey]) {
        TSSDKType preferredType = (TSSDKType)[defaults integerForKey:kTSPreferredSDKTypeKey];
        if ([availableTypes containsObject:@(preferredType)]) {
            return preferredType;
        }
    }
    if ([defaults objectForKey:kTSLastInitializedSDKTypeKey]) {
        TSSDKType lastType = (TSSDKType)[defaults integerForKey:kTSLastInitializedSDKTypeKey];
        if ([availableTypes containsObject:@(lastType)]) {
            return lastType;
        }
    }
    return availableTypes.count > 0 ?
        (TSSDKType)availableTypes.firstObject.unsignedIntegerValue : eTSSDKTypeUnknow;
}

/** 初始化或立即切换到指定 SDK 类型 */
- (void)initializeSDKType:(TSSDKType)sdkType completion:(TSCompletionBlock)completion {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeSDKType:sdkType completion:completion];
        });
        return;
    }
    if (![[self availableSDKTypes] containsObject:@(sdkType)]) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorProviderUnavailable
                                            description:@"The selected SDK Provider is unavailable"];
        [self complete:completion success:NO error:error];
        return;
    }
    TSDeviceBindingRecord *record = [self.bindingStore bindingRecord];
    if (record && record.sdkType != sdkType) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorBindingConflict
                                            description:@"Unbind the current device before activating another SDK Provider"];
        [self complete:completion success:NO error:error];
        return;
    }
    if (self.snapshot.sdkState == TSDemoSDKStateReady) {
        if (self.snapshot.activeSDKType == sdkType) {
            [self complete:completion success:YES error:nil];
            return;
        }
    }
    if (self.snapshot.sdkState == TSDemoSDKStateInitializing) {
        if (self.snapshot.activeSDKType != sdkType) {
            NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorOperationInProgress
                                                description:@"Wait for the current SDK initialization to finish"];
            [self complete:completion success:NO error:error];
        } else if (completion) {
            [self.initializationCompletions addObject:[completion copy]];
        }
        return;
    }
    if (self.connectionOperationInProgress || self.sessionPreparationInProgress ||
        self.snapshot.connectionState != eTSBleStateDisconnected) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorOperationInProgress
                                            description:@"Disconnect the current device before switching SDK Provider"];
        [self complete:completion success:NO error:error];
        return;
    }

    if (completion) {
        [self.initializationCompletions addObject:[completion copy]];
    }
    self.sdkGeneration += 1;
    NSUInteger sdkGeneration = self.sdkGeneration;
    if (self.snapshot.sdkState != TSDemoSDKStateIdle) {
        [self.connector stopSearchPeripheral];
        self.connector = nil;
    }
    self.snapshot = [self snapshotWithSDKState:TSDemoSDKStateInitializing
                                 activeSDKType:sdkType
                               connectionState:eTSBleStateDisconnected
                                    peripheral:nil
                                  sessionReady:NO
                                         error:nil];
    [self postSnapshotDidChange];

    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self configOptionsForSDKType:sdkType]
                                                  completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleInitializationResult:success
                                           error:error
                                         sdkType:sdkType
                                   sdkGeneration:sdkGeneration];
        });
    }];
}

/** 通过当前进程的连接器开始扫描 */
- (void)startScanWithParam:(TSPeripheralScanParam *)param
        discoverPeripheral:(TSScanDiscoveryBlock)discoverPeripheral
                completion:(TSScanCompletionBlock)completion {
    if (self.snapshot.sdkState != TSDemoSDKStateReady || !self.connector) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                            description:@"Initialize an SDK Provider before scanning"];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(eTSScanCompleteReasonSystemError, error);
        });
        return;
    }
    NSUInteger sdkGeneration = self.sdkGeneration;
    __weak typeof(self) weakSelf = self;
    [self.connector startSearchPeripheralWithParam:param
                                discoverPeripheral:^(TSPeripheral *peripheral) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.sdkGeneration != sdkGeneration) {
                return;
            }
            discoverPeripheral(peripheral);
        });
    }
                                        completion:^(TSScanCompletionReason reason, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.sdkGeneration != sdkGeneration) {
                return;
            }
            completion(reason, error);
        });
    }];
}

/** 停止当前扫描 */
- (void)stopScan {
    [self.connector stopSearchPeripheral];
}

/** 通过唯一连接通道发起连接 */
- (void)connectPeripheral:(TSPeripheral *)peripheral
                    param:(TSPeripheralConnectParam *)param
               completion:(TSCompletionBlock)completion {
    if (self.snapshot.sdkState != TSDemoSDKStateReady || !self.connector) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                            description:@"The SDK is not ready"];
        [self complete:completion success:NO error:error];
        return;
    }
    if (self.connectionOperationInProgress || self.sessionPreparationInProgress) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorOperationInProgress
                                            description:@"Another connection operation is in progress"];
        [self complete:completion success:NO error:error];
        return;
    }
    TSDeviceBindingRecord *record = [self.bindingStore bindingRecord];
    TSSDKType activeType = self.snapshot.activeSDKType;
    if (record && record.sdkType != activeType) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorBindingConflict
                                            description:@"The binding belongs to another SDK Provider"];
        [self complete:completion success:NO error:error];
        return;
    }

    self.pendingPeripheral = peripheral;
    self.pendingConnectParam = param;
    self.pendingConnectCompletion = [completion copy];
    self.connectionOperationInProgress = YES;
    [self publishConnectionState:eTSBleStateConnecting
                      peripheral:peripheral
                    sessionReady:NO
                           error:nil];

    NSUInteger sdkGeneration = self.sdkGeneration;
    self.connectionOperationGeneration += 1;
    NSUInteger operationGeneration = self.connectionOperationGeneration;
    __weak typeof(self) weakSelf = self;
    [self.connector connectWithPeripheral:peripheral param:param completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf.sdkGeneration != sdkGeneration ||
                strongSelf.connectionOperationGeneration != operationGeneration ||
                !strongSelf.connectionOperationInProgress) {
                return;
            }
            if (success) {
                [strongSelf prepareConnectedSessionIfNeeded];
            } else {
                NSError *connectionError = error ?:
                    [strongSelf coordinatorErrorWithCode:TSDeviceCoordinatorErrorConnectionFailed
                                               description:@"The SDK connection request failed"];
                [strongSelf publishConnectionState:eTSBleStateDisconnected
                                         peripheral:nil
                                       sessionReady:NO
                                              error:connectionError];
                [strongSelf finishPendingConnection:NO error:connectionError];
            }
        });
    }];
}

/** 使用持久化绑定记录重连 */
- (void)reconnectWithCompletion:(TSCompletionBlock)completion {
    TSDeviceBindingRecord *record = [self.bindingStore bindingRecord];
    if (!record) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorBindingMissing
                                            description:@"No persisted device binding exists"];
        [self complete:completion success:NO error:error];
        return;
    }
    if (self.snapshot.sdkState != TSDemoSDKStateReady ||
        self.snapshot.activeSDKType != record.sdkType) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                            description:@"Initialize the bound SDK Provider before reconnecting"];
        [self complete:completion success:NO error:error];
        return;
    }

    if (![record.userIdentifier isEqualToString:TSDemoDefaultUserIdentifier]) {
        record.userIdentifier = TSDemoDefaultUserIdentifier;
        [self.bindingStore saveBindingRecord:record];
    }
    TSPeripheral *peripheral = [[TSPeripheral alloc] init];
    peripheral.systemInfo.mac = record.macAddress;
    TSPeripheralConnectParam *param = [TSPeripheralConnectParam paramWithUserId:TSDemoDefaultUserIdentifier];
    [self connectPeripheral:peripheral param:param completion:completion];
}

/** 主动断开并保留绑定记录 */
- (void)disconnectWithCompletion:(TSCompletionBlock)completion {
    if (!self.connector) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                            description:@"The SDK connector is unavailable"];
        [self complete:completion success:NO error:error];
        return;
    }
    if (self.connectionOperationInProgress) {
        self.connectionOperationGeneration += 1;
        NSError *cancelError = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorOperationCancelled
                                                   description:@"The connection operation was cancelled"];
        [self finishPendingConnection:NO error:cancelError];
    }
    __weak typeof(self) weakSelf = self;
    [self.connector disconnectCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (success) {
                [strongSelf publishConnectionState:eTSBleStateDisconnected
                                         peripheral:nil
                                       sessionReady:NO
                                              error:nil];
            }
            [strongSelf complete:completion success:success error:error];
        });
    }];
}

/** 在线解绑设备；离线场景由页面显式选择是否忘记本地绑定 */
- (void)unbindWithCompletion:(TSCompletionBlock)completion {
    if (!self.connector || ![self.connector isConnected]) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorDeviceNotConnected
                                            description:@"Connect the device before unbinding it"];
        [self complete:completion success:NO error:error];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.connector unbindPeripheralCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (success) {
                [strongSelf.bindingStore clearBindingRecord];
                [strongSelf publishConnectionState:eTSBleStateDisconnected
                                         peripheral:nil
                                       sessionReady:NO
                                              error:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSDeviceBindingDidClearNotification
                                                                    object:strongSelf];
            }
            [strongSelf complete:completion success:success error:error];
        });
    }];
}

/** 忘记离线本地绑定 */
- (void)clearLocalBinding {
    [self.bindingStore clearBindingRecord];
    [self publishConnectionState:self.snapshot.connectionState
                      peripheral:self.snapshot.peripheral
                    sessionReady:self.snapshot.sessionReady
                           error:self.snapshot.error];
    [[NSNotificationCenter defaultCenter] postNotificationName:TSDeviceBindingDidClearNotification
                                                        object:self];
}

#pragma mark - SDK 初始化处理

/** 处理当前 SDK 初始化结果 */
- (void)handleInitializationResult:(BOOL)success
                             error:(NSError *)error
                           sdkType:(TSSDKType)sdkType
                     sdkGeneration:(NSUInteger)sdkGeneration {
    if (self.sdkGeneration != sdkGeneration ||
        self.snapshot.sdkState != TSDemoSDKStateInitializing ||
        self.snapshot.activeSDKType != sdkType) {
        return;
    }
    if (!success) {
        NSError *initializationError = error ?:
            [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                               description:@"SDK initialization failed"];
        self.snapshot = [self snapshotWithSDKState:TSDemoSDKStateFailed
                                     activeSDKType:sdkType
                                   connectionState:eTSBleStateDisconnected
                                        peripheral:nil
                                      sessionReady:NO
                                             error:initializationError];
        [self postSnapshotDidChange];
        [self finishInitializationCompletions:NO error:initializationError];
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sdkType forKey:kTSLastInitializedSDKTypeKey];
    [defaults setInteger:sdkType forKey:kTSPreferredSDKTypeKey];
    self.snapshot = [self snapshotWithSDKState:TSDemoSDKStateReady
                                 activeSDKType:sdkType
                               connectionState:eTSBleStateDisconnected
                                    peripheral:nil
                                  sessionReady:NO
                                         error:nil];
    [self postSnapshotDidChange];
    [self bindActiveConnectorForSDKGeneration:sdkGeneration];
    if (!self.connector) {
        [self finishInitializationCompletions:NO error:self.snapshot.error];
        return;
    }
    [self finishInitializationCompletions:YES error:nil];
}

/** 完成并清理等待中的初始化回调 */
- (void)finishInitializationCompletions:(BOOL)success error:(NSError *)error {
    NSArray *completions = [self.initializationCompletions copy];
    [self.initializationCompletions removeAllObjects];
    for (TSCompletionBlock completion in completions) {
        [self complete:completion success:success error:error];
    }
}

/** 绑定当前进程连接器的唯一全局状态监听 */
- (void)bindActiveConnectorForSDKGeneration:(NSUInteger)sdkGeneration {
    self.connector = [TopStepComKit sharedInstance].bleConnector;
    if (!self.connector) {
        NSError *error = [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                            description:@"The active Provider did not create a BLE connector"];
        self.snapshot = [self snapshotWithSDKState:TSDemoSDKStateFailed
                                     activeSDKType:self.snapshot.activeSDKType
                                   connectionState:eTSBleStateDisconnected
                                        peripheral:nil
                                      sessionReady:NO
                                             error:error];
        [self postSnapshotDidChange];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.connector registerConnectionStateDidChanged:^(TSBleConnectionState connectionState, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleConnectionState:connectionState
                                      error:error
                              sdkGeneration:sdkGeneration];
        });
    }];
    [self.connector getConnectState:^(TSBleConnectionState connectionState, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf handleConnectionState:connectionState
                                        error:error
                                sdkGeneration:sdkGeneration];
            TSDeviceBindingRecord *record = [strongSelf.bindingStore bindingRecord];
            BOOL shouldReconnect = connectionState == eTSBleStateDisconnected &&
                record && record.sdkType == strongSelf.snapshot.activeSDKType &&
                strongSelf.automaticReconnectGeneration != sdkGeneration;
            if (shouldReconnect) {
                strongSelf.automaticReconnectGeneration = sdkGeneration;
                [strongSelf reconnectWithCompletion:^(BOOL success, NSError *reconnectError) {
                    TSLog(@"[TSDeviceCoordinator] 自动重连结果: %d, error: %@",
                          success,
                          reconnectError.localizedDescription);
                }];
            }
        });
    }];
}

#pragma mark - 连接状态与会话

/** 处理连接状态并丢弃旧 SDK 初始化代次事件 */
- (void)handleConnectionState:(TSBleConnectionState)connectionState
                        error:(NSError *)error
                sdkGeneration:(NSUInteger)sdkGeneration {
    if (self.sdkGeneration != sdkGeneration ||
        self.snapshot.sdkState != TSDemoSDKStateReady) {
        return;
    }
    TSPeripheral *peripheral = connectionState == eTSBleStateConnected ?
        ([TopStepComKit sharedInstance].connectedPeripheral ?: self.pendingPeripheral) : self.pendingPeripheral;
    BOOL preserveSession = connectionState == eTSBleStateConnected && self.snapshot.sessionReady;
    [self publishConnectionState:connectionState
                      peripheral:connectionState == eTSBleStateDisconnected ? nil : peripheral
                    sessionReady:preserveSession
                           error:error];
    if (connectionState == eTSBleStateDisconnected && self.connectionOperationInProgress) {
        NSError *connectionError = error ?:
            [self coordinatorErrorWithCode:TSDeviceCoordinatorErrorConnectionFailed
                               description:@"The connection ended before the device session became ready"];
        [self finishPendingConnection:NO error:connectionError];
    }
    if (connectionState == eTSBleStateConnected) {
        [self prepareConnectedSessionIfNeeded];
    }
}

/** 完成连接后的统一会话准备并提交绑定记录 */
- (void)prepareConnectedSessionIfNeeded {
    if (self.sessionPreparationInProgress || self.snapshot.sessionReady ||
        self.snapshot.sdkState != TSDemoSDKStateReady ||
        self.snapshot.connectionState != eTSBleStateConnected) {
        return;
    }
    self.sessionPreparationInProgress = YES;
    NSUInteger sdkGeneration = self.sdkGeneration;
    NSUInteger connectionStateGeneration = self.connectionStateGeneration;
    TSPeripheral *requestedPeripheral = self.pendingPeripheral;
    TSPeripheralConnectParam *connectParam = self.pendingConnectParam;

    __weak typeof(self) weakSelf = self;
    [TSDeviceConnectionWorkflow prepareConnectedDeviceWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.sessionPreparationInProgress = NO;
        BOOL stillCurrent = strongSelf.snapshot.sdkState == TSDemoSDKStateReady &&
            strongSelf.sdkGeneration == sdkGeneration &&
            strongSelf.connectionStateGeneration == connectionStateGeneration &&
            strongSelf.snapshot.connectionState == eTSBleStateConnected &&
            [strongSelf.connector isConnected];
        if (!stillCurrent) {
            NSError *error = [strongSelf coordinatorErrorWithCode:TSDeviceCoordinatorErrorSDKNotReady
                                                       description:@"The connection changed during session preparation"];
            [strongSelf finishPendingConnection:NO error:error];
            return;
        }

        TSPeripheral *peripheral = [TopStepComKit sharedInstance].connectedPeripheral ?: requestedPeripheral;
        if (peripheral.systemInfo.mac.length > 0 && connectParam.userId.length > 0) {
            TSDeviceBindingRecord *record = [[TSDeviceBindingRecord alloc] init];
            record.schemaVersion = 1;
            record.sdkType = strongSelf.snapshot.activeSDKType;
            record.macAddress = peripheral.systemInfo.mac;
            record.userIdentifier = connectParam.userId;
            [strongSelf.bindingStore saveBindingRecord:record];
        }
        strongSelf.connectionGeneration += 1;
        [strongSelf publishConnectionState:eTSBleStateConnected
                                 peripheral:peripheral
                               sessionReady:YES
                                      error:nil];
        [strongSelf finishPendingConnection:YES error:nil];
    }];
}

/** 完成并清理一次连接请求 */
- (void)finishPendingConnection:(BOOL)success error:(NSError *)error {
    TSCompletionBlock completion = self.pendingConnectCompletion;
    self.pendingConnectCompletion = nil;
    self.connectionOperationInProgress = NO;
    self.pendingPeripheral = nil;
    self.pendingConnectParam = nil;
    [self complete:completion success:success error:error];
}

/** 发布新的不可变连接快照 */
- (void)publishConnectionState:(TSBleConnectionState)connectionState
                    peripheral:(TSPeripheral *)peripheral
                  sessionReady:(BOOL)sessionReady
                         error:(NSError *)error {
    if (self.snapshot.connectionState != connectionState) {
        self.connectionStateGeneration += 1;
    }
    self.snapshot = [self snapshotWithSDKState:self.snapshot.sdkState
                                 activeSDKType:self.snapshot.activeSDKType
                               connectionState:connectionState
                                    peripheral:peripheral
                                  sessionReady:sessionReady
                                         error:error];
    [self postSnapshotDidChange];
}

/** 构建连接快照 */
- (TSDeviceConnectionSnapshot *)snapshotWithSDKState:(TSDemoSDKState)sdkState
                                       activeSDKType:(TSSDKType)activeSDKType
                                     connectionState:(TSBleConnectionState)connectionState
                                          peripheral:(TSPeripheral *)peripheral
                                        sessionReady:(BOOL)sessionReady
                                               error:(NSError *)error {
    return [TSDeviceConnectionSnapshot snapshotWithSDKState:sdkState
                                              activeSDKType:activeSDKType
                                            connectionState:connectionState
                                                 peripheral:peripheral
                                                      error:error
                                                 hasBinding:[self.bindingStore bindingRecord] != nil
                                               sessionReady:sessionReady
                                       connectionGeneration:self.connectionGeneration];
}

/** 通过通知中心向多个页面广播同一快照 */
- (void)postSnapshotDidChange {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:TSDeviceConnectionSnapshotDidChangeNotification
                      object:self
                    userInfo:@{TSDeviceConnectionSnapshotUserInfoKey: self.snapshot}];
}

#pragma mark - 辅助方法

/** 构建 Demo SDK 配置 */
- (TSKitConfigOptions *)configOptionsForSDKType:(TSSDKType)sdkType {
    TSKitConfigOptions *options = [TSKitConfigOptions configOptionWithSDKType:sdkType
                                                                      license:kTSDemoSDKLicense];
    TSLogConfig *logConfig = [[TSLogConfig alloc] init];
    logConfig.enabled = YES;
    logConfig.level = TopStepLogLevelDebug;
    options.logConfig = logConfig;
    return options;
}

/** 创建协调器错误 */
- (NSError *)coordinatorErrorWithCode:(TSDeviceCoordinatorErrorCode)code
                          description:(NSString *)description {
    return [NSError errorWithDomain:TSDeviceCoordinatorErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @"Device coordinator error"}];
}

/** 在主线程完成公开回调 */
- (void)complete:(TSCompletionBlock)completion success:(BOOL)success error:(NSError *)error {
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(success, error);
    });
}

@end
