#import <CoreBluetooth/CoreBluetooth.h>
#import "TSBleManager.h"
#import "TSMetaRealtimeLog.h"

@class TSMetaRealtimeLogChannel;

NS_ASSUME_NONNULL_BEGIN

/// @brief UART service identity. @chinese UART 服务标识。
FOUNDATION_EXPORT BOOL TSMetaRealtimeLogIsService(CBService *service);
/// @brief UART characteristic identity. @chinese UART 特征标识。
FOUNDATION_EXPORT BOOL TSMetaRealtimeLogIsCharacteristic(CBCharacteristic *characteristic);

/// @brief UART connection and write queue access. @chinese UART 使用的连接与写队列入口。
@interface TSBleManager (RealtimeLogChannel)
/// @brief Execute on the connection queue. @chinese 在连接队列执行。 @param block Work / 工作块。
- (void)performConnectionBlock:(dispatch_block_t)block;
/// @brief Execute on the BLE write queue. @chinese 在 BLE 写队列执行。 @param block Work / 工作块。
- (void)performOnWriteDataSerialQueue:(dispatch_block_t)block;
/// @brief Get the channel for an exact connection. @chinese 取得原连接的通道。
/// @param peripheral Original peripheral / 原外设。 @param generation Original generation / 原代次。
- (nullable TSMetaRealtimeLogChannel *)realtimeLogChannelForPeripheral:(CBPeripheral *)peripheral
                                                            generation:(NSUInteger)generation;
@end

/// @brief UART operations belonging to one physical connection. @chinese 同一物理连接的 UART 操作。
@interface TSMetaRealtimeLogChannel : NSObject

/// @brief Bind a channel to a connection. @chinese 将通道绑定到原连接。
/// @param manager BLE manager / BLE 管理器。 @param peripheral Original peripheral / 原外设。
/// @param generation Original generation / 原代次。 @param service UART service / UART 服务。
- (instancetype)initWithManager:(TSBleManager *)manager
                      peripheral:(CBPeripheral *)peripheral
                      generation:(NSUInteger)generation
                         service:(nullable CBService *)service;

/// @brief Discover or reuse capabilities. @chinese 探测或复用能力。
/// @param validator Owner check / 归属校验。 @param completion Capability result / 能力结果。
- (void)queryWithValidator:(TSMetaBleConnectionValidator)validator
                completion:(TSMetaRealtimeLogCapabilityHandler)completion;

/// @brief Start a capture. @chinese 启动抓取。
/// @param identifier Capture identity / 抓取标识。 @param commands Wire commands / 协议命令。
/// @param validator Owner check / 归属校验。 @param dataHandler Byte consumer / 字节接收回调。
/// @param eventHandler Event consumer / 事件回调。
- (void)startCapture:(NSUUID *)identifier
            commands:(NSArray<NSNumber *> *)commands
           validator:(TSMetaBleConnectionValidator)validator
         dataHandler:(TSMetaRealtimeLogDataHandler)dataHandler
        eventHandler:(TSMetaRealtimeLogEventHandler)eventHandler;

/// @brief Stop a matching capture. @chinese 停止匹配的抓取。 @param identifier Capture identity / 抓取标识。
- (void)stopCapture:(NSUUID *)identifier;
/// @brief End work for the old connection. @chinese 结束旧连接工作。 @param error Underlying error / 底层错误。
- (void)disconnectWithError:(nullable NSError *)error;
/// @brief Invalidate the matching UART service. @chinese 作废匹配的 UART 服务。 @param services Services / 已失效服务。
- (void)didInvalidateServices:(NSArray<CBService *> *)services;
/// @brief Consume UART discovery. @chinese 处理 UART 特征发现。
/// @param service Discovered service / 已发现服务。 @param error Discovery error / 发现错误。
- (void)didDiscoverCharacteristics:(CBService *)service error:(nullable NSError *)error;
/// @brief Consume UART subscription changes. @chinese 处理 UART 订阅变化。
/// @param characteristic Notify characteristic / 通知特征。 @param error Subscription error / 订阅错误。
- (void)didUpdateNotification:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
/// @brief Consume a UART inbound value. @chinese 处理 UART 传入值。
/// @param characteristic Notify characteristic / 通知特征。 @param error Receive error / 接收错误。
- (void)didReceiveValue:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
/// @brief Consume an acknowledged write result. @chinese 处理带响应写回调。
/// @param characteristic Write characteristic / 写特征。 @param error Write error / 写入错误。
- (void)didWriteValue:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
/// @brief Resume a UART write waiting for transport capacity. @chinese 继续等待发送额度的 UART 写入。
- (void)peripheralReadyToWrite;

@end

NS_ASSUME_NONNULL_END
