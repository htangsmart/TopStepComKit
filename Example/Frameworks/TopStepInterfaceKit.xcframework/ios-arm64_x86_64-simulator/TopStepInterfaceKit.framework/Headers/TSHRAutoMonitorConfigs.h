//
//  TSAutoMonitorConfigs.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/24.
//

#import "TSAutoMonitorConfigs.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSHRAutoMonitorConfigs : TSAutoMonitorConfigs

/**
 * @brief Indicates whether resting heart rate warning is enabled.
 * @chinese 是否开启静息心率警告
 *
 * @discussion
 * [EN]: Indicates whether resting heart rate warning is enabled.
 * [CN]: 表示是否启用静息心率警告。
 */
@property (nonatomic, assign) BOOL restHRWarnEnabled;

/**
 * @brief Maximum value for triggering a warning when resting heart rate exceeds this value.
 * @chinese 静息心率警告最大值
 *
 * @discussion
 * [EN]: Maximum value for triggering a warning when resting heart rate exceeds this value.
 * [CN]: 当静息心率超过此值时触发警告的最大值。
 *
 * @note
 * [EN]: Valid range is 60-100.
 * [CN]: 有效范围为60-100。
 */
@property (nonatomic, assign) CGFloat restHeartRateMax;

/**
 * @brief Minimum value for triggering a warning when resting heart rate falls below this value.
 * @chinese 静息心率警告最小值
 *
 * @discussion
 * [EN]: Minimum value for triggering a warning when resting heart rate falls below this value.
 * [CN]: 当静息心率低于此值时触发警告的最小值。
 *
 * @note
 * [EN]: Valid range is 40-60.
 * [CN]: 有效范围为40-60。
 */
@property (nonatomic, assign) CGFloat restHeartRateMin;

/**
 * @brief Indicates whether exercise heart rate warning is enabled.
 * @chinese 是否开启运动心率报警
 *
 * @discussion
 * [EN]: Indicates whether exercise heart rate warning is enabled.
 * [CN]: 表示是否启用运动心率报警。
 */
@property (nonatomic, assign) BOOL exerciseHRWarnEnabled;

/**
 * @brief Maximum value for triggering a warning when exercise heart rate exceeds this value.
 * @chinese 运动心率警告最大值
 *
 * @discussion
 * [EN]: Maximum value for triggering a warning when exercise heart rate exceeds this value.
 * [CN]: 当运动心率超过此值时触发警告的最大值。
 *
 * @note
 * [EN]: Valid range is 100-220.
 * [CN]: 有效范围为100-220。
 */
@property (nonatomic, assign) CGFloat exerciseHeartRateMax;

/**
 * @brief Minimum value for triggering a warning when exercise heart rate falls below this value.
 * @chinese 运动心率警告最小值
 *
 * @discussion
 * [EN]: Minimum value for triggering a warning when exercise heart rate falls below this value.
 * [CN]: 当运动心率低于此值时触发警告的最小值。
 *
 * @note
 * [EN]: Valid range is 40-100.
 * [CN]: 有效范围为40-100。
 */
@property (nonatomic, assign) CGFloat exerciseHeartRateMin;

@end

NS_ASSUME_NONNULL_END
