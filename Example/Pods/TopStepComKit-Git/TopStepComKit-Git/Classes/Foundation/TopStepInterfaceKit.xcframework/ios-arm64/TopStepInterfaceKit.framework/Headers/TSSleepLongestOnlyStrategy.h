//
//  TSSleepLongestOnlyStrategy.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/20.
//

#import "TSSleepBasicStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Longest only sleep statistics strategy (Rule 3)
 * @chinese 仅最长段睡眠统计策略（规则3）
 *
 * @discussion
 * [EN]: Strategy that uses longest continuous sleep segment only.
 * - No distinction between night and day
 * - Uses longest continuous sleep segment
 * - Other segments are ignored
 *
 * [CN]: 仅使用最长连续睡眠段的策略。
 * - 不区分夜间和日间
 * - 使用最长连续睡眠段
 * - 其他片段被忽略
 */
@interface TSSleepLongestOnlyStrategy : TSSleepBasicStrategy

@end

NS_ASSUME_NONNULL_END

