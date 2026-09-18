//
//  TSAINetworkStatusProvider.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Whether the current network path permits a connection attempt
 * @chinese 当前网络路径是否允许尝试建立连接
 */
typedef NS_ENUM(NSUInteger, TSAINetworkStatus) {
    TSAINetworkStatusUnknown = 0, ///< Initial path is not known / 尚未取得初始路径
    TSAINetworkStatusUnavailable, ///< No usable path / 当前无可用路径
    TSAINetworkStatusAvailable,   ///< A connection may be attempted / 可以尝试建立连接
};

/**
 * @brief Receive an initial network snapshot or a subsequent status change
 * @chinese 接收初始网络快照或后续状态变化
 * @param status EN: Current path status. CN: 当前路径状态。
 */
typedef void (^TSAINetworkStatusHandler)(TSAINetworkStatus status);

/**
 * @brief Shared or injected source of network path snapshots
 * @chinese 共享或外部注入的网络路径快照来源
 * @discussion
 * EN: Available permits an attempt, including paths activated on demand; it does
 *     not guarantee internet or service reachability. Delivery is asynchronous
 *     on a source-owned serial queue. Consumers enqueue work on their own queue.
 * CN: Available 表示允许尝试，包含可按需建立的路径，不保证互联网或业务服务可达。
 *     回调在来源自己的串行队列异步执行，使用方应将处理派发到自己的队列。
 */
@protocol TSAINetworkStatusProvider <NSObject>

/**
 * @brief Thread-safe latest snapshot; Unknown before the initial path arrives
 * @chinese 可跨线程读取的最新快照；初始路径到达前为 Unknown
 */
@property (atomic, assign, readonly) TSAINetworkStatus currentStatus;

/**
 * @brief Add an independent observer with ordered initial and changed snapshots
 * @chinese 添加独立观察者，按顺序接收初值及后续变化
 * @discussion
 * EN: Each observation first receives the current snapshot, followed by distinct
 *     changes in order. Keep the returned token and remove it when no longer used.
 * CN: 每个观察者先接收当前快照，再依次接收去重后的状态变化。保留令牌并在不用时移除。
 * @param observer EN: Status callback. CN: 状态回调。
 * @return EN: Opaque token owned by this source. CN: 由当前来源管理的不透明令牌。
 */
- (id)addStatusObserver:(TSAINetworkStatusHandler)observer;

/**
 * @brief Remove only the observation identified by the token
 * @chinese 仅移除令牌对应的观察者
 * @discussion
 * EN: Removal is ordered on the delivery queue and is idempotent. Earlier queued
 *     callbacks may still arrive; consumers must validate their own lifecycle.
 * CN: 移除操作在回调队列有序执行，可重复调用；此前排队的回调仍可能到达，使用方须校验自身生命周期。
 * @param token EN: Token returned by this source. CN: 当前来源返回的观察令牌。
 */
- (void)removeStatusObserver:(id)token;

@end

NS_ASSUME_NONNULL_END
