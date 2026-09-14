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
 * - Night window: 20:00→08:00 (12h, narrower window to reduce daytime data mixing into night)
 * - Keep only the longest night segment with duration >= 3h; keep the earlier one on ties
 * - Valid naps: 20min <= duration < 3h
 * - Duration includes awake time within a segment
 * - Count the retained night segment and valid naps
 *
 * [CN]: 使用最长连续夜间睡眠段的策略。
 * - 夜间窗口：20:00→08:00（12小时，窗口收窄以减少日间数据混入夜间）
 * - 夜间仅保留最长且时长 >= 3小时的一段，等长时保留较早段
 * - 有效小睡：20分钟 <= 时长 < 3小时
 * - 时长包含段内清醒
 * - 统计保留的夜间段及有效小睡
 */
@interface TSSleepLongestNightStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END

