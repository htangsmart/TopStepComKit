//
//  TSMetaFileUploadChannel.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class TSBleManager;

NS_ASSUME_NONNULL_BEGIN

/** @brief Raw channel receive event. @chinese 原始通道数据或连接失效事件。 */
typedef void (^TSMetaFileUploadReceiveHandler)(NSData * _Nullable data, NSError * _Nullable error);
/** @brief Local write submission event. @chinese 本地写入提交进展；不表示设备协议确认。 */
typedef void (^TSMetaFileUploadWriteHandler)(NSUInteger submittedBytes, BOOL finished, NSError * _Nullable error);

/** @brief Independent upload GATT channel owned by one connection.
 * @chinese 一次连接持有的独立上传GATT通道，不解析文件协议。
 */
@interface TSMetaFileUploadChannel : NSObject
/**
 * @brief Captured connection generation
 * @chinese 创建通道时捕获的连接代次
 *
 * @discussion
 * [EN]: Session counter supplied at initialization and unchanged for this channel;
 *       it is not a timestamp. Each write checks it against the owning manager's
 *       current generation, so a channel cannot be reused after a connection change.
 * [CN]: 初始化时传入并在本通道生命周期内保持不变的会话计数，不是时间戳。
 *       每次写入均与所属管理器的当前代次核对，连接变化后不能复用旧通道。
 */
@property (nonatomic, assign, readonly) NSUInteger generation;

/**
 * @brief Captured peripheral UUID string
 * @chinese 捕获的外设 UUID 字符串
 *
 * @discussion
 * [EN]: Copied from peripheral.identifier.UUIDString during initialization. It
 *       identifies the original peripheral and is not a MAC address. Detaching a
 *       task does not change this connection-level identity.
 * [CN]: 初始化时复制 peripheral.identifier.UUIDString，用于标识原始外设，
 *       不是 MAC 地址。解绑某个上传任务不会改变这一连接级身份。
 */
@property (nonatomic, copy, readonly) NSString *peripheralIdentifier;
/** @brief Create the connection channel. @chinese 创建连接通道，反向弱引用管理器。
 * @param manager Connection owner / 连接所有者。
 * @param peripheral Connected peripheral / 已连接外设。
 * @param generation Connection generation / 连接代次。
 * @return Channel / 通道。
 */
- (instancetype)initWithManager:(TSBleManager *)manager
                    peripheral:(CBPeripheral *)peripheral
                    generation:(NSUInteger)generation;
/** @brief Bind one task and prepare notification delivery. @chinese 绑定单个任务并准备通知，所有回调派发到指定队列。
 * @param task Task identity / 任务身份。
 * @param queue Callback queue / 回调队列。
 * @param handler Raw receive handler / 原始数据接收回调。
 * @param completion Preparation result / 准备结果。
 */
- (void)prepareForTask:(NSUUID *)task callbackQueue:(dispatch_queue_t)queue
       receiveHandler:(TSMetaFileUploadReceiveHandler)handler completion:(void (^)(NSError * _Nullable error))completion;
/** @brief Submit a bounded byte frame. @chinese 提交一个有界字节帧；packetSize为0表示只采用系统写入上限。
 * @param data Whole frame / 完整帧。
 * @param packetSize Device packet limit / 设备小包限制。
 * @param attempt Unique attempt identity / 单次发送身份。
 * @param handler Submission events / 本地提交事件。
 */
- (void)sendData:(NSData *)data packetSize:(NSUInteger)packetSize
 attemptIdentifier:(NSUUID *)attempt eventHandler:(TSMetaFileUploadWriteHandler)handler;
/** @brief Stop unsubmitted bytes on the write queue. @chinese 在写队列停止未提交尾包并等待停发屏障；同一attempt重复调用返回相同累计提交量。
 * @param attempt Attempt to stop / 待停止身份。
 * @param completion Bytes already submitted / 已提交字节数量。
 */
- (void)stopAttempt:(NSUUID *)attempt completion:(void (^)(NSUInteger submittedBytes))completion;
/** @brief Stop only an attempt with no bytes submitted. @chinese 未提交时原子停发；已开始的帧继续提交，供取消边界判断。
 * @param attempt Attempt to inspect / 待检查身份。
 * @param completion Bytes already submitted / 已提交字节数量。
 */
- (void)stopAttemptIfUnsubmitted:(NSUUID *)attempt completion:(void (^)(NSUInteger submittedBytes))completion;
/** @brief Detach only the matching task. @chinese 解绑匹配任务，不关闭连接级通知。
 * @param task Task identity / 任务身份。
 * @param completion Write barrier completion / 停发屏障完成。
 */
- (void)detachTask:(NSUUID *)task completion:(dispatch_block_t)completion;
/** @brief Handle discovered services. @chinese 处理已有服务列表。
 * @param peripheral Event peripheral / 事件所属外设。
 * @param error Discovery error / 服务发现错误。 */
- (void)didDiscoverServicesForPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
/** @brief Handle upload characteristics. @chinese 处理新服务特征发现结果。
 * @param service Upload service / 上传服务。
 * @param error Discovery error / 特征发现错误。 */
- (void)didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error;
/** @brief Handle notification subscription. @chinese 处理新通知订阅结果。
 * @param characteristic Notification characteristic / 通知特征。
 * @param error Subscription error / 订阅错误。 */
- (void)didUpdateNotificationForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
/** @brief Handle raw notification bytes. @chinese 接收新特征的原始通知。
 * @param characteristic Notification characteristic / 通知特征。
 * @param error Notification error / 通知错误。 */
- (void)didReceiveCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
/** @brief Use one bounded write turn. @chinese 在共享写上下文同步取得一次有界写入机会。 */
- (void)peripheralReadyToWrite;
/** @brief Invalidate this connection. @chinese 使本连接通道失效，停止本地写入并通知任务。
 * @param error Connection error / 连接错误。
 */
- (void)invalidateWithError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
