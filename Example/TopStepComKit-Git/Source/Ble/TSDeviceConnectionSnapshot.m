//
//  TSDeviceConnectionSnapshot.m
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import "TSDeviceCoordinator.h"

@interface TSDeviceConnectionSnapshot ()

/** Demo 自有 SDK 初始化状态 */
@property (nonatomic, assign, readwrite) TSDemoSDKState sdkState;
/** 当前进程选定的 SDK 类型 */
@property (nonatomic, assign, readwrite) TSSDKType activeSDKType;
/** BLE 原始连接状态 */
@property (nonatomic, assign, readwrite) TSBleConnectionState connectionState;
/** 当前连接设备 */
@property (nonatomic, strong, readwrite, nullable) TSPeripheral *peripheral;
/** 最近一次错误 */
@property (nonatomic, strong, readwrite, nullable) NSError *error;
/** 是否存在绑定记录 */
@property (nonatomic, assign, readwrite) BOOL hasBinding;
/** 会话准备是否完成 */
@property (nonatomic, assign, readwrite) BOOL sessionReady;
/** 成功连接会话代次 */
@property (nonatomic, assign, readwrite) NSUInteger connectionGeneration;

@end

@implementation TSDeviceConnectionSnapshot

#pragma mark - 公开方法

/** 创建不可变设备连接快照 */
+ (instancetype)snapshotWithSDKState:(TSDemoSDKState)sdkState
                       activeSDKType:(TSSDKType)activeSDKType
                     connectionState:(TSBleConnectionState)connectionState
                          peripheral:(TSPeripheral *)peripheral
                               error:(NSError *)error
                          hasBinding:(BOOL)hasBinding
                        sessionReady:(BOOL)sessionReady
                connectionGeneration:(NSUInteger)connectionGeneration {
    TSDeviceConnectionSnapshot *snapshot = [[self alloc] init];
    snapshot.sdkState = sdkState;
    snapshot.activeSDKType = activeSDKType;
    snapshot.connectionState = connectionState;
    snapshot.peripheral = peripheral;
    snapshot.error = error;
    snapshot.hasBinding = hasBinding;
    snapshot.sessionReady = sessionReady;
    snapshot.connectionGeneration = connectionGeneration;
    return snapshot;
}

/** 返回设备业务是否已就绪 */
- (BOOL)isReady {
    return self.sdkState == TSDemoSDKStateReady &&
        self.connectionState == eTSBleStateConnected &&
        self.sessionReady &&
        self.peripheral != nil;
}

/** 返回当前是否处于 SDK 或连接过渡状态 */
- (BOOL)isTransitioning {
    BOOL sdkTransitioning = self.sdkState == TSDemoSDKStateInitializing;
    BOOL connectionTransitioning =
        self.connectionState == eTSBleStateConnecting ||
        self.connectionState == eTSBleStateAuthenticating ||
        self.connectionState == eTSBleStatePreparingData;
    return sdkTransitioning || connectionTransitioning;
}

/** 复制不可变快照 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
