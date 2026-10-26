#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable device work-state snapshot.
 * @chinese 不可变的设备工作状态快照。
 */
@interface TSWorkStateSnapshot : NSObject

/**
 * @brief Normalized state name.
 * @chinese 归一化状态名称。
 * @discussion
 * [EN]: Describes the last observation, independently of command responses.
 * [CN]: 描述最近一次状态观测，与命令响应相互独立。
 * @note
 * [EN]: Unknown states use unknown; idle is never inferred from a missing value.
 * [CN]: 未知状态使用 unknown，不从缺失值推导空闲。
 */
@property (nonatomic, copy, readonly) NSString *state;

/**
 * @brief Provider code for compatibility and diagnostics.
 * @chinese 用于兼容和诊断的厂商状态码。
 * @discussion
 * [EN]: Buds uses its documented work-state values.
 * [CN]: Buds 使用其协议定义的工作状态值。
 * @note
 * [EN]: Minus one means unavailable; values are not shared across providers.
 * [CN]: -1 表示不可用，不将该数值协议套用其他 Provider。
 */
@property (nonatomic, assign, readonly) NSInteger legacyCode;

/**
 * @brief Connection-scoped snapshot metadata.
 * @chinese 属于当前连接的快照元数据。
 * @discussion
 * [EN]: Includes deviceIdentifier, sessionIdentifier, connectionEpoch, revision,
 *       validity, source and observedAt (Unix milliseconds).
 * [CN]: 包含设备、会话、连接代次、版本、有效性、来源和毫秒级观测时间。
 * @note
 * [EN]: Cached observations are marked cached, never deviceQuery.
 * [CN]: 缓存观测标记为 cached，不冒充 deviceQuery。
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *context;

/**
 * @brief Construct an immutable snapshot.
 * @chinese 创建不可变快照。
 * @param state
 * EN: Normalized state.
 * CN: 归一化状态。
 * @param legacyCode
 * EN: Original provider state, or -1 when unavailable.
 * CN: 厂商原始状态，不可用时为 -1。
 * @param context
 * EN: Immutable scalar metadata owned by this observation.
 * CN: 本次观测的不可变标量元数据。
 * @return
 * EN: Snapshot with copied values.
 * CN: 持有值副本的快照。
 */
- (instancetype)initWithState:(NSString *)state
                  legacyCode:(NSInteger)legacyCode
                     context:(NSDictionary<NSString *, id> *)context NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Encode for an application bridge.
 * @chinese 编码为应用桥接数据。
 * @return
 * EN: Immutable dictionary with schemaVersion 1.
 * CN: schemaVersion 为 1 的不可变字典。
 */
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
