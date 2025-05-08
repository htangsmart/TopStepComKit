//
//  TSStressValueModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSStressValueModel : TSHealthValueModel

/**
 * @brief Stress level value
 * @chinese 压力水平值
 *
 * @discussion
 * [EN]: The stress level value measured on a scale, typically from 0 to 100.
 * [CN]: 通常在0到100的范围内测量的压力水平值。
 */
@property (nonatomic, assign) UInt8 stressValue;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic, assign) BOOL isUserInitiated;

@end

NS_ASSUME_NONNULL_END
