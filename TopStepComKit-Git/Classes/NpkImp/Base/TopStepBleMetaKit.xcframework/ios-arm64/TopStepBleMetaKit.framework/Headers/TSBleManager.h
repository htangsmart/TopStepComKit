//
//  TSBleManager.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/5.
//

#import "TSBusinessBase.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSBleScanPeripheralParam.h"
#import "TSBleConnectOption.h"
#import <TopStepToolKit/TopStepToolKit.h>
#import "TSMetaBleConnectDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Posted synchronously after connection generation or readiness changes
 * @chinese 连接代次或就绪事实变更后同步发送的通知
 *
 * @discussion
 * [EN]: The object is the manager. Delivery occurs outside its connection lock on the changing thread.
 * [CN]: object 为管理器；在连接锁外、变更发生的线程同步投递。
 * [EN]: Readiness can change within one epoch; observers must validate the current physical facts.
 * [CN]: 同一代次内也可能发生就绪变化；观察者必须核验当前物理事实。
 */
FOUNDATION_EXPORT NSNotificationName const TSBleConnectionGenerationDidChangeNotification;

/**
 * @brief Notification user-info key containing the changed connection generation
 * @chinese 通知 userInfo 中已变更连接代次的键
 */
FOUNDATION_EXPORT NSString * const TSBleConnectionGenerationUserInfoKey;

/**
 * @brief Immutable identity of one BLE write attempt
 * @chinese 单次 BLE 写入尝试的不可变身份
 */
@interface TSBleWriteContext : NSObject <NSCopying>

/**
 * @brief Original target peripheral
 * @chinese 原始目标外设
 *
 * @discussion
 * [EN]: Retains the exact peripheral instance selected when the attempt was created.
 * [CN]: 持有创建尝试时选定的确切外设实例。
 *
 * @note
 * [EN]: Never replaced with the manager's later selection.
 * [CN]: 不会替换为管理器后来选择的外设。
 */
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

/**
 * @brief Original physical connection generation
 * @chinese 原始物理连接代次
 *
 * @discussion
 * [EN]: Shares the manager's connection epoch and is checked before every fragment.
 * [CN]: 使用管理器的连接代次，每个片段提交前均核验。
 *
 * @note
 * [EN]: Zero is invalid; reconnecting requires a new context.
 * [CN]: 零为无效值；重连后必须创建新上下文。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Unique identifier of this write attempt
 * @chinese 本次写入尝试的唯一标识
 *
 * @discussion
 * [EN]: Identifies the exact operation when cancelling or draining the write queue.
 * [CN]: 取消和排空写队列时用于定位确切操作。
 *
 * @note
 * [EN]: Use a fresh nonempty identifier for every attempt; do not reuse a drained identifier.
 * [CN]: 每次尝试使用新的非空标识；不得复用已排空的标识。
 */
@property (nonatomic, copy, readonly) NSString *operationIdentifier;

/**
 * @brief Optional live ownership predicate
 * @chinese 可选的实时所有者判断
 *
 * @discussion
 * [EN]: Evaluated on the write queue before admission and each fragment, outside the connection lock.
 * [CN]: 在写队列准入和每片发送前执行，执行时不持有连接锁。
 *
 * @note
 * [EN]: May be nil. Must be nonblocking and must not synchronously wait for the write queue.
 * [CN]: 允许为空；必须非阻塞，且不得同步等待写队列。
 */
@property (nonatomic, copy, readonly, nullable) BOOL (^validator)(void);

/**
 * @brief Freeze the identity of a write attempt
 * @chinese 冻结一次写入尝试的身份
 *
 * @param peripheral
 * EN: Original peripheral instance.
 * CN: 原始外设实例。
 *
 * @param generation
 * EN: Original nonzero physical connection epoch.
 * CN: 原始非零物理连接代次。
 *
 * @param operationIdentifier
 * EN: Unique nonempty identifier for this attempt.
 * CN: 本次尝试的非空唯一标识。
 *
 * @param validator
 * EN: Optional nonblocking ownership predicate.
 * CN: 可选的非阻塞所有者判断。
 *
 * @return
 * EN: An immutable identity snapshot.
 * CN: 不可变身份快照。
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                       generation:(NSUInteger)generation
              operationIdentifier:(NSString *)operationIdentifier
                        validator:(nullable BOOL (^)(void))validator NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


#pragma mark - TSBleManager Interface

/**
 * @brief BLE Manager - Core Bluetooth Low Energy management class
 * @chinese 蓝牙管理器 - 核心蓝牙低功耗管理类
 *
 * @discussion
 * [EN]: Singleton class that manages BLE operations including scanning, connecting, 
 *       data transmission, and peripheral management. Acts as the "parts factory" 
 *       in the architecture, providing fundamental BLE capabilities.
 * [CN]: 单例类，管理蓝牙操作包括扫描、连接、数据传输和外设管理。在架构中作为"零件生产厂"，
 *       提供基础的蓝牙功能。
 */
@interface TSBleManager : TSBusinessBase

#pragma mark - Connection Properties

/**
 * @brief Current connected peripheral
 * @chinese 当前已连接的外设
 */
//@property (nonatomic, strong, readonly, nullable) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong, readonly, nullable) CBPeripheral *currentPeripheral;

/**
 * @brief Monotonic connection epoch shared with file transfers
 * @chinese 与文件传输共享的单调连接代次
 *
 * @discussion
 * [EN]: Changes when a connection session starts or becomes invalid; it is not a connection count.
 * [CN]: 连接会话开始或失效时变化；此值不是连接次数。
 *
 * @note
 * [EN]: Initially zero. Read together with a captured peripheral through the validation methods.
 * [CN]: 初始值为零；应通过校验方法与原外设共同读取和使用。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Capture the current ready transport generation for an exact peripheral
 * @chinese 为指定外设原子捕获当前就绪传输代次
 *
 * @param peripheral
 * EN: Original peripheral instance to validate; nil represents no selected peripheral.
 * CN: 待校验的原始外设实例；nil 表示尚未选择外设。
 *
 * @return
 * EN: The nonzero generation, or nil when the peripheral or transport is no longer current and ready.
 * CN: 非零代次；外设或传输已非当前就绪状态时返回 nil。
 */
- (nullable NSNumber *)connectionGenerationForConnectedPeripheral:(nullable CBPeripheral *)peripheral;

/**
 * @brief Validate a captured peripheral and ready transport generation atomically
 * @chinese 原子校验已捕获的外设与就绪传输代次
 *
 * @param peripheral
 * EN: Original peripheral instance; nil is always rejected.
 * CN: 原始外设实例；nil 一律拒绝。
 *
 * @param generation
 * EN: Previously captured nonzero generation.
 * CN: 此前捕获的非零代次。
 *
 * @return
 * EN: YES only while the same transport remains current and ready.
 * CN: 仅同一传输仍为当前就绪连接时返回 YES。
 */
- (BOOL)isCurrentConnectedPeripheral:(nullable CBPeripheral *)peripheral generation:(NSUInteger)generation;

/**
 * @brief Connection state
 * @chinese 连接状态
 */
@property (nonatomic, assign, readonly) BOOL isConnected;

/**
 * @brief Current connection purpose (bind / login)
 * @chinese 当前连接目的（绑定 / 登录）
 *
 * @discussion
 * [EN]: Initial value is set when a connection starts; flipped to Login by the
 *       auth layer once authentication succeeds. Decides whether to auto reconnect
 *       on CBErrorPeripheralDisconnected (code 7): Bind → stop, Login → reconnect.
 *       Reset to Bind when the connection session is cleared.
 * [CN]: 连接发起时设置初值；认证成功后由认证层翻转为 Login。
 *       决定 code 7 断开后是否自动重连：Bind → 停止，Login → 重连。
 *       连接会话清理时复位为 Bind。
 */
@property (nonatomic, assign) TSMetaBleConnectPurpose connectPurpose;

/**
 * @brief Maximum write value length for connected peripheral
 * @chinese 已连接外设的最大写入值长度
 */
@property (nonatomic, assign, readonly) NSInteger maximumWriteValueLength;

/**
 * @brief BLE manager state
 * @chinese 蓝牙管理器状态
 */
@property (nonatomic, assign, readonly) CBManagerState bleManagerState;

#pragma mark - Initialization & Status Methods
/**
 * @brief Get the shared instance of TSBleManager
 * @chinese 获取TSBleManager的共享实例
 */
+ (instancetype)sharedInstance;

/**
 * @brief Check if BLE is ready for operations
 * @chinese 检查蓝牙是否准备好进行操作
 */
- (BOOL)isBleReady;

#pragma mark - Scanning Methods

/**
 * @brief Scan for BLE peripherals with complete callback support
 * @chinese 带完整回调支持的蓝牙外设扫描
 */
- (void)startScanWithParam:(TSBleScanPeripheralParam *_Nonnull)scanParam
     didDiscoverPeripheral:(TSDiscoverPeripheralBlock _Nullable)discoverBlock
                completion:(TSMetaScanCompletionBlock _Nullable)completion;

/**
 * @brief Stop scanning for BLE peripherals
 * @chinese 停止扫描蓝牙外设
 */
- (void)stopScan;

#pragma mark - Connection Methods

/**
 * @brief Connect to a BLE peripheral with options
 * @chinese 连接蓝牙外设（支持连接参数）
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
                   option:(TSBleConnectOption * _Nullable)connectOption
                  purpose:(TSMetaBleConnectPurpose)purpose
               completion:(TSMetaBleConnectionCompletionBlock _Nonnull)completion;

/**
 * @brief Start a connection only while the original request owner remains valid
 * @chinese 仅原请求所有者仍有效时启动连接
 *
 * @param peripheral
 * EN: Exact target selected by the caller.
 * CN: 调用方选定的精确目标。
 *
 * @param connectOption
 * EN: Existing connection and reconnect policy.
 * CN: 既有连接及重连策略。
 *
 * @param purpose
 * EN: Bind or login purpose for this request.
 * CN: 本次请求的绑定或登录目的。
 *
 * @param connectionValidator
 * EN: Optional nonblocking predicate checked before session creation and physical connection startup.
 * CN: 会话创建及实际物理连接启动前检查的可选非阻塞判断。
 *
 * @param completion
 * EN: Existing connection-state delivery; a superseded owner receives no new physical connection.
 * CN: 既有连接状态交付；失效所有者不会启动新的物理连接。
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
                   option:(nullable TSBleConnectOption *)connectOption
                  purpose:(TSMetaBleConnectPurpose)purpose
      connectionValidator:(nullable BOOL (^)(void))connectionValidator
               completion:(TSMetaBleConnectionCompletionBlock)completion;

/**
 * @brief Disconnect from the current BLE peripheral
 * @chinese 断开当前蓝牙外设
 */
- (void)disconnectPeripheralCompletion:(TSMetaCompletionBlock)completion;

/**
 * @brief Disconnect the selected transport only while the captured selection and owner remain valid
 * @chinese 仅已捕获连接选择及所有者仍有效时断开传输
 *
 * @param validator
 * EN: Optional nonblocking owner check performed in the connection queue before disconnecting.
 * CN: 可选非阻塞所有者判断，在连接队列真正断开前执行。
 *
 * @param completion
 * EN: Result for this disconnect operation; a stale selection fails without touching a newer connection.
 * CN: 本次断开结果；选择失效时失败，不影响较新的连接。
 */
- (void)disconnectPeripheralWithValidator:(nullable BOOL (^)(void))validator
                              completion:(TSMetaCompletionBlock)completion;

#pragma mark - Data Transmission Methods

/**
 * @brief Write data to BLE peripheral (batch mode)
 * @chinese 向蓝牙外设批量写入数据
 */
- (void)writeData:(NSArray<NSData *> * _Nonnull)needWriteDataArray 
         progress:(void(^_Nullable)(CGFloat progress))progress 
       completion:(TSMetaCompletionBlock _Nonnull)completion;

/**
 * @brief Submit copied fragments for one exact connection and operation
 * @chinese 为确切连接和操作提交已复制的片段
 *
 * @param data
 * EN: Nonempty array; both the array and its data elements are copied before enqueueing.
 * CN: 非空数组；数组及数据元素在入队前复制。
 *
 * @param context
 * EN: Original immutable identity. A busy owned operation is never replaced by this entry.
 * CN: 原始不可变身份；此入口不会替换仍在执行的归属写操作。
 *
 * @param progress
 * EN: Optional local submission progress, invoked on the write queue without waiting for main.
 * CN: 可选的本地提交进度，在写队列调用，不等待主线程。
 *
 * @param completion
 * EN: Invoked once on the write queue; success means local submission, not device acknowledgement.
 * CN: 在写队列回调一次；成功仅表示本地提交，不代表设备确认。
 */
- (void)writeData:(NSArray<NSData *> *)data
         context:(TSBleWriteContext *)context
        progress:(nullable void (^)(CGFloat progress))progress
      completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Cancel and drain one exact write attempt
 * @chinese 取消并排空确切的一次写入尝试
 *
 * @param identifier
 * EN: Original operation identifier; a different active operation remains untouched.
 * CN: 原始操作标识；不同的活动操作不受影响。
 *
 * @param completion
 * EN: Called once on the write queue after local cancellation. No more fragments from that attempt
 *     will be submitted; already submitted bytes cannot be recalled from CoreBluetooth.
 * CN: 本地取消后在写队列回调一次；此尝试不再提交新片段，已交给 CoreBluetooth 的字节无法撤回。
 */
- (void)cancelWriteOperationWithIdentifier:(NSString *)identifier
                              completion:(nullable dispatch_block_t)completion;

/**
 * @brief Cancel the latest write submitted through the compatibility entry
 * @chinese 取消兼容入口最近提交的写入
 *
 * @discussion
 * [EN]: Captures the original compatibility submission at entry. Owned writes use their operation
 *       cancellation API; a later owned operation is never cleared by this compatibility method.
 * [CN]: 调用时捕获原兼容提交；归属写入使用按操作取消接口，本兼容方法不清理后来的归属操作。
 */
- (void)cancelAllWriteData;


#pragma mark - Utility Methods

/**
 * @brief Get connected peripherals with default service UUID
 * @chinese 获取默认服务UUID的已连接外设
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithDefaultService;

/**
 * @brief Get all connected BLE peripherals (without service filter)
 * @chinese 获取所有已连接的BLE外设（不限制服务UUID）
 *
 * @discussion
 * [EN]: Retrieves all BLE peripherals currently connected to the system, regardless of service UUID.
 *       This is useful when you don't know the service UUID or want to find all connected devices.
 * [CN]: 获取系统当前所有已连接的BLE外设，不限制服务UUID。
 *       当不知道服务UUID或想查找所有已连接设备时很有用。
 */
- (NSArray<CBPeripheral *> *)retrieveAllConnectedPeripherals;

/**
 * @brief Get all connected peripherals with specified services
 * @chinese 获取所有已连接的指定服务的外设
 */
- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> * _Nullable)serviceUUIDs;

/**
 * @brief Get peripherals by their identifiers
 * @chinese 通过标识符获取外设
 */
- (NSArray<CBPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;




@end

NS_ASSUME_NONNULL_END
