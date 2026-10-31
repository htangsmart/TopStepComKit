//
//  TSCmdDataReceiver.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/24.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
#import "TSPackageHandleInterface.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSCmdDataReceiver : TSMetaBase

+ (instancetype)sharedInstance;

/**
 * @brief 处理收到的响应数据
 * @chinese 当从设备收到响应数据时调用此方法
 *
 * @param receiveData 响应数据
 * EN: Response data received from device
 * CN: 从设备收到的响应数据
 *
 * @param error 错误信息
 * EN: Error information if data reception failed
 * CN: 数据接收失败时的错误信息
 *
 * @discussion
 * EN: - responseData is nil when error occurs
 *     - error is nil when data reception succeeds
 *     - Both parameters cannot be nil simultaneously
 * CN: - 当发生错误时，responseData 为 nil
 *     - 当数据接收成功时，error 为 nil
 *     - 两个参数不能同时为 nil
 */
- (void)handleReceivedData:(NSData *_Nullable)receiveData error:(NSError *_Nullable)error;

/**
 * @brief Parse received bytes with their original physical connection source
 * @chinese 使用原始物理连接来源解析接收字节
 *
 * @param receiveData
 * EN: Received bytes; mutable input is copied before buffering.
 * CN: 接收字节；可变输入在加入缓存前复制。
 *
 * @param error
 * EN: Optional receive error; errored bytes are not buffered.
 * CN: 可选接收错误；出现错误时不缓存字节。
 *
 * @param peripheral
 * EN: Original callback peripheral, captured before any asynchronous work.
 * CN: 在任何异步操作前捕获的原始回调外设。
 *
 * @param generation
 * EN: Original physical generation; call from the serial BLE receive context.
 * CN: 原物理代次；须在串行蓝牙接收上下文调用。
 *
 * @discussion
 * [EN]: Rejects stale sources and prevents incomplete bytes from crossing connection boundaries.
 * [CN]: 拒绝失效来源，禁止未完成字节跨连接边界组包。
 */
- (void)handleReceivedData:(nullable NSData *)receiveData
                     error:(nullable NSError *)error
                peripheral:(CBPeripheral *)peripheral
                generation:(NSUInteger)generation;

/**
 * @brief Clear incomplete received protocol bytes at a connection boundary
 * @chinese 在连接边界清除未完成的接收协议字节
 *
 * @discussion
 * [EN]: Call in the same serial context that delivers received bytes, before accepting a new connection.
 * [CN]: 应在交付接收字节的同一串行上下文调用，并先于接纳新连接数据。
 */
- (void)clearReceivedDataBuffer;

#pragma mark - 数据处理器管理

/**
 * @brief 注册数据处理器
 * @chinese 注册一个数据处理器来处理特定类型的数据
 *
 * @param handler 数据处理器
 *        EN: Data handler object
 *        CN: 数据处理器对象
 */
- (void)registerPackageHandler:(id<TSPackageHandleInterface>)handler;

/**
 * @brief 移除数据处理器
 * @chinese 移除指定的数据处理器
 *
 * @param handler 要移除的数据处理器
 *        EN: Data handler to remove
 *        CN: 要移除的数据处理器
 */
- (void)removePackageHandler:(id<TSPackageHandleInterface>)handler;

/**
 * @brief 获取所有注册的处理器
 * @chinese 获取所有已注册的数据处理器
 *
 * @return 数据处理器数组
 *         EN: Array of registered data handlers
 *         CN: 已注册的数据处理器数组
 */
- (NSArray<id<TSPackageHandleInterface>> *)getAllPackageHandlers;

@end

NS_ASSUME_NONNULL_END
