//
//  TSHsdParentalModeModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Parental mode model (basic)
 * @chinese 家长模式模型（基础版）
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature. Fixed switches plus a game time window.
 *      Read with TSHuashengdaInterface.fetchParentalMode: and written with setParentalMode:completion:,
 *      available when isSupportParentalMode is YES (FitCloud firmware withParentalControl).
 *      NPK devices expose the advanced TSHsdParentalControlModel instead; see isSupportParentalControl.
 * [CN]: 华盛达定制能力。固定开关 + 游戏时段。
 *      通过 TSHuashengdaInterface.fetchParentalMode: 读取，setParentalMode:completion: 设置，
 *      isSupportParentalMode 为 YES 时可用（FitCloud 固件 withParentalControl）。
 *      NPK 设备使用进阶版 TSHsdParentalControlModel，见 isSupportParentalControl。
 */
@interface TSHsdParentalModeModel : TSKitBaseModel <NSCopying>

/**
 * @brief Whether parental mode is enabled
 * @chinese 家长模式总开关
 *
 * @discussion
 * [EN]: When NO, the other switches in this model are ignored by the device.
 * [CN]: 为 NO 时设备忽略本模型中的其他开关。
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Whether time setting on the watch is allowed
 * @chinese 是否允许在手表上设置时间
 */
@property (nonatomic, assign, getter=isTimeSettingEnabled) BOOL timeSettingEnabled;

/**
 * @brief Whether entering settings on the watch is allowed
 * @chinese 是否允许在手表上进入设置
 */
@property (nonatomic, assign, getter=isEnterSettingEnabled) BOOL enterSettingEnabled;

/**
 * @brief Whether alarm setting on the watch is allowed
 * @chinese 是否允许在手表上设置闹钟
 */
@property (nonatomic, assign, getter=isAlarmSettingEnabled) BOOL alarmSettingEnabled;

/**
 * @brief Whether the game time window is enforced
 * @chinese 是否限制游戏时段
 *
 * @discussion
 * [EN]: When YES, games are only allowed between gameStartMinute and gameEndMinute.
 * [CN]: 为 YES 时仅允许在 gameStartMinute 到 gameEndMinute 之间玩游戏。
 */
@property (nonatomic, assign, getter=isGameDurationEnabled) BOOL gameDurationEnabled;

/**
 * @brief Start of the game time window
 * @chinese 游戏时段开始时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 480 = 08:00).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 480 表示 08:00）。
 */
@property (nonatomic, assign) NSInteger gameStartMinute;

/**
 * @brief End of the game time window
 * @chinese 游戏时段结束时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 1200 = 20:00).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 1200 表示 20:00）。
 */
@property (nonatomic, assign) NSInteger gameEndMinute;

@end

NS_ASSUME_NONNULL_END
