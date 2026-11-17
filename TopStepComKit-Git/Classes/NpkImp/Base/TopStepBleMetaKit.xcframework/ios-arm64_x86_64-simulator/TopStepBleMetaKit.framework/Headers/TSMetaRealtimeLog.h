#import <Foundation/Foundation.h>
#import "TSMetaBleConnect.h"

@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

/** @brief Result of UART characteristic discovery. @chinese UART 特征探测结果。 */
typedef void (^TSMetaRealtimeLogCapabilityHandler)(BOOL canNotify, BOOL canWrite, NSError * _Nullable error);
/** @brief Returns NO when delivery exceeds its buffer. @chinese 接收队列超出容量时返回 NO。 */
typedef BOOL (^TSMetaRealtimeLogDataHandler)(NSData *data);
/** @brief Releases the connection slot after terminal delivery. @chinese 终态交付后释放连接上的抓取占用。 */
typedef void (^TSMetaRealtimeLogRelease)(dispatch_block_t completion);
/** @brief Transport capture phases reported to the platform adapter. @chinese 通道报告给平台实现的抓取阶段。 */
typedef NS_ENUM(NSUInteger, TSMetaRealtimeLogEvent) {
    TSMetaRealtimeLogEventStarted,
    TSMetaRealtimeLogEventStopping,
    TSMetaRealtimeLogEventFinished,
};
/** @brief Phase change with an optional error and terminal release. @chinese 阶段变化，可携带错误和终态释放回调。 */
typedef void (^TSMetaRealtimeLogEventHandler)(TSMetaRealtimeLogEvent event, NSError * _Nullable error,
                                              TSMetaRealtimeLogRelease _Nullable release);

/**
 * @brief Connection-scoped bridge for the UART log channel.
 * @chinese 当前连接的 UART 实时日志桥接。
 */
@interface TSMetaRealtimeLog : NSObject

/**
 * @brief Query the UART characteristics for the captured connection.
 * @chinese 查询原连接的 UART 特征。
 * @param peripheral The original peripheral / 原外设。
 * @param generation The connection generation / 原连接代次。
 * @param validator Current owner check / 当前归属校验。
 * @param completion The characteristic result / 特征探测回调。
 */
+ (void)queryForPeripheral:(CBPeripheral *)peripheral
                generation:(NSUInteger)generation
                 validator:(TSMetaBleConnectionValidator)validator
                completion:(TSMetaRealtimeLogCapabilityHandler)completion;

/**
 * @brief Start a capture on the captured connection.
 * @chinese 在原连接开启抓取。
 * @param identifier Unique capture identity / 本次抓取标识。
 * @param commands Ordered UART command codes / 按序发送的 UART 命令值。
 * @param peripheral The original peripheral / 原外设。
 * @param generation The connection generation / 原连接代次。
 * @param validator Current owner check / 当前归属校验。
 * @param dataHandler Raw bytes, invoked on the connection queue / 原始字节，在连接队列调用。
 * @param eventHandler Start and terminal events on the connection queue / 连接队列上的启动和终态事件。
 */
+ (void)startCaptureWithIdentifier:(NSUUID *)identifier
                         commands:(NSArray<NSNumber *> *)commands
                       peripheral:(CBPeripheral *)peripheral
                       generation:(NSUInteger)generation
                        validator:(TSMetaBleConnectionValidator)validator
                      dataHandler:(TSMetaRealtimeLogDataHandler)dataHandler
                     eventHandler:(TSMetaRealtimeLogEventHandler)eventHandler;

/**
 * @brief Stop the matching capture.
 * @chinese 停止匹配的抓取。
 * @param identifier The original capture identity / 原抓取标识。
 * @param peripheral The original peripheral / 原外设。
 * @param generation The connection generation / 原连接代次。
 */
+ (void)stopCaptureWithIdentifier:(NSUUID *)identifier
                      peripheral:(CBPeripheral *)peripheral
                      generation:(NSUInteger)generation;

@end

NS_ASSUME_NONNULL_END
