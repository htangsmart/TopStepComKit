//
//  TSNpkReconnectCoordinator.h
//  TopStepNewPlatformKit
//
#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Cold-start automatic reconnection coordinator
 * @chinese 冷启动自动重连协调器
 *
 * @discussion
 * [EN]: Rebuilds connection parameters from the latest persisted record and starts
 *       the standard connection flow after Bluetooth becomes available.
 * [CN]: 蓝牙可用后，从最新的持久化连接记录重建参数并启动标准连接流程。
 */
@interface TSNpkReconnectCoordinator : NSObject

/**
 * @brief Return the shared reconnection coordinator
 * @chinese 返回共享的重连协调器
 *
 * @return
 * [EN]: Shared coordinator instance
 * [CN]: 共享协调器实例
 */
+ (instancetype)sharedCoordinator;

/**
 * @brief Start automatic reconnection coordination
 * @chinese 启动自动重连协调
 *
 * @param connector
 * [EN]: Connector shared with the application connection-state listener
 * [CN]: 与应用连接状态监听共享的连接器
 *
 * @discussion
 * [EN]: This method is idempotent. It attempts reconnection when Bluetooth becomes powered on.
 * [CN]: 此方法具备幂等性，在蓝牙变为可用状态时尝试重连。
 */
- (void)startWithConnector:(id<TSBleConnectInterface>)connector;

@end

NS_ASSUME_NONNULL_END
