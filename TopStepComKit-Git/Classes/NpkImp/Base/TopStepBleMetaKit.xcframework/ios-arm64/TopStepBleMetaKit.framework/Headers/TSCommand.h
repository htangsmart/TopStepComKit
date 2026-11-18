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

@class TSBleWriteContext;

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
 */
+(void)executeResponseCommand:(TSRequestCommand)command
                          key:(UInt8)key
                      payload:(NSData * _Nullable)payload
                   completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute a response command with preparation immediately before transmission
 * @chinese 执行响应命令，并在首次发送前完成准备工作
 *
 * @param command
 * EN: Main command code.
 * CN: 主命令类型。
 * @param key
 * EN: Sub-command key.
 * CN: 子命令键。
 * @param payload
 * EN: Optional request payload.
 * CN: 可选的请求负载。
 * @param requestWillStartBlock
 * EN: Callback invoked once after sequence assignment and before transmission.
 * CN: 序列号分配完成后、请求发送前执行一次的回调。
 * @param completion
 * EN: Command completion callback.
 * CN: 命令完成回调。
 */
+ (void)executeResponseCommand:(TSRequestCommand)command
                           key:(UInt8)key
                       payload:(NSData * _Nullable)payload
                     willStart:(nullable TSRequestWillStartBlock)requestWillStartBlock
                    completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute a transactional response command with cancellation handling
 * @chinese 执行支持取消处理的事务型响应命令
 *
 * @param command
 * EN: Main command code.
 * CN: 主命令类型。
 * @param key
 * EN: Sub-command key.
 * CN: 子命令键。
 * @param payload
 * EN: Optional request payload.
 * CN: 可选的请求负载。
 * @param requestWillStartBlock
 * EN: Callback invoked once after sequence assignment and before transmission.
 * CN: 序列号分配完成后、请求发送前执行一次的回调。
 * @param requestCancellationBlock
 * EN: Opt-in callback invoked if the manager cancels this request.
 * CN: 请求被管理器取消时调用的可选回调。
 * @param completion
 * EN: Command completion callback.
 * CN: 命令完成回调。
 */
+ (void)executeResponseCommand:(TSRequestCommand)command
                           key:(UInt8)key
                       payload:(NSData * _Nullable)payload
                     willStart:(nullable TSRequestWillStartBlock)requestWillStartBlock
                  cancellation:(nullable TSRequestCancellationBlock)requestCancellationBlock
                    completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute command without waiting for response
 * @chinese 执行命令不等待响应
 */
+ (void)executeNoResponseCommand:(TSRequestCommand)command
                             key:(UInt8)key
                         payload:(NSData *_Nullable)payload
                      completion:(nullable TSRequestCompletionBlock)completion ;


/**
 * @brief Execute command with single payload and custom callbacks
 * @chinese 执行带单个负载和自定义回调的命令
 */
+(void)executeCommand:(TSRequestCommand)command
                  key:(UInt8)key
              payload:(NSData *)payload
      waitForResponse:(BOOL)waitForResponse
      clearsDuplicate:(BOOL)clearsDuplicate
               option:(TSRequestOption *_Nullable)option
             progress:(nullable void(^)(CGFloat progress))progress
         stateChanged:(nullable void(^)(TSRequestStatus status))stateChanged
           completion:(nullable TSRequestCompletionBlock)completion;

/**
 * @brief Execute command with multiple payloads (simplified version)
 * @chinese 执行带多个负载的命令（简化版本）
 */
+(void)executeRespondListCommand:(TSRequestCommand)command
                      key:(UInt8)key
              allPayloads:(NSArray<NSData *> * _Nullable)allPayloads
               completion:(nullable TSRequestListCompletionBlock)completion;

/**
 * @brief Execute an ordinary request and retain every independent response message
 * @chinese 使用普通请求格式发送，并保留全部独立响应消息
 * @param command EN: Main command. CN: 主命令。
 * @param key EN: Command key. CN: 子命令。
 * @param payload EN: Optional request bytes. CN: 可选请求数据。
 * @param completion EN: Ordered complete messages, including empty messages. CN: 有序完整消息，保留空消息。
 */
+ (void)executeListResponseCommand:(TSRequestCommand)command
                               key:(UInt8)key
                           payload:(nullable NSData *)payload
                        completion:(nullable TSRequestListCompletionBlock)completion;

/**
 * @brief Execute a list query bound to the original physical connection
 * @chinese 在原物理连接执行列表查询
 * @param command EN: Main command. CN: 主命令。
 * @param key EN: Command key. CN: 子命令。
 * @param payload EN: Optional request bytes. CN: 可选请求数据。
 * @param context EN: Original connection, or nil to use normal admission. CN: 原连接上下文，nil 使用普通准入。
 * @param completion EN: Complete response or error. CN: 完整响应或错误。
 */
+ (void)executeListResponseCommand:(TSRequestCommand)command
                               key:(UInt8)key
                           payload:(nullable NSData *)payload
                           context:(nullable TSBleWriteContext *)context
                        completion:(nullable TSRequestListCompletionBlock)completion;

/**
 * @brief Write complete list messages and wait for the final packet response
 * @chinese 写入完整列表消息并等待末包应答
 * @param command EN: Main command. CN: 主命令。
 * @param key EN: Command key. CN: 子命令。
 * @param allPayloads EN: Preencoded messages; an empty list is one empty message. CN: 预编码消息，清空操作为一个空消息。
 * @param completion EN: Final response after all writes complete. CN: 全部写入完成后的最终响应。
 * @discussion EN: Each message uses a distinct sequence. Automatic request retry is disabled.
 * CN: 每条消息使用独立序号，不自动重试整批写入。
 */
+ (void)executeListWriteCommand:(TSRequestCommand)command
                            key:(UInt8)key
                    allPayloads:(NSArray<NSData *> *)allPayloads
                     completion:(nullable TSRequestListCompletionBlock)completion;

/**
 * @brief Write list messages on the original physical connection
 * @chinese 在原物理连接写入列表消息
 * @param command EN: Main command. CN: 主命令。
 * @param key EN: Command key. CN: 子命令。
 * @param allPayloads EN: Complete preencoded messages. CN: 完整预编码消息。
 * @param context EN: Original connection, or nil to use normal admission. CN: 原连接上下文，nil 使用普通准入。
 * @param completion EN: Final response or error; a timeout leaves device state uncertain. CN: 最终响应或错误，超时后设备状态需回读。
 */
+ (void)executeListWriteCommand:(TSRequestCommand)command
                            key:(UInt8)key
                    allPayloads:(NSArray<NSData *> *)allPayloads
                        context:(nullable TSBleWriteContext *)context
                     completion:(nullable TSRequestListCompletionBlock)completion;

/**
 * @brief Reassemble the bytes of one object from ordered response fragments
 * @chinese 将有序响应片段重组为单个对象字节
 * @param payloads EN: At least one fragment; zero-byte fragments are valid. CN: 至少一个片段，允许零字节片段。
 * @param error EN: Receives a format error for a missing or invalid collection. CN: 缺失或非法集合时返回格式错误。
 * @return EN: Complete object bytes, or nil on error. CN: 完整对象数据，失败返回 nil。
 */
+ (nullable NSData *)objectResponseDataFromPayloads:(nullable NSArray<NSData *> *)payloads
                                             error:(NSError * _Nullable * _Nullable)error;

+ (void)executeNoRespondListCommand:(TSRequestCommand)command
                                key:(UInt8)key
                        allPayloads:(NSArray<NSData *> *_Nullable)allPayloads
                         completion:(nullable TSRequestListCompletionBlock)completion ;

/**
 * @brief Execute command with multiple payloads and custom callbacks
 * @chinese 执行带多个负载和自定义回调的命令
 */
+(void)executeListCommand:(TSRequestCommand)command
                      key:(UInt8)key
              allPayloads:(NSArray<NSData *> * _Nullable)allPayloads
          waitForResponse:(BOOL)waitForResponse
          clearsDuplicate:(BOOL)clearsDuplicate
                   option:(TSRequestOption *_Nullable)option
                 progress:(nullable void(^)(CGFloat progress))progress
             stateChanged:(nullable void(^)(TSRequestStatus status))stateChanged
               completion:(nullable TSRequestListCompletionBlock)completion;


#pragma mark -- Notifier

/**
 * @brief Add notification listener for object packet mode (KVO-style API)
 * @chinese 添加对象分包模式的通知监听器（KVO风格API）
 */
+(void)addRequestNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key completion:(nonnull TSRequestCompletionBlock)completion;

/**
 * @brief Add notification listener for list packet mode (KVO-style API)
 * @chinese 添加列表分包模式的通知监听器（KVO风格API）
 */
+(void)addListRequestNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key completion:(nonnull TSRequestListCompletionBlock)completion;

/**
 * @brief Add a sequence-scoped object notification listener
 * @chinese 添加限定序列号的对象通知监听器
 *
 * @param notifier EN: Logical listener owner. CN: 监听器逻辑持有者。
 * @param sequenceId
 * EN: Expected transaction sequence ID; zero keeps wildcard behavior.
 * CN: 期望的事务序列号；零表示保留通配行为。
 * @param command EN: Main command code. CN: 主命令类型。
 * @param key EN: Sub-command key. CN: 子命令键。
 * @param completion EN: Notification callback. CN: 通知回调。
 * @return
 * EN: Unique listener identifier for scoped listeners, otherwise nil.
 * CN: 限定序列监听器的唯一标识，否则返回 nil。
 */
+ (nullable NSString *)addRequestNotifier:(id)notifier
                               sequenceId:(UInt16)sequenceId
                                  command:(TSRequestCommand)command
                                      key:(UInt8)key
                               completion:(nonnull TSRequestCompletionBlock)completion;

/**
 * @brief Add a sequence-scoped list notification listener
 * @chinese 添加限定序列号的列表通知监听器
 *
 * @param notifier EN: Logical listener owner. CN: 监听器逻辑持有者。
 * @param sequenceId
 * EN: Expected transaction sequence ID; zero keeps wildcard behavior.
 * CN: 期望的事务序列号；零表示保留通配行为。
 * @param command EN: Main command code. CN: 主命令类型。
 * @param key EN: Sub-command key. CN: 子命令键。
 * @param completion EN: Notification callback. CN: 通知回调。
 * @return
 * EN: Unique listener identifier for scoped listeners, otherwise nil.
 * CN: 限定序列监听器的唯一标识，否则返回 nil。
 */
+ (nullable NSString *)addListRequestNotifier:(id)notifier
                                   sequenceId:(UInt16)sequenceId
                                      command:(TSRequestCommand)command
                                          key:(UInt8)key
                                   completion:(nonnull TSRequestListCompletionBlock)completion;

/**
 * @brief Remove notification listener for specified notifier (KVO-style API)
 * @chinese 移除指定 notifier 的通知监听器（KVO风格API）
 *
 */
+ (void)removeNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key;

/**
 * @brief Remove a notification listener by its unique identifier
 * @chinese 根据唯一标识移除通知监听器
 *
 * @param identifier
 * EN: Identifier returned when adding a scoped listener.
 * CN: 添加限定序列监听器时返回的唯一标识。
 */
+ (void)removeNotifierWithIdentifier:(NSString *)identifier;


/**
 * @brief Reset command sequence counter
 * @chinese 重置命令序列计数器
 */
+ (void)resetCommandSequence;

@end

NS_ASSUME_NONNULL_END
