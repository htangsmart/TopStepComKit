//
//  TSBPValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBPValueItem : TSHealthValueItem

/**
 * @brief Systolic blood pressure value
 * @chinese 收缩压值
 * 
 * @discussion
 * [EN]: The systolic blood pressure value measured in mmHg.
 * [CN]: 以mmHg为单位测量的收缩压值。
 */
@property (nonatomic,assign) UInt8 systolic;

/**
 * @brief Diastolic blood pressure value
 * @chinese 舒张压值
 * 
 * @discussion
 * [EN]: The diastolic blood pressure value measured in mmHg.
 * [CN]: 以mmHg为单位测量的舒张压值。
 */
@property (nonatomic,assign) UInt8 diastolic;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 * 
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic,assign) BOOL isUserInitiated;

@end

NS_ASSUME_NONNULL_END
