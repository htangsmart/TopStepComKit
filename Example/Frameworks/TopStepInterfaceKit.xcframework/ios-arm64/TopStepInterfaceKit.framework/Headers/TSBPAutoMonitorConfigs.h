//
//  TSBPAutoMonitorConfigs.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/14.
//

#import "TSAutoMonitorConfigs.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBPAutoMonitorConfigs : TSAutoMonitorConfigs


/**
 * @brief Is Warning Enabled
 * @chinese 是否开启警告
 *
 * @discussion
 * [EN]: Indicates if warnings are enabled for values exceeding max or below min thresholds.
 * [CN]: 表示是否启用警告，当值超过最大值或低于最小值时会报警。
 */
@property (nonatomic, assign) BOOL isWarningEnabled;



/**
 * @brief Warning Max Value
 * @chinese 警告最大值
 *
 * @discussion
 * [EN]: Maximum value for triggering a warning.
 * [CN]: 触发警告的最大值。
 */
@property (nonatomic, assign) CGFloat warningMaxSpbValue;

/**
 * @brief Warning Min Value
 * @chinese 警告最小值
 *
 * @discussion
 * [EN]: Minimum value for triggering a warning.
 * [CN]: 触发警告的最小值。
 */
@property (nonatomic, assign) CGFloat warningMinSpbValue;


/**
 * @brief Warning Max Value
 * @chinese 警告最大值
 *
 * @discussion
 * [EN]: Maximum value for triggering a warning.
 * [CN]: 触发警告的最大值。
 */
@property (nonatomic, assign) CGFloat warningMaxDpbValue;

/**
 * @brief Warning Min Value
 * @chinese dpb 警告最小值
 *
 * @discussion
 * [EN]: Minimum value for triggering a warning.
 * [CN]: 触发警告的最小值。
 */
@property (nonatomic, assign) CGFloat warningMinDpbValue;


@end

NS_ASSUME_NONNULL_END
