//
//  TSUserInfoInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/13.
//

#import <Foundation/Foundation.h>
#import "TSUserInfoModel.h"
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief User information management interface
 * @chinese 用户信息管理接口
 *
 * @discussion
 * EN: This protocol defines all operations related to user information, including:
 *     1. Getting user information
 *     2. Setting user information
 *     3. Monitoring user information changes
 *     All methods are asynchronous and provide completion handlers.
 *
 * CN: 该协议定义了与用户信息相关的所有操作，包括：
 *     1. 获取用户信息
 *     2. 设置用户信息
 *     3. 监听用户信息变化
 *     所有方法都是异步的，并提供完成回调。
 */
@protocol TSUserInfoInterface <TSKitBaseInterface>

/**
 * @brief Get user information callback block type
 * @chinese 用户信息获取回调block类型
 *
 * @param userInfo 
 * EN: User information model, nil if retrieval fails
 * CN: 用户信息模型，获取失败时为nil
 *
 * @param error 
 * EN: Error information, nil if successful
 * CN: 错误信息，获取成功时为nil
 */
typedef void(^TSUserInfoResultBlock)(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error);

/**
 * @brief Get user information from device
 * @chinese 从设备获取用户信息
 *
 * @param completion 
 * EN: Callback block that returns the user information or error
 *     - userInfo: User information model, nil if retrieval fails
 *     - error: Error object if retrieval fails, nil if successful
 * CN: 返回用户信息或错误的回调block
 *     - userInfo: 用户信息模型，获取失败时为nil
 *     - error: 获取失败时的错误对象，成功时为nil
 *
 * @discussion
 * EN: Retrieves basic user information from the device including:
 *     - Height
 *     - Weight
 *     - Gender
 *     - Age
 *     The information is returned asynchronously through the completion block.
 *
 * CN: 从设备获取用户的基本信息，包括：
 *     - 身高
 *     - 体重
 *     - 性别
 *     - 年龄
 *     信息通过completion block异步返回。
 */
- (void)getUserInfoWithCompletion:(nullable TSUserInfoResultBlock)completion;

/**
 * @brief Set user information to device
 * @chinese 设置用户信息到设备
 *
 * @param userInfo 
 * EN: User information model to be set
 * CN: 要设置的用户信息模型
 *
 * @param completion 
 * EN: Callback block that returns the result
 *     - success: Whether the setting was successful
 *     - error: Error object if setting fails, nil if successful
 * CN: 返回设置结果的回调block
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误对象，成功时为nil
 *
 * @discussion
 * EN: Sets the user's basic information to the device.
 *     If any property in userInfo exceeds valid range, a parameter error will be returned.
 *     The operation result is returned asynchronously through the completion block.
 *
 * CN: 向设备设置用户的基本信息。
 *     如果userInfo中的任何属性超出有效范围，将返回参数错误。
 *     操作结果通过completion block异步返回。
 */
- (void)setUserInfo:(TSUserInfoModel *)userInfo
         completion:(TSCompletionBlock)completion;

/**
 * @brief Register for user information change notifications
 * @chinese 注册用户信息变化通知
 *
 * @param completion 
 * EN: Callback block triggered when user information changes
 *     - userInfo: New user information model
 *     - error: Error object if retrieval fails, nil if successful
 *     Pass nil to unregister the notification
 * CN: 用户信息变化时触发的回调block
 *     - userInfo: 新的用户信息模型
 *     - error: 获取新信息失败时的错误对象，成功时为nil
 *     传入nil可以取消注册通知
 *
 * @discussion
 * EN: This callback will be triggered when user information changes on the device.
 *     The new information is provided through the completion block.
 *     To stop receiving notifications, call this method with nil.
 *
 * CN: 当设备端的用户信息发生变化时，此回调会被触发。
 *     新的信息通过completion block提供。
 *     要停止接收通知，请使用nil调用此方法。
 */
- (void)registerUserInfoDidChangedBlock:(nullable TSUserInfoResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
