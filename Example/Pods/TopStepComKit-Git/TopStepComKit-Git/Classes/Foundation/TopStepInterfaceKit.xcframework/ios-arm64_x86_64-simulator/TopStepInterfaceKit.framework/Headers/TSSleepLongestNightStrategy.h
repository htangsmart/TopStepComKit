//
//  TSSleepLongestNightStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSSleepBasicStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Longest night segment sleep statistics strategy (Rule 2)
 * @chinese 最长夜间段睡眠统计策略（规则2）
 *
 * @discussion
 * [EN]: Strategy that uses longest continuous night sleep segment.
 * - Night sleep: 20:00-08:00 (longest continuous segment)
 * - Valid naps: 20min < duration <= 3h
 * - All sleep counted in total (including naps)
 *
 * [CN]: 使用最长连续夜间睡眠段的策略。
 * - 夜间睡眠：20:00-08:00（最长连续段）
 * - 有效小睡：20分钟 < 时长 <= 3小时
 * - 总睡眠包含所有睡眠（含小睡）
 */
@interface TSSleepLongestNightStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END

