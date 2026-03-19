//
//  TSLockEditorVC.h
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

/** 保存回调：密码(1-6位)、开始分钟、结束分钟。取消时不调用。 */
typedef void(^TSLockEditorSaveBlock)(NSString *password, NSInteger startMinutes, NSInteger endMinutes);
/** 取消回调，用于弹窗关闭时刷新列表使 Switch 保持关闭 */
typedef void(^TSLockEditorCancelBlock)(void);

/**
 * @brief Lock editor view controller, presented when enabling a lock switch.
 * @chinese 锁编辑页，打开开关时弹出
 *
 * @discussion
 * [EN]: Screen lock shows password field only; game lock shows password + start/end time pickers.
 *       Cancel button on the left, save button on the right.
 * [CN]: 屏幕锁仅显示密码输入框；游戏锁显示密码 + 开始/结束时间选择器。左上取消，右上保存。
 */
@interface TSLockEditorVC : TSRootVC

/**
 * @brief YES for screen lock (password only), NO for game lock (password + time range).
 * @chinese YES 表示屏幕锁（仅密码），NO 表示游戏锁（密码 + 时间段）
 */
@property (nonatomic, assign) BOOL isScreenLock;

/**
 * @brief Navigation bar title; falls back to "lock.password" if empty.
 * @chinese 导航栏标题，为空时回退到 "lock.password"
 */
@property (nonatomic, copy) NSString *pageTitle;

/**
 * @brief Pre-filled password (1–6 digits); nil means empty input.
 * @chinese 预填密码（1–6 位数字），nil 表示空输入
 */
@property (nonatomic, copy, nullable) NSString *initialPassword;

/**
 * @brief Initial start time as minutes from 00:00 (game lock only).
 * @chinese 初始开始时间（距 0 点分钟数，仅游戏锁使用）
 */
@property (nonatomic, assign) NSInteger initialStartMinutes;

/**
 * @brief Initial end time as minutes from 00:00 (game lock only).
 * @chinese 初始结束时间（距 0 点分钟数，仅游戏锁使用）
 */
@property (nonatomic, assign) NSInteger initialEndMinutes;

/**
 * @brief Called after device save succeeds; not called on cancel.
 * @chinese 设备保存成功后回调，取消时不调用
 */
@property (nonatomic, copy, nullable) TSLockEditorSaveBlock onSave;

/**
 * @brief Called when user taps cancel; used to revert switch state in parent.
 * @chinese 用户点击取消时回调，用于父页面恢复开关状态
 */
@property (nonatomic, copy, nullable) TSLockEditorCancelBlock onCancel;

@end

NS_ASSUME_NONNULL_END
