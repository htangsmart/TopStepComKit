//
//  TSSleepWithNapStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSSleepBasicStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep statistics strategy with nap support (Rule 1)
 * @chinese 带小睡功能的睡眠统计策略（规则1）
 *
 * @discussion
 * [EN]: Strategy for devices with nap support.
 * - Sensor active: 24 hours
 * - Night window: 20:00→09:00 (13h, 09:00 onwards treated as daytime nap)
 * - Daytime naps: 09:00-20:00
 * - Valid nap criteria: 20min < duration <= 3h
 *
 * [CN]: 带小睡功能的设备策略。
 * - 传感器激活：24小时
 * - 夜间窗口：20:00→09:00（13小时，09:00之后的睡眠归入日间小睡处理）
 * - 日间小睡：09:00-20:00
 * - 有效小睡标准：20分钟 < 时长 <= 3小时
 */
@interface TSSleepWithNapStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END

