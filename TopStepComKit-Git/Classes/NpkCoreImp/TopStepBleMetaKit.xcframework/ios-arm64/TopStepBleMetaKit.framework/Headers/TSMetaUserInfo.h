//
//  TSMetaUserInfo.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "TSBusinessBase.h"
#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief User information management class
 * @chinese 用户信息管理类
 */
@interface TSMetaUserInfo : TSBusinessBase

/**
 * @brief Set user information
 * @chinese 设置用户信息
 *
 * @param userInfo 
 * EN: User information object containing gender, age, height and weight
 * CN: 包含性别、年龄、身高和体重的用户信息对象
 *
 * @param completion 
 * EN: Completion callback with success status and error information
 * CN: 完成回调，包含成功状态和错误信息
 */
+ (void)setUserInfo:(TSMetaUserModel *)userInfo completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get user information
 * @chinese 获取用户信息
 *
 * @param completion 
 * EN: Completion callback with user information and error
 * CN: 完成回调，包含用户信息和错误信息
 *
 * @discussion
 * EN: Returns the current user information stored on the device.
 * CN: 返回设备上存储的当前用户信息。
 */
+ (void)getUserInfo:(void(^)(TSMetaUserModel * _Nullable userInfo, NSError * _Nullable error))completion;

/**
 * @brief Register user information change notification
 * @chinese 注册用户信息变更通知
 *
 * @param completion 
 * EN: Callback invoked when user info changes; returns latest user info and error if any
 * CN: 当用户信息变化时触发回调；返回最新用户信息及错误
 *
 * @discussion
 * EN: Listen for user information changes in real time.
 * CN: 实时监听用户信息的变化。
 */
+ (void)registerUserInfoDidChanged:(void(^)(TSMetaUserModel * _Nullable userInfo, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
