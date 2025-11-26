//
//  TSBleConnectOption.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TSMetaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBleConnectOption : TSMetaBaseModel

/**
 * @brief Notify on connection
 * @chinese 连接时是否发送通知
 *
 * @discussion
 * [EN]: If YES, a notification will be sent when the peripheral connects.
 * [CN]: YES时，外设连接成功时会发送通知。
 *
 * @note
 * [EN]: Default is YES.
 * [CN]: 默认YES。
 */
@property (nonatomic, assign) BOOL notifyOnConnection;

/**
 * @brief Notify on disconnection
 * @chinese 断开连接时是否发送通知
 *
 * @discussion
 * [EN]: If YES, a notification will be sent when the peripheral disconnects.
 * [CN]: YES时，外设断开连接时会发送通知。
 *
 * @note
 * [EN]: Default is YES.
 * [CN]: 默认YES。
 */
@property (nonatomic, assign) BOOL notifyOnDisconnection;

/**
 * @brief Notify on notification
 * @chinese 收到通知时是否发送通知
 *
 * @discussion
 * [EN]: If YES, a notification will be sent when the peripheral sends a notification.
 * [CN]: YES时，外设发送通知时会发送通知。
 *
 * @note
 * [EN]: Default is YES.
 * [CN]: 默认YES。
 */
@property (nonatomic, assign) BOOL notifyOnNotification;

/**
 * @brief Start delay before connection (CoreBluetooth native option)
 * @chinese 连接开始前的延迟时间（CoreBluetooth原生选项）
 *
 * @discussion
 * [EN]: Delay in seconds before CoreBluetooth actually starts the connection process
 *       after connectPeripheral is called. This is a system-level delay.
 *       
 *       ⚠️ Important: This delay applies to ALL connections (first connect + reconnects).
 *       Total reconnect delay = reconnectDelayInterval + startDelay
 *       
 *       Typical use cases:
 *       - Set to 0.0 for immediate connection (recommended for reconnect)
 *       - Set to small value (0.1-0.5s) if you need to batch multiple operations
 * [CN]: 调用 connectPeripheral 后，CoreBluetooth 真正开始连接前的延迟时间（秒）。
 *       这是系统级延迟。
 *       
 *       ⚠️ 重要：此延迟应用于所有连接（首次连接+重连）。
 *       总重连延迟 = reconnectDelayInterval + startDelay
 *       
 *       典型使用场景：
 *       - 设为 0.0 立即连接（重连时推荐）
 *       - 设为小值（0.1-0.5秒）如果需要批量操作
 *
 * @note
 * [EN]: Default is 0.0 (no delay). Available on iOS 13.0+.
 *       Keep at 0.0 for auto-reconnect to avoid unnecessary delay.
 * [CN]: 默认0.0（无延迟）。iOS 13.0+可用。
 *       自动重连时建议保持0.0，避免不必要的延迟。
 */
@property (nonatomic, assign) NSTimeInterval startDelay;

/**
 * @brief Enable auto reconnect
 * @chinese 是否启用自动重连
 *
 * @discussion
 * [EN]: If YES, the system will automatically attempt to reconnect when the connection is lost due to signal issues or unexpected disconnections.
 *       Auto reconnect will NOT trigger for:
 *       - User-initiated disconnections
 *       - Bluetooth powered off
 *       - System errors (unauthorized, unsupported)
 *       - Max reconnect attempts reached
 * [CN]: YES时，当连接因信号问题或意外断开时，系统会自动尝试重连。
 *       以下情况不会触发自动重连：
 *       - 用户主动断开连接
 *       - 蓝牙关闭
 *       - 系统错误（权限被拒、不支持等）
 *       - 达到最大重连次数
 *
 * @note
 * [EN]: Default is YES. Reconnection uses exponential backoff strategy to reduce battery consumption.
 * [CN]: 默认YES。重连使用指数退避策略以降低电量消耗。
 */
@property (nonatomic, assign) BOOL isAutoReconnect;

/**
 * @brief Maximum auto reconnect attempts
 * @chinese 最大自动重连尝试次数
 *
 * @discussion
 * [EN]: Maximum number of automatic reconnection attempts before giving up.
 *       After reaching this limit, manual reconnection is required.
 *       Set to 0 for unlimited retries (not recommended).
 *       Reconnect counter resets when:
 *       - Connection succeeds
 *       - User manually disconnects
 *       - Bluetooth is turned off and on again
 * [CN]: 放弃前的最大自动重连尝试次数。
 *       达到此限制后，需要手动重连。
 *       设置为0表示无限重试（不推荐）。
 *       重连计数器在以下情况重置：
 *       - 连接成功
 *       - 用户手动断开
 *       - 蓝牙关闭后重新开启
 *
 * @note
 * [EN]: Default is 5. Range: 0-10 (0 means unlimited, which may drain battery).
 * [CN]: 默认5次。范围：0-10（0表示无限制，可能导致电量消耗过大）。
 */
@property (nonatomic, assign) NSUInteger maxReconnectAttempts;

/**
 * @brief Reconnect delay interval (ONLY for auto-reconnect)
 * @chinese 重连延迟间隔（仅用于自动重连）
 *
 * @discussion
 * [EN]: Delay before calling connectPeripheral after disconnection (app-level logic).
 *       This controls when to initiate the reconnection attempt.
 *       
 *       ⚠️ NOTE: This property is only used when exponential backoff is DISABLED.
 *       When exponential backoff is enabled, the system uses a fixed strategy:
 *       - Attempt 1: 1s  (quick first retry)
 *       - Attempt 2: 5s
 *       - Attempt 3: 10s
 *       - Attempt 4: 15s
 *       - Attempt 5: 20s
 *       - And so on... (linearly increases by 5s)
 *       
 *       ⚠️ Important: Total reconnect delay = calculated_delay + startDelay
 *       Timeline after disconnect:
 *       1. Wait calculated delay (1s, 5s, 10s, 15s, 20s...)
 *       2. Call connectPeripheral
 *       3. Wait startDelay (usually 0s)
 *       4. System starts connecting
 * [CN]: 断开连接后调用 connectPeripheral 前的延迟（应用层逻辑）。
 *       此属性控制何时发起重连尝试。
 *       
 *       ⚠️ 注意：此属性仅在禁用指数退避时使用。
 *       启用指数退避时，系统使用固定策略：
 *       - 第1次：1秒（快速首次重试）
 *       - 第2次：5秒
 *       - 第3次：10秒
 *       - 第4次：15秒
 *       - 第5次：20秒
 *       - 以此类推...（线性递增5秒）
 *       
 *       ⚠️ 重要：总重连延迟 = 计算延迟 + startDelay
 *       断开后的时间线：
 *       1. 等待计算延迟（1秒、5秒、10秒、15秒、20秒...）
 *       2. 调用 connectPeripheral
 *       3. 等待 startDelay（通常0秒）
 *       4. 系统开始连接
 *
 * @note
 * [EN]: Default is 3.0 seconds (only used when exponential backoff is disabled).
 *       Valid range: 1.0 - 10.0 seconds.
 * [CN]: 默认3.0秒（仅在禁用指数退避时使用）。
 *       有效范围：1.0 - 10.0秒。
 */
@property (nonatomic, assign) NSTimeInterval reconnectDelayInterval;

/**
 * @brief Enable smart reconnect strategy
 * @chinese 启用智能重连策略
 *
 * @discussion
 * [EN]: If YES, reconnection delay will increase linearly with each failed attempt.
 *       This reduces battery consumption and network load when device is temporarily unavailable.
 *       The delay strategy is:
 *       - Attempt 1: 1s  (quick first retry for temporary signal loss)
 *       - Attempt 2: 5s
 *       - Attempt 3: 10s
 *       - Attempt 4: 15s
 *       - Attempt 5: 20s
 *       - And so on... (increases by 5s each time, capped by maxReconnectDelay)
 *       
 *       Benefits of this strategy:
 *       - Fast recovery from brief signal interruptions (1s first retry)
 *       - Reduces battery drain from frequent connection attempts
 *       - Prevents overwhelming the device when it's temporarily unavailable
 *       - Balanced approach between speed and battery efficiency
 *       
 *       If NO, uses fixed reconnectDelayInterval for all attempts.
 * [CN]: YES时，重连延迟将随每次失败尝试线性增长。
 *       这可以在设备暂时不可用时减少电量消耗和网络负载。
 *       延迟策略为：
 *       - 第1次：1秒（针对临时信号中断的快速重试）
 *       - 第2次：5秒
 *       - 第3次：10秒
 *       - 第4次：15秒
 *       - 第5次：20秒
 *       - 以此类推...（每次递增5秒，受maxReconnectDelay限制）
 *       
 *       此策略的好处：
 *       - 快速从短暂信号中断中恢复（1秒首次重试）
 *       - 减少频繁连接尝试造成的电量消耗
 *       - 防止在设备暂时不可用时过度尝试
 *       - 在速度和电量效率之间取得平衡
 *       
 *       NO时，所有尝试使用固定的reconnectDelayInterval。
 *
 * @note
 * [EN]: Default is YES. Highly recommended for production use to save battery.
 * [CN]: 默认YES。强烈推荐在生产环境使用以节省电量。
 */
@property (nonatomic, assign) BOOL enableExponentialBackoff;

/**
 * @brief Maximum reconnect delay
 * @chinese 最大重连延迟
 *
 * @discussion
 * [EN]: Maximum delay between reconnection attempts when smart reconnect strategy is enabled.
 *       This prevents the delay from growing indefinitely.
 *       The actual delay is calculated as: min(calculatedDelay, maxReconnectDelay)
 *       
 *       Example with maxReconnectDelay=30.0s:
 *       - Attempt 1: 1s
 *       - Attempt 2: 5s
 *       - Attempt 3: 10s
 *       - Attempt 4: 15s
 *       - Attempt 5: 20s
 *       - Attempt 6: 25s (5 × 5 = 25s)
 *       - Attempt 7: 30s (5 × 6 = 30s, capped at 30s)
 *       - Attempt 8+: 30s (capped at 30s)
 * [CN]: 启用智能重连策略时重连尝试之间的最大延迟。
 *       防止延迟无限增长。
 *       实际延迟计算为：min(计算延迟, maxReconnectDelay)
 *       
 *       示例（maxReconnectDelay=30.0秒）：
 *       - 第1次：1秒
 *       - 第2次：5秒
 *       - 第3次：10秒
 *       - 第4次：15秒
 *       - 第5次：20秒
 *       - 第6次：25秒 (5 × 5 = 25秒)
 *       - 第7次：30秒 (5 × 6 = 30秒，限制在30秒)
 *       - 第8次+：30秒（限制在30秒）
 *
 * @note
 * [EN]: Default is 60.0 seconds. Valid range: 10.0 - 300.0 seconds.
 *       Only effective when enableExponentialBackoff is YES.
 * [CN]: 默认60.0秒。有效范围：10.0 - 300.0秒。
 *       仅在enableExponentialBackoff为YES时生效。
 */
@property (nonatomic, assign) NSTimeInterval maxReconnectDelay;


/**
 * @brief Create default option for auto-reconnect (optimized for reconnection)
 * @chinese 创建自动重连的默认配置（为重连优化）
 *
 * @return
 * EN: TSBleConnectOption configured for optimal auto-reconnect behavior
 * CN: 为自动重连优化配置的 TSBleConnectOption
 *
 * @discussion
 * [EN]: This factory method creates an option specifically optimized for auto-reconnect:
 *       - isAutoReconnect = YES
 *       - maxReconnectAttempts = 5
 *       - reconnectDelayInterval = 3.0s (only used if exponential backoff is disabled)
 *       - enableExponentialBackoff = YES (uses smart strategy: 1s, 5s, 10s, 15s, 20s)
 *       - maxReconnectDelay = 60.0s
 *       - startDelay = 0.0 (⭐ no extra delay for reconnect)
 *       
 *       With this configuration, the actual reconnect delays will be:
 *       - 1st attempt: 1s (fast recovery from brief signal loss)
 *       - 2nd attempt: 5s
 *       - 3rd attempt: 10s
 *       - 4th attempt: 15s
 *       - 5th attempt: 20s
 *       
 *       Use this when you want auto-reconnect with recommended settings.
 * [CN]: 此工厂方法创建专为自动重连优化的配置：
 *       - isAutoReconnect = YES
 *       - maxReconnectAttempts = 5次
 *       - reconnectDelayInterval = 3.0秒（仅在禁用指数退避时使用）
 *       - enableExponentialBackoff = YES（使用智能策略：1秒、5秒、10秒、15秒、20秒）
 *       - maxReconnectDelay = 60.0秒
 *       - startDelay = 0.0（⭐ 重连时无额外延迟）
 *       
 *       使用此配置时，实际重连延迟为：
 *       - 第1次：1秒（快速从短暂信号中断恢复）
 *       - 第2次：5秒
 *       - 第3次：10秒
 *       - 第4次：15秒
 *       - 第5次：20秒
 *       
 *       当需要使用推荐设置的自动重连时使用此方法。
 *
 * @note
 * [EN]: This is the recommended way to configure auto-reconnect.
 * [CN]: 这是配置自动重连的推荐方式。
 */
+ (TSBleConnectOption * _Nonnull)reconnectOption;

/**
 * @brief Calculate reconnect delay for specific attempt
 * @chinese 计算指定重连尝试的延迟时间
 *
 * @param attemptCount
 *        EN: Current reconnect attempt count (0-based)
 *        CN: 当前重连尝试次数（从0开始）
 *
 * @return
 * EN: Calculated delay interval in seconds
 * CN: 计算出的延迟时间（秒）
 *
 * @discussion
 * [EN]: This method calculates the reconnection delay based on the configured strategy.
 *       If smart reconnect strategy is enabled (enableExponentialBackoff = YES):
 *       - Strategy: 1s, 5s, 10s, 15s, 20s... (linear growth)
 *       - Formula: attemptCount == 0 ? 1s : min(5s × attemptCount, maxReconnectDelay)
 *       - Example:
 *         Attempt 0: 1s, Attempt 1: 5s, Attempt 2: 10s, Attempt 3: 15s, Attempt 4: 20s
 *       If smart reconnect strategy is disabled (enableExponentialBackoff = NO):
 *       - Returns fixed reconnectDelayInterval for all attempts
 * [CN]: 此方法根据配置的策略计算重连延迟。
 *       如果启用智能重连策略（enableExponentialBackoff = YES）：
 *       - 策略：1秒、5秒、10秒、15秒、20秒...（线性增长）
 *       - 公式：attemptCount == 0 ? 1秒 : min(5秒 × attemptCount, maxReconnectDelay)
 *       - 示例：
 *         第0次：1秒，第1次：5秒，第2次：10秒，第3次：15秒，第4次：20秒
 *       如果未启用智能重连策略（enableExponentialBackoff = NO）：
 *       - 所有尝试返回固定的reconnectDelayInterval
 *
 * @note
 * [EN]: attemptCount is 0-based (first attempt = 0, second attempt = 1, etc.)
 * [CN]: attemptCount 从0开始计数（第一次尝试 = 0，第二次尝试 = 1，以此类推）
 */
- (NSTimeInterval)calculateReconnectDelayForAttempt:(NSUInteger)attemptCount;

/**
 * @brief Generate connect options dictionary for CoreBluetooth
 * @chinese 生成CoreBluetooth连接参数字典
 *
 * @discussion
 * [EN]: Returns a dictionary suitable for connectPeripheral:options:, based on notification and delay properties.
 * [CN]: 根据通知和延迟属性，生成适用于connectPeripheral:options:方法的字典。
 *
 * @return
 * EN: Options dictionary for CoreBluetooth connection
 * CN: CoreBluetooth连接参数字典
 */
- (NSDictionary<NSString *, id> *)optionsInfo;



+ (TSBleConnectOption * _Nonnull)defaultOption;

@end

NS_ASSUME_NONNULL_END
