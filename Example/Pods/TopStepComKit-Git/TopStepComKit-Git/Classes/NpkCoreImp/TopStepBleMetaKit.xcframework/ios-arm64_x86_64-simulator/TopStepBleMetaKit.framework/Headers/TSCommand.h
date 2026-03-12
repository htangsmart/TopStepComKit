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
 * @brief Remove notification listener for specified notifier (KVO-style API)
 * @chinese 移除指定 notifier 的通知监听器（KVO风格API）
 *
 */
+ (void)removeNotifier:(id)notifier command:(TSRequestCommand)command key:(UInt8)key;


/**
 * @brief Reset command sequence counter
 * @chinese 重置命令序列计数器
 */
+ (void)resetCommandSequence;

@end

NS_ASSUME_NONNULL_END
