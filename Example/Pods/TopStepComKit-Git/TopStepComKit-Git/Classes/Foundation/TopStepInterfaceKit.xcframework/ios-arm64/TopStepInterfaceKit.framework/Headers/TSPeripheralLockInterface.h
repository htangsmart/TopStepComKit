//
//  TSPeripheralLockInterface.h
//  Pods
//
//  Created by 磐石 on 2026/3/18.
//

#import "TSKitBaseInterface.h"
#import "TSScreenLockModel.h"
#import "TSGameLockModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callback block for querying screen lock info.
 * @chinese 查询屏幕锁信息的回调块
 *
 * @param model
 * EN: Screen lock model (enabled, password); nil if query fails.
 * CN: 屏幕锁模型（是否开启、密码）；查询失败时为 nil。
 *
 * @param error
 * EN: Error object if operation fails, nil if successful.
 * CN: 操作失败时的错误对象，成功时为 nil。
 */
typedef void(^TSScreenLockResultBlock)(TSScreenLockModel * _Nullable model, NSError * _Nullable error);

/**
 * @brief Callback block for querying game lock info.
 * @chinese 查询游戏锁信息的回调块
 *
 * @param model
 * EN: Game lock model (enabled, password, start/end time); nil if query fails.
 * CN: 游戏锁模型（是否开启、密码、开始/结束时间）；查询失败时为 nil。
 *
 * @param error
 * EN: Error object if operation fails, nil if successful.
 * CN: 操作失败时的错误对象，成功时为 nil。
 */
typedef void(^TSGameLockResultBlock)(TSGameLockModel * _Nullable model, NSError * _Nullable error);

/**
 * @brief Peripheral lock management interface protocol (screen lock & game lock).
 * @chinese 外设锁管理接口协议（屏幕锁与游戏锁）
 *
 * @discussion
 * [EN]: This protocol defines the interface for device screen lock and game lock:
 * - Screen lock: TSScreenLockModel (enabled, password only).
 * - Game lock: TSGameLockModel (enabled, password, start, end).
 * [CN]: 屏幕锁使用 TSScreenLockModel（仅是否开启、密码）；游戏锁使用 TSGameLockModel（含开始/结束时间）。
 */
@protocol TSPeripheralLockInterface <TSKitBaseInterface>

#pragma mark - Screen Lock 屏幕锁

/**
 * @brief Check whether the device supports screen lock.
 * @chinese 检查设备是否支持屏幕锁
 *
 * @return
 * EN: YES if screen lock is supported, NO otherwise.
 * CN: 支持屏幕锁返回 YES，否则返回 NO。
 */
- (BOOL)isSupportScreenLock;

/**
 * @brief Query current screen lock configuration from device.
 * @chinese 从设备查询当前屏幕锁配置
 *
 * @param completion
 * EN: Callback with screen lock model or error.
 * CN: 回调返回屏幕锁模型或错误。
 */
- (void)queryScreenLock:(TSScreenLockResultBlock)completion;

/**
 * @brief Set screen lock configuration on device.
 * @chinese 设置设备屏幕锁配置
 *
 * @param screenLock
 * EN: Screen lock model (enabled, password only). Password must be 6-digit numeric string.
 * CN: 屏幕锁模型（仅是否开启、密码），密码必须是 6 位数字类型字符串。
 *
 * @param completion
 * EN: Callback when set operation completes.
 * CN: 设置完成时的回调。
 */
- (void)setScreenLock:(TSScreenLockModel *)screenLock completion:(TSCompletionBlock)completion;

#pragma mark - Game Lock 游戏锁

/**
 * @brief Check whether the device supports game lock.
 * @chinese 检查设备是否支持游戏锁
 *
 * @return
 * EN: YES if game lock is supported, NO otherwise.
 * CN: 支持游戏锁返回 YES，否则返回 NO。
 */
- (BOOL)isSupportGameLock;

/**
 * @brief Query current game lock configuration from device.
 * @chinese 从设备查询当前游戏锁配置
 *
 * @param completion
 * EN: Callback with game lock model (enabled, password, start, end) or error.
 * CN: 回调返回游戏锁模型（是否开启、密码、开始/结束时间）或错误。
 */
- (void)queryGameLock:(TSGameLockResultBlock)completion;

/**
 * @brief Set game lock configuration on device.
 * @chinese 设置设备游戏锁配置
 *
 * @param gameLock
 * EN: Game lock model (enabled, password, start, end). Password must be 6-digit numeric string.
 * CN: 游戏锁模型（是否开启、密码、开始/结束时间），密码必须是 6 位数字类型字符串。
 *
 * @param completion
 * EN: Callback when set operation completes.
 * CN: 设置完成时的回调。
 */
- (void)setGameLock:(TSGameLockModel *)gameLock completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
