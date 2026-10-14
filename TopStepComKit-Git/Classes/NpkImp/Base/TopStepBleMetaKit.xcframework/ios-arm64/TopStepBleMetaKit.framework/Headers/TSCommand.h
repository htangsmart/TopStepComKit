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
