#import "TSAIDeviceBridge.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional authentication transport owned by the physical device SDK
 * @chinese 物理设备 SDK 持有的可选认证通道
 * @discussion
 * [EN]: Providers interpret SDK-specific parameter keys and choose a service. The bridge
 *       does not receive cloud configuration or select an AI provider. Existing raw transports
 *       need not adopt this protocol. A managed service must not also use a virtual handshake.
 * [CN]: Provider 解释设备 SDK 参数并选择服务；桥接层不接收云端配置、不选择 AI 厂商。
 *       已有原始数据通道无需实现本协议；托管服务不得再启动第二套虚拟握手。
 */
@protocol TSAIDeviceAuthenticationBridge <TSAIDeviceBridge>

/**
 * @brief Read the frozen native connection authentication parameters
 * @chinese 读取已冻结的原生连接认证参数
 * @return
 * EN: Immutable SDK-namespaced metadata, or nil after invalidation. Safe on any queue.
 * CN: 按设备 SDK 命名空间组织的不可变元数据；失效后为 nil，可在任意队列读取。
 * @discussion
 * [EN]: Contains only native connection metadata, never cloud tokens or application secrets.
 * [CN]: 仅包含原生连接元数据，不包含云端 Token 或应用密钥。
 */
- (nullable NSDictionary<NSString *, id> *)deviceAuthenticationParameters;

/**
 * @brief Query whether the device SDK owns a complete authentication service
 * @chinese 查询设备 SDK 是否持有完整的认证服务
 * @param serviceIdentifier
 * EN: Opaque native service identifier interpreted by the device adapter.
 * CN: 由设备适配器解释的原生服务标识。
 * @return
 * EN: YES only when retry and the final result are both wired. Safe on any queue.
 * CN: 重试和最终结果均已接通时为 YES，可在任意队列查询。
 */
- (BOOL)managesDeviceAuthenticationForService:(NSString *)serviceIdentifier;

/**
 * @brief Await one native service's final authentication result
 * @chinese 等待原生服务的最终认证结果
 * @param serviceIdentifier
 * EN: A service advertised by this activation.
 * CN: 本次激活声明的服务。
 * @param completion
 * EN: Exactly once on main, including disconnection, cancellation and timeout.
 * CN: 在主队列完成一次，覆盖断连、取消和超时；命令发送成功不等于授权成功。
 * @discussion
 * [EN]: A wait timeout does not cancel the physical handshake. A bridge must not start
 *       overlapping retries while that handshake's terminal result is unknown.
 * [CN]: 等待超时不代表物理握手取消；原握手终态未知时不得叠加重试。
 */
- (void)authenticateDeviceService:(NSString *)serviceIdentifier
                       completion:(TSAICompletionBlock)completion;

@end

/**
 * @brief Optional readiness notification for an externally authenticated AI service
 * @chinese 外部 AI 服务完成鉴权后，可选的设备就绪通知能力
 * @discussion
 * [EN]: Independent of native authentication and provider selection. Providers whose
 *       authentication runs outside the device SDK use this only on adopting bridges.
 * [CN]: 与原生鉴权和厂商选择独立；鉴权在设备 SDK 外完成的 Provider 仅对实现本协议的桥调用。
 */
@protocol TSAIDeviceAIServiceReadinessBridge <TSAIDeviceBridge>

/**
 * @brief Notify the bound device that the external AI service is ready
 * @chinese 通知绑定设备：外部 AI 服务已就绪
 * @param completion
 * EN: Exactly once on main with the device SDK command result, including rejection,
 *     disconnection, deactivation and timeout. Failure must include an error.
 * CN: 主队列回调一次，返回设备 SDK 命令结果；覆盖拒绝、断连、失活和超时，失败必须附带错误。
 * @discussion
 * [EN]: Callable on any queue. Bind to the current activation and physical connection;
 *       never redirect queued work to a new connection. Success is not firmware readback
 *       or an AI conversation start acknowledgement. No cloud credentials are accepted.
 * [CN]: 可在任意队列调用，绑定当前激活及物理连接，排队请求不得转投新连接。
 *       成功不代表固件状态回读或对话启动成功；本接口不接收云端凭证。
 */
- (void)reportAIServiceReadyWithCompletion:(TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
