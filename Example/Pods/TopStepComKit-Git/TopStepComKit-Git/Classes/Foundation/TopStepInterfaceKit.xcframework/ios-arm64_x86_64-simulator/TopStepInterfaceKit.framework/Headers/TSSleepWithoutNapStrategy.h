//
//  TSSleepWithoutNapStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSSleepBasicStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sleep statistics strategy without nap support (Rule 0)
 * @chinese 不带小睡功能的睡眠统计策略（规则0）
 *
 * @discussion
 * [EN]: Strategy for devices without nap support.
 * - Sensor active: 20:00-12:00
 * - All sleep treated as night sleep
 * - No nap records
 *
 * [CN]: 不带小睡功能的设备策略。
 * - 传感器激活：20:00-12:00
 * - 所有睡眠视为夜间睡眠
 * - 不记录小睡
 */
@interface TSSleepWithoutNapStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END
