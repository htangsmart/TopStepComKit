//
//  TSPeripheralLock.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2026/3/18.
//

#import "TSBusinessBase.h"
#import "TSCommandDefines.h"
#import "PbSettingParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 锁操作完成回调（返回 TSMetaLockModel）
 * @chinese 获取屏幕锁/游戏锁时的回调，返回协议层锁模型或错误
 */
typedef void(^TSMetaLockCompletionBlock)(TSMetaLockModel * _Nullable lockModel, NSError * _Nullable error);

@interface TSPeripheralLock : TSBusinessBase

/**
 * @brief 获取屏幕锁
 * @chinese 从设备获取当前屏幕锁配置（TSMetaLockModel，屏幕锁无 start/end 有效含义）
 */
+ (void)fetchScreenLockWithCompletion:(nullable TSMetaLockCompletionBlock)completion;

/**
 * @brief 设置屏幕锁
 * @chinese 向设备设置屏幕锁配置，payload 为 TSMetaLockModel 序列化数据
 */
+ (void)pushScreenLock:(TSMetaLockModel *)lockModel completion:(nullable TSMetaCompletionBlock)completion;

/**
 * @brief 获取游戏锁
 * @chinese 从设备获取当前游戏锁配置（TSMetaLockModel，含 start/end 时间段）
 */
+ (void)fetchGameLockWithCompletion:(nullable TSMetaLockCompletionBlock)completion;

/**
 * @brief 设置游戏锁
 * @chinese 向设备设置游戏锁配置，payload 为 TSMetaLockModel 序列化数据
 */
+ (void)pushGameLock:(TSMetaLockModel *)lockModel completion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
