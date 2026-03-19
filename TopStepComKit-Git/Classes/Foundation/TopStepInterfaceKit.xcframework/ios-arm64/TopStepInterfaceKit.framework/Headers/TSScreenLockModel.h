//
//  TSScreenLockModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Model for screen lock (no time range).
 * @chinese 屏幕锁数据模型（无时间段）
 *
 * @discussion
 * [EN]: Screen lock only has isEnabled and password; no start/end. For game lock with time range, use TSGameLockModel.
 * [CN]: 屏幕锁仅有是否开启与密码，无开始/结束时间；带时间段的游戏锁请使用 TSGameLockModel。
 */
@interface TSScreenLockModel : NSObject

/**
 * @brief Whether the lock is enabled.
 * @chinese 是否开启锁
 *
 * @discussion
 * [EN]: YES = lock is on, NO = lock is off.
 * [CN]: YES 表示开启，NO 表示关闭。
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * @brief Lock password string (6 digits only).
 * @chinese 锁密码字符串（必须是 6 位数字）
 *
 * @discussion
 * [EN]: Must be a 6-digit numeric string (e.g. "123456"). Only characters '0'-'9', length exactly 6.
 * [CN]: 必须是 6 位数字类型字符串（例如 "123456"），仅含字符 '0'-'9'，长度恰好为 6。
 */
@property (nonatomic, copy, nullable) NSString *password;

@end

NS_ASSUME_NONNULL_END
