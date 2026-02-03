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
 * @brief Notify user of connection state change
 * @chinese 通知用户连接状态变化
 * 
 * @param connectedState 
 * EN: Current connection state
 * CN: 当前的连接状态
 * 
 * @param error 
 * EN: Error information if connection failed, nil if successful
 * CN: 连接失败时的错误信息，成功时为nil
 * 
 * @discussion 
 * EN: Notifies the delegate object when Bluetooth connection state changes.
 * CN: 当蓝牙连接状态发生变化时，通过该方法通知代理对象。
 */
- (void)noticeUserConnect:(TSBleConnectionState)connectedState error:(NSError *)error;

/**
 * @brief Begin authentication process
 * @chinese 开始认证过程
 * 
 * @discussion 
 * EN: Notifies the delegate to begin the authentication process after successful Bluetooth connection and service discovery.
 * CN: 在蓝牙连接成功并发现服务后，通知代理开始认证过程。
 */
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
 * @brief Start searching for Bluetooth peripherals
 * @chinese 开始搜索蓝牙设备
 * 
 * @param param 
 * EN: Scan parameters, including timeout, MAC address, user ID, etc.
 * CN: 扫描参数，包括超时时间、MAC地址、用户ID等
 * 
 * @param discoverPeripheral 
 * EN: Callback block called when a peripheral is discovered during scanning
 * CN: 扫描过程中发现外设时的回调块
 * 
 * @param completion 
 * EN: Callback block called when scanning completes or stops
 * CN: 扫描完成或停止时的回调块
 * 
 * @discussion 
 * EN: Starts Bluetooth device scanning. If BLE is not ready, waits for initialization (max 3 seconds). The scan will discover peripherals and call the discoverPeripheral callback for each found device.
 * CN: 启动蓝牙设备扫描。如果BLE未准备好，会等待初始化完成（最多3秒）。扫描过程中发现设备时会调用discoverPeripheral回调。
 */
- (void)startSearchPeripheralWithParam:(nonnull TSPeripheralScanParam *)param discoverPeripheral:(nonnull TSScanDiscoveryBlock)discoverPeripheral completion:(nonnull TSScanCompletionBlock)completion ;


/**
 * @brief 停止搜索蓝牙设备
 * @discussion 停止当前的蓝牙设备扫描过程
 */
- (void)stopSearchPeripheral;

/**
 * @brief Start connecting to the specified Bluetooth peripheral
 * @chinese 开始连接指定的蓝牙设备
 * 
 * @param peripheral 
 * EN: The TSPeripheral object to connect to
 * CN: 要连接的TSPeripheral对象
 * 
 * @discussion 
 * EN: Attempts to establish a connection with the specified Bluetooth peripheral. Sets up connection timeout timer and initiates the connection process. If the peripheral is already connected, returns immediately.
 * CN: 尝试与指定的蓝牙设备建立连接。会设置连接超时定时器并启动连接过程。如果外设已经连接，则立即返回。
 */
- (void)beginConnectWithPeripheral:(TSPeripheral *)peripheral ;

/**
 * @brief Disconnect the current Bluetooth connection
 * @chinese 断开当前蓝牙连接
 * 
 * @param completion 
 * EN: Callback block called when disconnection completes
 * CN: 断开连接完成时的回调块
 * 
 * @discussion 
 * EN: Actively disconnects from the currently connected Bluetooth device. Cancels the connection timeout timer, resets reconnection attempts, and marks the disconnect type as user-initiated.
 * CN: 主动断开与当前连接的蓝牙设备的连接。会取消连接超时定时器，重置重连计数，并将断开类型标记为用户主动断开。
 */
- (void)disconnectCompletion:(TSCompletionBlock)completion ;


/**
 * @brief Check if currently connected to a Bluetooth peripheral
 * @chinese 检查是否已连接到蓝牙外设
 * 
 * @return 
 * EN: YES if connected, NO otherwise
 * CN: 已连接返回YES，否则返回NO
 * 
 * @discussion 
 * EN: Returns whether there is a currently connected peripheral and its state is CBPeripheralStateConnected.
 * CN: 返回是否存在当前连接的外设且其状态为CBPeripheralStateConnected。
 */
- (BOOL)isConnected ;


/**
 * @brief 请求当前蓝牙连接状态
 * @param completion 状态查询完成的回调，返回当前的连接状态
 * @discussion 异步获取当前蓝牙连接的状态
 */
- (void)getConnectState:(TSBleConnectionStateCallback)completion;



/**
 * @brief Find target peripheral in history peripherals
 * @chinese 在历史外设中查找目标外设
 * 
 * @param peripheral 
 * EN: The peripheral to search for in history
 * CN: 要在历史记录中查找的外设
 * 
 * @return 
 * EN: The matched TSPeripheral object if found, nil otherwise
 * CN: 如果找到匹配的外设则返回TSPeripheral对象，否则返回nil
 * 
 * @discussion 
 * EN: Searches for the specified peripheral in the history of connected peripherals by matching UUID or MAC address.
 * CN: 通过匹配UUID或MAC地址在已连接外设的历史记录中查找指定的外设。
 */
- (TSPeripheral *)targetPeripheralInHistoryPeripherals:(TSPeripheral *)peripheral;

/**
 * @brief Find peripheral from retrieved connected peripherals with default service by UUID
 * @chinese 从已检索的默认服务已连接外设中通过UUID查找外设
 * 
 * @param uuidString 
 * EN: The UUID string of the peripheral to find
 * CN: 要查找的外设的UUID字符串
 * 
 * @return 
 * EN: The CBPeripheral object if found, nil otherwise
 * CN: 如果找到则返回CBPeripheral对象，否则返回nil
 * 
 * @discussion 
 * EN: Retrieves connected peripherals with the default service UUID (FFFF) and searches for a peripheral matching the specified UUID string.
 * CN: 检索具有默认服务UUID（FFFF）的已连接外设，并查找匹配指定UUID字符串的外设。
 */
- (CBPeripheral *)findFwPeripheralFromRetrieveConnectedPeripheralsWithDefaultServiceWithUUid:(NSString *)uuidString;

/**
 * @brief Check if Bluetooth Low Energy is ready
 * @chinese 检查低功耗蓝牙是否已准备好
 * 
 * @return 
 * EN: YES if BLE manager state is CBManagerStatePoweredOn, NO otherwise
 * CN: 如果BLE管理器状态为CBManagerStatePoweredOn则返回YES，否则返回NO
 * 
 * @discussion 
 * EN: Checks whether the CBCentralManager is in the powered-on state and ready for Bluetooth operations.
 * CN: 检查CBCentralManager是否处于已开启状态并准备好进行蓝牙操作。
 */
- (BOOL)isBleReady ;


/**
 * @brief Search for peripheral with existing peripheral object or MAC address
 * @chinese 通过现有外设对象或MAC地址搜索外设
 * 
 * @param existingPeripheral 
 * EN: Existing TSPeripheral object, if provided will be returned directly
 * CN: 现有的TSPeripheral对象，如果提供则直接返回
 * 
 * @param macAddress 
 * EN: MAC address of the peripheral to search for
 * CN: 要搜索的外设的MAC地址
 * 
 * @param userId 
 * EN: User ID for querying history records
 * CN: 用于查询历史记录的用户ID
 * 
 * @param completion 
 * EN: Callback block called when search completes, returns the found TSPeripheral or error
 * CN: 搜索完成时的回调块，返回找到的TSPeripheral或错误信息
 * 
 * @discussion 
 * EN: Searches for a peripheral using either an existing peripheral object or MAC address. If existingPeripheral is provided, returns it directly. Otherwise, searches in history records first, then scans if not found.
 * CN: 使用现有外设对象或MAC地址搜索外设。如果提供了existingPeripheral，则直接返回。否则先在历史记录中搜索，如果未找到则进行扫描。
 */
- (void)searchPeripheralWithExistingPeripheral:(TSPeripheral *)existingPeripheral
                                    macAddress:(NSString *)macAddress
                                        userId:(NSString *)userId
                                    completion:(void (^)(TSPeripheral * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
