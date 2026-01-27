/**
 * @file TSFwBleConnectHelper.h
 * @brief 蓝牙连接助手类的头文件
 * @discussion 该类负责处理蓝牙设备的搜索、连接和状态管理等核心功能
 */
//#import <>
#import <persimwearSDK/persimwearSDK.h>

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSDisconnectType) {
    eTSDisconnectUnknow,
    eTSDisconnectByLostSignal,
    eTSDisconnectByUser,
    eTSDisconnectByConnectOther,
};

@class TSFwBleConnectHelper;

/**
 * @protocol TSFWBleConnectHelperDelegate
 * @brief 蓝牙连接助手代理协议
 * @discussion 定义了蓝牙连接状态变化时的回调方法
 */
@protocol TSFwBleConnectHelperDelegate <NSObject>

/**
 * @brief 通知用户连接状态变化
 * @param connectedState 当前的连接状态
 * @param delay 延迟通知的时间（秒）
 * @discussion 当蓝牙连接状态发生变化时，通过该方法通知代理对象
 */
- (void)noticeUserConnect:(TSBleConnectionState)connectedState error:(NSError *)error;

- (void)beginAuthenticate;

@end

/**
 * @interface TSFWBleConnectHelper
 * @brief 蓝牙连接助手类
 * @discussion 提供蓝牙设备搜索、连接、状态管理等功能的实现
 */
@interface TSFwBleConnectHelper : NSObject

/**
 * @brief 蓝牙连接助手的代理对象
 * @discussion 用于接收蓝牙连接状态变化的通知
 */
@property (nonatomic, weak) id<TSFwBleConnectHelperDelegate>  delegate;


/**
 * @brief 开始搜索蓝牙设备
 * @param searchHandler 搜索结果回调，返回找到的外设信息
 * @discussion 启动蓝牙设备扫描，并通过回调返回扫描到的设备信息
 */
- (void)startSearchPeripheralWithParam:(nonnull TSPeripheralScanParam *)param discoverPeripheral:(nonnull TSScanDiscoveryBlock)discoverPeripheral completion:(nonnull TSScanCompletionBlock)completion ;


/**
 * @brief 停止搜索蓝牙设备
 * @discussion 停止当前的蓝牙设备扫描过程
 */
- (void)stopSearchPeripheral;

/**
 * @brief 开始连接指定的蓝牙设备
 * @param peripheral 要连接的蓝牙设备对象
 * @discussion 尝试与指定的蓝牙设备建立连接
 */
- (void)beginConnectWithPeripheral:(TSPeripheral *)peripheral ;

/**
 * @brief 断开当前蓝牙连接
 * @discussion 主动断开与当前连接的蓝牙设备的连接
 */
- (void)disconnectCompletion:(TSCompletionBlock)completion ;


- (BOOL)isConnected ;


/**
 * @brief 请求当前蓝牙连接状态
 * @param completion 状态查询完成的回调，返回当前的连接状态
 * @discussion 异步获取当前蓝牙连接的状态
 */
- (void)getConnectState:(TSBleConnectionStateCallback)completion;



- (TSPeripheral *)targetPeripheralInHistoryPeripherals:(TSPeripheral *)peripheral;

- (CBPeripheral *)findFwPeripheralFromRetrieveConnectedPeripheralsWithDefaultServiceWithUUid:(NSString *)uuidString;

- (BOOL)isBleReady ;


- (void)searchPeripheralWithExistingPeripheral:(TSPeripheral *)existingPeripheral
                                    macAddress:(NSString *)macAddress
                                    userId:(NSString *)userId
                                    completion:(void (^)(CBPeripheral * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
