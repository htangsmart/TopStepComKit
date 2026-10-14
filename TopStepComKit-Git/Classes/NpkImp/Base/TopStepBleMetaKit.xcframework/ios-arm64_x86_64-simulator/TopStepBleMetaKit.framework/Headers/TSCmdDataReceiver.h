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
