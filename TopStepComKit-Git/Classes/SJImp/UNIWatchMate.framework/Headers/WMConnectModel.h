//
//  WMConnectModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMConnectModel : NSObject

/// 可订阅对象，设备是否连接 (Subscribed objects, whether the device is connected)
@property (nonatomic, strong) RACSignal<NSNumber *> *isConnected;
@property (nonatomic, assign, readonly) BOOL isConnectedValue;

/// 可订阅对象，设备是否初始化完成，可以进行数据交互 (Subscribable objects, whether the device initialization is complete, can perform data interaction)
@property (nonatomic, strong) RACSignal<NSNumber *> *isReady;
@property (nonatomic, assign, readonly) BOOL isReadyValue;

/// 可订阅对象，使用CBPeripheralState表示，SDK是否在连接目标设备（0未发起连接，1正在连接，2连接成功）
/// 可订阅对象，使用CBPeripheralState表示，SDK是否在连接目标设备（0未发起连接，1正在连接，2连接成功）
@property (nonatomic, strong) RACSignal<NSNumber *> *connectState;
@property (nonatomic, assign, readonly) BOOL connectStateValue;

/// 连接 (connect)
/// needBtConnected ：是否检查 设备bt连接（通过 音频路由设备的名称和ble广播名称是否相同 判断）,如果needBtConnected为true，连接时检查bt未连接，则SDK中会循环去检查 ，
/// 检查通过 即去连接
/// needBtConnected: Whether to check the bt connection of the device (determine whether the name of the audio routing device is the same as the ble broadcast name). If needBtConnected is true and bt is not connected during connection, the SDK will loop to check.
/// If the check passes, the connection is disconnected
- (void)connect: (BOOL) needBtConnected;


/// 断开连接 (disconnect)
- (void)disconnect;

/// 恢复出厂（解绑），解绑结果BOOL (Restore factory (unbind), unbind result BOOL)
- (RACSignal<NSNumber *> *)restoreFactory;

/// 重启设备 (Restart the device)
- (RACSignal<NSNumber *> *)reboot;

@end

NS_ASSUME_NONNULL_END
