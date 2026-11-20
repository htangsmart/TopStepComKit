//
//  TSNpkBleConnect+Internal.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import "TSNpkBleConnect.h"

@class CBPeripheral;
@class TSMetaPeripheralInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable information authenticated for one physical connection
 * @chinese 一次物理连接认证后的不可变设备信息
 *
 * @discussion
 * [EN]: Retained snapshots remain historical values after the shared source is invalidated.
 * [CN]: 共享信息源失效后，已持有的快照仍是历史值，不再表示当前连接就绪。
 */
@interface TSNpkBleConnectionInformation : NSObject <NSCopying>

/**
 * @brief Identifier of the authenticated peripheral
 * @chinese 已认证外设的标识
 *
 * @discussion
 * [EN]: Copies the physical peripheral UUID string captured at publication.
 * [CN]: 复制发布时捕获的物理外设 UUID 字符串。
 *
 * @note
 * [EN]: Nonempty and immutable; it is not the advertised name or an AI vendor credential.
 * [CN]: 非空且不可变；不是广播名称或 AI 供应商凭据。
 */
@property (nonatomic, copy, readonly) NSString *deviceIdentifier;

/**
 * @brief Physical connection generation of the information
 * @chinese 设备信息所属的物理连接代次
 *
 * @discussion
 * [EN]: Uses the sole generation supplied by BleMeta; a reconnect creates a different generation.
 * [CN]: 使用 BleMeta 提供的唯一连接代次；重新连接将产生不同代次。
 *
 * @note
 * [EN]: Immutable; do not replace it with a per-consumer counter.
 * [CN]: 不可变；不能用消费者自行维护的计数器替代。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Owner that published the authenticated information
 * @chinese 发布已认证信息的所有者
 *
 * @discussion
 * [EN]: Copies the owner token created for one connection attempt.
 * [CN]: 复制一次连接尝试创建的所有者标识。
 *
 * @note
 * [EN]: Internal identity only; it grants no service authorization.
 * [CN]: 仅用于内部归属判断，不代表服务授权。
 */
@property (nonatomic, copy, readonly) NSString *ownerToken;

/**
 * @brief Independent copy of the authenticated protobuf information
 * @chinese 已认证 protobuf 设备信息的独立副本
 *
 * @discussion
 * [EN]: Captures the message at publication and returns a new copy on every read.
 * [CN]: 发布时冻结消息，每次读取都返回新的副本。
 *
 * @note
 * [EN]: Never nil; mutating a returned message cannot change this snapshot or the shared source.
 * [CN]: 不为 nil；修改返回消息不会改变当前快照或共享信息源。
 */
@property (nonatomic, copy, readonly) TSMetaPeripheralInfo *peripheralInfo;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Internal source for owner-scoped authenticated connection information
 * @chinese 按所有者隔离的已认证连接信息内部源
 *
 * @discussion
 * [EN]: Shared by all connector instances without depending on AI or replacing public connection callbacks.
 * [CN]: 所有连接器实例共享，不依赖 AI，也不替换公开连接回调。
 */
@interface TSNpkBleConnect (Internal)

/**
 * @brief Replace the current information owner
 * @chinese 替换当前设备信息所有者
 *
 * @param handler
 * EN: Optional callback scheduled on main when this owner is superseded;
 *     compare the original owner before local cleanup.
 * CN: 该所有者被替换时异步投递到主队列的可选回调；本地清理前须比较原所有者。
 *
 * @return
 * EN: A unique token; starting another owner invalidates any published information.
 * CN: 唯一标识；后续新所有者会使已发布信息失效。
 */
+ (NSString *)beginDeviceInformationOwnerWithInvalidationHandler:(nullable dispatch_block_t)handler;

/**
 * @brief Check ownership before a physical connection is bound
 * @chinese 在物理连接绑定前检查所有者
 *
 * @param owner
 * EN: Original connection-attempt token.
 * CN: 原连接尝试标识。
 *
 * @return
 * EN: YES only while the original token is current.
 * CN: 仅原标识仍为当前所有者时返回 YES。
 */
+ (BOOL)isCurrentDeviceInformationOwner:(NSString *)owner;

/**
 * @brief Bind the current owner to a connected physical generation
 * @chinese 将当前所有者绑定到已连接的物理代次
 *
 * @param owner
 * EN: Original connection-attempt token.
 * CN: 原连接尝试标识。
 *
 * @param peripheral
 * EN: Physical peripheral captured by the connection callback.
 * CN: 连接回调捕获的物理外设。
 *
 * @param generation
 * EN: Generation captured from the same physical connection.
 * CN: 从同一次物理连接捕获的代次。
 *
 * @return
 * EN: YES only if ownership and the physical connection still match; prior information is cleared on rebinding.
 * CN: 仅所有者和物理连接仍匹配时返回 YES；重新绑定将清除旧信息。
 */
+ (BOOL)bindDeviceInformationOwner:(NSString *)owner
                        peripheral:(CBPeripheral *)peripheral
                        generation:(NSUInteger)generation;

/**
 * @brief Check the exact owner and physical binding
 * @chinese 检查精确所有者与物理连接绑定
 *
 * @param owner
 * EN: Original owner token.
 * CN: 原所有者标识。
 *
 * @param peripheral
 * EN: Original physical peripheral.
 * CN: 原物理外设。
 *
 * @param generation
 * EN: Original physical generation.
 * CN: 原物理连接代次。
 *
 * @return
 * EN: YES only while all three still match the connected physical source.
 * CN: 仅三项仍匹配已连接的物理信息源时返回 YES。
 */
+ (BOOL)isCurrentDeviceInformationOwner:(NSString *)owner
                             peripheral:(CBPeripheral *)peripheral
                             generation:(NSUInteger)generation;

/**
 * @brief Publish authenticated information for the exact current binding
 * @chinese 为精确的当前连接发布已认证信息
 *
 * @param info
 * EN: Successfully read device information; nil is never published.
 * CN: 成功读取的设备信息；不得发布 nil。
 *
 * @param owner
 * EN: Original owner token.
 * CN: 原所有者标识。
 *
 * @param peripheral
 * EN: Physical peripheral captured before authentication.
 * CN: 认证开始前捕获的物理外设。
 *
 * @param generation
 * EN: Physical generation captured before authentication.
 * CN: 认证开始前捕获的物理连接代次。
 *
 * @return
 * EN: YES when the immutable information was accepted; stale callbacks return NO.
 * CN: 接受不可变信息时返回 YES；过期回调返回 NO。
 */
+ (BOOL)recordAuthenticatedDeviceInformation:(TSMetaPeripheralInfo *)info
                                      owner:(NSString *)owner
                                 peripheral:(CBPeripheral *)peripheral
                                 generation:(NSUInteger)generation;

/**
 * @brief Invalidate only the matching physical binding
 * @chinese 仅使匹配的物理连接绑定失效
 *
 * @param owner
 * EN: Original owner token.
 * CN: 原所有者标识。
 *
 * @param peripheral
 * EN: Original peripheral.
 * CN: 原物理外设。
 *
 * @param generation
 * EN: Original physical generation.
 * CN: 原物理连接代次。
 *
 * @discussion
 * [EN]: Clears the binding and information without ending the owner,
 *       so its automatic reconnect may bind a new generation.
 * [CN]: 清除绑定和信息但保留所有者，使该所有者的自动重连可以绑定新代次。
 */
+ (void)invalidateDeviceInformationForOwner:(NSString *)owner
                                peripheral:(CBPeripheral *)peripheral
                                generation:(NSUInteger)generation;

/**
 * @brief End only the matching information owner
 * @chinese 仅结束匹配的设备信息所有者
 *
 * @param owner
 * EN: Original owner token; an already superseded token does nothing.
 * CN: 原所有者标识；已被替换的标识不产生影响。
 */
+ (void)endDeviceInformationOwner:(NSString *)owner;

/**
 * @brief Read information only while its physical binding remains current
 * @chinese 仅在物理连接绑定仍有效时读取设备信息
 *
 * @return
 * EN: Immutable current information, or nil before publication and after invalidation.
 * CN: 当前不可变信息；尚未发布或已经失效时为 nil。
 */
+ (nullable TSNpkBleConnectionInformation *)authenticatedDeviceInformation;

/**
 * @brief Observe current information with an atomic initial replay
 * @chinese 观察当前设备信息并原子登记初始重放
 *
 * @param observer
 * EN: Receives an immutable snapshot or nil and a monotonically increasing source version on main.
 * CN: 在主队列接收不可变快照或 nil，以及单调递增的信息源版本。
 *
 * @return
 * EN: A unique registration token; remove it when the consumer stops.
 *     A nil observer is defensively rejected with an empty token.
 * CN: 唯一观察标识；消费者停止时须移除。对 nil 观察者防御性返回空标识。
 *
 * @discussion
 * [EN]: Registration and initial replay are ordered under one source lock. Delivery is always asynchronous and outside
 *       that lock. Superseded queued versions may be coalesced; initial replay can never overwrite a newer version.
 * [CN]: 登记与初始重放在同一信息源锁下排序；交付始终异步且不持有该锁。允许合并已过期的排队版本，
 *       初始重放不会覆盖较新的版本。
 */
+ (NSString *)observeAuthenticatedDeviceInformation:
    (void (^)(TSNpkBleConnectionInformation * _Nullable information, NSUInteger version))observer;

/**
 * @brief Remove an observation and suppress its pending deliveries
 * @chinese 移除观察并抑制尚未交付的排队回调
 *
 * @param token
 * EN: Token returned by registration.
 * CN: 登记时返回的观察标识。
 *
 * @discussion
 * [EN]: A callback already executing may finish; callbacks not yet claimed for delivery are suppressed.
 * [CN]: 已经开始执行的回调可以完成；尚未取得交付权的回调会被抑制。
 */
+ (void)removeDeviceInformationObserver:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
