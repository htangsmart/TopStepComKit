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
 * - Night sleep: 20:00-09:00
 * - Daytime naps: 09:00-20:00
 * - Valid nap criteria: 20min < duration <= 3h
 *
 * [CN]: 带小睡功能的设备策略。
 * - 传感器激活：24小时
 * - 夜间睡眠：20:00-09:00
 * - 日间小睡：09:00-20:00
 * - 有效小睡标准：20分钟 < 时长 <= 3小时
 */
@interface TSSleepWithNapStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END

