//
//  TSMetaBleConnect.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "TSBleManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PbConnectParam.pbobjc.h"
#import "TSMetaBleConnectDefines.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Verify ownership of a pending connection operation
 * @chinese 校验待处理连接操作的归属
 *
 * @return
 * EN: YES while the original owner remains valid. The block must not block or mutate connection state.
 * CN: 原所有者仍有效时返回 YES；此 block 不得阻塞或修改连接状态。
 */
typedef BOOL (^TSMetaBleConnectionValidator)(void);

/**
 * @brief BLE connection manager
 * @chinese 蓝牙连接管理器
 *
 * @discussion
 * [EN]: Provides high-level BLE connection management including scanning, connecting, 
 *       authentication, binding, and device management operations.
 * [CN]: 提供高级蓝牙连接管理，包括扫描、连接、认证、绑定和设备管理等操作。
 */
@interface TSMetaBleConnect : TSBusinessBase

#pragma mark - Scanning Methods

/**
 * @brief Scan for BLE peripherals with filter parameters
 * @chinese 按参数扫描蓝牙外设
 */
+ (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
      didDiscoverPeripheral:(TSDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 */
+ (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral
 * @chinese 连接蓝牙外设（仅建立物理连接，认证参数由 beginAuthWithParam: 单独传入）
 *
 * @param peripheral 目标外设
 * @param purpose    连接目的（绑定/登录），由上层根据本地绑定记录判定；
 *                   决定 code 7 断开后是否自动重连，认证成功后内部翻转为 Login
 * @param completion 连接状态回调
 */
+ (void)connectPeripheral:(CBPeripheral *_Nonnull)peripheral
                  purpose:(TSMetaBleConnectPurpose)purpose
               completion:(TSMetaBleConnectionCompletionBlock _Nullable)completion;

/**
 * @brief Connect an exact target while its original request owner remains valid
 * @chinese 原请求所有者有效时连接精确目标
 *
 * @param peripheral
 * EN: Target peripheral selected by the caller.
 * CN: 调用方选定的目标外设。
 *
 * @param purpose
 * EN: Existing bind or login purpose.
 * CN: 既有绑定或登录目的。
 *
 * @param connectionValidator
 * EN: Optional nonblocking owner predicate checked before queued physical startup.
 * CN: 排队的物理连接真正启动前检查的可选非阻塞所有者判断。
 *
 * @param completion
 * EN: Existing connection-state callback; stale owners cannot start a newer transport.
 * CN: 既有连接状态回调；失效所有者不能启动较新的传输。
 */
+ (void)connectPeripheral:(CBPeripheral *)peripheral
                  purpose:(TSMetaBleConnectPurpose)purpose
      connectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
               completion:(nullable TSMetaBleConnectionCompletionBlock)completion;


/**
 * @brief Disconnect from the currently connected peripheral
 * @chinese 断开当前连接的外设
 */
+ (void)disConnectPeripheralCompletion:(TSMetaCompletionBlock _Nonnull)completion;

/**
 * @brief Disconnect an exact selected connection with optional owner validation
 * @chinese 携带可选所有者校验断开精确选中连接
 *
 * @param connectionValidator
 * EN: Optional original-owner predicate; Connecting cancellation does not require a ready transport.
 * CN: 可选原所有者判断；取消 Connecting 不要求传输已经就绪。
 *
 * @param completion
 * EN: Result of this operation; a stale owner cannot disconnect a newer selection.
 * CN: 本次操作结果；失效所有者不能断开较新的连接选择。
 */
+ (void)disConnectPeripheralWithConnectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
                                       completion:(TSMetaCompletionBlock)completion;

#pragma mark - BT Connection

/**
 * @brief Notify device to start sending BT connection / pairing
 * @chinese 通知设备开始发送 BT 配对/连接
 *
 * @param isBind     YES = 绑定流程，仅尝试一次；NO = 登录流程，失败立即重发，最多 kTSStartBtConnectionLoginMaxRetry 次
 * @param completion 结果回调
 */
+ (void)startSendBtConnectionForBind:(BOOL)isBind
                          completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Start pairing while retaining exact transport and optional owner validation
 * @chinese 保持精确传输及可选所有者校验后启动配对
 *
 * @param isBind
 * EN: YES for a single bind attempt; NO for the existing bounded login retry policy.
 * CN: YES 表示单次绑定尝试；NO 沿用现有有界登录重试策略。
 *
 * @param connectionValidator
 * EN: Optional original-owner predicate, evaluated before sends and callbacks.
 * CN: 可选原所有者判断，在发送和回调处理前执行。
 *
 * @param completion
 * EN: Called once on the main queue on success, failure or loss of ownership.
 * CN: 成功、失败或归属失效时在主队列完成一次。
 */
+ (void)startSendBtConnectionForBind:(BOOL)isBind
               connectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
                        completion:(TSMetaCompletionBlock)completion;

#pragma mark - Authentication Methods

/**
 * @brief Begin authentication (bind or login), mode decided by current connect purpose
 * @chinese 执行认证（绑定或登录），模式由当前连接目的决定
 *
 * @discussion
 * [EN]: Reads the live value of TSBleManager.connectPurpose instead of taking a flag:
 *       initial value is determined by upper layer before connecting; flipped to Login
 *       once auth succeeds, so reconnect replays automatically pick the correct mode.
 * [CN]: 认证模式不由调用方传入，直接读 TSBleManager.connectPurpose 现值：
 *       初值由上层在连接发起前查定；认证成功后翻转为 Login，重连重放时自动取到正确模式。
 */
+ (void)beginAuthWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Authenticate only while the original transport and optional owner remain valid
 * @chinese 仅在原传输及可选所有者仍有效时执行认证
 *
 * @param param
 * EN: Authentication parameters for the captured connection.
 * CN: 已捕获连接的认证参数。
 *
 * @param connectionValidator
 * EN: Optional original-owner predicate checked before side effects and recursive sends.
 * CN: 副作用及递归发送前检查的可选原所有者判断。
 *
 * @param completion
 * EN: Called once on the main queue with the result or an ownership-lost error.
 * CN: 在主队列完成一次，返回结果或归属失效错误。
 */
+ (void)beginAuthWithParam:(TSMetaAuthParam *)param
     connectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
              completion:(TSMetaCompletionBlock)completion;
/**
 * @brief Login to BLE device
 * @chinese 登录蓝牙设备
 */
+ (void)loginWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Bind BLE device
 * @chinese 绑定蓝牙设备
 */
+ (void)bindWithParam:(TSMetaAuthParam *)param completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Unbind peripheral
 * @chinese 解绑外设
 */
+ (void)unbindPeripheral:(TSMetaCompletionBlock)completion;

/**
 * @brief Unbind only the captured transport while its original owner remains valid
 * @chinese 仅在原所有者有效时解绑已捕获的传输连接
 *
 * @param connectionValidator
 * EN: Optional original-owner predicate checked before sending, responding and disconnecting.
 * CN: 发送、响应和断开前检查的可选原所有者判断。
 *
 * @param completion
 * EN: Reports the unbind result once on the main queue; a later disconnect cannot change this result.
 * CN: 主队列只回调一次解绑结果；后续断开不改变此结果。
 */
+ (void)unbindPeripheralWithConnectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
                                    completion:(TSMetaCompletionBlock)completion;

#pragma mark - Device Management Methods

/**
 * @brief Check if a peripheral is currently connected
 * @chinese 检查外设是否已连接
 */
+ (BOOL)isConnected;

/**
 * @brief Request peripheral device information
 * @chinese 请求外设设备信息
 */
+ (void)requestPeripheralInfoCompletion:(void(^)(TSMetaPeripheralInfo * _Nullable peripheralInfo, NSError * _Nullable error))completion;

/**
 * @brief Get Bluetooth information (BLE and Classic Bluetooth)
 * @chinese 获取蓝牙信息（BLE和经典蓝牙）
 */
+ (void)requestBluetoothInfoCompletion:(void(^)(TSMetaBluetoothInfo * _Nullable bluetoothInfo, NSError * _Nullable error))completion;

#pragma mark - Device Discovery Business Methods

/**
 * @brief Search peripheral by MAC address or existing peripheral object (unified business interface)
 * @chinese 查找外设（统一业务接口）
 */
+ (void)searchPeripheralWithExistingPeripheral:(CBPeripheral * _Nullable)existingPeripheral
                                    macAddress:(NSString * _Nullable)macAddress
                                    completion:(void(^)(CBPeripheral * _Nullable peripheral, NSError * _Nullable error))completion;

/**
 * @brief Search only while the original connection attempt still owns discovery
 * @chinese 仅在原连接尝试仍拥有查找归属时搜索外设
 *
 * @param existingPeripheral
 * EN: Existing system peripheral, or nil to perform a MAC lookup.
 * CN: 已有系统外设；为 nil 时按 MAC 查找。
 *
 * @param macAddress
 * EN: MAC address copied for the lookup, or nil when a system peripheral is supplied.
 * CN: 为本次查找复制的 MAC；已有系统外设时允许为 nil。
 *
 * @param connectionValidator
 * EN: Optional original-owner predicate; it does not require an established physical connection.
 * CN: 可选的原所有者判断；不要求物理连接已经建立。
 *
 * @param completion
 * EN: With a validator, reports once on main with a peripheral, lookup error or ownership-lost error.
 * CN: 提供校验器时在主队列完成一次，返回外设、查找错误或归属失效错误。
 *
 * @discussion
 * [EN]: A nil validator preserves the existing search path. Scoped searches recheck ownership before scan
 *       fallback, before stopping a discovered scan, and before delivering terminal callbacks.
 * [CN]: 校验器为 nil 时保留原查找路径；具归属的查找在转入扫描、发现后停止扫描和交付终态前重检所有者。
 */
+ (void)searchPeripheralWithExistingPeripheral:(nullable CBPeripheral *)existingPeripheral
                                    macAddress:(nullable NSString *)macAddress
                           connectionValidator:(nullable TSMetaBleConnectionValidator)connectionValidator
                                    completion:(void (^)(CBPeripheral * _Nullable peripheral,
                                                         NSError * _Nullable error))completion;



+(CBPeripheral *)findPeripheralFromRetrieveConnectedPeripheralsWithDefaultServiceWithUUid:(NSString *)uuidString;

+(CBPeripheral *)findPeripheralFromretRievePeripheralsWithIdentifiersWithUUid:(NSString *)uuidString;


+ (void)saveUuidToKeychain:(NSString *)uuid forMac:(NSString *)mac ;

+ (void)removeUuidFromKeychainWithMac:(NSString *)mac ;

@end

NS_ASSUME_NONNULL_END
