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

/**
 * @brief Register notification handler for single-response notifications
 * @chinese 注册单响应通知的处理器
 *
 * @param command
 *        EN: The command type to listen for
 *        CN: 要监听的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific notification
 *        CN: 标识特定通知的子命令键
 * @param completion
 *        EN: Completion callback invoked each time a matching notification is received.
 *             Called on main thread. Handler remains active until explicitly removed.
 *        CN: 每次接收到匹配的通知时调用的完成回调。
 *             在主线程调用。处理器保持活动状态直到显式移除。
 *
 * @discussion
 * EN: Registers a persistent listener for device notifications (unsolicited messages).
 *     Unlike command requests, notifications are initiated by the device, not the app.
 *     The completion callback will be invoked every time the device sends a matching notification.
 *     
 *     Common use cases:
 *     - Real-time sensor data updates (heart rate, steps, etc.)
 *     - Device status changes (battery, connection quality)
 *     - User interaction events (button press, gesture)
 *     
 *     The handler remains active until removed with removeObserverWithCommand:key:.
 * CN: 注册设备通知（非请求消息）的持久监听器。
 *     与命令请求不同，通知由设备发起，而非应用。
 *     每次设备发送匹配的通知时，都会调用完成回调。
 *     
 *     常见使用场景：
 *     - 实时传感器数据更新（心率、步数等）
 *     - 设备状态变化（电量、连接质量）
 *     - 用户交互事件（按键、手势）
 *     
 *     处理器保持活动直到使用 removeObserverWithCommand:key: 移除。
 *
 * @note
 * EN: Multiple registrations for the same command+key will override previous ones.
 *     Remember to call removeObserverWithCommand:key: when done to avoid memory leaks.
 *     Completion block is retained, so avoid capturing self strongly to prevent retain cycles.
 * CN: 对相同 command+key 的多次注册会覆盖之前的注册。
 *     使用完毕后记得调用 removeObserverWithCommand:key: 以避免内存泄漏。
 *     完成回调会被保持，避免强引用 self 以防止循环引用。
 */
+(void)registerNotifyCommand:(TSRequestCommand)command
                         key:(UInt8)key
                  completion:(TSRequestCompletionBlock)completion;

/**
 * @brief Register notification handler for multi-response (list) notifications
 * @chinese 注册多响应（列表）通知的处理器
 *
 * @param command
 *        EN: The command type to listen for
 *        CN: 要监听的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific notification
 *        CN: 标识特定通知的子命令键
 * @param completion
 *        EN: Completion callback invoked with array of responses when notification is received.
 *             Called on main thread. Handler remains active until explicitly removed.
 *        CN: 接收到通知时，以响应数组调用的完成回调。
 *             在主线程调用。处理器保持活动状态直到显式移除。
 *
 * @discussion
 * EN: Registers a persistent listener for device notifications that contain multiple data items.
 *     Similar to registerNotifyCommand but designed for notifications with fragmented/list data.
 *     The callback receives an array of NSData, each representing one complete data item.
 *     
 *     Common use cases:
 *     - Batch data synchronization notifications
 *     - Historical data push from device
 *     - Multi-item status updates
 *     
 *     The handler remains active until removed with removeObserverWithCommand:key:.
 * CN: 注册包含多个数据项的设备通知的持久监听器。
 *     类似于 registerNotifyCommand，但专为带分包/列表数据的通知设计。
 *     回调接收 NSData 数组，每个元素代表一个完整的数据项。
 *     
 *     常见使用场景：
 *     - 批量数据同步通知
 *     - 设备推送的历史数据
 *     - 多项状态更新
 *     
 *     处理器保持活动直到使用 removeObserverWithCommand:key: 移除。
 *
 * @note
 * EN: Multiple registrations for the same command+key will override previous ones.
 *     Remember to call removeObserverWithCommand:key: when done to avoid memory leaks.
 *     Completion block is retained, so avoid capturing self strongly to prevent retain cycles.
 * CN: 对相同 command+key 的多次注册会覆盖之前的注册。
 *     使用完毕后记得调用 removeObserverWithCommand:key: 以避免内存泄漏。
 *     完成回调会被保持，避免强引用 self 以防止循环引用。
 */
+ (void)registerListRequestNotifyCommand:(TSRequestCommand)command
                                     key:(UInt8)key
                              completion:(nonnull TSRequestListCompletionBlock)completion ;

/**
 * @brief Remove notification observer
 * @chinese 移除通知观察者
 *
 * @param command
 *        EN: The command type to stop listening for
 *        CN: 要停止监听的命令类型
 * @param key
 *        EN: Sub-command key identifying the specific notification handler to remove
 *        CN: 标识要移除的特定通知处理器的子命令键
 *
 * @discussion
 * EN: Removes a previously registered notification handler for the specified command+key.
 *     After calling this method, the completion callback will no longer be invoked
 *     when notifications are received for this command+key combination.
 *     
 *     Best practices:
 *     - Call this method when the observer is no longer needed
 *     - Always call before the observer object is deallocated
 *     - Safe to call even if no observer was registered
 * CN: 移除指定 command+key 之前注册的通知处理器。
 *     调用此方法后，当接收到此 command+key 组合的通知时，
 *     完成回调将不再被调用。
 *     
 *     最佳实践：
 *     - 当不再需要观察者时调用此方法
 *     - 总是在观察者对象被释放前调用
 *     - 即使没有注册观察者也可以安全调用
 *
 * @note
 * EN: If the specified command+key combination is not registered, this method does nothing.
 *     This is the cleanup counterpart to registerNotifyCommand and registerListRequestNotifyCommand.
 * CN: 如果指定的 command+key 组合未注册，此方法不执行任何操作。
 *     这是 registerNotifyCommand 和 registerListRequestNotifyCommand 的清理对应方法。
 */
+ (void)removeObserverWithCommand:(TSRequestCommand)command key:(UInt8)key;


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
