//
//  TSLockEditorSaveService.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Service that persists lock settings to device via SDK.
 * @chinese 通过 SDK 将锁配置持久化到设备的服务
 *
 * @discussion
 * [EN]: Single responsibility: build lock model, call peripheralLock API, report result. No UI.
 * [CN]: 单一职责：组装锁模型、调用外设锁接口、上报结果，不包含任何 UI。
 */
@interface TSLockEditorSaveService : NSObject

/**
 * @brief Save lock config (screen or game) to device; completion is called on main queue.
 * @chinese 将屏幕锁或游戏锁配置保存到设备，completion 在主线程回调
 *
 * @param isScreenLock YES = screen lock (password only), NO = game lock (password + start/end).
 * @param password Normalized 1–6 digit password (will be padded to 6 for SDK).
 * @param startMinutes Start time as minutes from 00:00 (used when isScreenLock = NO).
 * @param endMinutes End time as minutes from 00:00 (used when isScreenLock = NO).
 * @param completion success=YES means device updated or SDK unavailable (caller may still dismiss); success=NO with error.
 */
+ (void)saveWithScreenLock:(BOOL)isScreenLock
                  password:(NSString *)password
             startMinutes:(NSInteger)startMinutes
               endMinutes:(NSInteger)endMinutes
               completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Set screen lock on/off on device; completion is called on main queue.
 * @chinese 设置设备屏幕锁开/关，completion 在主线程回调
 *
 * @param enabled YES = turn on (use password), NO = turn off.
 * @param password When enabled=YES, 1–6 digit password (padded to 6); when enabled=NO, may be nil (sends 000000).
 * @param completion success=YES when device updated or SDK unavailable; success=NO with error.
 */
+ (void)setScreenLockEnabled:(BOOL)enabled
                    password:(nullable NSString *)password
                  completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

/**
 * @brief Set game lock on/off on device; completion is called on main queue.
 * @chinese 设置设备游戏锁开/关，completion 在主线程回调
 *
 * @param enabled YES = turn on, NO = turn off.
 * @param password When enabled=YES, 1–6 digit password; when enabled=NO, may be nil.
 * @param startMinutes Start minutes (used when enabled=YES).
 * @param endMinutes End minutes (used when enabled=YES).
 * @param completion success=YES when device updated or SDK unavailable; success=NO with error.
 */
+ (void)setGameLockEnabled:(BOOL)enabled
                  password:(nullable NSString *)password
             startMinutes:(NSInteger)startMinutes
               endMinutes:(NSInteger)endMinutes
               completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
