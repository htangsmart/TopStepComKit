//
//  TSWearDetectionInterface.h
//  TopStepBudsKit
//
//  Created by 磐石 on 2026/4/30.
//

#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device wear state
 * @chinese 设备佩戴状态
 */
typedef NS_ENUM(NSUInteger, TSWearState) {
    /// 未佩戴    （Not worn）
    TSWearStateNone  = 0,
    /// 仅左侧佩戴 （Only left side is worn）
    TSWearStateLeft  = 1,
    /// 仅右侧佩戴 （Only right side is worn）
    TSWearStateRight = 2,
    /// 双侧佩戴   （Both sides are worn）
    TSWearStateBoth  = 3,
};

/**
 * @brief Wear detection enabled state callback
 * @chinese 佩戴检测开关状态回调
 *
 * @param enabled
 * EN: Current wear detection enabled state, NO if retrieval fails
 * CN: 当前佩戴检测开关状态，获取失败时为 NO
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSWearDetectionEnabledResultBlock)(BOOL enabled, NSError * _Nullable error);

/**
 * @brief Wear state callback
 * @chinese 佩戴状态回调
 *
 * @param state
 * EN: Current wear state, TSWearStateNone if retrieval fails
 * CN: 当前佩戴状态，获取失败时为 TSWearStateNone
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSWearStateResultBlock)(TSWearState state, NSError * _Nullable error);

/**
 * @brief Device wear detection management interface
 * @chinese 设备佩戴检测管理接口
 *
 * @discussion
 * EN: This interface defines operations related to device wear detection, including:
 *     1. Check whether the wear detection enable/disable setting is supported
 *     2. Set wear detection enabled state
 *     3. Get current wear detection enabled state
 *     4. Register a listener for wear detection enabled state changes
 *     5. Get current wear state
 *     6. Register a listener for wear state changes
 * CN: 该接口定义了与设备佩戴检测相关的操作，包括：
 *     1. 查询是否支持佩戴检测开关设置
 *     2. 设置佩戴检测开关状态
 *     3. 获取当前佩戴检测开关状态
 *     4. 注册佩戴检测开关状态变化监听
 *     5. 获取当前佩戴状态
 *     6. 注册佩戴状态变化监听
 */
@protocol TSWearDetectionInterface <TSKitBaseInterface>

/**
 * @brief Whether the wear detection enable/disable setting is supported
 * @chinese 是否支持佩戴检测开关设置
 *
 * @return
 * EN: YES if the device allows the App to toggle wear detection on/off, NO otherwise
 * CN: 设备允许 App 开关佩戴检测时返回 YES，否则返回 NO
 *
 * @discussion
 * EN: This method is orthogonal to the inherited isSupport. isSupport indicates whether
 *     the device can report wear state at all; this method indicates whether the
 *     setWearDetectionEnabled: toggle is exposed. A device may always have wear
 *     detection on with the state readable but the toggle not adjustable.
 * CN: 本方法与继承自 TSKitBaseInterface 的 isSupport 互相独立。isSupport 表示设备
 *     是否具备佩戴检测能力（能否读到状态）；本方法表示 setWearDetectionEnabled:
 *     开关是否可调。部分设备佩戴检测常开不可关，但状态仍可读。
 */
- (BOOL)isSupportEnabledSetting;

/**
 * @brief Set wear detection enabled state
 * @chinese 设置佩戴检测开关状态
 *
 * @param enabled
 * EN: YES to enable wear detection, NO to disable wear detection
 * CN: 传 YES 表示开启佩戴检测，NO 表示关闭佩戴检测
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 */
- (void)setWearDetectionEnabled:(BOOL)enabled
                     completion:(TSCompletionBlock)completion;

/**
 * @brief Get wear detection enabled state
 * @chinese 获取佩戴检测开关状态
 *
 * @param completion
 * EN: Completion callback
 *     - enabled: Current wear detection enabled state, NO if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - enabled: 当前佩戴检测开关状态，获取失败时为 NO
 *     - error: 获取失败时的错误信息，成功时为 nil
 */
- (void)getWearDetectionEnabled:(nullable TSWearDetectionEnabledResultBlock)completion;

/**
 * @brief Register wear detection enabled state changed notify
 * @chinese 注册佩戴检测开关状态变化监听
 *
 * @param completion
 * EN: completion invoked when device wear detection enabled state changes
 * CN: 设备佩戴检测开关状态变化时回调
 *
 * @discussion
 * EN: After registration, the callback will be invoked whenever the device reports
 *     a wear detection enabled state change.
 * CN: 注册后，当设备上报佩戴检测开关状态变化时会触发回调。
 */
- (void)registerWearDetectionEnabledDidChanged:(nullable TSWearDetectionEnabledResultBlock)completion;

/**
 * @brief Get current wear state
 * @chinese 获取当前佩戴状态
 *
 * @param completion
 * EN: Completion callback
 *     - state: Current wear state, TSWearStateNone if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - state: 当前佩戴状态，获取失败时为 TSWearStateNone
 *     - error: 获取失败时的错误信息，成功时为 nil
 */
- (void)getCurrentWearState:(nullable TSWearStateResultBlock)completion;

/**
 * @brief Register wear state changed notify
 * @chinese 注册佩戴状态变化监听
 *
 * @param completion
 * EN: completion invoked when device wear state changes
 * CN: 设备佩戴状态变化时回调
 *
 * @discussion
 * EN: After registration, the callback will be invoked whenever the device reports a wear state change.
 * CN: 注册后，当设备上报佩戴状态变化时会触发回调。
 */
- (void)registerWearStateDidChanged:(nullable TSWearStateResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
