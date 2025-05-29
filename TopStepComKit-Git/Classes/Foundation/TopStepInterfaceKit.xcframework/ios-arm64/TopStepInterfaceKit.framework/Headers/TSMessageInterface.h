//
//  TSMessageInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseInterface.h"
#import "TSMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Message notification callback block
 * @chinese 消息通知回调block
 * @param notifications List of notifications (通知列表)
 * @param error Error information, nil when operation succeeds (错误信息，操作成功时为nil)
 */
typedef void(^TSMessageListBlock)(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error);


/**
 * @brief Message notification interface protocol
 * @chinese 消息通知接口协议
 * @discussion 
 * EN: Defines all operation interfaces related to device message notifications
 * CN: 定义了与设备消息通知相关的所有操作接口
 */
@protocol TSMessageInterface <TSKitBaseInterface>

/**
 * @brief Get the list of enabled messages
 * @chinese 获取消息启用列表
 *
 * @param completion 
 * EN: Completion callback that returns an array of messages models
 * CN: 完成回调，返回消息模型数组
 *
 * @discussion 
 * EN: This method is used to get the enable status list of all current messages
 * CN: 此方法用于获取当前所有消息的启用状态列表
 *
 * @note 
 * EN: If the retrieval fails, the messages parameter will be nil, and the error should be checked for the specific reason
 * CN: 如果获取失败，messages参数将为nil，应当检查error了解具体原因
 */
- (void)getMessageEnableList:(nullable TSMessageListBlock)completion;

/**
 * @brief Set the list of enabled messages
 * @chinese 设置消息启用列表
 *
 * @param messages 
 * EN: Array of messages models to be set
 * CN: 要设置的消息模型数组
 *
 * @param completion 
 * EN: Completion callback that returns operation success status and error information
 * CN: 完成回调，返回操作成功与否及错误信息
 * 
 * @discussion 
 * EN: This method is used to batch set the enable status of notifications
 * CN: 此方法用于批量设置通知的启用状态
 * 
 * @note 
 * EN: If messages is empty, a parameter error will be returned
 * CN: 如果messages为空，将返回参数错误
 */
- (void)setMessageEnableList:(NSArray<TSMessageModel *> *)messages
                 completion:(TSCompletionBlock)completion;


/**
 * @brief Get the list of supported messages
 * @chinese 获取设备支持的消息列表
 *
 * @param completion
 * EN: Completion callback that returns an array of supported message models
 * CN: 完成回调，返回设备支持的消息模型数组
 *
 * @discussion
 * EN: This method is used to get the list of all message types that the current device supports
 * CN: 此方法用于获取当前设备支持的所有消息类型列表
 *
 * @note
 * EN: If the retrieval fails, the messages parameter will be nil, and the error should be checked for the specific reason
 * （This method is not supported yet and will be implemented in a future version）
 * CN: 如果获取失败，messages参数将为nil，应当检查error了解具体原因（此方法暂不支持，将在未来版本中实现）
 */
- (void)supportMessageList:(nullable TSMessageListBlock)completion NS_UNAVAILABLE ; 

@end

NS_ASSUME_NONNULL_END
