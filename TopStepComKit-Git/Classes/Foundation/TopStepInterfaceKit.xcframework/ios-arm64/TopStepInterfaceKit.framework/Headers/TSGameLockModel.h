//
//  TSGameLockModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Model for game lock (with time range).
 * @chinese 游戏锁数据模型（含时间段）
 *
 * @discussion
 * [EN]: Game lock has isEnabled, password, start and end (minute offset from 00:00). Corresponds to _LockObj with full fields.
 * [CN]: 游戏锁包含是否开启、密码、开始/结束时间（相对 0 点的分钟偏移），对应完整的 _LockObj。
 */
@interface TSGameLockModel : NSObject

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

/**
 * @brief Start time as minute offset from 00:00.
 * @chinese 开始时间（距离 0 点的分钟偏移数）
 *
 * @discussion
 * [EN]: e.g. 0 = 00:00, 60 = 01:00, 540 = 09:00.
 * [CN]: 例如 0 表示 00:00，60 表示 01:00，540 表示 09:00。
 */
@property (nonatomic, assign) NSInteger start;

/**
 * @brief End time as minute offset from 00:00.
 * @chinese 结束时间（距离 0 点的分钟偏移数）
 *
 * @discussion
 * [EN]: e.g. 0 = 00:00, 60 = 01:00, 1439 = 23:59.
 * [CN]: 例如 0 表示 00:00，60 表示 01:00，1439 表示 23:59。
 */
@property (nonatomic, assign) NSInteger end;

@end

NS_ASSUME_NONNULL_END
