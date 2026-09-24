//
//  TSHsdParentalControlModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/24.
//

#import "TSKitBaseModel.h"
#import "TSAlarmClockModel.h"
#import "TSHsdDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Parental-control period
 * @chinese 家长模式时段
 *
 * @discussion
 * [EN]: One time window of a TSHsdParentalControlItemModel. Maps to _HsdParentalControlPeriod.
 * [CN]: TSHsdParentalControlItemModel 的一个时间窗口，对应 _HsdParentalControlPeriod。
 */
@interface TSHsdParentalControlPeriodModel : NSObject <NSCopying>

/**
 * @brief Start of the period
 * @chinese 时段开始时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439] (e.g. 480 = 08:00).
 *      startMinute == endMinute means the whole day (prefer 0 / 0).
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]（如 480 表示 08:00）。
 *      startMinute == endMinute 表示全天（建议填 0 / 0）。
 */
@property (nonatomic, assign) NSInteger startMinute;

/**
 * @brief End of the period
 * @chinese 时段结束时间
 *
 * @discussion
 * [EN]: Minutes since midnight, valid range [0, 1439]. startMinute > endMinute means the period crosses midnight.
 * [CN]: 距零点的分钟数，取值范围 [0, 1439]。startMinute > endMinute 表示跨天。
 */
@property (nonatomic, assign) NSInteger endMinute;

/**
 * @brief Weekly repeat options
 * @chinese 星期重复选项
 *
 * @discussion
 * [EN]: Bitmask reusing TSAlarmRepeat (bit0 = Monday … bit6 = Sunday); for a period that crosses midnight
 *      the bit refers to the start day. TSAlarmRepeatNone means one-off.
 * [CN]: 复用 TSAlarmRepeat 位掩码（bit0 = 周一 … bit6 = 周日）；跨天时段以起始日为准。TSAlarmRepeatNone 表示仅一次。
 */
@property (nonatomic, assign) TSAlarmRepeat repeatOptions;

@end

/**
 * @brief Parental-control item
 * @chinese 家长模式功能项
 *
 * @discussion
 * [EN]: One controlled watch action (see TSHsdParentalControlFunction) with its periods. Maps to _HsdParentalControlItem.
 * [CN]: 一个受控的手表动作（见 TSHsdParentalControlFunction）及其时段列表，对应 _HsdParentalControlItem。
 */
@interface TSHsdParentalControlItemModel : TSKitBaseModel <NSCopying>

/**
 * @brief Controlled action
 * @chinese 受控动作
 *
 * @discussion
 * [EN]: See TSHsdParentalControlFunction. Must be unique within TSHsdParentalControlModel.items.
 * [CN]: 见 TSHsdParentalControlFunction。在 TSHsdParentalControlModel.items 中不可重复。
 */
@property (nonatomic, assign) TSHsdParentalControlFunction function;

/**
 * @brief Whether this item is enabled
 * @chinese 本项开关
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Behaviour inside the periods
 * @chinese 时段内的行为
 *
 * @discussion
 * [EN]: See TSHsdParentalControlMode; values outside the enum fail validation.
 * [CN]: 见 TSHsdParentalControlMode；枚举之外的取值校验失败。
 */
@property (nonatomic, assign) TSHsdParentalControlMode mode;

/**
 * @brief Periods the item applies to
 * @chinese 生效时段列表
 *
 * @discussion
 * [EN]: At most TSHuashengdaInterface.parentalControlMaxPeriodCount (10 on current firmware); more fail validation.
 *      Empty is allowed.
 * [CN]: 最多 TSHuashengdaInterface.parentalControlMaxPeriodCount 个（当前固件为 10），超出时校验失败；允许为空。
 */
@property (nonatomic, copy) NSArray<TSHsdParentalControlPeriodModel *> *periods;

@end

/**
 * @brief Parental control model (advanced parental mode)
 * @chinese 家长模式模型（进阶版：按功能动作 + 时段控制）
 *
 * @discussion
 * [EN]: Huashengda customer-specific feature (NPK ability bit 29). Maps to _HsdParentalControl.
 *      Read with TSHuashengdaInterface.fetchParentalControl: and written with setParentalControl:completion:,
 *      available when isSupportParentalControl is YES. The whole item list is written on every set and the
 *      device replaces its configuration; the SDK splits items into protocol fragments of 7 transparently.
 * [CN]: 华盛达定制能力（NPK 能力位 bit29），对应 _HsdParentalControl。
 *      通过 TSHuashengdaInterface.fetchParentalControl: 读取，setParentalControl:completion: 设置，
 *      isSupportParentalControl 为 YES 时可用。每次设置下发完整功能列表、设备整体替换；SDK 按每包 7 条自动分包。
 */
@interface TSHsdParentalControlModel : TSKitBaseModel <NSCopying>

/**
 * @brief Whether parental mode is enabled
 * @chinese 家长模式总开关
 *
 * @discussion
 * [EN]: When NO, the device ignores every item.
 * [CN]: 为 NO 时设备忽略所有功能项。
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 * @brief Controlled action items
 * @chinese 功能项列表
 *
 * @discussion
 * [EN]: function must be unique across items; each item is validated with its own doesModelHasError.
 * [CN]: 各项 function 不可重复；每个功能项按各自的 doesModelHasError 校验。
 */
@property (nonatomic, copy) NSArray<TSHsdParentalControlItemModel *> *items;

@end

NS_ASSUME_NONNULL_END
