//
//  TSCommand.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/8/1.
//

#import "TSCommandBase.h"
#import "TSCommandDefines.h"
#import "TSCommandRequest.h"
#import "TSRequestManager.h"
#import "TSRequestNotifyManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSCommand class
 * @chinese TSCommand类
 *
 * @discussion
 * [EN]: Main command execution class for TopStep BLE Meta Kit.
 *        Provides methods to execute various BLE commands with different payload configurations.
 * [CN]: TopStep BLE Meta Kit的主要命令执行类。
 *       提供执行各种BLE命令的方法，支持不同的负载配置。
 */
@interface TSCommand : TSCommandBase

/**
 * @brief Execute command with single payload (wait for response)
 * @chinese 执行带单个负载的命令（等待响应）
 *
 * @param command
 *        EN: The command type to execute
 *        CN: 要执行的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific operation
 *        CN: 标识特定操作的子命令键
 * @param payload
 *        EN: Data payload to send with the command (nil for commands without payload)
 *        CN: 与命令一起发送的数据负载（无负载的命令传nil）
 * @param completion
 *        EN: Completion callback invoked when command finishes or fails
 *        CN: 命令完成或失败时调用的完成回调
 *
 * @discussion
 * EN: Convenience method for executing commands that expect a device response.
 *     Uses default timeout and retry configurations.
 *     Equivalent to calling executeCommand with waitForResponse=YES and option=nil.
 * CN: 用于执行期望设备响应的命令的便捷方法。
 *     使用默认的超时和重试配置。
 *     等同于调用 executeCommand，并设置 waitForResponse=YES 和 option=nil。
 *
 * @note
 * EN: This method waits for device response with default timeout (18s).
 *     For commands that don't need response, use executeNoResponseCommand instead.
 * CN: 此方法等待设备响应，使用默认超时时间（18秒）。
 *     对于不需要响应的命令，请使用 executeNoResponseCommand。
 */
+(void)executeResponseCommand:(TSRequestCommand)command
                          key:(UInt8)key
                      payload:(NSData * _Nullable)payload
                   completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute command without waiting for response
 * @chinese 执行命令不等待响应
 *
 * @param command
 *        EN: The command type to execute
 *        CN: 要执行的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific operation
 *        CN: 标识特定操作的子命令键
 * @param payload
 *        EN: Data payload to send with the command (nil for commands without payload)
 *        CN: 与命令一起发送的数据负载（无负载的命令传nil）
 * @param completion
 *        EN: Completion callback invoked when data is sent (not when device responds)
 *        CN: 数据发送完成时调用的完成回调（而非设备响应时）
 *
 * @discussion
 * EN: Convenience method for executing commands that don't require a device response.
 *     The completion block is called immediately after data is sent successfully.
 *     Equivalent to calling executeCommand with waitForResponse=NO and option=nil.
 *     Use this for "fire-and-forget" commands like configuration updates.
 * CN: 用于执行不需要设备响应的命令的便捷方法。
 *     完成回调在数据成功发送后立即调用。
 *     等同于调用 executeCommand，并设置 waitForResponse=NO 和 option=nil。
 *     适用于"发送即忘"类型的命令，如配置更新。
 *
 * @note
 * EN: This method does NOT wait for device response. Completion indicates send success only.
 *     If you need to know device response status, use executeResponseCommand instead.
 * CN: 此方法不等待设备响应。完成回调仅表示发送成功。
 *     如果需要知道设备响应状态，请使用 executeResponseCommand。
 */
+ (void)executeNoResponseCommand:(TSRequestCommand)command
                             key:(UInt8)key
                         payload:(NSData *_Nullable)payload
                      completion:(nullable TSRequestCompletionBlock)completion ;


/**
 * @brief Execute command with single payload and custom callbacks
 * @chinese 执行带单个负载和自定义回调的命令
 *
 * @param command
 *        EN: The command type to execute
 *        CN: 要执行的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific operation
 *        CN: 标识特定操作的子命令键
 * @param payload
 *        EN: Data payload to send with the command
 *        CN: 与命令一起发送的数据负载
 * @param waitForResponse
 *        EN: Whether to wait for device response before completing
 *        CN: 是否等待设备响应后才完成
 * @param option
 *        EN: Custom request configuration (timeout, retry, etc.). Pass nil to use defaults.
 *        CN: 自定义请求配置（超时、重试等）。传入 nil 使用默认值。
 * @param progress
 *        EN: Progress callback for packet sending (0.0 - 1.0). Called on main thread.
 *        CN: 分包发送进度回调（0.0 - 1.0）。在主线程调用。
 * @param stateChanged
 *        EN: State change callback (Pending → Processing → Success/Failed). Called on main thread.
 *        CN: 状态变化回调（Pending → Processing → Success/Failed）。在主线程调用。
 * @param completion
 *        EN: Completion callback with response data or error. Called on main thread.
 *        CN: 完成回调，包含响应数据或错误。在主线程调用。
 *
 * @discussion
 * EN: Full-featured method for executing BLE commands with maximum control.
 *     Provides progress tracking, state monitoring, and custom timeout/retry configurations.
 *     Use this when you need fine-grained control over the command execution process.
 *     
 *     Progress callback: Reports packet sending progress (0.0 = start, 1.0 = all packets sent)
 *     State callback: Reports request lifecycle (Pending → Processing → Success/Failed/Cancelled)
 *     Completion: Final result with response data (if waitForResponse=YES) or error
 * CN: 功能完整的BLE命令执行方法，提供最大程度的控制。
 *     提供进度跟踪、状态监控和自定义超时/重试配置。
 *     当需要对命令执行过程进行细粒度控制时使用此方法。
 *     
 *     进度回调：报告分包发送进度（0.0 = 开始，1.0 = 所有包已发送）
 *     状态回调：报告请求生命周期（Pending → Processing → Success/Failed/Cancelled）
 *     完成回调：最终结果，包含响应数据（如果 waitForResponse=YES）或错误
 *
 * @note
 * EN: All callbacks are executed on the main thread for UI updates.
 *     Use TSRequestOption factory methods for common scenarios:
 *     - [TSRequestOption defaultOption] for standard commands
 *     - [TSRequestOption fastQueryOption] for quick queries
 *     - [TSRequestOption otaOption] for firmware updates
 *     - [TSRequestOption fileTransferOption] for file transfers
 * CN: 所有回调都在主线程执行，便于更新UI。
 *     对常见场景使用 TSRequestOption 工厂方法：
 *     - [TSRequestOption defaultOption] 用于标准命令
 *     - [TSRequestOption fastQueryOption] 用于快速查询
 *     - [TSRequestOption otaOption] 用于固件更新
 *     - [TSRequestOption fileTransferOption] 用于文件传输
 */
+(void)executeCommand:(TSRequestCommand)command
                  key:(UInt8)key
              payload:(NSData *)payload
      waitForResponse:(BOOL)waitForResponse
               option:(TSRequestOption *_Nullable)option
             progress:(nullable void(^)(CGFloat progress))progress
         stateChanged:(nullable void(^)(TSRequestStatus status))stateChanged
           completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute command with multiple payloads (simplified version)
 * @chinese 执行带多个负载的命令（简化版本）
 *
 * @param command
 *        EN: The command type to execute
 *        CN: 要执行的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific operation
 *        CN: 标识特定操作的子命令键
 * @param allPayloads
 *        EN: Array of data payloads to send sequentially. Each element is sent as a separate packet.
 *        CN: 要依次发送的数据负载数组。每个元素作为单独的包发送。
 * @param completion
 *        EN: Completion callback with array of response data (one per payload) or error
 *        CN: 完成回调，包含响应数据数组（每个负载对应一个响应）或错误
 *
 * @discussion
 * EN: Convenience method for executing list commands with multiple payloads.
 *     Uses default timeout and retry configurations.
 *     Automatically sets packetMode to eTSPacketModeList for proper fragmentation.
 *     Each payload in the array is sent as a separate packet in the list protocol.
 *     The response array maintains the same order as the input payload array.
 * CN: 用于执行带多个负载的列表命令的便捷方法。
 *     使用默认的超时和重试配置。
 *     自动设置 packetMode 为 eTSPacketModeList 以正确分包。
 *     数组中的每个负载作为列表协议中的单独包发送。
 *     响应数组保持与输入负载数组相同的顺序。
 *
 * @note
 * EN: Typical use cases: Batch operations (alarms, contacts, workout data).
 *     For single payload commands, use executeResponseCommand instead.
 *     Response array length matches input payload array length.
 * CN: 典型使用场景：批量操作（闹钟、联系人、运动数据）。
 *     对于单负载命令，请使用 executeResponseCommand。
 *     响应数组长度与输入负载数组长度匹配。
 */
+(void)executeRespondListCommand:(TSRequestCommand)command
                      key:(UInt8)key
              allPayloads:(NSArray<NSData *> * _Nullable)allPayloads
               completion:(nullable TSRequestListCompletionBlock)completion;

+ (void)executeNoRespondListCommand:(TSRequestCommand)command key:(UInt8)key allPayloads:(NSArray<NSData *> *_Nullable)allPayloads completion:(nullable TSRequestListCompletionBlock)completion ;

/**
 * @brief Execute command with multiple payloads and custom callbacks
 * @chinese 执行带多个负载和自定义回调的命令
 *
 * @param command
 *        EN: The command type to execute
 *        CN: 要执行的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific operation
 *        CN: 标识特定操作的子命令键
 * @param allPayloads
 *        EN: Array of data payloads to send sequentially. Each element is sent as a separate packet.
 *        CN: 要依次发送的数据负载数组。每个元素作为单独的包发送。
 * @param option
 *        EN: Custom request configuration (timeout, retry, etc.). Pass nil to use defaults.
 *        CN: 自定义请求配置（超时、重试等）。传入 nil 使用默认值。
 * @param progress
 *        EN: Progress callback for packet sending (0.0 - 1.0). Called on main thread.
 *        CN: 分包发送进度回调（0.0 - 1.0）。在主线程调用。
 * @param stateChanged
 *        EN: State change callback (Pending → Processing → Success/Failed). Called on main thread.
 *        CN: 状态变化回调（Pending → Processing → Success/Failed）。在主线程调用。
 * @param completion
 *        EN: Completion callback with array of response data or error. Called on main thread.
 *        CN: 完成回调，包含响应数据数组或错误。在主线程调用。
 *
 * @discussion
 * EN: Full-featured method for executing list commands with multiple payloads.
 *     Provides progress tracking, state monitoring, and custom timeout/retry configurations.
 *     Automatically sets packetMode to eTSPacketModeList for proper fragmentation handling.
 *     
 *     Use cases:
 *     - Batch sync operations (alarms, contacts, sports data)
 *     - File transfer operations with multiple data chunks
 *     - Any operation requiring multiple sequential data packets
 *     
 *     Progress tracking: Reports overall sending progress across all payloads
 *     Response handling: Collects all responses and returns them in order
 * CN: 功能完整的列表命令执行方法，支持多个负载。
 *     提供进度跟踪、状态监控和自定义超时/重试配置。
 *     自动设置 packetMode 为 eTSPacketModeList 以正确处理分包。
 *     
 *     使用场景：
 *     - 批量同步操作（闹钟、联系人、运动数据）
 *     - 带多个数据块的文件传输操作
 *     - 任何需要多个连续数据包的操作
 *     
 *     进度跟踪：报告所有负载的总体发送进度
 *     响应处理：收集所有响应并按顺序返回
 *
 * @note
 * EN: All callbacks are executed on the main thread for UI updates.
 *     The response array length matches the input payload array length.
 *     For single payload, use executeCommand instead for better performance.
 * CN: 所有回调都在主线程执行，便于更新UI。
 *     响应数组长度与输入负载数组长度匹配。
 *     对于单负载，使用 executeCommand 以获得更好的性能。
 */
+(void)executeListCommand:(TSRequestCommand)command
                      key:(UInt8)key
              allPayloads:(NSArray<NSData *> * _Nullable)allPayloads
          waitForResponse:(BOOL)waitForResponse
                   option:(TSRequestOption *_Nullable)option
                 progress:(nullable void(^)(CGFloat progress))progress
             stateChanged:(nullable void(^)(TSRequestStatus status))stateChanged
               completion:(nullable TSRequestListCompletionBlock)completion;


#pragma mark -- Notifier

/**
 * @brief Add notification listener for object packet mode (KVO-style API)
 * @chinese 添加对象分包模式的通知监听器（KVO风格API）
 *
 * @param notifier
 *        EN: The observer object that will receive notifications. Its class name is used as the unique identifier.
 *             If the same notifier registers again for the same cmd+key, the previous registration will be replaced.
 *        CN: 将接收通知的观察者对象。其类名用作唯一标识符。
 *            如果同一个 notifier 对相同的 cmd+key 再次注册，将替换之前的注册。
 * @param command
 *        EN: The command type for the notification
 *        CN: 通知的命令类型
 * @param key
 *        EN: Sub-command key for the notification
 *        CN: 通知的子命令键
 * @param completion
 *        EN: Completion callback that receives a single response data object.
 *             Called on main thread when notification is received.
 *             The callback signature is: (BOOL isSuccess, NSData *respondData, NSError *error)
 *        CN: 完成回调，接收单个响应数据对象。
 *            收到通知时在主线程调用。
 *            回调签名为：(BOOL isSuccess, NSData *respondData, NSError *error)
 *
 * @discussion
 * EN: Registers a persistent notification listener for unsolicited messages from the BLE peripheral.
 *     Uses object packet mode, suitable for single-object notifications.
 *     
 *     Key features:
 *     - De-duplication: Same notifier class can only have one listener per cmd+key (replaces previous)
 *     - Multiple classes: Different notifier classes can listen to the same cmd+key simultaneously
 *     - Persistent: Listener remains active until explicitly removed
 *     - Memory management: Manager holds strong reference to request, must call removeNotifier:command:key: to clean up
 *     - Single object response: Completion callback receives a single NSData object, not an array
 *     
 *     The completion callback receives a single response data object.
 *     For notifications that may contain multiple objects, use addListRequestNotifier instead.
 * CN: 为来自BLE外设的主动通知消息注册持久监听器。
 *     使用对象分包模式，适用于单对象通知。
 *     
 *     关键特性：
 *     - 去重机制：同一个 notifier 类对同一个 cmd+key 只能有一个监听器（会替换之前的）
 *     - 多类支持：不同的 notifier 类可以同时监听同一个 cmd+key
 *     - 持久性：监听器保持活动状态，直到显式移除
 *     - 内存管理：Manager 持有 request 的强引用，必须调用 removeNotifier:command:key: 清理
 *     - 单对象响应：完成回调接收单个 NSData 对象，而非数组
 *     
 *     完成回调接收单个响应数据对象。
 *     对于可能包含多个对象的通知，请使用 addListRequestNotifier。
 *
 * @note
 * EN: - The notifier's class name is used as the identifier for de-duplication
 *     - Must call removeNotifier:command:key: in dealloc or when no longer needed to avoid memory leaks
 *     - Completion callback is called on main thread for UI updates
 *     - If the same notifier registers again, the previous listener is automatically replaced
 *     - Typical use cases: Device status changes, single data item notifications
 * CN: - notifier 的类名用作去重标识符
 *     - 必须在 dealloc 中或不再需要时调用 removeNotifier:command:key: 以避免内存泄漏
 *     - 完成回调在主线程调用，便于更新UI
 *     - 如果同一个 notifier 再次注册，之前的监听器会自动替换
 *     - 典型使用场景：设备状态变化、单个数据项通知
 */
+(void)addRequestNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key completion:(nonnull TSRequestCompletionBlock)completion;

/**
 * @brief Add notification listener for list packet mode (KVO-style API)
 * @chinese 添加列表分包模式的通知监听器（KVO风格API）
 *
 * @param notifier
 *        EN: The observer object that will receive notifications. Its class name is used as the unique identifier.
 *             If the same notifier registers again for the same cmd+key, the previous registration will be replaced.
 *        CN: 将接收通知的观察者对象。其类名用作唯一标识符。
 *            如果同一个 notifier 对相同的 cmd+key 再次注册，将替换之前的注册。
 * @param command
 *        EN: The command type for the notification
 *        CN: 通知的命令类型
 * @param key
 *        EN: Sub-command key for the notification
 *        CN: 通知的子命令键
 * @param completion
 *        EN: Completion callback that receives the full array of response data objects.
 *             Called on main thread when notification is received.
 *        CN: 完成回调，接收完整的响应数据对象数组。
 *            收到通知时在主线程调用。
 *
 * @discussion
 * EN: Registers a persistent notification listener for unsolicited messages from the BLE peripheral.
 *     Uses list packet mode (eTSPacketModeList), suitable for notifications that may contain multiple data objects.
 *     
 *     Key features:
 *     - De-duplication: Same notifier class can only have one listener per cmd+key (replaces previous)
 *     - Multiple classes: Different notifier classes can listen to the same cmd+key simultaneously
 *     - Persistent: Listener remains active until explicitly removed
 *     - Memory management: Manager holds strong reference to request, must call removeNotifier:command:key: to clean up
 *     
 *     The completion callback receives the complete array of response objects.
 *     For single-object notifications, use addRequestNotifier instead for better performance.
 * CN: 为来自BLE外设的主动通知消息注册持久监听器。
 *     使用列表分包模式（eTSPacketModeList），适用于可能包含多个数据对象的通知。
 *     
 *     关键特性：
 *     - 去重机制：同一个 notifier 类对同一个 cmd+key 只能有一个监听器（会替换之前的）
 *     - 多类支持：不同的 notifier 类可以同时监听同一个 cmd+key
 *     - 持久性：监听器保持活动状态，直到显式移除
 *     - 内存管理：Manager 持有 request 的强引用，必须调用 removeNotifier:command:key: 清理
 *     
 *     完成回调接收完整的响应对象数组。
 *     对于单对象通知，使用 addRequestNotifier 可获得更好的性能。
 *
 * @note
 * EN: - The notifier's class name is used as the identifier for de-duplication
 *     - Must call removeNotifier:command:key: in dealloc or when no longer needed to avoid memory leaks
 *     - Completion callback is called on main thread for UI updates
 *     - If the same notifier registers again, the previous listener is automatically replaced
 *     - Typical use cases: Batch data sync notifications, fragmented data transfers
 * CN: - notifier 的类名用作去重标识符
 *     - 必须在 dealloc 中或不再需要时调用 removeNotifier:command:key: 以避免内存泄漏
 *     - 完成回调在主线程调用，便于更新UI
 *     - 如果同一个 notifier 再次注册，之前的监听器会自动替换
 *     - 典型使用场景：批量数据同步通知、分片数据传输
 */
+(void)addListRequestNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key completion:(nonnull TSRequestListCompletionBlock)completion;

/**
 * @brief Remove notification listener for specified notifier (KVO-style API)
 * @chinese 移除指定 notifier 的通知监听器（KVO风格API）
 *
 * @param notifier
 *        EN: The observer object whose listener should be removed. Must match the notifier used in addRequestNotifier or addListRequestNotifier.
 *        CN: 要移除其监听器的观察者对象。必须与 addRequestNotifier 或 addListRequestNotifier 中使用的 notifier 匹配。
 * @param command
 *        EN: The command type that was registered
 *        CN: 已注册的命令类型
 * @param key
 *        EN: The sub-command key that was registered
 *        CN: 已注册的子命令键
 *
 * @discussion
 * EN: Removes the notification listener registered for the specified notifier, command, and key combination.
 *     This method only removes the listener for the specific notifier's class.
 *     Other notifier classes listening to the same cmd+key will remain active.
 *     
 *     This is a cleanup method that should be called:
 *     - In the notifier's dealloc method
 *     - When the notifier no longer needs to receive notifications
 *     - Before the notifier object is deallocated
 *     
 *     Failure to call this method will result in memory leaks, as the Manager holds a strong reference to the request.
 * CN: 移除为指定的 notifier、command 和 key 组合注册的通知监听器。
 *     此方法仅移除特定 notifier 类的监听器。
 *     监听同一 cmd+key 的其他 notifier 类将保持活动状态。
 *     
 *     这是一个清理方法，应在以下情况调用：
 *     - 在 notifier 的 dealloc 方法中
 *     - 当 notifier 不再需要接收通知时
 *     - 在 notifier 对象被释放之前
 *     
 *     不调用此方法将导致内存泄漏，因为 Manager 持有 request 的强引用。
 *
 * @note
 * EN: - This method is safe to call multiple times (idempotent)
 *     - Only removes the listener for the specified notifier class
 *     - Other notifier classes listening to the same cmd+key are unaffected
 *     - If no listener is found for the specified notifier, a warning is logged but no error is thrown
 *     - Must be called to prevent memory leaks
 * CN: - 此方法可以安全地多次调用（幂等性）
 *     - 仅移除指定 notifier 类的监听器
 *     - 监听同一 cmd+key 的其他 notifier 类不受影响
 *     - 如果未找到指定 notifier 的监听器，会记录警告但不会抛出错误
 *     - 必须调用以防止内存泄漏
 */
+ (void)removeNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key;


/**
 * @brief Reset command sequence counter
 * @chinese 重置命令序列计数器
 *
 * @discussion
 * EN: Resets the internal sequence ID counter to zero.
 *     The next command will start with sequence ID 1.
 *     
 *     Typical use case:
 *     - After device binding/pairing to start fresh sequence
 *     - When reconnecting to a device that expects sequence to start from 1
 *     - During development/testing to reset state
 *     
 *     This is a class-level operation affecting all subsequent commands.
 * CN: 将内部序列ID计数器重置为零。
 *     下一个命令将从序列ID 1开始。
 *     
 *     典型使用场景：
 *     - 设备绑定/配对后重新开始新序列
 *     - 重新连接到期望序列从1开始的设备
 *     - 开发/测试期间重置状态
 *     
 *     这是类级别操作，影响所有后续命令。
 *
 * @note
 * EN: This method is thread-safe and can be called from any thread.
 *     Sequence IDs are used to match responses with requests.
 *     Only reset when necessary, as it may cause confusion with pending requests.
 * CN: 此方法是线程安全的，可以从任何线程调用。
 *     序列ID用于将响应与请求匹配。
 *     仅在必要时重置，因为它可能会与待处理的请求产生混淆。
 */
+ (void)resetCommandSequence;

@end

NS_ASSUME_NONNULL_END
